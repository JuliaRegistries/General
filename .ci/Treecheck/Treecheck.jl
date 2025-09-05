module Treecheck

import CodecZlib
import JSON3
import LibGit2
import TOML
import Tar
import Test

# Bring some names into scope, just for convenience:
using Test: @testset, @test

struct Package
    name::String
    uuid_str::String
end

struct RegistryToml
    root::String
    dict::AbstractDict
end

function RegistryToml(root::AbstractString, path::AbstractString)
    dict = TOML.parsefile(path)
    return RegistryToml(root, dict)
end

function RegistryToml()
    root_dotci_treecheckdir = @__DIR__
    root_dotci = dirname(root_dotci_treecheckdir)
    root = dirname(root_dotci)
    registry_toml_path = joinpath(root, "Registry.toml")
    return RegistryToml(root, registry_toml_path)
end

function gha_set_output(name::AbstractString, value::AbstractString)
    open(ENV["GITHUB_OUTPUT"], "a") do io
        line = "$name=$value"
        println(io, line)
    end
    return nothing
end

generate_ci_matrix() = generate_ci_matrix(RegistryToml())
function generate_ci_matrix(registrytoml::RegistryToml)
    str = ENV["ALL_CHANGED_FILES"]

    println("# BEGIN ALL_CHANGED_FILES")
    println(str)
    println("# END ALL_CHANGED_FILES")

    elements = split(str) # Split on whitespace

    package_list = Package[]

    for element in elements
        for (k, v) in registrytoml.dict["packages"]
            package_uuid_str = k
            package_name = v["name"]
            package_relpath = v["path"]
            package = Package(package_name, package_uuid_str)
            if element == package_relpath*"/Package.toml"
                @info "" package element package_relpath
                push!(package_list, package)
            end
        end
    end

    num_changed_packages = length(package_list)

    if num_changed_packages > 10
        # This step prevents us from launching too many CI jobs (e.g. a hundred jobs)

        msg = "Too many changed packages: $(num_changed_packages)"
        error(msg)
    end

    dict = Dict()
    dict["include"] = []

    for package in package_list
        matrix_entry = Dict(
            "PACKAGE_NAME" => package.name,
            "PACKAGE_UUID" => package.uuid_str,
        )
        push!(dict["include"], matrix_entry)
    end

    # Necessary to avoid erroring on empty matrix:
    if isempty(dict["include"])
        json_str = ""
    else
        json_str = JSON3.write(dict)
    end

    println(Base.stderr, json_str)

    gha_set_output("matrix", json_str)

    return json_str
end

function does_the_archive_roundtrip(repo_dir::AbstractString, expected_treehash::AbstractString)
    result = mktempdir() do tmpdir
        tgz_file = joinpath(tmpdir, "archive.tar.gz")
        cmd = `git -C "$(repo_dir)" archive --format=tar.gz -o "$(tgz_file)" "$(expected_treehash)"`
        proc = run(cmd)
        @test success(proc)

        # Verify that the .tar.gz file has the correct treehash
        return verify_archive_tree_hash(tgz_file, expected_treehash)
    end

    return result
end

# Verify the git-tree-sha1 hash of a compressed archive.
#
# I copied (and slightly modified) this function from JuliaLang/Pkg.jl (license: MIT).
# https://github.com/JuliaLang/Pkg.jl/blob/482399a51bc8bea0c58cb8722fd7ddf7637aff77/src/PlatformEngines.jl#L687-L703
#
# We're vendoring this function because IIUC, it's not part of Pkg.jl's public API, and
# I don't want this script to randomly break.
#
# Note: The function `Tar.tree_hash()` is part of Tar.jl's public API.
# See: https://github.com/JuliaIO/Tar.jl/blob/9dd8ed1b5f8503804de49da9272150dcc18ca7c7/README.md?plain=1#L17-L32
function verify_archive_tree_hash(tar_gz::AbstractString, expected_hash::String)
    # This can fail because unlike sha256 verification of the downloaded
    # tarball, tree hash verification requires that the file can i) be
    # decompressed and ii) is a proper archive.
    calc_hash = try
        open(CodecZlib.GzipDecompressorStream, tar_gz) do stream
            Tar.tree_hash(stream)
        end
    catch err
        @warn "unable to decompress and read archive" exception = err
        return false
    end
    if calc_hash != expected_hash
        @warn "tarball content does not match expected git-tree-sha1"
        return false
    end
    return true
end

check(package_uuid_str::AbstractString) = check(RegistryToml(), package_uuid_str)
function check(registrytoml::RegistryToml, package_uuid_str::AbstractString)
    package_name = registrytoml.dict["packages"][package_uuid_str]["name"]
    package_relpath = registrytoml.dict["packages"][package_uuid_str]["path"]
    package_abspath = joinpath(registrytoml.root, package_relpath)
    package_toml = joinpath(package_abspath, "Package.toml")
    versions_toml = joinpath(package_abspath, "Versions.toml")
    package_dict = TOML.parsefile(package_toml)
    versions_dict = TOML.parsefile(versions_toml)
    package_git_repo_url = package_dict["repo"]
    @testset "Treecheck for package: $(package_name)" begin
        @test !isempty(versions_dict)
        mktempdir() do tmpdir
            run(`git clone "$(package_git_repo_url)" "$(tmpdir)"`)
            gitrepo_libgit2 = LibGit2.GitRepo(tmpdir)

            # First, run an explicit `git gc`, to guard against a tree hash being at risk of removal.
            run(`git -C "$(tmpdir)" gc`)

            # For each tree, make sure the tree exists
            @testset "Make sure trees exist" begin
                for (k, v) in pairs(versions_dict)
                    treehash = v["git-tree-sha1"]
                    tree_libgit2 = LibGit2.GitTree(gitrepo_libgit2, LibGit2.GitHash(treehash))
                    @test tree_libgit2 isa LibGit2.GitTree
                end
            end

            # For each tree, make sure that `git archive` produces a tarball with the correct contents
            @testset "Make sure git archive produces good tarballs" begin
                for (k, v) in pairs(versions_dict)
                    treehash = v["git-tree-sha1"]
                    @test does_the_archive_roundtrip(tmpdir, treehash)
                end
            end
        end
    end;
end

end # module
