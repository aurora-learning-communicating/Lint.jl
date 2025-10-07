begin
    import Lint
    import Lint.checks: check!, Check
    import Lint.checks: AsyncRule

    import Lint: constants, lint
    import .constants.marker: Marker
    import .constants: placeholder

    import Lint.matching: match_template, match_structure, match_pattern
    import Lint.lint: Context
    import Lint.checks: Check
    
    import CSTParser
end

#= check = Check(AsyncRule, Dict{Marker, String}())
code = read("test/template.jl", String)
cst = CSTParser.parse(code)
check!(check, cst)
println(cst)

# if match
cst = CSTParser.parse(code)
match_template(cst, "@async $(placeholder.variable)") =#

# test if match_template
let code = "@async println(\"hello\")"
    cst = CSTParser.parse(code)
    template = "@async $(placeholder.variable)"

    println(match_template(cst, template))
end


let code = """
    @async begin
        println("hello")
    end
    """

    cst = CSTParser.parse(code)
    @info cst
    template1 = "@async $(placeholder.variable)"
    println(match_template(cst, template1))

    template2 = "@async $(placeholder.vararg_variable)"
    @info template2
    println(match_template(cst, template2))
end

let code = "println(1, 2, 3)"
    cst = CSTParser.parse(code)
    @info cst

    template1 = "println($(placeholder.variable))"
    println(match_template(cst, template1))

    template2 = "println($(placeholder.vararg_variable))"
    println(match_template(cst, template2))
end


let code = "println(1, 2, 3)"
    left = CSTParser.parse(code)

    template1 = "println($(placeholder.variable))"
    right = CSTParser.parse(template1)

    named_variable_placeholders = Vector{Pair{String, CSTParser.EXPR}}()
    @info match_structure(left, right, named_variable_placeholders)
    @info named_variable_placeholders

    empty!(named_variable_placeholders)
    template2 = "println($(placeholder.variable)A)"
    right = CSTParser.parse(template2)
    @info right
    @info match_structure(left, right, named_variable_placeholders)
    @info named_variable_placeholders
end

# TODO: 匹配 单个占位符

using Debugger
let code = "println(1, 2, 3)"
    cst = CSTParser.parse(code)

    template = "println($(placeholder.variable))"
    @info match_pattern(cst, CSTParser.parse(template))

    template = "println($(placeholder.variable), $(placeholder.variable), $(placeholder.variable))"
    @info match_pattern(cst, CSTParser.parse(template))

    template = "println($(placeholder.vararg_variable))"
    right = CSTParser.parse(template)
    @info match_pattern(cst, right)
end

using Debugger
let code = "println(1, 2, 3)"
    cst = CSTParser.parse(code)

    template = "println($(placeholder.vararg_variable))"
    right = CSTParser.parse(template)
    bindings = Vector{Pair{String, CSTParser.EXPR}}()

    @info match_structure(cst, right, bindings)
end

# TODO: check lint

let code = read(joinpath(@__DIR__, "template.jl"), String)
    cst = CSTParser.parse(code)

    check = Check(AsyncRule, Dict{Marker, String}())
    check!(check, cst)
    
    dump(cst)
end