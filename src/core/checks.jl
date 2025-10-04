function check!(rule_type::Type{FinalizerRule}, expr::EXPR)
    error_message = "`finalizer(_,_)`` should not be used"
    generic_check!(rule_type, expr, "finalizer($placeholder_variable, $placeholder_variable)", error_message)
    generic_check!(rule_type, expr, "finalizer($placeholder_variable) do $placeholder_variable $placeholder_vararg_variable end", error_message)
end

function check!(rule_type::Type{AsyncRule}, expr::EXPR)
    error_message = "Use `@spawn` instead of `@async`"
    generic_check!(rule_type, expr, "@async $placeholder_variable", error_message)
    generic_check!(rule_type, expr, "Threads.@async $placeholder_variable", error_message)
end

function check!(rule_type::Type{CcallRule}, expr::EXPR)
    error_message = caution("ccall")
    generic_check!(rule_type, expr, "ccall($placeholder_vararg_variable)", error_message)
end

function check!(rule_type::Type{InitializingWithFunctionRule}, expr::EXPR, markers::Dict{Marker, String})
    if !haskey(markers, marker_const)
        return
    end

    generic_check!(rule_type, expr, "Threads.nthreads()", "`Threads.nthreads()` should not be used in a constant variable")
    generic_check!(rule_type, expr, "is_local_deployment()", "`is_local_deployment()` should not be used in a constant variable")
    generic_check!(rule_type, expr, "Deloyment.is_local_deployment()", "`Deployment.is_local_deployment()` should not be used in a constant value")
end

function check!(rule_type::Type{CFunctionRule}, expr::EXPR)
    generic_check!(rule_type, expr, "@cfunction($placeholder_variable, $placeholder_vararg_variable)", "Macro `@cfunction` should not be used")
end

function check!(rule_type::Type{UnlockRule}, expr::EXPR)
    generic_check!(rule_type, expr, "unlock($placeholder_variable)")
end

function check!(rule_type::Type{YieldRule}, expr::EXPR)
    generic_check!(rule_type, expr, "yield()")
end

function check!(rule_type::Type{SleepRule}, expr::EXPR)
    generic_check!(rule_type, expr, "sleep($placeholder_variable)")
end

function check!(rule_type::Type{InboundsRule}, expr::EXPR)
    generic_check!(rule_type, expr, "@inbounds $placeholder_variable")
end

function check!(rule_type::Type{ArrayWithNoTypeRule}, expr::EXPR, markers::Dict{Marker, String})
    # ATTENTION: the `contains` might not be reached
    #= haskey(markers, :filename) || return
    contains(markers[:filename], "src/Compiler") || return =#

    value_of_filename = get(markers, marker_filename, nothing)
    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "src/Compiler")
        return
    end

    value_of_macrocall = get(markers, marker_macrocall, nothing)

    if !isnothing(value_of_macrocall)
        if value_of_macrocall == "@match" || value_of_macrocall == "@matchrule"
            return
        end
    end

    generic_check!(rule_type, expr, "[]", "need a specific Array type to be provided")
end

function check!(rule_type::Type{ThreadsRule}, expr::EXPR)
    error_message = caution("@threads")
    generic_check!(rule_type, expr, "Threads.@threads $placeholder_variable", error_message)
    generic_check!(rule_type, expr, "@threads $placeholder_variable", error_message)
end

function check!(rule_type::Type{GeneratedRule}, expr::EXPR)
    generic_check!(rule_type, expr, "@generated $placeholder_variable")
end

function check!(rule_type::Type{SyncRule}, expr::EXPR)
    error_message = caution("@sync")
    generic_check!(rule_type, expr, "@sync $placeholder_variable", error_message)
    generic_check!(rule_type, expr, "Threads.@sync $placeholder_variable", error_message)
end

function check!(rule_type::Type{RemovePageRule}, expr::EXPR)
    generic_check!(rule_type, expr, "remove_page($placeholder_variable, $placeholder_variable)")
end

function check!(rule_type::Type{TaskRule}, expr::EXPR)
    generic_check!(rule_type, expr, "Task($placeholder_variable)")
end

function check!(rule_type::Type{ErrorExceptionRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)

    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "test.jl")
        return
    end

    if contains(value_of_filename, "tests.jl")
        return
    end

    if contains(value_of_filename, "bench/")
        return
    end

    if contains(value_of_filename, "Vectorized/Test")
        return
    end

    generic_check!(rule_type, expr, "ErrorException($placeholder_vararg_variable)", "Use custom exception instead of generic `ErrorException`")
end

function check!(rule_type::Type{ErrorRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)
    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "test.jl")
        return
    end

    if contains(value_of_filename, "tests.jl")
        return
    end

    if contains(value_of_filename, "bench/")
        return
    end

    if contains(value_of_filename, "Vectorized/Test")
        return
    end

    generic_check!(rule_type, expr, "error($placeholder_variable)", "Use custom exception instead of the generic `error()`")
end

function check!(rule_type::Type{UnsafeRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_function = get(markers, marker_function, nothing)

    if isnothing(value_of_function)
        return
    end

    match_result = match(Regex("_unsafe_.*"), value_of_function)
    if !isnothing(match_result)
        return
    end

    match_result = match(Regex("unsafe_.*"), value_of_function)
    if !isnothing(match_result)
        return
    end

    generic_check!(rule_type, expr, "unsafe_$anymatch($placeholder_vararg_variable)", "an `unsafe_` function should be called only from an `unsafe_` function")
    generic_check!(rule_type, expr, "_unsafe_$anymatch($placeholder_vararg_variable)", "an `unsafe_` function should be called only from an `unsafe_` function")
end

function check!(rule_type::Type{InRule}, expr::EXPR)
    error_message = "use `tin(item, collection)` instead of Julia's `in` or `∈`"

    generic_check!(rule_type, expr, "in($placeholder_variable, $placeholder_variable)", error_message)
    generic_check!(rule_type, expr, "$placeholder_variable in $placeholder_variable", error_message)
    generic_check!(rule_type, expr, "∈($placeholder_variable, $placeholder_variable)", error_message)
    generic_check!(rule_type, expr, "$placeholder_variable ∈ $placeholder_variable", error_message)
end

function check!(rule_type::Type{HasKeyRule}, expr::EXPR)
    error_message = "use `thaskey(dict, key)` instead of Julia's haskey"
    generic_check!(rule_type, expr, "haskey($placeholder_variable, $placeholder_variable)", error_message)
end

function check!(rule_type::Type{EqualRule}, expr::EXPR)
    error_message = "Use `tequal(dict,key)` instead of the Julia's `equal`"
    generic_check!(rule_type, expr, "equal($placeholder_variable, $placeholder_variable)", error_message)
end

function check!(rule_type::Type{UvRule}, expr::EXPR)
    generic_check!(rule_type, expr, "uv_$anymatch($placeholder_vararg_variable)", caution("uv_"))
end

function check!(rule_type::Type{SplattingRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)
    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "test.jl")
        return
    end

    if contains(value_of_filename, "tests.jl")
        return
    end

    if haskey(markers, marker_macro)
        return
    end

    error_message = caution("Splatting(...)") * " platting from dynamically sized containers could result in severe performance degradation. Splatting from statically-sized tuples is usually okay. This lint rule cannot determine if this is dynamic or static, so please check carefully. See https://github.com/RelationalAI/RAIStyle#splatting for more information."
    generic_check!(rule_type, expr, "$placeholder_variable($placeholder_vararg_variable...)", error_message)

    generic_check!(
        rule_type,
        expr, 
        "$placeholder_variable([$placeholder_variable($placeholder_vararg_variable) for $placeholder_variable in $placeholder_variable]...)",
        "Splatting (`...`) should not be used with dynamically sized containers. This may result in performance degradation. See https://github.com/RelationalAI/RAIStyle#splatting for more information.")
end

function check!(rule_type::Type{UnreachableBranchRule}, expr::EXPR)
    let template_code = """
        if $(placeholder_variable)A
            $placeholder_variable
        elseif $(placeholder_variable)A
            $placeholder_variable
        end
        """
    
        generic_check!(rule_type, expr, template_code, "Unreachable branch")
    end

    let template_code = """
        if $(placeholder_variable)A
            $placeholder_variable
        elseif $placeholder_variable
            $placeholder_variable
        elseif $(placeholder_variable)A
            $placeholder_variable
        end
        """
        generic_check!(rule_type, expr, template_code, "Unreachable branch")
    end
end

function check!(rule_type::Type{StringInterpolationRule}, expr::EXPR)
    if expr.head != Symbol(head_string_interpolation)
        return
    end

    error_message = raw"Use $(x) instead of $x ([explanation](https://github.com/RelationalAI/RAIStyle?tab=readme-ov-file#string-interpolation))."
    # We iterate over the arguments of the CST String to check for STRING: (
    # if we find one, this means the string was incorrectly interpolated

    # The number of interpolations is the same than $ in trivia and arguments
    dollars_count = length(filter(cst -> cst.head == Symbol(head_operator) && cst.val == raw"$", expr.trivia))
    open_paren_count = length(filter(cst -> cst.head == Symbol(head_left_paren), expr.trivia))

    if open_paren_count != dollars_count
        seterror!(expr, LintRuleReport{StringInterpolationRule}(rule_type, error_message))
    end
end

function check!(rule_type::Type{RelPathAPIUsageRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)

    if !isnothing(value_of_filename)
        return
    end

    if !contains(value_of_filename, "src/Compiler/Front")
        return
    end

    generic_check!(rule_type, expr, "$placeholder_variable::RelPath", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(rule_type, expr, "RelPath($placeholder_variable)", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(rule_type, expr, "RelPath($placeholder_variable, $placeholder_variable)", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(rule_type, expr, "split_path($placeholder_variable)", "usage of `RelPath` API method `split_path` is not allowed in this context")
    generic_check!(rule_type, expr, "drop_first($placeholder_variable)", "usage of `RelPath` API method `drop_first` is not allowed in this context")
    generic_check!(rule_type, expr, "relpath_from_signature($placeholder_variable)", "usage of `RelPath` API method `relpath_from_signature` is not allowed in this context")
end

function check!(rule_type::Type{NonFrontShapeAPIUsageRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)
    if !isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "src/FrontCompiler")
        return
    end

    if contains(value_of_filename, "packages/RAI_FrontCompiler")
        return
    end

    if contains(value_of_filename, "src/FFI")
        return
    end

    # We're allowing this for serialization.
    if contains(value_of_filename, "src/Database")
        return
    end

    if contains(value_of_filename, "packages/Shapes")
        return
    end

    if contains(value_of_filename, "packages/RAI_FrontIR")
        return
    end

    # Also, allow usages in tests
    if contains(value_of_filename, "test/")
        return
    end

    # Also, allow usages of the name `Shape` in `packages/` although they refer to a different thing.
    if contains(value_of_filename, "packages/RAI_Protos/src/proto/metadata.proto")
        return
    end

    if contains(value_of_filename, "packages/RAI_Protos/src/gen/relationalai/protocol/metadata_pb.jl")
        return
    end

    generic_check!(rule_type, expr, "shape_term($placeholder_vararg_variable)", "Usage of `shape_term` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(rule_type, expr, "Front.shap_term($placeholder_vararg_variable)", "Usage of `shape_term` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(rule_type, expr, "shape_splat($placeholder_vararg_variable)", "Usage of `shape_splat` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(rule_type, expr, "Front.shape_splat($placeholder_vararg_variable)", "Usage of `shape_splat` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(rule_type, expr, "ffi_shape_term($placeholder_vararg_variable)", "Usage of `ffi_shape_term` is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(rule_type, expr, "Shape", "Usage of `Shape` is not allowed outside of the Front-end Compiler and FFI.")
end

function check!(rule_type::Type{InterpolationInSafeLogRule}, expr::EXPR)
    generic_check!(rule_type, expr, "@warnv_safe_to_log $placeholder_variable \"$placeholder_string_interpolation\"", "Safe warning log has interpolation.")
end

function check!(rule_type::Type{UseOfStaticThreads}, expr::EXPR)
    error_message = "Use `Threads.@threads :dynamic` instead of `Threads.@threads :static`. Static threads must not be used as generated tasks will not be able to migrate across threads."

    generic_check!(rule_type, expr, "@threads :static $placeholder_vararg_variable", error_message)
    generic_check!(rule_type, expr, "Threads.@threads :static $placeholder_vararg_variable", error_message)
end

function check!(rule_type::Type{LogStatementsMustBeSafe}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)

    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end

        if contains(value_of_filename, "bench/")
            return
        end
    end

    error_message = "Unsafe logging statement. You must enclose variables and strings with `@safe(...)`."

    # @info and its friends
    if expr.head == Symbol(head_macrocall) && expr.args[1].head == Symbol(head_identifier) && startswith(expr.args[1].val, "@info")
        if !all_arguments_safe(expr)
            seterror!(expr, LintRuleReport{LogStatementsMustBeSafe}(rule_type, error_message))
        end
    end

    # @debug and its friends
    if expr.head == Symbol(head_macrocall) && expr.args[1].head == Symbol(head_identifier) && startswith(expr.args[1].val, "@debug")
        if !all_arguments_safe(expr)
            seterror!(expr, LintRuleReport{LogStatementsMustBeSafe}(rule_type, error_message))
        end
    end

    # @error and its friends
    if expr.head == Symbol(head_macrocall) && expr.args[1].head == Symbol(head_identifier) && startswith(expr.args[1].val, "@error")
        if !all_arguments_safe(expr)
            seterror!(expr, LintRuleReport{LogStatementsMustBeSafe}(rule_type, error_message))
        end
    end

    # @warn and its friends
    if expr.head == Symbol(head_macrocall) && expr.args[1].head == Symbol(head_identifier) && startswith(expr.args[1].val, "@warn")
        if !all_arguments_safe(expr)
            seterror!(expr, LintRuleReport{LogStatementsMustBeSafe}(rule_type, error_message))
        end
    end
end

function check!(rule_type::Type{AssertionStatementsMustBeSafe}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)
    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end
    end

    error_message = "Unsafe assertion statement. You must enclose the message `@safe(...)`."
    if expr.head == Symbol(head_macrocall) &&
        expr.args[1].head == Symbol(head_identifier) &&
        (startswith(expr.args[1].val, "@assert") || startswith(expr.args[1].val, "@dassert"))

        if !all_arguments_safe(expr; skip_first_arg = true)
            seterror!(expr, LintRuleReport{AssertionStatementsMustBeSafe}(rule_type, error_message))
        end
    end
end

function check!(rule_type::Type{MustNotUseShow}, expr::EXPR)
    error_message = "Do not use `@show`, use `@info` instead."

    generic_check!(rule_type, expr, "@show $placeholder_variable", error_message)
end


function check!(rule_type::Type{NoinlineAndLiteralRule}, expr::EXPR)
    if is_match_template_code(expr, "@noinline $placeholder_variable($placeholder_vararg_variable) = $placeholder_vararg_variable")
        return
    end

    if expr.head == Symbol(head_macrocall) &&
        expr.args[1].head == Symbol(head_identifier) &&
        expr.args[1].val == "@noinline"

        # Are we in a function definition?
        function_def = fetch_value(expr, head_function, false)
        if !isnothing(function_def)
            return
        end

        # Retrieve function call below the @noinline macro
        fetch_call = fetch_value(expr, head_call, false, 1)
        error_message = "For call-site `@noinline` call, all args must be literals or identifiers only. \
        Pull complex args out to top-level. [RAI-35086](https://relationalai.atlassian.net/browse/RAI-35086)."

        # We found no function call, check for a macro call then
        if isnothing(fetch_call)
            macro_call = fetch_value(expr, head_macrocall, false, -1, true)

            # If we have not found a macro call, then we merely exit.
            # could happen with `@noinline 42` for example
            if isnothing(macro_call)
                return
            end
            
            # we found a macro call
            seterror!(expr, LintRuleReport{NoinlineAndLiteralRule}(rule_type, error_message))
        else
            if !all_arguments_literal_or_identifier(fetch_call)
                seterror!(expr, LintRuleReport{NoinlineAndLiteralRule}(rule_type, error_message))
            end
        end
        
    end
end

function check!(rule_type::Type{NoReturnInAnonymousFunctionRule}, expr::EXPR, markers::Dict{Marker, String})
    value_of_filename = get(markers, marker_filename, nothing)
    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end
    end

    if !haskey(markers, marker_anonymous_function)
        return
    end

    error_message = "Anonymous function must not have `return` [Explanation](https://github.com/RelationalAI/RAIStyle#returning-from-a-closure)."
    generic_check!(rule_type, expr, "return $placeholder_variable", error_message)
end

function check!(rule_type::Type{NoImportRule}, expr::EXPR)
    error_message = "Imports must be specified using `using` and not `import` [Explanation](https://github.com/RelationalAI/RAIStyle?tab=readme-ov-file#module-imports)."
    generic_check!(rule_type, expr, "import $placeholder_variable", error_message)

    # Arbitrary number of hole variables
    # TODO: This is hacky and it deserves a better solution.
    for index in 1:15
        placeholders = join(map(_ -> "$placeholder_variable", 1:index), ", ")
        template_code = "import $placeholder_variable: $placeholders"
        generic_check!(rule_type, expr, template_code, error_message)
    end
end

function check!(rule_type::Type{NotImportingRAICodeRule}, expr::EXPR)
    error_message = "Importing RAICode should be avoided (when possible)."
    generic_check!(rule_type, expr, "using RAICode", error_message)
    # Arbitrary number of hole variables
    # TODO: This is hacky and it deserves a better solution.
    for index in 1:15
        placeholders = join(map(_ -> "$placeholder_variable", 1:index), ", ")
        template_code = "using RAICode: $placeholders"
        generic_check!(rule_type, expr, template_code, error_message)
    end
end
