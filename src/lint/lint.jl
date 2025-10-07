module lint

import CSTParser: EXPR, parse
import InteractiveUtils: subtypes
import ..rules
import ..rules: LintRule
import ..extension
import ..utils: FileExclusion
import ..constants: head, marker as marker, placeholder
import ..checks: check!, Check
import ..output: LintError
import .marker: Marker

struct Context
    rules::Vector{DataType}
    exclusions::Vector{FileExclusion}

    Context(types::Vector{DataType}) = new(types, FileExclusion[])
    Context() = begin
        types = vcat(
            subtypes(rules.RecommendationLintRule),
            subtypes(rules.ViolationLintRule),
            subtypes(rules.FatalLintRule))

        new(types, FileExclusion[])
    end
end

include("check_all.jl")
include("collect_error.jl")
include("run.jl")

end