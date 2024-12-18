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

# only for these hosts will we redirect automatically, for all others the user needs to click the link
function known_host(host)
    host in ("github.com", "gitlab.com", "codeberg.org")
end

function package_path(args...)
    # results in URLs like juliaregistries.github.io/General/packages/redirect_to_repo/SomePackage
    joinpath("webroot", "packages", "redirect_to_repo", args...)
end

function style_block(backgroundcolor, color)
    """
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
            border: 3px solid $color;
            background-color: $backgroundcolor;
            border-radius: 10px;
            padding: 20px;
            margin: 20px;
            text-align: center;
            color: #333;
            max-width: 30em;
            word-wrap: break-word;
        }
        .centered-div a {
            color: $color;
            font-weight: bold;
        }
    </style>
    """
end

function create_redirect_page(; name, path)
    repo = get_repo(path)
    host = get_host(repo)
    jlname = name * ".jl"
    should_redirect = known_host(host)
    meta_redirection = should_redirect ? """<meta http-equiv="refresh" content="0; url=$repo">""" : ""
    message = if should_redirect
        """Redirecting to $jlname...<br><br>Click the link below if you are not redirected automatically to the registered repository for the Julia package $jlname<br><br><a href="$repo" rel="nofollow">$repo</a>"""
    else
        """Click the link below to go to the registered repository for the Julia package $jlname<br><br><a href="$repo" rel="nofollow">$repo</a>"""
    end
    title = if should_redirect
        "Redirecting to $jlname..."
    else
        "Confirm redirect to $jlname"
    end

    open(package_path(name * ".html"), "w") do io
        write(io, """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>$title</title>
            $meta_redirection
            $(style_block("#f8e9ff", "#9558B2"))
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

function create_404_page()
    open(joinpath("webroot", "404.html"), "w") do io
        write(io, """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Page not found</title>
            $(style_block("#ffcbc8", "#CB3C33"))
        </head>
        <body>
            <div class="centered-div">
                <p>No page exists here.<br><br>Redirection pages for registered Julia packages follow the format packages/redirect_to_repo/SomePackage.</p>
            </div>

            <script>
            // Get the current URL path
            const urlPath = window.location.pathname;

            // Define the regex pattern to match the URL structure
            const pattern = /\\/packages\\/redirect_to_repo\\/([^\\/]+?)(\\.html)?\$/;

            // Check if the URL matches the pattern
            const match = urlPath.match(pattern);

            if (match) {
                const packageName = match[1]; // Extract the package name
                const messageElement = document.querySelector(".centered-div p");
                // Update the paragraph text
                messageElement.innerHTML = `\
                    There is no package \${packageName}.jl registered in the Julia General Registry.\
                    <br><br>\
                    Would you like to try searching <a href="https://github.com/search?q=\${packageName}.jl&type=repositories">GitHub</a>, \
                    <a href="https://about.gitlab.com/search/?searchText=\${packageName}.jl">GitLab</a>, \
                    <a href="https://www.google.com/search?q=\${packageName}.jl">Google</a>, \
                    or <a href="https://duckduckgo.com/?q=\${packageName}.jl">DuckDuckGo</a> for it?`;
            }
        </script>
        </body>
        </html>
        """)
    end
    return
end

function main()
    cd(joinpath(@__DIR__, "..")) do
        mkpath(package_path())
        packages_info = get_packages_info()
        for (; name, path) in packages_info
            create_redirect_page(; name, path)
        end
        create_404_page()
    end
end

main()
