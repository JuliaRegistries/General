using TOML

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

function create_redirect_page(; name, path)
    repo = get_repo(path)
    host = get_host(repo)
    should_redirect = known_host(host)
    meta_redirection = should_redirect ? """<meta http-equiv="refresh" content="0; url=$repo">""" : ""
    message = if should_redirect
        """Click this link if you are not redirected automatically to the repository page of the registered Julia package <b>$name</b>: <a href="$repo">$repo</a>"""
    else
        """Click this link to go to the repository page of the registered Julia package <b>$name</b>: <a href="$repo">$repo</a>"""
    end

    open(joinpath("packages", name * ".html"), "w") do io
        write(io, """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Redirecting...</title>
            $meta_redirection
        </head>
        <body>
            <p>$message</p>
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