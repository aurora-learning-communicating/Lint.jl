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