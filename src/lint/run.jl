function run(rootpath::String, context::Context)::Vector{LintError}
    file_content = read(rootpath, String)
    cst = parse(file_content, true)
    lines = split(file_content, "\n")

    markers::Dict{Marker, String} = Dict(marker.filename => rootpath)
    check_all!(cst, markers, context)

    reports = LintError[]
    errors = Pair{Int, EXPR}[]

    collect_lint_error!(cst, false, errors)
    
    for (offset, expr) in errors
        if extension.haserror(expr)
            lint_rule_error = expr.meta.error::LintError
            lint_rule_error.offset = offset

            line_number, column, _ = offset_to_line(lint_rule_error.offset + 1, lines)
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

function offset_to_line(offset::Int, lines::Vector{<:AbstractString})::Tuple{Int, Int, Union{Nothing, String}}
    error("not implement yet")
end