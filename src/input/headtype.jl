struct HeadType
    type::Symbol
end

const head_string_literal = HeadType(:STRING)
const head_string_interpolation = HeadType(:string)
const head_identifier = HeadType(:IDENTIFIER)
const head_nothing = HeadType(:NOTHING)
const head_integer = HeadType(:INTEGER)
const head_float = HeadType(:FLOAT)
const head_true = HeadType(:TRUE)
const head_false = HeadType(:FALSE)
const head_hexint = HeadType(:HEXINT)
const head_binint = HeadType(:BININT)
const head_char = HeadType(:CHAR)
const head_octint = HeadType(:OCTINT)
const head_operator = HeadType(:OPERATOR)
const head_left_paren = HeadType(:LPAREN)
const head_right_paren = HeadType(:RPAREN)
const head_macrocall = HeadType(:macrocall)
const head_parameters = HeadType(:parameters)
const head_kw = HeadType(:kw)
const head_function = HeadType(:function)
const head_call = HeadType(:call)

Base.Symbol(value::HeadType) = value.type