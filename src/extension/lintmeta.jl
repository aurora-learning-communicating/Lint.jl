mutable struct LintMeta
    error::Union{Nothing, LintError}

    LintMeta() = new(nothing)
    LintMeta(error::Union{Nothing, LintError}) = new(error)
end


haserror(meta::LintMeta) = meta.error !== nothing
haserror(expr::EXPR) = hasmeta(expr) && haserror(expr.meta)
hasmeta(expr::EXPR) = expr.meta isa LintMeta

function seterror!(expr::EXPR, error::LintError)
    if !hasmeta(expr)
        expr.meta = LintMeta()
    end

    expr.meta.error = error
end
