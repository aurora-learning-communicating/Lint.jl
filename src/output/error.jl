mutable struct LintError
    rule_type::Type{<:rules.LintRule}
    message::String
    template_code::String
    file::String
    line::Int64
    column::Int64
    is_disabled::Bool
    offset::Int64

    LintError(rule_type::Type{<:rules.LintRule}, message::String) = new(rule_type, message, "", "", 0, 0, false, 0)
end

function is_recommendation(report::LintError)::Bool
    return report.rule_type isa rules.RecommendationLintRule
end

function is_violation(report::LintError)::Bool
    return report.rule_type isa rules.ViolationLintRule
end

function is_fatal(report::LintError)::Bool
    return report.rule_type isa rules.FatalLintRule
end