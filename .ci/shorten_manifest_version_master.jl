import Pkg
import TOML

function is_manifest_filename(file::AbstractString)
    is_manifest = any(startswith.(Ref(file), first.(splitext.(Base.manifest_names))))
    is_toml = endswith(lowercase(file), ".toml")
    return is_manifest && is_toml
end

function _shorten_manifest_version_master(; manifest_filename::AbstractString)
    julia_version_key = "julia_version"
    manifest_dict = TOML.parsefile(manifest_filename)
    old_julia_version = get(manifest_dict, julia_version_key, nothing)
    if old_julia_version !== nothing
        m = match(r"^([0-9]*?)\.([0-9]*?)\.([0-9]*?)\-DEV\.([0-9]*?)$", old_julia_version)
        if m !== nothing
            major = m[1]
            minor = m[2]
            patch = m[3]
            new_julia_version = "$(major).$(minor).$(patch)-DEV"
            manifest_dict[julia_version_key] = new_julia_version
            @info "Fixing manifest file at $(manifest_filename)" old_julia_version new_julia_version
            Pkg.Types.write_manifest(manifest_dict, manifest_filename)
        end
    end
    return nothing
end

function shorten_manifest_version_master(dir::AbstractString)
    for (root, dirs, files) in walkdir(abspath(dir))
        for file in files
            if is_manifest_filename(file)
                manifest_filename = joinpath(root, file)
                @info "Checking manifest file at $(manifest_filename)"
                _shorten_manifest_version_master(; manifest_filename)
            end
        end
    end
    return nothing
end
