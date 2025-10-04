function is_placeholder_named_variable(expr::EXPR)::Bool
    return expr.head == Symbol(head_identifier) &&
            expr.val != String(placeholder_vararg_variable) &&
            startswith(expr.val, String(placeholder_variable)) &&
            length(expr.val) > length(String(placeholder_variable))
end

function is_placeholder_string(expr::EXPR)::Bool
    return expr.head == Symbol(head_string_literal) && expr.val == String(placeholder_string)
end

function is_placeholder_string_with_interpolation(expr::EXPR)::Bool
    return expr.head == Symbol(head_string_literal) && expr.val == String(placeholder_string_interpolation)
end

function is_placeholder_variable(expr::EXPR)::Bool
    return expr.head == Symbol(head_identifier) && 
            expr.val == String(placeholder_variable)
end

function is_placeholder_variable_star(expr::EXPR)::Bool
    return expr.head == Symbol(head_identifier) && expr.val == String(placeholder_vararg_variable)
end
