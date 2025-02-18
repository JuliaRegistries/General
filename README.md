# General

| Workflow | Status |
| --------------------------- | ---------------------------------------------------------------------- |
| AutoMerge                   | [![AutoMerge status][AutoMerge-img]][AutoMerge-url]                    |
| Registry consistency tests | [![Registry consistency tests][CI-img]][CI-url]                |
| TagBot Triggers             | [![TagBot Triggers status][TagBotTriggers-img]][TagBotTriggers-url]    |
| Update Manifests            | [![Update Manifests status][UpdateManifests-img]][UpdateManifests-url] |

[AutoMerge-url]: https://github.com/JuliaRegistries/General/actions/workflows/automerge.yml
[AutoMerge-img]: https://github.com/JuliaRegistries/General/actions/workflows/automerge.yml/badge.svg "AutoMerge status"
[CI-url]: https://github.com/JuliaRegistries/General/actions/workflows/registry-consistency-ci.yml
[CI-img]: https://github.com/JuliaRegistries/General/actions/workflows/registry-consistency-ci.yml/badge.svg?branch=master "Registry consistency tests"
[TagBotTriggers-url]: https://github.com/JuliaRegistries/General/actions/workflows/TagBotTriggers.yml
[TagBotTriggers-img]: https://github.com/JuliaRegistries/General/actions/workflows/TagBotTriggers.yml/badge.svg "TagBot Triggers status"
[UpdateManifests-url]: https://github.com/JuliaRegistries/General/actions/workflows/update_manifests.yml
[UpdateManifests-img]: https://github.com/JuliaRegistries/General/actions/workflows/update_manifests.yml/badge.svg "Update Manifests status"

General is the default Julia package registry. Package registries are used by Julia's
package manager [Pkg.jl][pkg] and includes information about packages such as versions,
dependencies and compatibility constraints.

The General registry is open for everyone to use and provides access to a large ecosystem
of packages.

If you are registering a new package, please make sure that you have read the [package naming guidelines](https://pkgdocs.julialang.org/v1/creating-packages/#Package-naming-guidelines).

Follow along new package registrations with the `#new-packages-feed` channels in the
[community Slack](https://julialang.org/slack/) or [Zulip](https://julialang.zulipchat.com/register/)!

See our **[Contributing Guidelines](./CONTRIBUTING.md)** for ways to get involved!

## Registering a package in General

New packages and new versions of packages are added to the General registry by pull requests
against this GitHub repository. It is ***highly recommended*** that you use
[Registrator.jl][registrator] to automate this process. Registrator can either be used as a
[GitHub App][registrator-app] or through a [web interface][registrator-web], as decribed in
the [Registrator README][registrator-readme].

When Registrator is triggered a pull request is opened against this repository. Pull
requests that meet certain guidelines is merged automatically, see
[Automatic merging of pull requests](#automatic-merging-of-pull-requests). Other pull
requests need to be manually reviewed and merged by a human.

It is ***highly recommended*** to also use [TagBot][tagbot], which automatically tags a release in your
repository after the new release of your package is merged into the registry.

Registered packages MUST have an [Open Source Initiative approved license](https://opensource.org/licenses),
clearly marked via the license file (see below for definition) in the package repository.
Packages that wrap proprietary libraries (or otherwise restrictive libraries) are
acceptable if the licenses of those libraries permit open source distribution of the Julia wrapper code.
The more restrictive license of the wrapped code:
1. MUST be mentioned in either the third party notice file or the license file (preferably the third party notice file).
2. SHOULD be mentioned in the README file.

Please note that:
- "README file" refers to the plain text file named `README.md`, `README`, or something similar.
- "License file" refers to the plain text file named `LICENSE.md`, `LICENSE`, `COPYING`, or something similar.
- "Third party notice file" refers to the plain text file named `THIRD_PARTY_NOTICE.md`, `THIRD_PARTY_NOTICE`, or something similar.

### Automatic merging of pull requests

Pull requests that meet certain criteria are automatically merged periodically.
Only pull requests that are opened by [Registrator][registrator] are candidates
for automatic merging.

The full list of AutoMerge guidelines is available in the
[RegistryCI documentation][automerge-guidelines].

Please report issues with automatic merging to the [RegistryCI repo][registryci].

Currently the waiting period is as follows:

 - New Julia packages: 3 days (this allows time for community feedback)
 - New versions of existing packages: 15 minutes
 - JLL package (binary dependencies): 15 minutes, for either a new package or a new version

## FAQ

### Do I need to register a package to install it?

No, you can simply do `using Pkg; Pkg.add(url="https://github.com/JuliaLang/Example.jl")`
or `] add https://github.com/JuliaLang/Example.jl` in the Pkg REPL mode
to e.g. install the package `Example.jl`, even if it was not registered. When a package
is installed this way, the URL is saved in the Manifest.toml, so that file is needed
to resolve Pkg environments that have unregistered packages installed.

Registering allows the package to be added by `Pkg.add("Example")` or `] add Example`
in the Pkg REPL mode. This is true if the package is installed in any registry
you have installed, not just General; you can even create your own registry!

### Should I register my package now?

If your package is at a stage where it might be useful to others, or provide functionality other
packages in General might want to rely on, go for it!

We ask that you consider the following best practices.

* It is easier for others to use your package if it has **documentation** that explains
what the package is for and how to use it. This could be in the form of a README
or hosted documentation such as that generated by
[Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).
* And in order to provide reliable functionality for your users, it is also important
to setup **tests** (see
[the Pkg.jl docs](https://pkgdocs.julialang.org/v1/creating-packages/#Adding-tests-to-the-package)
and the [Test stdlib docs](https://docs.julialang.org/en/v1/stdlib/Test/)), which
can be automatically run by free **continuous integration** services such as GitHub Actions. As part of the test suite, tools like [Aqua.jl](https://github.com/JuliaTesting/Aqua.jl) and [JET.jl](https://github.com/aviatesk/JET.jl) can help you remove bugs or typos and improve the general quality of your code.

Packages like [PkgTemplates.jl](https://github.com/invenia/PkgTemplates.jl) or
[PkgSkeleton.jl](https://github.com/tpapp/PkgSkeleton.jl) provide easy ways to setup
documentation, tests, and continuous integration.

Some types of packages should not be registered, or are not yet ready for registration:

* The General registry is not a place for "personal packages" that consist of
collections of "utility functions" nor for packages that are only useful for a closed group
(like a research group or a company). For that, it is easy to set up your own registry using
for example [LocalRegistry.jl](https://github.com/GunnarFarneback/LocalRegistry.jl). The
[Pkg documentation about registries](https://pkgdocs.julialang.org/v1/registries/) might be useful
if you decide to go this route.
* "Empty" packages that do not yet have functionality are not ready to be registered.

### Can my package in this registry depend on unregistered packages?

No. In this registry, your package cannot depend on other packages that are
unregistered. In addition, your package cannot depend on an unregistered
version of an otherwise registered package. Both of these scenarios would cause
this registry to be unreproducible.

### Can my package be registered if it requires a version of Julia that is not yet released?

Yes, if your package is ready for use, it can be registered before Julia itself has a compatible release.
The [`compat` mechanism](https://pkgdocs.julialang.org/v1/compatibility/)
should be used to indicate which versions of Julia your package is compatible with.
However, AutoMerge will fail to load your package (as currently it only operates on the latest release of Julia),
so the initial package registration and every new version will require manual merging until a compatible version
of Julia has been released.

### My pull request was not approved for automatic merging, what do I do?

It is recommended that you fix the release to conform to the guidelines and
then retrigger Registrator on the branch/commit that includes the fix.

If you for some reason can't (or won't) adhere to the guidelines you will have
to wait for a human to review/merge the pull request. You can contact a human
in the `#pkg-registration` channel in the official Julia Slack to expedite this process.

### My package fails to load because it needs proprietary software/additional setup to work, what can I do?

Before merging a pull request, AutoMerge will check that your package can be installed and
loaded.  It is OK for your package to not be fully functional, but making it at least load
successfully would streamline registration, as it does not require manual intervention from
the registry maintainers.  This would also let other packages depend on it, and use its
functionalities only when the proprietary software is available in the system, as done for
example by the [`CUDA.jl`](https://github.com/JuliaGPU/CUDA.jl) package.  If you are not
able or willing to make your package always loadable without the proprietary dependency
(which is the preferred solution), you can check if the environment variable
`JULIA_REGISTRYCI_AUTOMERGE` is equal to `true` and make your package loadable during
AutoMerge at least, so that it can be registered without manual intervention.  Examples of
packages with proprietary software that use the environment variable check include
[`Gurobi.jl`](https://github.com/jump-dev/Gurobi.jl) and
[`CPLEX.jl`](https://github.com/jump-dev/CPLEX.jl).

### My pull request has a merge conflict, what do I do?

Retrigger Registrator.

### How do I retrigger Registrator in order to update my pull request?

Do what you did when you triggered Registrator the first time.

For more details, please see the [Registrator.jl README](https://github.com/JuliaRegistries/Registrator.jl/blob/master/README.md).

### I commented `@JuliaRegistrator register` on a pull request in the General registry, but nothing happened.

If you want to retrigger Registrator by using the Registrator comment-bot,
you need to post the `@JuliaRegistrator register` comment on a commit in
**your repository** (the repository that contains your package). Do not post
any comments of the form `@JuliaRegistrator ...` in the `JuliaRegistries/General`
repository.

### AutoMerge is blocked by one of my comments, how do I unblock it?

Simply edit `[noblock]` into all your comments. AutoMerge periodically
checks each PR, and if there are no blocking comments when it checks
(i.e. all comments have `[noblock]` present), it will continue to merge
(assuming of course that all of its other checks have passed).

### Are there any requirements for package names in the General registry?

There are no hard requirements, but it is *highly recommended* to follow
the [package naming guidelines][naming-guidelines].

### What to do when asked to reconsider/update the package name?

If someone comments on the name of your package when you first release it it is often
because it does not follow the [naming guidelines][naming-guidelines]. If you think that
your package should not follow those conventions for some reason or another, just explain
why. Otherwise, it is often a good idea to just rename the package -- it is more disruptive
to do so after it is already registered, and sticking to the conventions makes it easier
for users to navigate Julia's many varied packages.

As long as the package is not yet registered, renaming the package from
`OldName.jl` to `NewName.jl` is reasonably straightforward:

* [Rename the GitHub repository][github-rename] to `NewName.jl`
* Rename the file `src/OldName.jl` to `src/NewName.jl`
* Rename the top-level module to `NewName`
* Rename the package name in `Project.toml` from `OldName` to `NewName`
* Update tests, documentation, etc, to reference the new name
* Once you are done renaming the package, retrigger registration.
  This will make a new pull request to General. It is helpful to comment
  in the old pull request that it can be closed, linking to the new one.

### How do I rename an existing registered package?

Technically, you can't rename a package once registered, as this would break existing users.
But you can re-register the package again under a new name with a new UUID, which basically
has the same effect.

 - Follow the instructions above for renaming a package: rename on GitHub, rename files etc.
    - if you rename the repository so it has a new URL, make a PR to edit the URL stored in the
      registry for the old package name to point to the new URL ([example](https://github.com/JuliaRegistries/General/pull/40190/files)).
      This allows the old versions of the package under the previous name to continue to work.
 - Generate a new UUID for the Project.toml
 - Increment the version in the Project.toml as a breaking change.
 - [Register](#registering-a-package-in-general) it as if it were a new package
 - Comment on the PR, that this is a rename.
 - It will have to go though the normal criteria for registring a new package.
    - In particular, even if you get it merged manually, it will need to wait 3 days from the PR being opened.
    - This gives others and yourself the chance to point out any naming issues.

You also should let your users know about the rename, e.g. by placing a note in the README,
or opening PRs/issues on downstream packages to change over.

### How do I transfer a package to an organization or another user?

 - Use the [GitHub transfer option][github-transfer] in the settings.
 - Make a pull request to [this repository](https://github.com/JuliaRegistries/General/pulls) in which you edit the repo URL in the package's Package.toml file (e.g [E/Example/Package.toml](https://github.com/JuliaRegistries/General/blob/master/E/Example/Package.toml#L3)).
 - If the PR is not attended to, or if you have any questions, you can ask for help in the `#pkg-registration` Slack channel.

Technically if you skip the second step things will keep working, because GitHub will redirect;
but it is best practice. For this reason, when you try to register a new release, the Julia
Registrator will complain if the second step is skipped.

### How do I move a subdirectory package to its own repository?

Follow these steps to move a [subdirectory package](https://pkgdocs.julialang.org/v1/managing-packages/#Adding-a-package-in-a-subdirectory-of-a-repository) to its own repository. These steps are focused on GitHub hosted packages but are still applicable for packages hosted elsewhere:

1. Follow Github's documentation on [splitting a subfolder out into a new repository][github-subfolder] and set the subdirectory package to be the new root folder of the new repository via `git-filter-repo`'s `--subdirectory-filter` flag. In order to avoid having to modify the package's `git-tree-sha1` entries in the registry it is important that subdirectory package's contents remain identical for the registered releases. Specifically, this means one should not use `git-filter-repo`'s `--path` functionality to transfer additional top-level directories (such as `.github/workflows`) when transferring the history, as this would modify root tree SHA.
2. [Check that the new repository contains all registered versions of the package](./CONTRIBUTING.md#appendix-checking-if-a-repository-contains-all-registered-versions-of-a-package).
3. Make a pull request to [this repository](https://github.com/JuliaRegistries/General/pulls) in which you edit the repo URL in the package's `Package.toml` file (e.g [`E/Example/Package.toml`](https://github.com/JuliaRegistries/General/blob/master/E/Example/Package.toml#L3)), and remove the `subdir` line. Be sure to include the printed output from the second step in your pull request, so the reviewer can see that the new repository indeed contains all registered versions fo the package. See [this pull request](https://github.com/JuliaRegistries/General/pull/106369) for an example of moving a subdirectory package to its own repository.

### How do I transfer a package to General from another registry?

You can simply register your next release in General (and don't change the package's name or UUID!).
This will be treated as a new package registration in General and be subject to the usual 3-day waiting period.
Once registered, Pkg.jl will look at all the versions from all registries it knows about, and use the compat
mechanism to figure out what version to resolve to as usual, regardless if some versions are in different registries
from others.

### How do I close a PR that Registrator has opened for my package?

If the PR is blocked from merging (which you can do by leaving a comment), then you can just ignore it, as it will eventually be closed by stale-PR automation.
If you need it closed sooner for some reason, you can make a request on the [#pkg-registration](https://julialang.slack.com/archives/C6M4DQA5P) channel on the
public Julia Language Slack for someone to close it.

### Where do I report a problem with a package in the General registry?

Report it to the package repository.

### How do I remove a package or version from the registry?

You can't. Package registrations are **permanent**. A version can not be overwritten in the
registry, and code cannot be deleted.

### Can my package be registered without an [OSI approved license](https://opensource.org/licenses)?

No, sorry. The registry is maintained by volunteers, and we don't have a legal team who can thoroughly review licenses.
It is very easy to accidentally wander into legally murky territory when combining common OSI licenses[^1] like GPL
with non-OSI licenses and we don't want to subject Julia users to that risk when installing packages registered in General.
See [these](https://github.com/JuliaRegistries/General/pull/31549#issuecomment-796671872) [comments](https://github.com/JuliaRegistries/General/pull/31549#issuecomment-804196208) for more discussion. We are not lawyers and this is not legal advice.

[^1]: Note that even within the world of OSI licenses, there are combinations of OSI licenses which are not
legal to use together, such as GPL2 with Apache2.

### Can my package registration PR be merged early?

New packages must typically wait for the 3 day timer to expire before they are merged, either automatically by the bot or manually.
This waiting period allows time for community comment and review, and to provide time to check things like:

- the name is appropriate (e.g. "safe for work", not typosquatting, and fitting with the [Pkg naming guidelines](https://pkgdocs.julialang.org/v1/creating-packages/#Package-naming-guidelines))
- the package is functional and non-empty
- the code is not malicious (e.g. exploiting security vulnerabilities)
- there is some form of README or documentation to enable users to use the package

If there is some urgent need for the package to be registered (for example, an upcoming talk featuring the package or other external deadline), the waiting period can be expedited by request made in the [#pkg-registration](https://julialang.slack.com/archives/C6M4DQA5P) channel on the
public Julia Language Slack, or directly on the PR itself. This request should include a link to the registration PR and why an expedited merge is needed. In this case, a registry maintainer (see below) can manually review the package (often with stricter standards than the typical package faces, given the lack of bandwidth to review all packages thoroughly).

### Who can approve an early merge?

Any registry maintainer may merge a package registration PR early.
Early merges should still be discussed on the [#pkg-registration](https://julialang.slack.com/archives/C6M4DQA5P) slack channel before merging.
Registry maintainers are discouraged from merging packages they directly *or* indirectly maintain as mentioned in [CONTRIBUTING.md](https://github.com/JuliaRegistries/General/blob/master/CONTRIBUTING.md#other-ways-to-help).

### When is yanking a release appropriate?

Releases that have already merged can be marked as "yanked" by adding `yanked = true` under the release
entry in `Versions.toml` ([example](https://github.com/JuliaRegistries/General/pull/94858/files)). This
tells Pkg to no longer resolve those versions (e.g. when running `Pkg.add()` or `Pkg.resolve()`). However,
to maintain perfect reproducibility of environments specified with a full manifest, yanked versions that
are specifically listed in a manifest will continue to instantiate when running `Pkg.instantiate()` and
yanked versions cannot be re-registered in General with different source code.

If a release is very broken (e.g. contains security vulnerabilities or bugs that are significantly worse 
than the package erroring on load), then it may be yanked. Releasing an ordinary patch release—potentially 
reusing the exact same source code as a previous release without the major bug—is a faster, easier to 
deploy, and less disruptive way to prevent most users from installing a specific version. If you seek to
yank a very broken release, you should typically also release a patch release.

There is however, a special category of bugged releases that can not be resolved by having a patch release.
These also may to be resolved by yanking. That special category is when the compat bounds have been set too
wide. i.e. say `v2.10.0` was released using a feature not on julia `v1.6` but the compat entry for julia was
not raised in the release. In this case releasing a `v2.10.1` with the corrected julia compat would not 
solve the issue as on julia v1.6 Pkg would still resolve the broken `v2.10.0`, and as a minor bump, reverting
the code changes would not be valid in a patch bump. In this case one may either submit a PR to retroactively
adjust the compat bounds of previous versions (best user-facing results, but slow and error-prone to implement)
or yank the offending release. See the [SciML collaborative practices for more guidance](https://github.com/SciML/ColPrac?tab=readme-ov-file#accidental-support-for-an-unsupported-dependency).

If yanking is urgent, open a PR and raise it on the `#pkg-registration` [slack channel](https://julialang.org/slack/)

For releases with actively exploited security vulnerabilities (i.e. malicious code) yanking is not suficient.
In this case, the release should be completely deleted from the registry and a new patch release should be
issued. This is a drastic measure that breaks reproducibility guarantees and has never been performed as of 
April, 2024.

### My new package registration PR fails one or more AutoMerge checks because of reason [X]. However, the General registry already contains a package PastPackage that does thing [X]. Will registry maintainers consider this PastPackage when they evaluate my new package registration PR?

As a general rule, no. If your package registration does not meet AutoMerge guidelines, then the presence of previous exceptions to those guidelines does not justify an exception for your package, and registry maintainers will not consider past packages to be any kind of precedent that applies to current and future registrations.

## Registry maintenance

The General registry is a shared resource that belongs to the entire Julia community. Therefore, we welcome comments and suggestions from everyone in the Julia community. However, all decisions regarding the General registry are ultimately up to the discretion of the registry maintainers.

See our **[Contributing Guidelines](./CONTRIBUTING.md)** for ways to get involved!

## Disclaimer

The General registry is open for everyone to register packages in. The General registry is
not a curated list of Julia packages. In particular this means that:

 - packages included in the General registry are **not** reviewed/scrutinized;
 - packages included in the General registry are **not** "official" packages and **not**
   endorsed/approved by the JuliaLang organization;
 - the General registry and its maintainers are **not** responsible for the package code
   you install through the General registry -- you are responsible for reviewing your
   code dependencies.

[pkg]: https://julialang.github.io/Pkg.jl/v1/
[registrator]: https://github.com/JuliaRegistries/Registrator.jl
[registrator-app]: https://github.com/JuliaRegistries/Registrator.jl#via-the-github-app
[registrator-web]: https://github.com/JuliaRegistries/Registrator.jl#via-the-web-interface
[registrator-readme]: https://github.com/JuliaRegistries/Registrator.jl/blob/master/README.md
[tagbot]: https://github.com/JuliaRegistries/TagBot
[naming-guidelines]: https://pkgdocs.julialang.org/v1/creating-packages/#Package-naming-rules
[automerge-guidelines]: https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/
[registryci]: https://github.com/JuliaRegistries/RegistryCI.jl
[github-rename]: https://help.github.com/en/github/administering-a-repository/renaming-a-repository
[github-subfolder]: https://docs.github.com/en/get-started/using-git/splitting-a-subfolder-out-into-a-new-repository
[github-transfer]: https://help.github.com/en/github/administering-a-repository/transferring-a-repository
