function is_safe_macro_call(expr::EXPR)::Bool
    expr_head = expr.head
    expr_args = expr.args

    if isnothing(expr_args)
        return false
    end

    first_condition = () -> expr_head == head.macrocall &&
        expr_args[1].head == head.identifier &&
        expr_args[1].val == "@safe"
    
    second_condition = () -> begin
        expr_head == head.macrocall && 
        expr_args[1].head isa EXPR && expr_args[1].head.head == head.operator &&
        expr_args[1].args[1].args[1].val == "SafeLogging" &&
        expr_args[1].args[2].args[1].val == "@safe"
    end

    return first_condition() || second_condition()
end

function is_safe_literal(expr::EXPR)::Bool
    predicate = head -> head == expr.head
    collections = [
        head.h_nothing, 
        head.integer, 
        head.float, 
        head.h_true, 
        head.h_false,
        head.hexint,
        head.binint,
        head.char,
        head.octint]

    return any(predicate, collections)
end

function is_literal(expr::EXPR)::Bool
    predicate = value -> head.to_symbol(value) == expr.head
    collections = [
        head.h_nothing,
        head.integer,
        head.float,
        head.h_true,
        head.h_false,
        head.hexint,
        head.binint,
        head.char,
        head.octint,
        head.string_literal
    ]
    
    return any(predicate, collections)
end

function is_identifier(expr::EXPR)::Bool
    return expr.head == head.identifier
end

function is_splatting(expr::EXPR)::Bool
    return expr.head isa EXPR && expr.head.head == head.operator && expr.head.val == "..."
end

function is_literal_or_identifier_or_splatting(expr::EXPR)::Bool
    return if expr.head == head.parameters || expr.head == head.kw
        all(is_literal_or_identifier_or_splatting, expr.args::Vector{EXPR})
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

    expr_args = expr.args::Vector{EXPR}

    for arg in expr_args[first_index:end]
        # This is safe
        #= if is_safe_macro_call(arg) || is_safe_literal(arg)
            continue
        elseif arg.head isa EXPR && arg.head.head == head.operator && arg.head.val == "=" &&
                (is_safe_macro_call(arg.args[2]) || is_safe_literal(arg.args[2]))
            continue
        else
            return false
        end =#

        if is_safe_macro_call(arg) || is_safe_literal(arg)
            continue
        else
            arg_head = arg.head
            arg_of_arg = (arg.args::Vector{EXPR})[2]

            if arg_head isa EXPR && 
               arg_head.head == head.operator && 
               arg_head.val == "=" &&
               (is_safe_macro_call(arg_of_arg) || is_safe_literal(arg_of_arg))
               continue
            else
                return false
            end
        end
    end

    return true
end

function all_arguments_literal_or_identifier(expr::EXPR)::Bool
    expr_args = (expr.args)::Vector{EXPR}
    return all(is_literal_or_identifier_or_splatting, expr_args[2:end])
end
