# General

General is the default Julia package registry. Package registries are used by Julia's
package manager [Pkg.jl][pkg] and includes information about packages such as versions,
dependencies and compatibility constraints.

The General registry is open for everyone to use and provides access to a large ecosystem
of packages.

## Registering a package in General

New packages and new versions of packages are added the General registry by pull requests
against this GitHub repository. It is *highly recommended* that you use
[Registrator.jl][registrator] to automate this process. Registrator can either be used as a
[GitHub App][registrator-app] or through a [web interface][registrator-web], as decribed in
the [Registrator README][registrator-readme].

When Registrator is triggered a pull request is opened against this repository. Pull
requests that meet certain guidelines is merged automatically, see
[Automatic merging of pull requests](#automatic-merging-of-pull-requests). Other pull
requests need to be manually reviewed and merged by a human.

It is recommended to also use [TagBot][tagbot], which automatically tags a release in your
repository after the new release of your package is merged into the registry.

### Automatic merging of pull requests

Pull requests that meet certain criteria are automatically merged peridically.
Only pull requests that are opened by [Registrator][registrator] are candidates
for automatic merging.

The following criteria are applied for all pull requests
(regardless if it is a new package or just a new version):

 - Version number: Should be a standard increment and not skip versions. This means
   incrementing the patch/minor/major version with +1 compared to previous (if any)
   releases. If, for example, `1.0.0` and `1.1.0` are existing versions, valid new
   versions are `1.0.1`, `1.1.1`, `1.2.0` and `2.0.0`. Invalid new versions include
   `1.0.2` (skips `1.0.1`), `1.3.0` (skips `1.2.0`), `3.0.0` (skips `2.0.0`) etc.

 - Dependencies: All dependencies should have `[compat]` entries that are upper bounded.
   Examples:
   ```toml
   [compat]
   PackageA = "1"        # [1.0.0, 2.0.0), has upper bound (good)
   PackageB = "0.1, 0.2" # [0.1.0, 0.3.0), has upper bound (good)
   PackageB = ">=3"      # [3.0.0, ∞), no upper bound (bad)
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

 - Package name: Should start with a capital letter, contain only ASCII alphanumeric
   characters, and be at least 5 characters long.
 - Version number: Should be a standard initial version number, e.g. `0.0.1`, `0.1.0`,
   or `1.0.0`.
 - Repository URL: Should end with `$PackageName.jl.git` where `PackageName` is the package
   name.

For more details, see [Automatic merging guidelines][automerge-guidelines].
Please report issues with automatic merging to the [RegistryCI repo][registryci].


## FAQ

#### My pull request was not approved for automatic merging, what do I do?

It is recommended that you fix the release to conform to the guidelines and
then retrigger Registrator on the branch/commit that includes the fix.

If you for some reason can't (or won't) adhere to the guidelines you will have
to wait for a human to review/merge the pull request. You can contact a human
in the `#pkg-registration` channel in the official Julia slack to expediate this process.

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

* Rename the GitHub repository to `NewName.jl`
* Rename the file `src/OldName.jl` to `src/NewName.jl`
* Rename the top-level module to `NewName`
* Update tests, documentation, etc, to reference the new name

#### Where do I report a problem with a package in the General registry?

Report it to the package repository.


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
