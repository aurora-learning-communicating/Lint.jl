abstract type LintRule end
abstract type ASTLintRule <: LintRule end
abstract type RecommendationLintRule <: ASTLintRule end
abstract type ViolationLintRule <: ASTLintRule end
abstract type FatalLintRule <: ASTLintRule end

struct AsyncRule <: ViolationLintRule end
struct CcallRule <: RecommendationLintRule end
struct InitializingWithFunctionRule <: ViolationLintRule end
struct FinalizerRule <: RecommendationLintRule end
struct CFunctionRule <: RecommendationLintRule end
struct UnlockRule <: RecommendationLintRule end
struct YieldRule <: RecommendationLintRule end
struct SleepRule <: RecommendationLintRule end
struct InboundsRule <: RecommendationLintRule end
struct ArrayWithNoTypeRule <: ViolationLintRule end
struct ThreadsRule <: RecommendationLintRule end
struct GeneratedRule <: FatalLintRule end
struct SyncRule <: RecommendationLintRule end
struct RemovePageRule <: ViolationLintRule end
struct TaskRule <: ViolationLintRule end
struct ErrorExceptionRule <: ViolationLintRule end
struct ErrorRule <: ViolationLintRule end
struct UnsafeRule <: ViolationLintRule end
struct InRule <: ViolationLintRule end
struct HasKeyRule <: ViolationLintRule end
struct EqualRule <: ViolationLintRule end
struct UvRule <: ViolationLintRule end
struct SplattingRule <: RecommendationLintRule end
struct UnreachableBranchRule <: ViolationLintRule end
struct StringInterpolationRule <: ViolationLintRule end
struct RelPathAPIUsageRule <: ViolationLintRule end
struct InterpolationInSafeLogRule <: RecommendationLintRule end
struct UseOfStaticThreads <: ViolationLintRule end
struct LogStatementsMustBeSafe <: FatalLintRule end
struct AssertionStatementsMustBeSafe <: FatalLintRule end
struct NonFrontShapeAPIUsageRule <: FatalLintRule end
struct MustNotUseShow <: FatalLintRule end
struct NoinlineAndLiteralRule <: FatalLintRule end
struct NoReturnInAnonymousFunctionRule <: FatalLintRule end
struct NoImportRule <: ViolationLintRule end
struct NotImportingRAICodeRule <: ViolationLintRule end



import InteractiveUtils: subtypes

const all_rules = Ref{Vector{Type{LintRule}}}(
    vcat(
        subtypes(RecommendationLintRule),
        subtypes(ViolationLintRule),
        subtypes(FatalLintRule)
    )
)

function get_all_rules()::Vector{Type{LintRule}}
    return all_rules[]
end