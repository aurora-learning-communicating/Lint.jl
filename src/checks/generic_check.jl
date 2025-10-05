function generic_check!(rule_type::Type{T}, expr::EXPR, template_code::String, error_message::String) where T <: LintRule
    if match.match_template(expr, template_code)
        extension.seterror!(expr, LintError(rule_type, error_message))
    end
end

function generic_check!(rule_type::Type{T}, expr::EXPR, template_code::String) where T <: LintRule
    keyword = first(split(template_code, ['(', '{', ' ']))
    return generic_check!(rule_type, expr, template_code, "`$(keyword)` should be used with extreme caution")
end
