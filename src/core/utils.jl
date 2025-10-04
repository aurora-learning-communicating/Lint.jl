headof(x::EXPR) = x.head
valof(x::EXPR) = x.val
parentof(x::EXPR) = x.parent
errorof(x::EXPR) = errorof(x.meta)
errorof(x) = x
haserror(m::LintMeta) = m.error !== nothing
haserror(x::EXPR) = hasmeta(x) && haserror(x.meta)
hasmeta(x::EXPR) = x.meta isa LintMeta

caution(keyword::String) = "`$keyword` should be used with extreme caution"

function is_safe_macro_call(expr::EXPR)::Bool
    first_condition = () -> expr.head == Symbol(head_macrocall) && expr.args[1].head == Symbol(head_identifier) && expr.args[1].val == "@safe"
    second_condition = () -> expr.head == Symbol(head_macrocall) && 
        expr.args[1].head isa EXPR && 
        expr.args[1].head.head == Symbol(head_operator) &&
        expr.args[1].args[1].args[1].val == "SafeLogging" &&
        expr.args[1].args[2].args[1].val == "@safe"

    return first_condition() || second_condition()
end

function is_safe_literal(expr::EXPR)::Bool
    return expr.head in map(Symbol, [head_nothing, head_integer, head_float, head_true, head_false, head_hexint, head_binint, head_char, head_octint])
end

function is_literal(expr::EXPR)::Bool
    return expr.head in map(Symbol, [head_nothing, head_integer, head_float, head_true, head_false, head_hexint, head_binint, head_char, head_octint, head_string_literal])
end

function is_identifier(expr::EXPR)::Bool
    return expr.head == Symbol(head_identifier)
end

function is_splatting(expr::EXPR)::Bool
    return expr.head isa EXPR && expr.head.head == Symbol(head_operator) && expr.head.val == "..."
end

function is_literal_or_identifier_or_splatting(expr::EXPR)::Bool
    return if expr.head == Symbol(head_parameters) || expr.head == Symbol(head_kw)
        all(is_literal_or_identifier_or_splatting, expr.args)
    else
        is_literal(expr) || is_identifier(expr) || is_splatting(expr)
    end
end

function all_arguments_safe(expr::EXPR; skip_first_arg::Bool = false)::Bool
    first_index = if skip_first_arg
        4
    else
        2
    end

    for arg in expr.args[first_index:end]
        # This is safe
        if is_safe_macro_call(arg) || is_safe_literal(arg)
            continue
        elseif arg.head isa EXPR && arg.head.head == Symbol(head_operator) && arg.head.val == "=" &&
                (is_safe_macro_call(arg.args[2]) || is_safe_literal(arg.args[2]))
            continue
        else
            return false
        end
    end

    return true
end

function all_arguments_literal_or_identifier(expr::EXPR)::Bool
    return all(is_literal_or_identifier_or_splatting, expr.args[2:end])
end

function fetch_value(
    expr::EXPR, 
    tag::HeadType, 
    should_get_value::Bool=true, 
    recursion_depth::Int = -1, 
    skip_head::Bool = false)::Union{Nothing, String, EXPR}

    if headof(expr) == Symbol(tag) && !skip_head
        return if should_get_value
            expr.val
        else
            expr
        end
    else
        if isnothing(expr.args)
            return nothing
        end

        if iszero(recursion_depth)
            return nothing
        end

        for arg in expr.args
            value = fetch_value(arg, tag, should_get_value, recursion_depth - 1, false)

            if !isnothing(value)
                return value
            end
        end

        return nothing
    end
end

function offset_to_line(offset::Integer, lines::Vector{String})::Tuple{Int, Int, Union{Nothing, String}}
    if offset < 0
        throw(BoundsError("source", offset))
    end

    # TODO:
end