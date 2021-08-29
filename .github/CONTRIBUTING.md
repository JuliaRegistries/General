# Contribution guidelines

Anyone can help improve the General registry! Here's a few ways.

## As a package author

You can register your package!
See [Registering a package in General](https://github.com/JuliaRegistries/General#registering-a-package-in-general) in the README for how to do that.
The [FAQ](FAQ) helps answer many more questions, like [do I need to register a package to install it?](https://github.com/JuliaRegistries/General#do-i-need-to-register-a-package-to-install-it), [should I register my package?](https://github.com/JuliaRegistries/General#should-i-register-my-package), and more.

* Please be aware of the [package naming guidelines](https://pkgdocs.julialang.org/dev/creating-packages/#Package-naming-guidelines-1)
* We strongly encourage authors to follow best practices like having documentation (or a descriptive README), tests, and continuous integration.

## As a Julia community member

You (yes, you!) can help General be the best registry it can be.

The first step is to check out new package registrations.
They are filed under the ["new package" label](https://github.com/JuliaRegistries/General/pulls?q=is%3Apr+is%3Aopen+label%3A%22new+package%22), and a automatic feed posts them in the `#new-packages-feed` channel in the [community Slack](https://julialang.org/slack/).


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


Besides helping out with new package registrations directly, there are other ways to help out as well.

* You can improve [General's README](https://github.com/JuliaRegistries/General#general), the [RegistryCI documentation](https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/), or these guidelines!
* You can add new checks to AutoMerge (in [RegistryCI](RegistryCI)) or improve existing ones.
* You can address open issues in [General](https://github.com/JuliaRegistries/General/issues), [RegistryCI](https://github.com/JuliaRegistries/RegistryCI.jl/issues), [Registrator.jl](https://github.com/JuliaRegistries/Registrator.jl/issues).
* You can write blog posts and documentation to help folks get started with writing documentation, tests, and setting up CI for their own packages, and find appropriate places to link to it and help out new package authors. 

Additionally, if you have elevated permissions to General, there's a few more things you can do:

* You can merge PRs that have the _needs to be manually merged in 3 days_ label once the requisite waiting period has passed, assuming there are no outstanding objections in the PR comments.
* You can give other contributors [triage](permissions)-level access so they can apply labels to PRs, or write-level permissions to merge PRs.


[FAQ]: https://github.com/JuliaRegistries/General#faq]
[naming-guidelines]: https://pkgdocs.julialang.org/dev/creating-packages/#Package-naming-guidelines-1
[permissions]: https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-permission-levels-for-an-organization#permission-levels-for-repositories-owned-by-an-organization
[RegistryCI]: https://github.com/JuliaRegistries/RegistryCI.jl/
