# 结构匹配
# original: `raw_comp`
function match_structure(left::EXPR, right::EXPR, named_variable_placeholders::Vector{Pair{String, EXPR}})::Bool
    #if is_placeholder_named_variable(left)
    if constants.is_named_variable(left)
        push!(named_variable_placeholders, left.val::String => right)
    end

    # if is_placeholder_variable(right)
    if constants.is_variable(right)
        push!(named_variable_placeholders, right.val::String => left)
    end

    if constants.is_variable(left) && constants.is_variable(right)
        return true
    end

    if constants.is_string_with_interpolation(left)
        return left.head == constants.head.string_interpolation && !isnothing(left.args)
    end

    if constants.is_string(left) && right.head == constants.head.string_literal
        return true
    end

    if constants.is_string(right) && right.head == constants.head.string_literal
        return true
    end
    
    flag = let 
        left_cst = left.head::EXPR
        right_cst = right.head::EXPR

        left_val = left.val::String
        right_val = right.val::String

        match_structure(left_cst, right_cst, named_variable_placeholders) && match_value(left_val, right_val)
    end
    
    if !flag
        return false
    end

    min_length = min(length(left), length(right))

    for index in 1:min_length
        left_cst = left[index]
        right_cst = right[index]
        
        if !match_structure(left_cst, right_cst, named_variable_placeholders)
            return false
        end

        if constants.is_vararg_variable(left_cst) || constants.is_vararg_variable(right_cst)
            return true
        end
    end

    if length(left) == length(right)
        return true
    end

    if length(left) == min_length
        return constants.is_vararg_variable(right[min_length + 1])
    end

    if length(right) == min_length
        return constants.is_vararg_variable(left[min_length + 1])
    end

    return false
end