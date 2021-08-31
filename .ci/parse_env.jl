# Used in `feed.yml`
function parse_env(env=ENV; verbose=true)
    pr_url = string("https://github.com/", env["GITHUB_REPOSITORY"], "/pull/", env["PR_NUMBER"])
    body = env["PR_BODY"]

    name = r"(?:^|\n|\r\n)(?:\-|\*) Registering package: (\w*?)(?:$|\n|\r\n)"
    repo = r"(?:^|\n|\r\n)(?:\-|\*) Repository: (.*?)(?:$|\n|\r\n)"
    description = r"(?:^|\n|\r\n)(?:\-|\*) Description: (.*?)(?:$|\n|\r\n)"
    release_notes = r"(?:^|\n|\r\n)(?:\-|\*) Release notes:(?:\s*?)(?:$|\n|\r\n)<!-- BEGIN RELEASE NOTES -->((?s).*)<!-- END RELEASE NOTES -->"

    text = sprint() do io
        match_name = match(name, body)
        has_name = match_name !== nothing
        match_description = match(description, body)
        has_description = match_description !== nothing

        match_release = match(release_notes, body)
        has_release = match_release !== nothing

        match_repo = match(repo, body)
        has_repo = match_repo !== nothing

        if has_description && has_name
            println(io, match_name[1], ": ", strip(match_description[1]))
        elseif has_description
            println(io, strip(match_description[1]))
        end
        
        if has_release
            # Leave a gap if we've just printed something
            has_description && println(io)
            println(io, "Release notes:")
            println(io, strip(match_release[1]))
        end

        # Leave a gap if we've just printed something
        if has_description || has_release
            println(io)
        end
        println(io, "Registration: ", pr_url)
        if has_repo
            println(io, "Repository:   ", strip(match_repo[1]))
        end
        # Nothing? Just print the `pr_url`
        if match_description === match_release === match_repo === nothing
            println(io, pr_url)
        end
    end

    verbose && @info "" pr_url text
    return (; text, pr_url)
end

env = Dict("GITHUB_REPOSITORY" => "JuliaRegistries/General",
           "PR_NUMBER" => "43765",
           "PR_BODY" =>
            """
            - Registering package: Fastnet
            - Repository: https://github.com/bridgewalker/Fastnet.jl
            - Version: v0.1.0
            - Description: This is a test description.
            - Commit: 976c26fc6165d5501fb765048fd18d2e30181a94
            - Git reference: v0.1.0
            - Release notes:
            <!-- BEGIN RELEASE NOTES -->
            > Fastnet is a Julia package that allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics
            <!-- END RELEASE NOTES -->
            """)

using Test
p = parse_env(env; verbose=false)

@testset "parse_env" begin
    @test p.text == "Fastnet: This is a test description.\n\nRelease notes:\n> Fastnet is a Julia package that allows very fast (linear-time) simulation of discrete-state dynamical processes on networks, such as commonly studied models of epidemics\n\nRegistration: https://github.com/JuliaRegistries/General/pull/43765\nRepository:   https://github.com/bridgewalker/Fastnet.jl\n"
    @test p.pr_url == "https://github.com/JuliaRegistries/General/pull/43765"
end
