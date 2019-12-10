# General registry

This is the official general Julia package registry where people can register
any package they want without too much debate about naming and without enforced
standards on documentation or testing. We nevertheless encourage documentation,
testing and some amount of consideration when choosing package names.

A registry of packages is used connect Julia's package manager
[Pkg.jl](https://julialang.github.io/Pkg.jl) to Julia packages, to allow them to
be updated and installed easily. This registry is installed by default in
standard Julia installations, and provides access to a large ecosystem of
packages.

## Guide for package authors

New packages and new versions of packages are added the Julia General registry
by pull requests against the
[JuliaRegistries/General](https://github.com/JuliaRegistries/General/pulls)
GitHub repository. This process can be automated by either the
[Registrator.jl](https://github.com/JuliaRegistries/Registrator.jl) GitHub bot
or the [web interface](https://github.com/JuliaRegistries/Registrator.jl).

It can be helpful to also install
[TagBot](https://github.com/JuliaRegistries/TagBot), which automatically tags a
release on your repository after the package or new version of the package is
added to the registry.

The process usually proceeds as follows:

Either:

* Install the Registrator bot on the repository corresponding to the package you
  would like to add or update in the General registry, following the
  instructions at
  [Registrator.jl/README.md](https://github.com/JuliaRegistries/Registrator.jl).
  Then file an issue on the repository, or make a comment on the commit, with
  "@JuliaRegistrator register". For more information on interacting with the
  Registrator bot, see
  [Registrator.jl/README.md](https://github.com/JuliaRegistries/Registrator.jl).
* Go to the [web interface](https://github.com/JuliaRegistries/Registrator.jl)
  and follow the instructions linked there to start the registration process.

After either option, a pull request is made against the
[JuliaRegistries/General](https://github.com/JuliaRegistries/General/pulls)
GitHub repository.

If the package meets the [automerge
requirements](#list-of-automerge-requirements), that is all one needs to do. New
packages are subject to a 3-day waiting period for community feedback, while new
versions of existing packages may be merged right away. Once the pull request is
merged, the package or new version of the package is available in the General
registry. If [TagBot](https://github.com/JuliaRegistries/TagBot) is installed,
then it will tag a release once the pull request is merged. This is very helpful
to ensure that tagged releases correspond exactly to versions in the registry.

Before the pull request is merged, retriggering the Registrator bot on the same
package (via a new comment or use of the web interface) will cause the bot to
update the pull request (by force pushing).

While usually starting the registration process is all the package author needs
to do, occasionally something more may be needed. The automerge bot will merge
the pull requests opened by the Registrator bot and the web interface if they
meet the [list of requirements](#list-of-automerge-requirements). In the case of
a brand new package (instead of an update), the bot will comment on any problems
or approve the request quickly, but will wait 3 days before merging it.

If the requirements are not met, the bot will comment to say which requirements
were not met. Either update the package to meet the automerge requirements and
retrigger the pull request (by the Registrator bot or the web interface), or
comment and ask for a manual merge.

To report issues with AutoMerge, please open an issue on the [RegistryCI
repo](https://github.com/JuliaRegistries/RegistryCI.jl), not on this repo (the
General registry).

## List of automerge requirements

### New packages

1. [Naming conventions](#julia-package-naming-conventions)
    * name should match r"^[A-Z]\w*[a-z][0-9]?$"
        * i.e. starts with a capital letter, ASCII alphanumerics only, ends in
          lowercase
    * name should be not too short
        * at least five letters
        * you can register names shorter than this, but doing so requires
          someone to approve
    * Repo URL ends with `/$name.jl.git` where `name` is the package name
2. [Standard initial version number](#version-numbers)
   * one of `0.0.1`, `0.1.0`, `1.0.0`
3. [Compat for all dependencies](#compatibility-requirements)
   * all `[deps]` should also have `[compat]` entries (and Julia itself)
   * all `[compat]` entries should have upper bounds
4. Package can be installed and loaded
   * given the proposed changes to the registry, can we resolve and install the
     package?
   * once it’s been installed, can we load the code?

### New versions of existing packages

1. [Sequential version number](#version-numbers)
    * if the last version was 1.2.3 then the next can be 1.2.4, 1.3.0 or 2.0.0
2. [Compat for all dependencies](#compatibility-requirements)
    * all `[deps]` should also have `[compat]` entries
    * all `[compat]` entries should have upper bounds
    * Julia itself should have a `[compat]` entry with an upper bound, and
      moreover a patch release cannot narrow the supported range of versions of
      Julia
3. Version can be installed and loaded
   * given the proposed changes to the registry, can we resolve and install the
     package?
   * once it’s been installed, can we load the code?

## Discussion and explanation of automerge requirements

### Julia Package naming conventions

The guidelines for naming packages are listed
[here](https://julialang.github.io/Pkg.jl/v1/creating-packages/#Package-naming-guidelines-1)
in the package manager's documentation. If a new package's name does not adhere
to those guidelines or could otherwise cause confusion, maintainers of the
General registry or the Julia community might comment on the pull request to ask
that the name be changed, or why the usual conventions were not used in this
case. Additionally, the automerge bot will not merge pull requests corresponding
to new packages whose names do not meet certain requirements. The package can
still be added by manually merging the request, however, and updates to the
package will still be automerged as usual.

If you think that your package should not follow those conventions for some
reason or another, just explain why. Otherwise, it is often a good idea to just
rename the package-- it is more disruptive to do so after it is already
registered, and sticking to the conventions makes it easier for users to
navigate Julia's many varied packages.

As long as the package is not yet registered, renaming the package from
`OldName.jl` to `NewName`.jl is reasonably straightforward:

* Rename the GitHub repository to `NewName.jl`
* Rename the file `src/OldName.jl` to `src/NewName.jl`
* Rename the top-level module to `NewName`
* Update tests to load the package by its new name, and update the readme.

### Version numbers

It is standard that new Julia packages start at version `0.1` or `1.0`, and that
new versions of packages do not skip version numbers. A package might go from
`0.1` to `0.1.1`, `0.2` or `1.0`, but not to `0.1.2` (which skips `0.1.1`) or to
`0.3` (which skips `0.2`), or to `2.0` (which skips `1.0`).

If a package skips a version number, the automerge bot will not merge the pull
request. If you have a reason to skip the version number, just say so; the
request can still be merged manually.

### Compatibility requirements

Every Julia package has at least one (implicit) dependency: the Julia language
itself. It is recommended that for every dependency, each package declares what
versions of the dependency it is compatible with, and this is a requirement for
automerging. This is done in the package's `Project.toml` file, and is
documented [here](https://julialang.github.io/Pkg.jl/v1/compatibility/) in the
Julia package manager's documentation.

Packages should declare the Julia version they are compatible with, by
e.g.

```toml
[compat]
julia = "1"
```

which declares that the package is compatible with all Julia versions from 1.0
onwards, until but not including, a possible 2.0 in the future. The automerge
bot will not merge packages that do not provide upper bounds for every package.
This means that, e.g.

```toml
[compat]
julia = ">= 1.3"
```

would not be sufficient. This is because such a statement declares that the
version of the package being registered is compatible with every possible future
version of Julia after (and including) `1.3`, but that is impossible to know.
Instead,

```toml
[compat]
julia = "1.3"
```

declares compatibility with Julia `1.3`, `1.4`, etc., including any release after
`1.3` but strictly before `2.0`, since none of those releases should break code
relying on the public API of Julia 1.3. (To specify only `1.3` and its patch
releases, use `julia= "~1.3"`.)

To claim compatibility with
more than one breaking release of a package, add multiple entries such as

```toml
[compat]
StaticArrays = "0.10, 0.11"
```

This attests that the package is compatible with both versions of `StaticArrays`
even though, according to semantic versioning (which is discussed in the `Pkg`
documentation
[here](https://julialang.github.io/Pkg.jl/dev/compatibility/#Version-specifier-format-1)),
the `0.11` release could have broken code relying on the `0.10` release's public
API.

See [the `Pkg`
documentation](https://julialang.github.io/Pkg.jl/v1/compatibility/) for more on
how to specify `compat` entries.

Note that standard libraries are currently coupled to the Julia version, and
don't have separate version numbers. So while they are declared as dependencies,
they don't need separate entries in the `compat` section from Julia itself.

### Merge conflicts

If the pull request against the General registry has merge conflicts with the
General registry itself, the pull request cannot be merged. In this case, just
retrigger the Registrator.jl bot (either add another comment with
"@JuliaRegistrator register", or use the web interface), and it will update the
pull request.
