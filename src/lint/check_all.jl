function check_all!(expr::EXPR, markers::Dict{Marker, String}, context::Context)
    if expr.head == marker.m_const
        markers[marker.m_const] = extension.fetch_value(expr, head.identifier)::String
    end

    if expr.head == marker.m_function
        markers[marker.m_function] = extension.fetch_value(expr, head.identifier)::String
    end

    if expr.head == marker.m_macro
        markers[marker.m_macro] = extension.fetch_value(expr, head.identifier)::String
    end

    if expr.head == marker.macrocall
        id = extension.fetch_value(expr, head.identifier)::String
        if !isnothing(id)
            markers[marker.macrocall] = id
        end
    end

    if expr.head isa EXPR && expr.head.head == head.operator && expr.head.val == "->"
        markers[marker.anonymous_function] = "anonymous"
    end

    for T in filter(rule_type -> rule_type <: rules.ASTLintRule, context.rules)
        check!(T, expr, markers) # TODO: 参数不匹配，需要接口定义

        if extension.haserror(expr) && expr.meta.error isa LintError
            lint_report = expr.meta.error

            value_of_filename = get(markers, marker.filename, nothing)
            if !isnothing(value_of_filename)
                lint_report.file = value_of_filename
            end
        end
    end

    expr_args = expr.args
    if !isnothing(expr_args)
        for arg in expr_args
            check_all!(arg, markers, context)
        end
    end

    # cleaning
    if expr.head == marker.m_const
        delete!(markers, marker.m_const)
    end

    if expr.head == marker.m_function
        delete!(markers, marker.m_function)
    end

    if expr.head == Symbol(marker.macrocall)
        delete!(markers, marker.macrocall)
    end

    if expr.head == Symbol(marker.m_macro)
        delete!(markers, marker.macro)
    end

    if expr.head isa EXPR && expr.head.head == head.operator && expr.head.val == "->"
        delete!(markers, marker.anonymous_function)
    end

    if expr.head == marker.m_do
        delete!(markers, marker.anonymous_function)
    end
end