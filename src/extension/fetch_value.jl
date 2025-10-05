function fetch_value(
    expr::EXPR, 
    tag::head.HeadType, 
    should_get_value::Bool=true, 
    recursion_depth::Int = -1, 
    skip_head::Bool = false)::Union{Nothing, String, EXPR}

    if expr.head == tag && !skip_head
        return if should_get_value
            expr.val
        else
            expr
        end
    end

    expr_args = expr.args
    if isnothing(expr_args)
        return nothing
    end

    if iszero(recursion_depth)
        return nothing
    end

    for arg in expr_args
        value = fetch_value(arg, tag, should_get_value, recursion_depth - 1, false)

        if !isnothing(value)
            return value
        end
    end

    return nothing
end
