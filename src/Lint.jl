module Lint # Core Module here

include("utils/utils.jl")
include("constants/constants.jl")
include("rules/rules.jl")


include("output/output.jl")
include("matching/matching.jl")
include("extension/extension.jl")

include("checks/checks.jl")
include("lint/lint.jl")

end