module RememberToUpdateRegistryCI

using GitCommand
using GitHub
using Pkg

# Some of the code in this file is taken from:
# CompatHelper.jl (https://github.com/bcbi/CompatHelper.jl)

struct AlwaysAssertionError <: Exception
end

@inline function always_assert(cond::Bool)::Nothing
    cond || throw(AlwaysAssertionError())
    return nothing
end

function get_all_pull_requests(repo::GitHub.Repo,
                               state::String;
                               auth::GitHub.Authorization,
                               per_page::Integer = 100,
                               page_limit::Integer = 100)
    all_pull_requests = Vector{GitHub.PullRequest}(undef, 0)
    myparams = Dict("state" => state,
                    "per_page" => per_page,
                    "page" => 1)
    prs, page_data = GitHub.pull_requests(repo;
                                          auth=auth,
                                          params = myparams,
                                          page_limit = page_limit)
    append!(all_pull_requests, prs)
    while haskey(page_data, "next")
        prs, page_data = GitHub.pull_requests(repo;
                                              auth=auth,
                                              page_limit = page_limit,
                                              start_page = page_data["next"])
        append!(all_pull_requests, prs)
    end
    unique!(all_pull_requests)
    return all_pull_requests
end

_repos_are_the_same(::GitHub.Repo, ::Nothing) = false
_repos_are_the_same(::Nothing, ::GitHub.Repo) = false
_repos_are_the_same(::Nothing, ::Nothing) = false
function _repos_are_the_same(x::GitHub.Repo, y::GitHub.Repo)
    if x.name == y.name && x.full_name == y.full_name &&
                           x.owner == y.owner &&
                           x.id == y.id &&
                           x.url == y.url &&
                           x.html_url == y.html_url &&
                           x.fork == y.fork
       return true
    else
        return false
    end
end

function exclude_pull_requests_from_forks(repo::GitHub.Repo, pr_list::Vector{GitHub.PullRequest})
    non_forked_pull_requests = Vector{GitHub.PullRequest}(undef, 0)
    for pr in pr_list
        always_assert(_repos_are_the_same(repo, pr.base.repo))
        if _repos_are_the_same(repo, pr.head.repo)
            push!(non_forked_pull_requests, pr)
        end
    end
    return non_forked_pull_requests
end

function only_my_pull_requests(pr_list::Vector{GitHub.PullRequest}; my_username::String)
    _my_username_lowercase = lowercase(strip(my_username))
    n = length(pr_list)
    pr_is_mine = BitVector(undef, n)
    for i = 1:n
        pr_user_login = pr_list[i].user.login
        if lowercase(strip(pr_user_login)) == _my_username_lowercase
            pr_is_mine[i] = true
        else
            pr_is_mine[i] = false
        end
    end
    my_pr_list = pr_list[pr_is_mine]
    return my_pr_list
end

function create_new_pull_request(repo::GitHub.Repo;
                                 base_branch::String,
                                 head_branch::String,
                                 title::String,
                                 body::String,
                                 auth::GitHub.Authorization)
    params = Dict{String, String}()
    params["title"] = title
    params["head"] = head_branch
    params["base"] = base_branch
    params["body"] = body
    result = GitHub.create_pull_request(repo; params = params, auth = auth)
    return result
end

function git_commit(message)::Bool
    return try
        git() do git
            success(`$git commit -m "$(message)"`)
        end
    catch
        false
    end
end

function generate_username_mentions(usernames::AbstractVector)::String
    intermediate_result = ""
    for username in usernames
        _username = filter(x -> x != '@', strip(username))
        if length(_username) > 0
            intermediate_result = intermediate_result * "\ncc: @$(_username)"
        end
    end
    final_result = convert(String, strip(intermediate_result))
    return final_result
end

function set_git_identity(username, email)
    git() do git
        run(`$git config user.name "$(username)"`)
        run(`$git config user.email "$(email)"`)
    end
    return nothing
end

function create_new_pull_request(repo::GitHub.Repo;
                                 base_branch::String,
                                 head_branch::String,
                                 title::String,
                                 body::String,
                                 auth::GitHub.Authorization)
    params = Dict{String, String}()
    params["title"] = title
    params["head"] = head_branch
    params["base"] = base_branch
    params["body"] = body
    result = GitHub.create_pull_request(repo; params = params, auth = auth)
    return result
end

function main(relative_path;
              registry,
              github_token = ENV["GITHUB_TOKEN"],
              master_branch = "master",
              pr_branch = "github_actions/remember_to_update_registryci",
              pr_title = "Update RegistryCI.jl by updating the .ci/Manifest.toml file",
              cc_usernames = String[],
              my_username = "github-actions[bot]",
              my_email = "41898282+github-actions[bot]@users.noreply.github.com")
    original_project = Base.active_project()
    original_directory = pwd()

    tmp_dir = mktempdir()
    atexit(() -> rm(tmp_dir; force = true, recursive = true))
    cd(tmp_dir)

    auth = GitHub.authenticate(github_token)
    my_repo = GitHub.repo(registry; auth = auth)
    registry_url_with_auth = "https://x-access-token:$(github_token)@github.com/$(registry)"
    _all_open_prs = get_all_pull_requests(my_repo, "open"; auth = auth)
    _nonforked_prs = exclude_pull_requests_from_forks(my_repo, _all_open_prs)
    pr_list = only_my_pull_requests(_nonforked_prs; my_username = my_username)
    pr_titles = Vector{String}(undef, length(pr_list))
    for i = 1:length(pr_list)
        pr_titles[i] = convert(String, strip(pr_list[i].title))::String
    end

    username_mentions_text = generate_username_mentions(cc_usernames)

    git() do git
        run(`$git clone $(registry_url_with_auth) REGISTRY`)
    end
    cd("REGISTRY")
    git() do git
        run(`$git checkout $(master_branch)`)
    end
    git() do git
        run(`$git checkout -B $(pr_branch)`)
    end
    cd(relative_path)
    manifest_filename = joinpath(pwd(), "Manifest.toml")
    rm(manifest_filename; force = true, recursive = true)
    Pkg.activate(pwd())
    Pkg.instantiate()
    Pkg.update()
    set_git_identity(my_username, my_email)
    try
        git() do git
            run(`$git add Manifest.toml`)
        end
    catch
    end
    commit_was_success = git_commit("Update .ci/Manifest.toml")
    @info("commit_was_success: $(commit_was_success)")
    if commit_was_success
        git() do git
            run(`$git push -f origin $(pr_branch)`)
        end
        if pr_title in pr_titles
            @info("An open PR with the title already exists", pr_title)
        else
            new_pr_body = strip(string("This pull request updates ",
                                       "RegistryCI.jl by updating the ",
                                       "`.ci/Manifest.toml` file.\n\n",
                                       username_mentions_text))
            _new_pr_body = convert(String, strip(new_pr_body))
            create_new_pull_request(my_repo;
                                    base_branch = master_branch,
                                    head_branch = pr_branch,
                                    title = pr_title,
                                    body = _new_pr_body,
                                    auth = auth)
        end
    end

    cd(original_directory)
    rm(tmp_dir; force = true, recursive = true)
    Pkg.activate(original_project)
    return commit_was_success
end

end # end module RememberToUpdateRegistryCI
