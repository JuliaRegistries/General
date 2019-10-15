module AutoMerge

import Dates
import GitHub
import HTTP
import LibGit2
import Pkg
import TimeZones

include("types.jl")

include("public.jl")

include("api_rate_limiting.jl")
include("cron.jl")
include("github.jl")
include("guidelines.jl")
include("new-package.jl")
include("new-version.jl")
include("pull-requests.jl")
include("semver.jl")
include("util.jl")

end # module
