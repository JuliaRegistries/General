function approve!(repo::GitHub.Repo, pr::GitHub.PullRequest; auth::GitHub.Authorization)
    repo_full_name = full_name(repo)
    pr_number = number(pr)
    endpoint = "/repos/$(repo_full_name)/pulls/$(pr_number)/reviews"
    myparams = Dict("event" => "APPROVE")
    GitHub.gh_post_json(GitHub.DEFAULT_API,
                        endpoint;
                        auth=auth,
                        params = myparams)
    return nothing
end

author_login(pull_request::GitHub.PullRequest) = pull_request.user.login

base_repo(pull_request::GitHub.PullRequest) = pull_request.base.repo

body(c::GitHub.Comment) = c.body

function created_at(pull_request::GitHub.PullRequest)
    result = time_is_already_in_utc(pull_request.created_at)
    return result
end

function delete_all_of_my_reviews!(repo::GitHub.Repo,
                                  pr::GitHub.PullRequest;
                                  auth::GitHub.Authorization,
                                  whoami::String)
    all_pr_reviews = get_all_pull_request_reviews(repo, pr; auth = auth)
    for rev in all_pr_reviews
        if reviewer_login(rev) == whoami
            delete_pr_review!(repo, pr, rev)
        end
    end
    return nothing
end

function delete_merged_branch!(repo::GitHub.Repo, pr::GitHub.PullRequest; auth::GitHub.Authorization)
    updated_pr = _get_updated_pull_request(pr; auth=auth)
    if is_merged(updated_pr)
        try
            head_branch = pull_request_head_branch(updated_pr)
            repo = head_branch.repo
            ref = "heads/$(head_branch.ref)"
            GitHub.delete_reference(repo, ref; auth=auth)
        catch ex
            showerror(stderr, ex)
            Base.show_backtrace(stderr, catch_backtrace())
            println(stderr)
        end
    end
    return nothing
end

function delete_pr_review!(repo::GitHub.Repo, pr::GitHub.PullRequest, r::GitHub.Review)
    repo_full_name = full_name(repo)
    pr_number = number(pull_request)
    review_id = IHAVENOIDEA
    endpoint = "/repos/$(repo_full_name)/pulls/$(pr_number)/reviews/$(review_id)"
    GitHub.gh_delete_json(GitHub.DEFAULT_API,
                          endpoint;
                          auth=auth)
    return nothing
end

full_name(repo::GitHub.Repo) = repo.full_name

function _get_updated_pull_request(pull_request::GitHub.PullRequest; auth::GitHub.Authorization)
    pr_base_repo = base_repo(pull_request)
    pr_number = number(pull_request)
    updated_pr = GitHub.pull_request(pr_base_repo, pr_number; auth=auth)
    return updated_pr
end

function get_all_pull_request_comments(repo::GitHub.Repo,
                                       pr::GitHub.PullRequest;
                                       auth::GitHub.Authorization)
    all_comments = Vector{GitHub.Comment}(undef, 0)
    myparams = Dict("per_page" => 100, "page" => 1)
    cs, page_data = GitHub.comments(repo, pr, :pr; auth=auth, params = myparams, page_limit = 100)
    append!(all_comments, cs)
    while haskey(page_data, "next")
        cs, page_data =  GitHub.comments(repo, pr, :pr; auth=auth, page_limit = 100, start_page = page_data["next"])
        append!(all_comments, cs)
    end
    unique!(all_comments)
    return all_comments
end

function get_all_pull_request_reviews(repo::GitHub.Repo,
                                      pr::GitHub.PullRequest;
                                      auth::GitHub.Authorization)
    all_reviews = Vector{GitHub.Review}(undef, 0)
    myparams = Dict("per_page" => 100, "page" => 1)
    revs, page_data = GitHub.reviews(repo, pr; auth=auth, params = myparams, page_limit = 100)
    append!(all_reviews, revs)
    while haskey(page_data, "next")
        revs, page_data = GitHub.reviews(repo, pr; auth=auth, page_limit = 100, start_page = page_data["next"])
        append!(all_reviews, revs)
    end
    unique!(all_reviews)
    return all_reviews
end

function get_all_pull_requests(repo::GitHub.Repo,
                               state::String;
                               auth::GitHub.Authorization)
    all_pull_requests = Vector{GitHub.PullRequest}(undef, 0)
    myparams = Dict("state" => state, "per_page" => 100, "page" => 1)
    prs, page_data = GitHub.pull_requests(repo; auth=auth, params = myparams, page_limit = 100)
    append!(all_pull_requests, prs)
    while haskey(page_data, "next")
        prs, page_data = GitHub.pull_requests(repo; auth=auth, page_limit = 100, start_page = page_data["next"])
        append!(all_pull_requests, prs)
    end
    unique!(all_pull_requests)
    return all_pull_requests
end

is_merged(pull_request::GitHub.PullRequest) = pull_request.merged

function is_open(pull_request::GitHub.PullRequest)
    result = pr_state(pull_request) == "open"
    !result && @error("Pull request is not open")
    return result
end

function merge!(registry_repo::GitHub.Repo, pr::GitHub.PullRequest; auth::GitHub.Authorization)
    pr_number = number(pr)
    @info("Attempting to merge pull request #$(pr_number)")
    try
        GitHub.merge_pull_request(registry_repo, pr_number; auth=auth)
    catch ex
        showerror(stderr, ex)
        Base.show_backtrace(stderr, catch_backtrace())
        println(stderr)
    end
    try
        delete_merged_branch!(registry_repo, pr; auth=auth)
    catch ex
        showerror(stderr, ex)
        Base.show_backtrace(stderr, catch_backtrace())
        println(stderr)
    end
    return nothing
end

number(pull_request::GitHub.PullRequest) = pull_request.number

function post_comment!(repo::GitHub.Repo,
                       pr::GitHub.PullRequest,
                       body::String;
                       auth::GitHub.Authorization)
    myparams = Dict("body" => body)
    GitHub.create_comment(repo, pr, :pr; auth=auth, params = myparams)
    return nothing
end

pull_request_head_branch(pull_request::GitHub.PullRequest) = pull_request.head

repo_url(repo::GitHub.Repo) = repo.html_url.uri

pr_state(pull_request::GitHub.PullRequest) = pull_request.state

review_state(r::GitHub.Review) = r.state

reviewer_login(r::GitHub.Review) = r.user.login

function time_since_pr_creation(pull_request::GitHub.PullRequest)
    _pr_created_at_utc = created_at(pull_request)
    _now_utc = now_utc()
    result = _now_utc - _pr_created_at_utc
    return result
end

title(pull_request::GitHub.PullRequest) = pull_request.title

function username(auth::GitHub.Authorization)
    user_information = GitHub.gh_get_json(GitHub.DEFAULT_API,
                                          "/user";
                                          auth = auth)
    return user_information["login"]::String
end
