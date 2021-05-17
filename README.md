# General

| Workflow | Status |
| --------------------------- | ---------------------------------------------------------------------- |
| AutoMerge                   | [![AutoMerge status][AutoMerge-img]][AutoMerge-url]                    |
| Continuous Integration (CI) | [![Continuous Integration (CI) status][CI-img]][CI-url]                |
| TagBot Triggers             | [![TagBot Triggers status][TagBotTriggers-img]][TagBotTriggers-url]    |
| Update Manifests            | [![Update Manifests status][UpdateManifests-img]][UpdateManifests-url] |

[AutoMerge-url]: https://github.com/JuliaRegistries/General/actions/workflows/automerge.yml
[AutoMerge-img]: https://github.com/JuliaRegistries/General/actions/workflows/automerge.yml/badge.svg "AutoMerge status"
[CI-url]: https://github.com/JuliaRegistries/General/actions/workflows/ci.yml
[CI-img]: https://github.com/JuliaRegistries/General/actions/workflows/ci.yml/badge.svg "Continuous Integration (CI) status"
[TagBotTriggers-url]: https://github.com/JuliaRegistries/General/actions/workflows/TagBotTriggers.yml
[TagBotTriggers-img]: https://github.com/JuliaRegistries/General/actions/workflows/TagBotTriggers.yml/badge.svg "TagBot Triggers status"
[UpdateManifests-url]: https://github.com/JuliaRegistries/General/actions/workflows/update_manifests.yml
[UpdateManifests-img]: https://github.com/JuliaRegistries/General/actions/workflows/update_manifests.yml/badge.svg "Update Manifests status"

General is the default Julia package registry. Package registries are used by Julia's
package manager [Pkg.jl][pkg] and includes information about packages such as versions,
dependencies and compatibility constraints.

The General registry is open for everyone to use and provides access to a large ecosystem
of packages.

If you are registering a new package, please make sure that you have read the [package naming guidelines](https://julialang.github.io/Pkg.jl/dev/creating-packages/#Package-naming-guidelines-1).

## Registering a package in General

New packages and new versions of packages are added the General registry by pull requests
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

Registered packages must have an [Open Source Initiative approved license](https://opensource.org/licenses),
clearly marked via a `LICENSE.md`, `LICENSE`, `COPYING` or similarly named file in the package repository.
Packages that wrap proprietary libraries are acceptable if the licenses of those libraries permit open
source distribution of the Julia wrapper code.

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

#### My pull request was not approved for automatic merging, what do I do?

It is recommended that you fix the release to conform to the guidelines and
then retrigger Registrator on the branch/commit that includes the fix.

If you for some reason can't (or won't) adhere to the guidelines you will have
to wait for a human to review/merge the pull request. You can contact a human
in the `#pkg-registration` channel in the official Julia Slack to expedite this process.

#### My package fails to load because it needs proprietary software/additional setup to work, what can I do?

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

#### My pull request has a merge conflict, what do I do?

Retrigger Registrator.

#### How do I retrigger Registrator in order to update my pull request?

Do what you did when you triggered Registrator the first time.

#### Are there any requirements for package names in the General registry?

There are no hard requirements, but it is *highly recommended* to follow
the [package naming guidelines][naming-guidelines].

#### What to do when asked to reconsider/update the package name?

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
* Update tests, documentation, etc, to reference the new name
* Once you are done renaming the package, retrigger registration.
  This will make a new pull request to General. It is helpful to comment
  in the old pull request that it can be closed, linking to the new one.

#### How do I rename an existing registered package?

Technically, you can't rename a package once registered, as this would break existing users.
But you can re-register the package again under a new name with a new UUID.
Which has basically the same effect.

 - Follow the instructions above for renaming a package: rename on GitHub, rename files etc.
 - Generate a new UUID for the Project.toml
 - Increment the version in the Project.toml as a breaking change.
 - [Register](#registering-a-package-in-general) it as if it were a new package
 - Comment on the PR, that this is a rename.
 - It will have to go though the normal criteria for registring a new package.
    - In particular, even if you get it merged manually, it will need to wait 3 days from the PR being opened.
    - This gives others and yourself the chance to point out any naming issues.

You also should let your users know about the rename, e.g. by placing a note in the README,
or opening PRs/issues on downstream packages to change over.

#### How do I transfer a package to an organization or another user?

 - Use the [GitHub transfer option][github-transfer] in the settings.
 - Manually, in the General edit the repo URL in package's `Package.toml` file (e.g [E/Example/Package.toml](https://github.com/JuliaRegistries/General/blob/master/E/Example/Package.toml#L3))

Technically if you skip the second step things will keep working, because GitHub will redirect;
but it is best practice.

#### Where do I report a problem with a package in the General registry?

Report it to the package repository.

#### How do I remove a package or version from the registry?

You can't. Package registrations are **permanent**. A version can not be overwritten in the
registry, and code cannot be deleted.

## Registry maintenance

The General registry is a shared resource that belongs to the entire Julia community. Therefore, we welcome comments and suggestions from everyone in the Julia community. However, all decisions regarding the General registry are ultimately up to the discretion of the registry maintainers.

## Disclaimer

The General registry is open for everyone to register packages in. The General registry is
not a curated list of Julia packages. In particular this means that:

 - packages included in the General registry are **not** reviewed/scrutinized;
 - packages included in the General registry are **not** "official" packages and **not**
   endorsed/approved by the JuliaLang organization;
 - the General registry and its maintainers are **not** responsible for the package code
   you install through the General registry -- you are responsible for reviewing your
   code dependencies.

## Tips for registry maintainers

### Enabling/disabling AutoMerge

To enable/disable automerge, make a pull request to edit the
[`.github/workflows/automerge.yml`](.github/workflows/automerge.yml) file. Specifically, you want
to edit the lines near the bottom of the file that look like this:
```yaml
        env:
          MERGE_NEW_PACKAGES: true
          MERGE_NEW_VERSIONS: true
```

[pkg]: https://julialang.github.io/Pkg.jl/v1/
[registrator]: https://github.com/JuliaRegistries/Registrator.jl
[registrator-app]: https://github.com/JuliaRegistries/Registrator.jl#via-the-github-app
[registrator-web]: https://github.com/JuliaRegistries/Registrator.jl#via-the-web-interface
[registrator-readme]: https://github.com/JuliaRegistries/Registrator.jl/blob/master/README.md
[tagbot]: https://github.com/JuliaRegistries/TagBot
[naming-guidelines]: https://julialang.github.io/Pkg.jl/v1/creating-packages/#Package-naming-guidelines-1
[automerge-guidelines]: https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/
[registryci]: https://github.com/JuliaRegistries/RegistryCI.jl
[github-rename]: https://help.github.com/en/github/administering-a-repository/renaming-a-repository
[github-transfer]: https://help.github.com/en/github/administering-a-repository/transferring-a-repository
