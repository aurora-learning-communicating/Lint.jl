function collect_lint_error!(expr::EXPR, isquoted::Bool, errors = Pair{Int, EXPR}[], position::Int = 0)
    if extension.haserror(expr)
        push!(errors, position => expr)
    end

    for child_expr in expr
        collect_lint_error!(child_expr, isquoted, errors, position)
        position += child_expr.fullspan
    end
end