import CSTParser

function generic_check!(::Type{RuleType}, expr::EXPR, template_code::String, error_message::String) where RuleType <: LintRule
    if is_match_template_code(expr, template_code)
        seterror!(expr, LintRuleReport{RuleType}(RuleType(), error_message))
    end
end

function generic_check!(rule_type::Type{LintRule}, expr::EXPR, template_code::String, error_message::String)
    generic_check!(rule_type, expr, template_code, error_message)
end

function generic_check!(rule_type::Type{LintRule}, expr::EXPR, template_code::String)
    generic_check!(rule_type, expr, template_code)
end

function generic_check!(rule_type::Type{RuleType}, expr::EXPR, template_code::String) where RuleType <: LintRule
    keyword = first(split(template_code), ['(', '{', ' '])
    return generic_check!(rule_type, expr, template_code, "`$(keyword)` should be used with extreme caution")
end


# original: `does_match`
function is_match_template_code(expr::EXPR, template_code::String)::Bool
    return match_pattern(expr, get_oracle_cst(template_code))
end



const check_cache = Dict{String, EXPR}()

# original: `get_oracle_ast`
function get_oracle_cst(template_code::String)::EXPR
    # get!(() -> CSTParser.parse(template_code), check_cache, template_code)
    result = get(check_cache, template_code, nothing)

    return if isnothing(result)
        cst = CSTParser.parse(template_code)
        check_cache[template_code] = cst
        cst
    else
        result
    end
end

function seterror!(expr::EXPR, exception::Exception)
    if !hasmeta(expr)
        expr.meta = LintMeta()
    end

    expr.meta.error = exception
end