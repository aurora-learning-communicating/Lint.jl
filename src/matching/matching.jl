module matching

import CSTParser: EXPR, parse
import ..constants
using Debugger

const anymatch = "QQQ"

include("match_value.jl")
include("match_structure.jl")
include("match_pattern.jl")
include("match_template.jl")

end