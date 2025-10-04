import Base: append!, ==

mutable struct LintResult
    file_count::Integer
    violation_count::Integer
    recommendation_count::Integer
    fatal_violations_count::Integer
    linted_files::Vector{String}
    printout_count::Integer
    lint_rule_reports::Vector{LintRuleReport}
    branch::String # git branch
end

function append!(left::LintResult, right::LintResult)
    left.file_count += right.file_count
    left.violation_count += right.violation_count
    left.recommendation_count += right.recommendation_count
    left.fatal_violations_count += right.fatal_violations_count

    append!(left.linted_files, right.linted_files)
    append!(left.lint_rule_reports, right.lint_rule_reports)

    left.printout_count += right.printout_count
end

function ==(left::LintResult, right::LintResult)::Bool
    return left.file_count == right.file_count &&
           left.violation_count == right.violation_count &&
           left.recommendation_count == right.recommendation_count &&
           left.fatal_violations_count == right.fatal_violations_count &&
           left.linted_files == right.linted_files &&
           left.lint_rule_reports == right.lint_rule_reports
end

function is_already_linted(result::LintResult, filename::String)::Bool
    return filename in result.linted_files
end

function has_values(result::LintResult, file_count::Integer, violation_count::Integer, recommendation_count::Integer)::Bool
    return result.file_count == file_count &&
           result.violation_count == violation_count &&
           result.recommendation_count == recommendation_count
end