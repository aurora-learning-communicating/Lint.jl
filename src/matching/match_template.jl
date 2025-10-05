const cache = Dict{String, EXPR}()

function match_template(expr::EXPR, template_code::String)::Bool
    return match_pattern(expr, get_oracle_cst(template_code))
end

function get_oracle_cst(template_code::String)::EXPR
    result = get(cache, template_code, nothing)

    return if isnothing(result)
        cst = parse(template_code)
        cache[template_code] = cst
        cst
    else
        result
    end
end