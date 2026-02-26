# Package naming guidelines

Package names should be sensible to most Julia users, *even to those who are not domain experts*.
The following guidelines apply to the `General` registry but may be useful for other package
registries as well.

Since the `General` registry belongs to the entire community, people may have opinions about
your package name when you publish it, especially if it's ambiguous or can be confused with
something other than what it is. Usually, you will then get suggestions for a new name that
may fit your package better.

1. Avoid jargon. In particular, avoid acronyms unless there is minimal possibility of confusion.

     * It's ok for package names to contain `DNA` if you're talking about the DNA, which has a universally agreed upon definition.
     * It's more difficult to justify package names containing the acronym `CI` for instance, which may mean continuous integration, confidence interval, etc.
     * If there is risk of confusion it may be best to disambiguate an acronym with additional words such as a lab group or field.
     * If your acronym is unambiguous, easily searchable, and/or unlikely to be confused across domains a good justification is often enough for approval.
2. Avoid using `Julia` in your package name or prefixing it with `Ju`.

     * It is usually clear from context and to your users that the package is a Julia package.
     * Package names already have a `.jl` extension, which communicates to users that `Package.jl` is a Julia package.
     * Having Julia in the name can imply that the package is connected to, or endorsed by, contributors
       to the Julia language itself.
3. Packages that provide most of their functionality in association with a new type should have pluralized
   names.

     * `DataFrames` provides the `DataFrame` type.
     * `BloomFilters` provides the `BloomFilter` type.
     * In contrast, `JuliaParser` provides no new type, but instead new functionality in the `JuliaParser.parse()`
       function.
4. Err on the side of clarity, even if clarity seems long-winded to you.

     * `RandomMatrices` is a less ambiguous name than `RndMat` or `RMT`, even though the latter are shorter.
     *  Generally package names should be at least 5 characters long not including the `.jl` extension
5. A less systematic name may suit a package that implements one of several possible approaches to
   its domain.

     * Julia does not have a single comprehensive plotting package. Instead, `Gadfly`, `PyPlot`, `Winston`
       and other packages each implement a unique approach based on a particular design philosophy.
     * In contrast, `SortingAlgorithms` provides a consistent interface to use many well-established
       sorting algorithms.

6. Packages that wrap external libraries or programs can be named after those libraries or programs. However, as of February 2026, we now request that these packages indicate in their package name (in some way) that they are wrapping an external library or program. For example, consider a hypothetical package that wraps a library or program named `ABC`. Possible names for the Julia package might include:
     * `ABCWrapper`
     * `ABCInterface`
     * `ExternalABC`
     * `ABCLibrary`
     * `LibABC`

7. Avoid naming a package closely to an existing package
     * `Websocket` is too close to `WebSockets` and can be confusing to users. Rather use a new name such as `SimpleWebsockets`.

8. Avoid using a distinctive name that is already in use in a well known, unrelated project.
     * Don't use the names `Tkinter.jl`, `TkinterGUI.jl`, etc. for a package that is unrelated
       to the popular `tkinter` python package, even if it provides bindings to Tcl/Tk.
       A package name of `Tkinter.jl` would only be appropriate if the package used Python's
       library to accomplish its work or was spearheaded by the same community of developers.
     * It's okay to name a package `HTTP.jl` even though it is unrelated to the popular rust
       crate `http` because in most usages the name "http" refers to the hypertext transfer
       protocol, not to the `http` rust crate.
     * It's okay to name a package `OpenSSL.jl` if it provides an interface to the OpenSSL
       library, even without explicit affiliation with the creators of the OpenSSL (provided
       there's no copyright or trademark infringement etc.)

9. Packages should follow the [Stylistic Conventions](https://docs.julialang.org/en/v1/manual/variables/#Stylistic-Conventions).
     * The package name should begin with a capital letter and word separation is shown with upper camel case
     * Only ASCII characters are allowed in a package name
     * Packages that provide the functionality of a project from another language should use the Julia convention
     * Packages that [provide pre-built libraries and executables](https://docs.binarybuilder.org/stable/jll/) can keep their original name, but should get `_jll`as a suffix. For example `pandoc_jll` wraps pandoc. However, note that the generation and release of most JLL packages is handled by the [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil) system.

10. For the complete list of rules for automatic merging into the General registry, see [the AutoMerge guidelines](https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/).
