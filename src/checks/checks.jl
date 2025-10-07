module checks

import ..rules: ViolationLintRule, RecommendationLintRule, FatalLintRule, ASTLintRule, LintRule
import ..utils: caution
import ..constants: marker, head, placeholder
import ..constants.marker: Marker

import ..matching
import ..extension
import ..output: LintError

import CSTParser: EXPR

struct Check{T <: LintRule}
    rule_type::Type{T}
    markers::Dict{Marker, String}

    function Check(rule_type::Type{T}, markers::Dict{Marker, String}) where T <: LintRule
        new{T}(rule_type, markers)
    end
end

include("extended_rules.jl")
include("generic_check.jl")
include("check.jl")

end