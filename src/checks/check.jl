function check!(check::Check{FinalizerRule}, expr::EXPR)
    error_message = "`finalizer(_,_)`` should not be used"
    generic_check!(check.rule_type, expr, "finalizer($(placeholder.variable), $(placeholder.variable))", error_message)
    generic_check!(check.rule_type, expr, "finalizer($(placeholder.variable)) do $(placeholder.variable) $(placeholder.vararg_variable) end", error_message)
end

function check!(check::Check{AsyncRule}, expr::EXPR)
    error_message = "Use `@spawn` instead of `@async`"
    generic_check!(check.rule_type, expr, "@async $(placeholder.variable)", error_message)
    generic_check!(check.rule_type, expr, "Threads.@async $(placeholder.variable)", error_message)
end

function check!(check::Check{CcallRule}, expr::EXPR)
    error_message = caution("ccall")
    generic_check!(check.rule_type, expr, "ccall($(placeholder.vararg_variable))", error_message)
end

function check!(check::Check{InitializingWithFunctionRule}, expr::EXPR)
    if !haskey(check.markers, marker.m_const)
        return
    end

    generic_check!(check.rule_type, expr, "Threads.nthreads()", "`Threads.nthreads()` should not be used in a constant variable")
    generic_check!(check.rule_type, expr, "is_local_deployment()", "`is_local_deployment()` should not be used in a constant variable")
    generic_check!(check.rule_type, expr, "Deloyment.is_local_deployment()", "`Deployment.is_local_deployment()` should not be used in a constant value")
end

function check!(check::Check{CFunctionRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "@cfunction($(placeholder.variable), $(placeholder.vararg_variable))", "Macro `@cfunction` should not be used")
end

function check!(check::Check{UnlockRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "unlock($(placeholder.variable))")
end

function check!(check::Check{YieldRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "yield()")
end

function check!(check::Check{SleepRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "sleep($(placeholder.variable))")
end

function check!(check::Check{InboundsRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "@inbounds $(placeholder.variable)")
end

function check!(check::Check{ArrayWithNoTypeRule}, expr::EXPR)
    # ATTENTION: the `contains` might not be reached
    #= haskey(markers, :filename) || return
    contains(markers[:filename], "src/Compiler") || return =#

    value_of_filename = get(check.markers, marker.filename, nothing)
    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "src/Compiler")
        return
    end

    value_of_macrocall = get(check.markers, marker.macrocall, nothing)

    if !isnothing(value_of_macrocall)
        if value_of_macrocall == "@match" || value_of_macrocall == "@matchrule"
            return
        end
    end

    generic_check!(check.rule_type, expr, "[]", "need a specific Array type to be provided")
end

function check!(check::Check{ThreadsRule}, expr::EXPR)
    error_message = caution("@threads")
    generic_check!(check.rule_type, expr, "Threads.@threads $(placeholder.variable)", error_message)
    generic_check!(check.rule_type, expr, "@threads $(placeholder.variable)", error_message)
end

function check!(check::Check{GeneratedRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "@generated $(placeholder.variable)")
end

function check!(check::Check{SyncRule}, expr::EXPR)
    error_message = caution("@sync")
    generic_check!(check.rule_type, expr, "@sync $(placeholder.variable)", error_message)
    generic_check!(check.rule_type, expr, "Threads.@sync $(placeholder.variable)", error_message)
end

function check!(check::Check{RemovePageRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "remove_page($(placeholder.variable), $(placeholder.variable))")
end

function check!(check::Check{TaskRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "Task($(placeholder.variable))")
end

function check!(check::Check{ErrorExceptionRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)

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

    generic_check!(check.rule_type, expr, "ErrorException($(placeholder.vararg_variable))", "Use custom exception instead of generic `ErrorException`")
end

function check!(check::Check{ErrorRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)
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

    generic_check!(check.rule_type, expr, "error($(placeholder.variable))", "Use custom exception instead of the generic `error()`")
end

function check!(check::Check{UnsafeRule}, expr::EXPR)
    value_of_function = get(check.markers, marker.m_function, nothing)

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

    generic_check!(check.rule_type, expr, "unsafe_$(matching.anymatch)($(placeholder.vararg_variable))", "an `unsafe_` function should be called only from an `unsafe_` function")
    generic_check!(check.rule_type, expr, "_unsafe_$(matching.anymatch)($(placeholder.vararg_variable))", "an `unsafe_` function should be called only from an `unsafe_` function")
end

function check!(check::Check{InRule}, expr::EXPR)
    error_message = "use `tin(item, collection)` instead of Julia's `in` or `∈`"

    generic_check!(check.rule_type, expr, "in($(placeholder.variable), $(placeholder.variable))", error_message)
    generic_check!(check.rule_type, expr, "$(placeholder.variable) in $(placeholder.variable)", error_message)
    generic_check!(check.rule_type, expr, "∈($(placeholder.variable), $(placeholder.variable))", error_message)
    generic_check!(check.rule_type, expr, "$(placeholder.variable) ∈ $(placeholder.variable)", error_message)
end

function check!(check::Check{HasKeyRule}, expr::EXPR)
    error_message = "use `thaskey(dict, key)` instead of Julia's haskey"
    generic_check!(check.rule_type, expr, "haskey($(placeholder.variable), $(placeholder.variable))", error_message)
end

function check!(check::Check{EqualRule}, expr::EXPR)
    error_message = "Use `tequal(dict,key)` instead of the Julia's `equal`"
    generic_check!(check.rule_type, expr, "equal($(placeholder.variable), $(placeholder.variable))", error_message)
end

function check!(check::Check{UvRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "uv_$(matching.anymatch)($(placeholder.vararg_variable))", caution("uv_"))
end

function check!(check::Check{SplattingRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)
    if isnothing(value_of_filename)
        return
    end

    if contains(value_of_filename, "test.jl")
        return
    end

    if contains(value_of_filename, "tests.jl")
        return
    end

    if haskey(check.markers, marker.m_macro)
        return
    end

    error_message = caution("Splatting(...)") * " platting from dynamically sized containers could result in severe performance degradation. Splatting from statically-sized tuples is usually okay. This lint rule cannot determine if this is dynamic or static, so please check carefully. See https://github.com/RelationalAI/RAIStyle#splatting for more information."
    generic_check!(check.rule_type, expr, "$(placeholder.variable)($(placeholder.vararg_variable)...)", error_message)

    generic_check!(
        check.rule_type,
        expr, 
        "$(placeholder.variable)([$(placeholder.variable)($(placeholder.vararg_variable)) for $(placeholder.variable) in $(placeholder.variable)]...)",
        "Splatting (`...`) should not be used with dynamically sized containers. This may result in performance degradation. See https://github.com/RelationalAI/RAIStyle#splatting for more information.")
end

function check!(check::Check{UnreachableBranchRule}, expr::EXPR)
    let template_code = """
        if $(placeholder.variable)A
            $(placeholder.variable)
        elseif $(placeholder.variable)A
            $(placeholder.variable)
        end
        """
    
        generic_check!(check.rule_type, expr, template_code, "Unreachable branch")
    end

    let template_code = """
        if $(placeholder.variable)A
            $(placeholder.variable)
        elseif $(placeholder.variable)
            $(placeholder.variable)
        elseif $(placeholder.variable)A
            $(placeholder.variable)
        end
        """
        generic_check!(check.rule_type, expr, template_code, "Unreachable branch")
    end
end

function check!(check::Check{StringInterpolationRule}, expr::EXPR)
    if expr.head != head.string_interpolation
        return
    end

    error_message = raw"Use $(x) instead of $x ([explanation](https://github.com/RelationalAI/RAIStyle?tab=readme-ov-file#string-interpolation))."
    # We iterate over the arguments of the CST String to check for STRING: (
    # if we find one, this means the string was incorrectly interpolated

    # The number of interpolations is the same than $ in trivia and arguments
    trivia = expr.trivia # still cannot detect if expr.trivia is nothing or not
    if isnothing(trivia)
        return
    end

    dollars_count = let
        predicate = cst -> cst.head == Symbol(head.operator) && cst.val == "\$"
        collections = trivia
        length(filter(predicate, collections))
    end

    open_paren_count = let
        predicate = cst -> cst.head == Symbol(head.left_paren)
        collections = trivia
        length(filter(predicate, collections))
    end

    if open_paren_count != dollars_count
        extension.seterror!(expr, LintError(check.rule_type, error_message))
    end
end

function check!(check::Check{RelPathAPIUsageRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)

    if isnothing(value_of_filename)
        return
    end

    if !contains(value_of_filename, "src/Compiler/Front")
        return
    end

    generic_check!(check.rule_type, expr, "$(placeholder.variable)::RelPath", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(check.rule_type, expr, "RelPath($(placeholder.variable))", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(check.rule_type, expr, "RelPath($(placeholder.variable), $(placeholder.variable))", "usage of tpe `RelPath` is not allowed in this context")
    generic_check!(check.rule_type, expr, "split_path($(placeholder.variable))", "usage of `RelPath` API method `split_path` is not allowed in this context")
    generic_check!(check.rule_type, expr, "drop_first($(placeholder.variable))", "usage of `RelPath` API method `drop_first` is not allowed in this context")
    generic_check!(check.rule_type, expr, "relpath_from_signature($(placeholder.variable))", "usage of `RelPath` API method `relpath_from_signature` is not allowed in this context")
end

function check!(check::Check{NonFrontShapeAPIUsageRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)
    if isnothing(value_of_filename)
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

    generic_check!(check.rule_type, expr, "shape_term($(placeholder.vararg_variable))", "Usage of `shape_term` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(check.rule_type, expr, "Front.shap_term($(placeholder.vararg_variable))", "Usage of `shape_term` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(check.rule_type, expr, "shape_splat($(placeholder.vararg_variable))", "Usage of `shape_splat` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(check.rule_type, expr, "Front.shape_splat($(placeholder.vararg_variable))", "Usage of `shape_splat` Shape API method is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(check.rule_type, expr, "ffi_shape_term($(placeholder.vararg_variable))", "Usage of `ffi_shape_term` is not allowed outside of the Front-end Compiler and FFI.")
    generic_check!(check.rule_type, expr, "Shape", "Usage of `Shape` is not allowed outside of the Front-end Compiler and FFI.")
end

function check!(check::Check{InterpolationInSafeLogRule}, expr::EXPR)
    generic_check!(check.rule_type, expr, "@warnv_safe_to_log $(placeholder.variable) \"$(placeholder.string_interpolation)\"", "Safe warning log has interpolation.")
end

function check!(check::Check{UseOfStaticThreads}, expr::EXPR)
    error_message = "Use `Threads.@threads :dynamic` instead of `Threads.@threads :static`. Static threads must not be used as generated tasks will not be able to migrate across threads."

    generic_check!(check.rule_type, expr, "@threads :static $(placeholder.vararg_variable)", error_message)
    generic_check!(check.rule_type, expr, "Threads.@threads :static $(placeholder.vararg_variable)", error_message)
end

function check!(check::Check{LogStatementsMustBeSafe}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)

    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end

        if contains(value_of_filename, "bench/")
            return
        end
    end

    error_message = "Unsafe logging statement. You must enclose variables and strings with `@safe(...)`."

    if expr.head != head.to_symbol(head.macrocall)
        return
    end

    args = expr.args
    if isnothing(args)
        return
    end

    if args[1].head != head.to_symbol(head.identifier)
        return
    end

    val = args[1].val
    if isnothing(val)
        return
    end
    # @info and its friends
    
    
    if startswith(val, "@info")
        if !extension.all_arguments_safe(expr)
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        end
    end

    # @debug and its friends
    if startswith(val, "@debug")
        if !extension.all_arguments_safe(expr)
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        end
    end

    # @error and its friends
    if startswith(val, "@error")
        if !extension.all_arguments_safe(expr)
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        end
    end

    # @warn and its friends
    if startswith(val, "@warn")
        if !extension.all_arguments_safe(expr)
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        end
    end
end

function check!(check::Check{AssertionStatementsMustBeSafe}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)
    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end
    end

    if expr.head != head.to_symbol(head.macrocall)
        return
    end

    args = expr.args
    if isnothing(args)
        return
    end

    if args[1].head != head.to_symbol(head.identifier)
        return
    end

    val = args[1].val
    if isnothing(val)
        return
    end

    if startswith(val, "@assert") || startswith(val, "@dassert")
        if !extension.all_arguments_safe(expr; skip_first_arg = true)
            error_message = "Unsafe assertion statement. You must enclose the message `@safe(...)`."
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        end
    end
end

function check!(check::Check{MustNotUseShow}, expr::EXPR)
    error_message = "Do not use `@show`, use `@info` instead."
    generic_check!(check.rule_type, expr, "@show $(placeholder.variable)", error_message)
end


function check!(check::Check{NoinlineAndLiteralRule}, expr::EXPR)
    if matching.match_template(expr, "@noinline $(placeholder.variable)($(placeholder.vararg_variable)) = $(placeholder.vararg_variable)")
        return
    end

    if expr.head == Symbol(head.macrocall) &&
        expr.args[1].head == Symbol(head.identifier) &&
        expr.args[1].val == "@noinline"

        # Are we in a function definition?
        function_def = extension.fetch_value(expr, head.function, false)
        if !isnothing(function_def)
            return
        end

        # Retrieve function call below the @noinline macro
        fetch_call = extension.fetch_value(expr, head.call, false, 1)
        error_message = "For call-site `@noinline` call, all args must be literals or identifiers only. \
        Pull complex args out to top-level. [RAI-35086](https://relationalai.atlassian.net/browse/RAI-35086)."

        # We found no function call, check for a macro call then
        if isnothing(fetch_call)
            macro_call = extension.fetch_value(expr, head.macrocall, false, -1, true)

            # If we have not found a macro call, then we merely exit.
            # could happen with `@noinline 42` for example
            if isnothing(macro_call)
                return
            end
            
            # we found a macro call
            extension.seterror!(expr, LintError(check.rule_type, error_message))
        else
            if !extension.all_arguments_literal_or_identifier(fetch_call)
                extension.seterror!(expr, LintError(check.rule_type, error_message))
            end
        end
        
    end
end

function check!(check::Check{NoReturnInAnonymousFunctionRule}, expr::EXPR)
    value_of_filename = get(check.markers, marker.filename, nothing)
    if !isnothing(value_of_filename)
        if contains(value_of_filename, "test/")
            return
        end
    end

    if !haskey(check.markers, marker.anonymous_function)
        return
    end

    error_message = "Anonymous function must not have `return` [Explanation](https://github.com/RelationalAI/RAIStyle#returning-from-a-closure)."
    generic_check!(check.rule_type, expr, "return $(placeholder.variable)", error_message)
end

function check!(check::Check{NoImportRule}, expr::EXPR)
    error_message = "Imports must be specified using `using` and not `import` [Explanation](https://github.com/RelationalAI/RAIStyle?tab=readme-ov-file#module-imports)."
    generic_check!(check.rule_type, expr, "import $(placeholder.variable)", error_message)

    # Arbitrary number of hole variables
    # TODO: This is hacky and it deserves a better solution.
    for index in 1:15
        placeholders = join(map(_ -> "$(placeholder.variable)", 1:index), ", ")
        template_code = "import $(placeholder.variable): $placeholders"
        generic_check!(check.rule_type, expr, template_code, error_message)
    end
end

function check!(check::Check{NotImportingRAICodeRule}, expr::EXPR)
    error_message = "Importing RAICode should be avoided (when possible)."
    generic_check!(check.rule_type, expr, "using RAICode", error_message)
    # Arbitrary number of hole variables
    # TODO: This is hacky and it deserves a better solution.
    for index in 1:15
        placeholders = join(map(_ -> "$(placeholder.variable)", 1:index), ", ")
        template_code = "using RAICode: $placeholders"
        generic_check!(check.rule_type, expr, template_code, error_message)
    end
end
