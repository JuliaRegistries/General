function travis_pull_request_build(::NewPackage,
                                   pr::GitHub.PullRequest,
                                   registry::GitHub.Repo;
                                   auth::GitHub.Authorization,
                                   authorized_authors::Vector{String},
                                   registry_head::String,
                                   registry_master::String,
                                   suggest_onepointzero::Bool,
                                   whoami::String)
    # first check if the PR is open, and the author is authorized - if not, then quit
    # then, delete ALL reviews by me
    # then check rules 1-5. if fail, post comment.
    # then check rules 6-7. if fail, post comment.
    # if everything passed, add an approving review by me
    # 1. Normal capitalization - name should match r"^[A-Z]\w*[a-z][0-9]?$" - i.e. starts with a capital letter, ASCII alphanumerics only, ends in lowercase
    # 2. Not too short - at least five letters - you can register names shorter than this, but doing so requires someone to approve
    # 3. Standard initial version number - one of 0.0.1, 0.1.0, 1.0.0
    # 4. Repo URL ends with /$name.jl.git where name is the package name
    # 5. Compat for all dependencies - all [deps] should also have [compat] entries (and Julia itself) - [compat] entries should have upper bounds
    # 6. Version can be installed - given the proposed changes to the registry, can we resolve and install the new version of the package?
    # 7. Version can be loaded - once it's been installed (and built?), can we load the code?
    pkg, version = parse_pull_request_title(NewPackage(), pr)
    @info("This is a new package pull request", pkg, version)
    pr_author_login = author_login(pr)
    if is_open(pr)
        if pr_author_login in authorized_authors
            my_retry(() -> delete_all_of_my_reviews!(registry, pr; auth = auth, whoami = whoami))
            newp_g1, newp_m1 = meets_normal_capitalization(pkg)
            newp_g2, newp_m2 = meets_name_length(pkg)
            newp_g3, newp_m3 = meets_standard_initial_version_number(version)
            newp_g4, newp_m4 = meets_repo_url_requirement(pkg;
                                                          registry_head = registry_head)
            newp_g5, newp_m5 = meets_compat_for_all_deps(registry_head,
                                                         pkg,
                                                         version)
            newp_g1through5 = [newp_g1, newp_g2, newp_g3, newp_g4, newp_g5]
            @info("Normal capitalization", meets_this_guideline = newp_g1, message = newp_m1)
            @info("Name not too short", meets_this_guideline = newp_g2, message = newp_m2)
            @info("Standard initial version number ", meets_this_guideline = newp_g3, message = newp_m3)
            @info("Repo URL ends with /name.jl.git", meets_this_guideline = newp_g4, message = newp_m4)
            @info("Compat (with upper bound) for all dependencies", meets_this_guideline = newp_g5, message = newp_m5)
            if all(newp_g1through5)
                newp_g6and7, newp_m6and7 = meets_version_can_be_loaded(registry_head,
                                                                         pkg,
                                                                         version)
                @info("Version can be installed and loaded", meets_this_guideline = newp_g6and7, message = newp_m6and7)
                if newp_g6and7
                    newp_commenttextpass = comment_text_pass(NewPackage(),
                                                             suggest_onepointzero,
                                                             version)
                    my_retry(() -> approve!(registry, pr; auth = auth))
                    my_retry(() -> post_comment!(registry, pr, newp_commenttextpass; auth = auth))
                    return nothing
                else
                    newp_commenttext6and7 = comment_text_fail(NewPackage(),
                                                              [newp_m6and7],
                                                              suggest_onepointzero,
                                                              version)
                    my_retry(() -> post_comment!(registry, pr, newp_commenttext6and7; auth = auth))
                    return nothing
                end
            else
                newp_allmessages1through5 = [newp_m1, newp_m2, newp_m3, newp_m4, newp_m5]
                newp_failingmessages1through5 = newp_allmessages1through5[.!newp_g1through5]
                newp_commenttext1through5 = comment_text_fail(NewPackage(),
                                                              newp_failingmessages1through5,
                                                              suggest_onepointzero,
                                                              version)
                my_retry(() -> post_comment!(registry, pr, newp_commenttext1through5; auth = auth))
                return nothing
            end
        else
            @info("Author $(pr_author_login) is not authorized to automerge. Exiting...")
            return nothing
        end
    else
        @info("The pull request is not open. Exiting...")
        return nothing
    end
    return nothing
end
