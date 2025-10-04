# 原子值(String, Number) 匹配
# original: `comp_value`
function match_value(left::String, right::String)::Bool
    is_there_any_anymatch = contains(left, anymatch) || contains(right, anymatch)
    if !is_there_any_anymatch
        return left == right
    end

    contain_left = contains(left, anymatch)
    contain_right = contains(right, anymatch)
    if contain_left && contain_right
        error("cannot both $left and $right have a star marker")
    end

    return if contain_left
        regex = Regex(replace(left, anymatch => ".*"))        
        !isnothing(match(regex, right))
    else
        regex = Regex(replace(right, anymatch => ".*"))
        !isnothing(match(regex, left))
    end
end

# 结构匹配
# original: `raw_comp`
function match_structure(left::EXPR, right::EXPR, named_variable_placeholders::Vector{Pair{String, EXPR}})::Bool
    if is_placeholder_named_variable(left)
        push!(named_variable_placeholders, left.val => right)
    end

    if is_placeholder_variable(right)
        push!(named_variable_placeholders, right.val => left)
    end

    if is_placeholder_variable(left) && is_placeholder_variable(right)
        return true
    end

    if is_placeholder_string_with_interpolation(left)
        return left.head == Symbol(head_string_interpolation) && !isnothing(left.args)
    end

    if is_placeholder_string(left) && right.head == Symbol(head_string_literal)
        return true
    end

    if is_placeholder_string(right) && right.head == Symbol(head_string_literal)
        return true
    end
    
    flag = match_structure(left.head, right.head, named_variable_placeholders) && match_value(left.val, right.val)
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

        if is_placeholder_variable_star(left_cst) || is_placeholder_variable_star(right_cst)
            return true
        end
    end

    if length(left) == length(right)
        return true
    end

    if length(left) == min_length
        return is_placeholder_variable_star(right[min_length + 1])
    end

    if length(right) == min_length
        return is_placeholder_variable_star(left[min_length + 1])
    end

    return false
end

# 模式匹配
# original: `comp`
function match_pattern(left::EXPR, right::EXPR)::Bool
    named_variable_placeholders = Vector{Pair{String, EXPR}}()
    result = match_structure(left, right, named_variable_placeholders)

    # If there is no or only one named variable hole, then we can exit
    if length(named_variable_placeholders) <= 1
        return result
    end

    all_placeholders = Set(first.(named_variable_placeholders))
    placeholder_to_values = Dict{String, EXPR}()

    for key in all_placeholders
        relevant = filter(pair -> first(pair) == key, named_variable_placeholders)
        relevant = map(pair -> last(pair), relevant)

        first_relevant = first(relevant)
        rest = relevant[2:end]
        if !all(r -> match_pattern(first_relevant, r), rest)
            return false
        end

        placeholder_to_values[key] = first_relevant
    end

    # At this point, we know that all the values for each named hole are the same.
    # We now need to check if values for each named holes are different.
    # If some values for two different named holes are the same, then there is no match
    values_of_placeholder = collect(values(placeholder_to_values))

    for value in values_of_placeholder
        delete_indexs = findall(isequal(value), values_of_placeholder)
        all_to_check = deleteat!(copy(values_of_placeholder), delete_indexs)

        if any(key -> match_pattern(key, value), all_to_check)
            return false
        end
    end

    return true
end