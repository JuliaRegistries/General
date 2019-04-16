
using Test, Pkg
using Base: UUID
using Pkg.Types: VersionRange
using Pkg.Operations: load_package_data_raw
import Pkg.TOML

@testset "(Registry|Package|Versions|Deps|Compat).toml" begin
    reg = TOML.parsefile("Registry.toml")
    reguuids = Set{UUID}(UUID(x) for x in keys(reg["packages"]))
    stdlibuuids = Set{UUID}(x for x in keys(Pkg.Types.gather_stdlib_uuids()))
    alluuids = reguuids ∪ stdlibuuids

    # Test that each entry in Registry.toml has a corresponding Package.toml
    # at the expected path with the correct uuid and name
    for (uuid, data) in reg["packages"]
        # Package.toml testing
        pkg = TOML.parsefile(abspath(data["path"], "Package.toml"))
        @test UUID(uuid) == UUID(pkg["uuid"])
        @test data["name"] == pkg["name"]
        @test haskey(pkg, "repo")

        # Versions.toml testing
        vers = TOML.parsefile(abspath(data["path"], "Versions.toml"))
        for (v, data) in vers
            @test VersionNumber(v) isa VersionNumber
            @test haskey(data, "git-tree-sha1")
        end

        # Deps.toml testing
        depsfile = abspath(data["path"], "Deps.toml")
        if isfile(depsfile)
            deps = TOML.parsefile(depsfile)
            # Require all deps to exist in the General registry or be a stdlib
            depuuids = Set{UUID}(UUID(x) for (_, d) in deps for (_, x) in d)
            @test depuuids ⊆ alluuids
            # Test that the way Pkg loads this data works
            @test Pkg.Operations.load_package_data_raw(UUID, depsfile) isa
                Dict{Pkg.Types.VersionRange,Dict{String,UUID}}
        end

        # Compat.toml testing
        compatfile = abspath(data["path"], "Compat.toml")
        if isfile(compatfile)
            compat = TOML.parsefile(compatfile)
            # Test that all names with compat is a dependency
            compatnames = Set{String}(x for (_, d) in compat for (x, _) in d)
            if !(isempty(compatnames) || (length(compatnames)== 1 && "julia" in compatnames))
                depnames = Set{String}(x for (_, d) in TOML.parsefile(depsfile) for (x, _) in d)
                push!(depnames, "julia") # All packages has an implicit dependency on julia
                @assert compatnames ⊆ depnames
            end
            # Test that the way Pkg loads this data works
            @test Pkg.Operations.load_package_data_raw(Pkg.Types.VersionSpec, compatfile) isa
                Dict{Pkg.Types.VersionRange,Dict{String,Pkg.Types.VersionSpec}}
        end
    end
end
