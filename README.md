# General

[![AutoMerge status][automerge-img]][automerge-url]
[![TagBot Triggers Status][tagbot-img]][tagbot-url]

[automerge-url]: https://github.com/JuliaRegistries/General/actions?query=workflow%3AAutoMerge+event%3Aschedule
[automerge-img]: https://github.com/JuliaRegistries/General/workflows/AutoMerge/badge.svg?event=schedule "AutoMerge status"
[tagbot-url]: https://github.com/JuliaRegistries/General/actions?query=workflow%3A%22TagBot+Triggers%22+event%3Aschedule
[tagbot-img]: https://github.com/JuliaRegistries/General/workflows/TagBot%20Triggers/badge.svg?event=schedule

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

The following criteria are applied for all pull requests
(regardless if it is a new package or just a new version):

 - Version number: Should be a standard increment and not skip versions. This means
   incrementing the patch/minor/major version with +1 compared to previous (if any)
   releases. If, for example, `1.0.0` and `1.1.0` are existing versions, valid new
   versions are `1.0.1`, `1.1.1`, `1.2.0` and `2.0.0`. Invalid new versions include
   `1.0.2` (skips `1.0.1`), `1.3.0` (skips `1.2.0`), `3.0.0` (skips `2.0.0`) etc.

 - Dependencies: All dependencies should have `[compat]` entries that are upper bounded and only include a finite number of breaking releases.
   For example, the following `[compat]` entries meet the criteria for automatic merging:
   ```toml
   [compat]
   PackageA = "1"          # [1.0.0, 2.0.0), has upper bound (good)
   PackageB = "0.1, 0.2"   # [0.1.0, 0.3.0), has upper bound (good)
   ```
   The following `[compat]` entries do NOT meet the criteria for automatic merging:
   ```toml
   [compat]
   PackageC = ">=3"        # [3.0.0, ∞), no upper bound (bad)
   PackageD = ">=0.4, <1"  # [-∞, ∞), no lower bound, no upper bound (very bad)
   ```
   Please note: each `[compat]` entry must include only a finite number of breaking releases. Therefore, the following `[compat]` entries do NOT meet the criteria for automatic merging:
   ```toml
   [compat]
   PackageE = "0"          # includes infinitely many breaking 0.x releases of PackageE (bad)
   PackageF = "0.2 - 0"    # includes infinitely many breaking 0.x releases of PackageF (bad)
   PackageG = "0.2 - 1"    # includes infinitely many breaking 0.x releases of PackageG (bad)
   ```
   See [Pkg's documentation][pkg-compat] for specification of `[compat]` entries in your
   `Project.toml` file.
   
   (**Note:** Standard libraries are excluded for this criterion since they are bundled
   with Julia, and, hence, implicitly included in the `[compat]` entry for Julia.
   For the time being, JLL dependencies are also excluded for this criterion because they
   often have non-standard version numbering schemes; however, this may change in the future.)
   
   You may find [CompatHelper.jl](https://github.com/bcbi/CompatHelper.jl) helpful for maintaining up-to-date `[compat]` entries.

 - Package installation: The package should be installable (`Pkg.add("PackageName")`),
   and loadable (`import PackageName`).

The following list is applied for new package registrations, in addition to the previous
list:

 - The package name should start with a capital letter, contain only ASCII
   alphanumeric characters, contain a lowercase letter, be at least 5
   characters long, and should not start with "Ju" or contain the string "julia".
 - To prevent confusion between similarly named packages, the names of new
   packages must also satisfy three checks:
      - the [Damerau–Levenshtein
        distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
        between the package name and the name of any existing package must be at
        least 3.
      - the Damerau–Levenshtein distance between the lowercased version of a
        package name and the lowercased version of the name of any existing
        package must be at least 2.
      - and a visual distance from
        [VisualStringDistances.jl](https://github.com/ericphanson/VisualStringDistances.jl)
        between the package name and any existing package must exceeds a certain
        a hand-chosen threshold (currently 2.5).

    These checks and tolerances are subject to change in order to improve the
    process.

    To test yourself that a tentative package name, say `MyPackage` meets these
    checks, you can use the following code (after adding the RegistryCI package
    to your Julia environment):

    ```julia
    using RegistryCI
    using RegistryCI.AutoMerge
    all_pkg_names = AutoMerge.get_all_non_jll_package_names(path_to_registry)
    AutoMerge.meets_distance_check("MyPackage", all_pkg_names)
    ```

    where `path_to_registry` is a path to the folder containing the registry of
    interest. For the General Julia registry, usually `path_to_registry =
    joinpath(DEPOT_PATH[1], "registries", "General")` if you haven't changed
    your `DEPOT_PATH`. This will return a boolean, indicating whether or not
    your tentative package name passed the check, as well as a string,
    indicating what the problem is in the event the check did not pass.

    Note that these automerge guidelines are deliberately conservative: it is
    very possible for a perfectly good name to not pass the automatic checks and
    require manual merging. They simply exist to provide a fast path so that
    manual review is not required for every new package.

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

[pkg]: https://julialang.github.io/Pkg.jl/v1/
[registrator]: https://github.com/JuliaRegistries/Registrator.jl
[registrator-app]: https://github.com/JuliaRegistries/Registrator.jl#via-the-github-app
[registrator-web]: https://github.com/JuliaRegistries/Registrator.jl#via-the-web-interface
[registrator-readme]: https://github.com/JuliaRegistries/Registrator.jl/blob/master/README.md
[tagbot]: https://github.com/JuliaRegistries/TagBot
[naming-guidelines]: https://julialang.github.io/Pkg.jl/v1/creating-packages/#Package-naming-guidelines-1
[automerge-guidelines]: https://github.com/JuliaRegistries/RegistryCI.jl#automatic-merging-guidelines
[pkg-compat]: https://julialang.github.io/Pkg.jl/v1/compatibility/
[registryci]: https://github.com/JuliaRegistries/RegistryCI.jl
[github-rename]: https://help.github.com/en/github/administering-a-repository/renaming-a-repository
[github-transfer]: https://help.github.com/en/github/administering-a-repository/transferring-a-repository

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
