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