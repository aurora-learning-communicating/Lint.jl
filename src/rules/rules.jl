module rules

abstract type LintRule end
abstract type ASTLintRule <: LintRule end
abstract type RecommendationLintRule <: ASTLintRule end
abstract type ViolationLintRule <: ASTLintRule end
abstract type FatalLintRule <: ASTLintRule end

end