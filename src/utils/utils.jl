module utils

import CSTParser: EXPR

headof(expr::EXPR) = expr.head
valof(expr::EXPR) = expr.val
parentof(expr::EXPR) = expr.parent
errorof(expr::EXPR) = expr.meta

include("file_exclusion.jl")

caution(keyword::String) = "`$keyword` should be used with extreme caution"

end