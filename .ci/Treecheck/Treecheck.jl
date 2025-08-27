module Treecheck

import JSON3
import LibGit2
import TOML
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

            # For each tree, make sure the tree exists
            @testset for (k, v) in pairs(versions_dict)
                treehash = v["git-tree-sha1"]
                tree_libgit2 = LibGit2.GitTree(gitrepo_libgit2, LibGit2.GitHash(treehash))
                @test tree_libgit2 isa LibGit2.GitTree
            end

        end
    end;
end

end # module
