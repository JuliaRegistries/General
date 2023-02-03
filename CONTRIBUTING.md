# Contribution guidelines

Anyone can help improve the General registry! Here are a few ways.

## As a package author

You can register your package!
See [Registering a package in General](https://github.com/JuliaRegistries/General#registering-a-package-in-general) in the README for how to do that.
The "FAQ" section in the README helps answer many more questions, like [do I need to register a package to install it?](https://github.com/JuliaRegistries/General#do-i-need-to-register-a-package-to-install-it), [should I register my package?](https://github.com/JuliaRegistries/General#should-i-register-my-package), and more.

* Please be aware of the [package naming guidelines](https://pkgdocs.julialang.org/dev/creating-packages/#Package-naming-guidelines-1)
* We strongly encourage authors to follow best practices like having documentation (or a descriptive README), tests, and continuous integration.

## As a Julia community member

You (yes, you!) can help General be the best registry it can be.

### New package registrations

The first step to getting involved with General is to check out new package registrations.
They are filed under the ["new package" label](https://github.com/JuliaRegistries/General/pulls?q=is%3Apr+is%3Aopen+label%3A%22new+package%22), and a automatic feed posts them in the `#new-packages-feed` channel in the [community Slack](https://julialang.org/slack/) or [Zulip](https://julialang.zulipchat.com/register/).

When registration is triggered for a new package (or new version of a package), [RegistryCI.jl](RegistryCI)-powered AutoMerge automatically runs and performs [some basic checks](https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/).
These are merely guidelines, and not all checks must pass --- if a check fails, the registration can still be manually merged.
There are a few ways to help here:

1. First, whenever you are engaging with a package author, remember to always be polite and kind-- if you are feeling frustrated, it may be better to not comment at all and let someone else respond instead.
Not everyone understands things from the same explanations, and some folks may need to translate or overcome other barriers to understanding, or may simply disagree with you.
When we are helping maintain the General registry, we are acting as representatives of the Julia community, and need to be mindful of that.
2. If an AutoMerge guideline fails and the package author does not seem to know how to address it, you can help guide them through the process.
Pointing them to the [FAQ](FAQ) can help, as can updating the FAQ and other guidance to make the process more clear.
Sometimes folks also just need a bit of help to understand the process, and writing a note can help.
3. If an AutoMerge fails but you think the package should be manually merged, comment in the PR to explain why. 
    * One common issue here is the name similarity check.
    This exists to prevent malicious [typosquatting](https://en.wikipedia.org/wiki/Typosquatting).
    For example, [Flux](https://github.com/FluxML/Flux.jl) is a popular machine learning package.
    A malicious actor could try to register FIux (with an uppercase-eye instead of a lowercase-ell), and encourage users to install it by writing a tutorial or such.
    They could then add malicious code to the package to try to steal secrets.
    Such an event would be an extreme security violation and the package would be yanked or removed from the registry as soon as possible-- but we try to be a bit safer by proactively screening names to require manual merging if they are "too similar" to an existing package name.
    
      If a package fails the name similarity check, you can help out by taking a look at the two names as well as the package code itself, and try to make a determination if it looks "too close" (e.g. Websockets vs WebSocket), and if the package code contains anything that would indicate malicious activity.
      You can make a comment in the PR indicating whether or not you think the name similarity is okay.
      If you have [triage](permissions)-level access or higher to General, you can additionally add the labels _Override AutoMerge: name similarity is okay_ and _needs to be manually merged in 3 days_.
      
4. Regardless of AutoMerge's status, if you think perhaps something more should be done before registration, feel free to leave a comment in the PR explaining what you think should be done first.
Any comment without `[noblock]` included in it will block AutoMerge from automatically merging the pull request (editing `[noblock]` into old comments **will** allow it to resume).
    * For example, occasionally someone will register a package without any content in order to reserve the package name, with the intent to add content later.
    We don't allow that in General, and ask authors to add content first before registering.
    * Sometimes authors register packages without any description of what the package is for in the README or without documentation.
    Since registration is a mechanism to share code with the whole Julia community, such a description is important for the package to be useful.
    While we don't strictly require such documentation, it can help to give a polite and gentle nudge in the PR comments, or show folks how to write documentation and/or what is helpful to include in a README.
    We want to encourage best practices (in an inclusive and friendly way!) even when they are not strict requirements.
    * Sometimes package names are possibly confusing or don't conform to our [naming guidelines](naming-guidelines), but AutoMerge does not detect this.
    Feel free to comment, describing what you think is confusing or non-compliant about the current name, and any suggestions you have for a more clear name.

### Other PRs to General

Sometimes, the registry needs to be updated in other ways that involve manual pull requests (PRs) rather than auto-generated ones.
The most common reason is to update the URL for a repository.

#### Updating the URL for a repository

If someone transfers a GitHub repository, [we ask](https://github.com/JuliaRegistries/General#how-do-i-transfer-a-package-to-an-organization-or-another-user) that they update the URL stored in General.
This is done by manually making a PR to General to update the URL.
You can review such a PR by checking that the old URL redirects to the new one.
* If it does, that's a clear sign that the change is legitimate and the new URL is correct.
  If you have write permissions to General, you can merge the PR; otherwise you can approve it or comment.
* If it does not, you can ask the author why. This should be handled on a case-by-case basis. Be sure to check that:
    1. The package is not being hijacked; check for example that the person making the PR has registered a version of the package before, indicating they are authorized to do so.
    2. All the registered revisions of the package are accessible in the new repository.
       Specifically, this means checking that all the git-tree-shas can be found in the new repository.
       See [the appendix](#appendix-checking-if-a-repository-contains-all-registered-versions-of-a-package) below for a script to automate this checking.

### Other ways to help

Besides helping out with PRs to General, you can...

* ...improve [General's README](https://github.com/JuliaRegistries/General#general), the [RegistryCI documentation](https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/), or these guidelines!
* ...add new checks to AutoMerge (in [RegistryCI](RegistryCI)) or improve existing ones.
* ...address open issues in [General](https://github.com/JuliaRegistries/General/issues), [RegistryCI.jl](https://github.com/JuliaRegistries/RegistryCI.jl/issues), or [Registrator.jl](https://github.com/JuliaRegistries/Registrator.jl/issues).
* ...write blog posts and documentation to help folks get started with writing documentation, tests, and setting up CI for their own packages, and find appropriate places to link to it and help out new package authors. 

Additionally, if you have elevated [permissions](permissions) to General, there's a few more things you can do:

* [triage] You can add or remove labels to PRs to help communicate the status.
* [triage] You can close PRs if the package author requests it or the registration is superseded by another registration request.
* [write] You can merge PRs that have the _needs to be manually merged in 3 days_ label once the requisite waiting period has passed, assuming there are no outstanding objections in the PR comments.
* [write] You can choose to facilitate expedited merge requests, after manually reviewing the package.
You generally should not merge your own registrations (though you can make requests to another maintainer).
* [write] You can merge improvements to the README, these guidelines, or our workflows.
* [admin] You can give other contributors triage-level access so they can apply labels to PRs, or write-level permissions to merge PRs.

## Appendix: Checking if a repository contains all registered versions of a package

When someone wishes to move a package from one repo to another, it is important that the new repo contains all of the tree hashes corresponding to registered versions of a package. That way these old versions of the package can continue to be installed from the new repository. In order to check if a given repository contains all of the registered versions of a package, the following script can be used:

```julia
using RegistryInstances, UUIDs, Git

const GENERAL_UUID = UUID("23338594-aafe-5451-b93e-139f81909106")

pretty_print_row(row) = println(row.pkg_name, ": v", row.version, " ", row.found ? "found" : "is missing")
pretty_print_table(table) = foreach(pretty_print_row, table)

function check_all_found(table)
    idx = findfirst(row -> !row.found, table)
    idx === nothing && return nothing
    row = table[idx]
    error(string("Repository missing v", row.version, " of package $(row.pkg_name)"))
end

function check_packages_versions(pkg_names, repo_url; registry_uuid=GENERAL_UUID, verbose=true, throw=true)
    dir = mktempdir()
    run(`$(git()) clone $(repo_url) $dir`)

    registry = only(filter!(r -> r.uuid == registry_uuid, reachable_registries()))

    table = @NamedTuple{pkg_name::String, version::VersionNumber, found::Bool}[]

    for pkg_name in pkg_names
        pkg = registry.pkgs[only(uuids_from_name(registry, pkg_name))]
        versions = registry_info(pkg).version_info
        for version in sort(collect(keys(versions)))
            tree_sha = versions[version].git_tree_sha1
            found = success(`$(git()) -C $dir rev-parse -q --verify "$(tree_sha)^{tree}"`)

            push!(table, (; pkg_name, version, found))
        end
    end
    verbose && pretty_print_table(table)
    throw && check_all_found(table)
    return table
end

check_package_versions(pkg_name, repo_url; kw...) = check_packages_versions([pkg_name], repo_url; kw...)
```

For example, in [General#75319](https://github.com/JuliaRegistries/General/pull/75319), a package author wanted to update the URL associated
to their package "FastParzenWindows". At the time, the package had 1 registered version. We can check that it is present in the new repository via:
```julia
julia> check_package_versions("FastParzenWindows", "https://github.com/ngiann/FastParzenWindows.jl.git");
Cloning into '/var/folders/jb/plyyfc_d2bz195_0rc0n_zcw0000gp/T/jl_ke9E8C'...
...text omitted...
FastParzenWindows: v0.1.2 found
```
We see that this version was found in the new repository. This script was based on [this comment from General#35965](https://github.com/JuliaRegistries/General/pull/35965#issuecomment-832721704),
which involved checking if 4 packages in the same repository all had their versions present in the new repository. That example can be handled as follows:

```julia
pkg_names = ["ReinforcementLearningBase", "ReinforcementLearningCore",
             "ReinforcementLearningEnvironments", "ReinforcementLearningZoo"]
check_packages_versions(pkg_names, "https://github.com/JuliaReinforcementLearning/ReinforcementLearning.jl.git")
```

[FAQ]: https://github.com/JuliaRegistries/General#faq]
[naming-guidelines]: https://pkgdocs.julialang.org/dev/creating-packages/#Package-naming-guidelines-1
[permissions]: https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-permission-levels-for-an-organization#permission-levels-for-repositories-owned-by-an-organization
[RegistryCI]: https://github.com/JuliaRegistries/RegistryCI.jl/
