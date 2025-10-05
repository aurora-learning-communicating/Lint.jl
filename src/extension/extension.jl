module extension

import CSTParser: EXPR
import ..output: LintError
import ..constants: head

include("lintmeta.jl")
include("predicate.jl")
include("fetch_value.jl")

end