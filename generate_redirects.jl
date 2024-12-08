import TOML

function get_repo(path::String)
    return TOML.parsefile(joinpath(path, "Package.toml"))["repo"]
end

function get_packages_info()
    reg = TOML.parsefile("Registry.toml")
    return [(; name = dict["name"], path = dict["path"]) for (uuid, dict) in reg["packages"]]
end

function get_host(repo)
    m = match(r"^https://([a-z\.]+)", repo)
    if m === nothing
        error("Repo url $(repr(repo)) did not match expected format")
    end
    return m[1]
end

function known_host(host)
    host in ("github.com", "gitlab.com", "codeberg.org")
end

function package_path(args...)
    joinpath("webroot", "packages", "redirect_to_repo", args...)
end

function create_redirect_page(; name, path)
    repo = get_repo(path)
    host = get_host(repo)
    should_redirect = known_host(host)
    meta_redirection = should_redirect ? """<meta http-equiv="refresh" content="0; url=$repo">""" : ""
    message = if should_redirect
        """Redirecting to $name...<br><br>Click the link below if you are not redirected automatically to the registered repository for the Julia package $name<br><br><a href="$repo" rel="nofollow">$repo</a>"""
    else
        """Click the link below to go to the registered repository for the Julia package $name<br><br><a href="$repo" rel="nofollow">$repo</a>"""
    end

    open(package_path(name * ".html"), "w") do io
        write(io, """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Redirecting to $name...</title>
            $meta_redirection
            <style>
                body {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    margin: 0;
                    font-family: Arial, sans-serif;
                    background-color: #f9f9f9;
                }
                .centered-div {
                    border: 2px solid #1E88E5;
                    border-radius: 10px;
                    padding: 20px;
                    margin: 20px;
                    text-align: center;
                    color: #333;
                    max-width: 30em;
                    word-wrap: break-word;
                }
                .centered-div a {
                    color: #1E88E5;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <div class="centered-div">
                <p>$message</p>
            </div>
        </body>
        </html>
        """)
    end
end

function main()
    mkpath(package_path())
    packages_info = get_packages_info()
    for (; name, path) in packages_info
        create_redirect_page(; name, path)
    end
end

main()
