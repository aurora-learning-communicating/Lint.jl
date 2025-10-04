struct LintContext
    rules::Vector{Type{LintRule}}
    exclusions::Vector{FileExclusion}

    LintContext(types::Vector{Type{LintRule}}) = new(types, FileExclusion[])
    LintContext() = new(get_all_rules(), FileExclusion[])
end


function lint(rootpath::String, context::LintContext)::Vector{LintError}
    file_content = read(rootpath, String)
    cst = CSTParser.parse(file_content, true)
    lines = split(file_content, "\n")

    markers::Dict{Marker, String} = Dict(marker_filename => rootpath)
    check_all!(cst, markers, context)

    reports = LintError[]
    errors = Pair{Int, EXPR}[]

    collect_lint_error!(cst, false, errors)
    
    for (offset, expr) in errors
        if haserror(expr)
            lint_rule_error = expr.meta.error
            lint_rule_error.offset = offset

            line_number, column, annotation_line = offset_to_line(lint_rule_error.offset + 1, lines)
            lint_rule_error.line = line_number
            lint_rule_error.column = column

            #= # If the annotation is to disable lint,
            if annotation_line == "lint-disable-line"
                # then we disable it.
            elseif !isnothing(annotation_line) && startswith("lint-disable-line: $(lint_rule_report.msg)", annotation_line)
                # then we disable it.
            else
                # Else we record it.
                push!(lint_rule_reports, lint_rule_report)
            end =#

            push!(reports, lint_rule_error)
        end
    end
    
    return reports
end


function ast_rules(context::LintContext)::Vector{Type{ASTLintRule}}
    return filter(rule_type -> rule_type <: ASTLintRule, context.rules)
end

function check_all!(expr::EXPR, markers::Dict{Marker, String}, context::LintContext)
    if expr.head == Symbol(marker_const)
        markers[marker_const] = fetch_value(expr, head_identifier)
    end

    if expr.head == Symbol(marker_function)
        markers[marker_function] = fetch_value(expr, head_identifier)
    end

    if expr.head == Symbol(marker_macro)
        markers[marker_macro] = fetch_value(expr, head_identifier)
    end

    if expr.head == Symbol(marker_macrocall)
        id = fetch_value(expr, head_identifier)
        if !isnothing(id)
            markers[marker_macrocall] = id
        end
    end

    if expr.head isa EXPR && expr.head.head == Symbol(head_operator) && expr.head.val == "->"
        markers[marker_anonymous_function] = "anonymous"
    end

    for T in ast_rules(context)
        check!(T, expr, markers)

        if haserror(expr) && expr.meta.error isa LintError
            lint_report = expr.meta.error

            value_of_filename = get(markers, marker_filename, nothing)
            if !isnothing(value_of_filename)
                lint_report.file = value_of_filename
            end
        end
    end

    if !isnothing(expr.args)
        for arg in expr.args
            check_all!(arg, markers, context)
        end
    end

    # cleaning
    if expr.head == Symbol(marker_const)
        delete!(markers, marker_const)
    end

    if expr.head == Symbol(marker_function)
        delete!(markers, marker_function)
    end

    if expr.head == Symbol(marker_macrocall)
        delete!(markers, marker_macrocall)
    end

    if expr.head == Symbol(marker_macro)
        delete!(markers, marker_macro)
    end

    if expr.head isa EXPR && expr.head.head  == Symbol(head_operator) && expr.head.val == "->"
        delete!(markers, marker_anonymous_function)
    end

    if expr.head == marker_do
        delete!(markers, marker_anonymous_function)
    end
end

function collect_lint_error!(expr::EXPR, isquoted::Bool, errors = Pair{Int, EXPR}[], position::Int = 0)
    if haserror(expr)
        push!(errors, position => expr)
    end

    for child_expr in expr
        collect_lint_error!(child_expr, isquoted, errors, position)
        position += child_expr.fullspan
    end
end