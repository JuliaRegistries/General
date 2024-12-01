using TOML

function get_repo(path::String)
    return TOML.parsefile(joinpath(path, "Package.toml"))["repo"]
end

function get_packages_info()
    reg = TOML.parsefile("Registry.toml")
    return [(; name = dict["name"], path = dict["path"]) for (uuid, dict) in reg["packages"]]
end

function create_redirect_page(; name, path)
    repo = get_repo(path)
    open(joinpath("packages", name * ".html"), "w") do io
        write(io, """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Redirecting...</title>
            <meta http-equiv="refresh" content="0; url=$repo">
        </head>
        <body>
            <p>If you are not redirected automatically, follow this <a href="$repo">link</a>.</p>
        </body>
        </html>
        """)
    end
end

function main()
    if !isdir("packages")
        mkdir("packages")
    end
    packages_info = get_packages_info()
    for (; name, path) in packages_info
        create_redirect_page(; name, path)
    end
end

main()