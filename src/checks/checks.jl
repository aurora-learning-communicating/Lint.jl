module checks

import ..rules: ViolationLintRule, RecommendationLintRule, FatalLintRule, ASTLintRule, LintRule
import ..utils: caution
import ..constants: marker, head, placeholder
import ..constants.marker: Marker

import ..matching
import ..extension
import ..output: LintError

import CSTParser: EXPR

include("extended_rules.jl")
include("generic_check.jl")
include("check.jl")

end