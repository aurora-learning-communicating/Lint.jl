struct FileExclusion
    pattern::Regex
end

function should_be_excluded(exclusion::FileExclusion, filename::String)::Bool
    pattern = exclusion.pattern
    match_result = match(pattern, filename)
    return !isnothing(match_result)
end

function should_be_excluded(exclusions::Vector{FileExclusion}, filename::String)::Bool
    return any(exclusion -> should_be_excluded(exclusion, filename), exclusions)
end