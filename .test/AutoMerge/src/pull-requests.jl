const new_package_title_regex = r"^New package: (\w*) v(.*)"

const new_version_title_regex = r"^New version: (\w*) v(.*)"

is_new_package(pull_request::GitHub.PullRequest) = occursin(new_package_title_regex, title(pull_request))

is_new_version(pull_request::GitHub.PullRequest) = occursin(new_version_title_regex, title(pull_request))

function parse_pull_request_title(::NewVersion,
                                  pull_request::GitHub.PullRequest)
    m = match(new_version_title_regex, title(pull_request))
    pkg = convert(String, m.captures[1])::String
    version = VersionNumber(m.captures[2])
    return pkg, version
end

function parse_pull_request_title(::NewPackage,
                                  pull_request::GitHub.PullRequest)
    m = match(new_package_title_regex, title(pull_request))
    pkg = convert(String, m.captures[1])::String
    version = VersionNumber(m.captures[2])
    return pkg, version
end

function travis_pull_request_build(pr_number::Integer,
                                   registry::GitHub.Repo,
                                   registry_head::String;
                                   whoami::String,
                                   auth::GitHub.Authorization,
                                   authorized_authors::Vector{String},
                                   suggest_onepointzero::Bool)
    pr = my_retry(() -> GitHub.pull_request(registry, pr_number; auth=auth))
    result = travis_pull_request_build(pr,
                                       registry,
                                       registry_head;
                                       auth=auth,
                                       authorized_authors=authorized_authors,
                                       suggest_onepointzero=suggest_onepointzero,
                                       whoami=whoami)
    return result
end

function travis_pull_request_build(pr::GitHub.PullRequest,
                                   registry::GitHub.Repo,
                                   registry_head::String;
                                   auth::GitHub.Authorization,
                                   authorized_authors::Vector{String},
                                   suggest_onepointzero::Bool,
                                   whoami::String)
    if is_new_package(pr)
        registry_master = clone_repo(registry)
        travis_pull_request_build(NewPackage(),
                                  pr,
                                  registry;
                                  auth = auth,
                                  authorized_authors=authorized_authors,
                                  registry_head = registry_head,
                                  registry_master = registry_master,
                                  suggest_onepointzero = suggest_onepointzero,
                                  whoami=whoami)
        rm(registry_master; force = true, recursive = true)
    elseif is_new_version(pr)
        registry_master = clone_repo(registry)
        travis_pull_request_build(NewVersion(),
                                  pr,
                                  registry;
                                  auth = auth,
                                  authorized_authors=authorized_authors,
                                  registry_head = registry_head,
                                  registry_master = registry_master,
                                  suggest_onepointzero = suggest_onepointzero,
                                  whoami=whoami)
        rm(registry_master; force = true, recursive = true)
    else
        @info("Neither a new package nor a new version. Exiting...")
        return nothing
    end
end
