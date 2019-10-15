clone_repo(repo::GitHub.Repo) = clone_repo(repo_url(repo))

function clone_repo(url::AbstractString)
    parent_dir = mktempdir()
    atexit(() -> rm(parent_dir; force = true, recursive = true))
    repo_dir = joinpath(parent_dir, "REPO")
    my_retry(() -> _clone_repo_into_dir(url, repo_dir))
    @info("Clone was successful")
    return repo_dir
end

function _clone_repo_into_dir(url::AbstractString, repo_dir)
    @info("Attempting to clone...")
    rm(repo_dir; force = true, recursive = true)
    mkpath(repo_dir)
    LibGit2.clone(url, repo_dir)
    return repo_dir
end

function _comment_disclaimer()
    result = string("\n\n---\n",
                    "It is important to note that if your pull request ",
                    "does not meet the guidelines for automatic merging, ",
                    "this does not mean that your pull request will never ",
                    "be merged. It just means that your pull request will ",
                    "require manual review by a human.\n\n",
                    "> These guidelines are intended not as requirements ",
                    "for packages but as very conservative guidelines, ",
                    "which, if your new package or new version of ",
                    "a package meets them, it may be ",
                    "automatically merged.")
    return result
end

function comment_text_pass(::NewVersion,
                           suggest_onepointzero::Bool,
                           version::VersionNumber)
    result = string("Your `new version` pull request met all of the ",
                    "guidelines for automatic merging.\n\n",
                    "I will automatically merge this pull request during ",
                    "the next `cron` job.\n\n",
                    "If you want to prevent this pull request from ",
                    "being auto-merged, simply leave a comment.\n\n",
                    "(If you want to post a comment without blocking ",
                    "auto-merging, you must include the text ",
                    "`[noblock]` in your comment.)",
                    _onepointzero_suggestion(suggest_onepointzero, version),
                    "\n\n---\n[noblock]")
    return result
end

function comment_text_pass(::NewPackage,
                           suggest_onepointzero::Bool,
                           version::VersionNumber)
    result = string("Your `new package` pull request met all of the ",
                    "guidelines for automatic merging.\n\n",
                    "I will automatically merge this pull request after ",
                    "the mandatory waiting period has elapsed.\n\n",
                    "If you want to prevent this pull request from ",
                    "being auto-merged, simply leave a comment.\n\n",
                    "(If you want to post a comment without blocking ",
                    "auto-merging, you must include the text ",
                    "`[noblock]` in your comment.)",
                    _onepointzero_suggestion(suggest_onepointzero, version),
                    "\n\n---\n[noblock]")
    return result
end

function comment_text_fail(::NewPackage,
                           reasons::Vector{String},
                           suggest_onepointzero::Bool,
                           version::VersionNumber)
    reasons_formatted = join(string.("- ", reasons), "\n")
    result = string("Your `new package` pull request does not meet ",
                    "all of the ",
                    "guidelines for automatic merging.\n\n",
                    "Specifically, your pull request does not ",
                    "meet the following guidelines:\n\n",
                    reasons_formatted,
                    _comment_disclaimer(),
                    _onepointzero_suggestion(suggest_onepointzero, version),
                    "\n\n---\n[noblock]")
    return result
end

function comment_text_fail(::NewVersion,
                           reasons::Vector{String},
                           suggest_onepointzero::Bool,
                           version::VersionNumber)
    reasons_formatted = join(string.("- ", reasons), "\n")
    result = string("Your `new version` pull request does not meet ",
                    "all of the ",
                    "guidelines for automatic merging.\n\n",
                    "Specifically, your pull request does not ",
                    "meet the following guidelines:\n\n",
                    reasons_formatted,
                    _comment_disclaimer(),
                    _onepointzero_suggestion(suggest_onepointzero, version),
                    "\n\n---\n[noblock]")
    return result
end

function comment_text_merge_now()
    result = string("The mandatory waiting period has elapsed.\n\n",
                    "Your pull request is ready to merge.\n\n",
                    "I will now merge this pull request.",
                    "\n\n---\n[noblock]")
    return result
end

is_julia_stdlib(name) = name in julia_stdlib_list()

function julia_stdlib_list()
    return readdir(Pkg.Types.stdlib_dir())
end

function now_utc()
    # my_local_timezone = TimeZones.localzone()
    utc_timezone = TimeZones.TimeZone("UTC")
    _now_utc = Dates.now(utc_timezone)
    return _now_utc
end

function _onepointzero_suggestion(suggest_onepointzero::Bool,
                                  version::VersionNumber)
    if suggest_onepointzero && version < v"1.0.0"
        result = string("\n\n---\n",
                        "On a separate note, I see that you are registering ",
                        "a release with a version number of the form ",
                        "`v0.X.Y`.\n\n",
                        "Does your package have a stable public API? ",
                        "If so, then it's time for you to register version ",
                        "`v1.0.0` of your package. ",
                        "(This is not a requirement. ",
                        "It's just a recommendation.)\n\n",
                        "If your package does not yet have a stable public ",
                        "API, then of course you are not yet ready to ",
                        "release version `v1.0.0`.")
        return result
    else
        return ""
    end
end

function time_is_already_in_utc(dt::Dates.DateTime)
    # my_local_timezone = TimeZones.localzone()
    utc_timezone = TimeZones.TimeZone("UTC")
    result = TimeZones.ZonedDateTime(dt, utc_timezone; from_utc = true)
    return result
end
