module constants

import CSTParser: EXPR

include("head.jl")
include("marker.jl")
include("placeholder.jl")

function is_named_variable(expr::EXPR)::Bool
    expr_head = expr.head
    expr_val = expr.val

    return !isnothing(expr_val) &&
        expr_head == head.identifier &&
        expr_val != placeholder.to_string(placeholder.vararg_variable) &&
        startswith(expr_val, placeholder.to_string(placeholder.variable)) &&
        length(expr_val) > length(placeholder.to_string(placeholder.variable))
end

function is_string(expr::EXPR)::Bool
    return expr.head == head.string_literal && expr.val == placeholder.string
end

function is_string_with_interpolation(expr::EXPR)::Bool
    return expr.head == head.string_literal && expr.val == placeholder.string_interpolation
end

function is_variable(expr::EXPR)::Bool
    return expr.head == head.identifier &&
        expr.val == placeholder.variable
end

function is_vararg_variable(expr::EXPR)::Bool
    return expr.head == head.identifier && expr.val == placeholder.vararg_variable
end

end