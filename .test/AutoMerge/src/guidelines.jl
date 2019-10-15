function meets_compat_for_all_deps(working_directory::AbstractString, pkg, version)
    deps = Pkg.TOML.parsefile(joinpath(working_directory, uppercase(pkg[1:1]), pkg, "Deps.toml"))
    compat = Pkg.TOML.parsefile(joinpath(working_directory, uppercase(pkg[1:1]), pkg, "Compat.toml"))
    # First, we construct a Dict in which the keys are the package's
    # dependencies, and the value is always false.
    dep_has_compat_with_upper_bound = Dict{String, Bool}()
    @debug("We always have julia as a dependency")
    dep_has_compat_with_upper_bound["julia"] = false
    for version_range in keys(deps)
        if version in Pkg.Types.VersionRange(version_range)
            for name in keys(deps[version_range])
                if !is_julia_stdlib(name)
                    @debug("Found a new dependency: $(name)")
                    dep_has_compat_with_upper_bound[name] = false
                end
            end
        end
    end
    # Now, we go through all the compat entries. If a dependency has a compat
    # entry with an upper bound, we change the corresponding value in the Dict
    # to true.
    for version_range in keys(compat)
        if version in Pkg.Types.VersionRange(version_range)
            for compat_entry in compat[version_range]
                name = compat_entry[1]
                value = compat_entry[2]
                if value isa Vector
                    if !isempty(value)
                        value_ranges = Pkg.Types.VersionRange.(value)
                        each_range_has_upper_bound = _has_upper_bound.(value_ranges)
                        if all(each_range_has_upper_bound)
                            @debug("Dependency \"$(name)\" has compat entries that all have upper bounds")
                            dep_has_compat_with_upper_bound[name] = true
                        end
                    end
                else
                    value_range = Pkg.Types.VersionRange(value)
                    if _has_upper_bound(value_range)
                        @debug("Dependency \"$(name)\" has a compat entry with an upper bound")
                        dep_has_compat_with_upper_bound[name] = true
                    end
                end
            end
        end
    end
    meets_this_guideline = all(values(dep_has_compat_with_upper_bound))
    if meets_this_guideline
        return true, ""
    else
        bad_dependencies = Vector{String}()
        for name in keys(dep_has_compat_with_upper_bound)
            if !(dep_has_compat_with_upper_bound[name])
                @error("Dependency \"$(name)\" does not have a compat entry that has an upper bound")
                push!(bad_dependencies, name)
            end
        end
        message = string("The following dependencies do not have a compat entry that has an upper bound: ", join(bad_dependencies, ", "))
        return false, message
    end
end

function meets_patch_release_does_not_narrow_julia_compat(pkg::String,
                                                          new_version::VersionNumber;
                                                          registry_head::String,
                                                          registry_master::String)
    old_version = latest_version(pkg, registry_master)
    julia_compats_for_old_version = julia_compat(pkg, old_version, registry_master)
    julia_compats_for_new_version = julia_compat(pkg, new_version, registry_head)
    if Set(julia_compats_for_old_version) == Set(julia_compats_for_new_version)
        return true, ""
    end
    meets_this_guideline = range_did_not_narrow(julia_compats_for_old_version, julia_compats_for_new_version)
    if meets_this_guideline
        return true, ""
    else
        return false, "A patch release is not allowed to narrow the supported range of Julia versions"
    end
end

function meets_name_length(pkg)
    meets_this_guideline = length(pkg) >= 5
    if meets_this_guideline
        return true, ""
    else
        return false, "Name is not at least five characters long"
    end
end

function meets_normal_capitalization(pkg)
    meets_this_guideline = occursin(r"^[A-Z]\w*[a-z][0-9]?$", pkg)
    if meets_this_guideline
        return true, ""
    else
        return false, "Name does not meet all of the following: starts with a capital letter, ASCII alphanumerics only, ends in lowercase"
    end
end

function meets_repo_url_requirement(pkg::String; registry_head::String)
    url = Pkg.TOML.parsefile(joinpath(registry_head, pkg[1:1], pkg, "Package.toml"))["repo"]
    meets_this_guideline = url_has_correct_ending(url, pkg)
    if meets_this_guideline
        return true, ""
    else
        return false, "Repo URL does not end with /name.jl.git, where name is the package name"
    end
end

function meets_sequential_version_number(old_version::VersionNumber, new_version::VersionNumber)
    if new_version > old_version
        diff = difference(old_version, new_version)
        @debug("Difference between versions: ", old_version, new_version, diff)
        if diff == v"1.0.0"
            return true, "", :major
        elseif diff == v"0.1.0"
            return true, "", :minor
        elseif diff == v"0.0.1"
            return true, "", :patch
        else
            return false, "Does not meet sequential version number guideline", :invalid
        end
    else
        return false, "Does not meet sequential version number guideline", :invalid
    end
end

function meets_sequential_version_number(pkg::String,
                                         new_version::VersionNumber;
                                         registry_head::String,
                                         registry_master::String)
    old_version = latest_version(pkg, registry_master)
    return meets_sequential_version_number(old_version, new_version)
end


function meets_standard_initial_version_number(version)
    meets_this_guideline = version == v"0.0.1" || version == v"0.1.0" || version == v"1.0.0"
    if meets_this_guideline
        return true, ""
    else
        return false, "Version number is not 0.0.1, 0.1.0, or 1.0.0"
    end
end

function meets_version_can_be_loaded(working_directory::String,
                                     pkg::String,
                                     version::VersionNumber)
    tmp_dir = mktempdir()
    atexit(() -> rm(tmp_dir; force = true, recursive = true))
    code = """
        import Pkg;
        Pkg.Registry.add(Pkg.RegistrySpec(path=\"$(working_directory)\"));
        @info("Attempting to install package...");
        Pkg.add(Pkg.PackageSpec(name=\"$(pkg)\", version=\"$(string(version))\"));
        @info("Successfully installed package");
        @info("Attempting to import package");
        import $(pkg);
        @info("Successfully imported package");
        """
    cmd = Cmd(`$(Base.julia_cmd()) -e $(code)`;
              env = Dict("PATH" => ENV["PATH"],
                         "JULIA_DEPOT_PATH" => tmp_dir))
    @info("Attempting to install the package")
    cmd_ran_successfully = success(pipeline(cmd, stdout=stdout, stderr=stderr))
    rm(tmp_dir; force = true, recursive = true)
    if cmd_ran_successfully
        @info("Successfully installed the package")
        return true, ""
    else
        @error("Was not able to successfully install the package")
        return false, "I was not able to install and import the package. See the Travis logs for details."
    end
end

url_has_correct_ending(url, pkg) = endswith(url, "/$(pkg).jl.git")
