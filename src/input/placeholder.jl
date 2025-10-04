import CSTParser: EXPR

struct PlaceHolder 
    identity::String
end

const placeholder_variable = PlaceHolder("variable")
const placeholder_string = PlaceHolder("string")
const placeholder_string_interpolation = PlaceHolder("string_with_interpolation")
const placeholder_vararg_variable = PlaceHolder("variables")

Base.String(value::PlaceHolder) = value.identity