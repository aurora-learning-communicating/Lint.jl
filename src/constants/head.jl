module head

struct HeadType
    type::Symbol
end

const string_literal = HeadType(:STRING)
const string_interpolation = HeadType(:string)
const identifier = HeadType(:IDENTIFIER)
const h_nothing = HeadType(:NOTHING)
const integer = HeadType(:INTEGER)
const float = HeadType(:FLOAT)
const h_true = HeadType(:TRUE)
const h_false = HeadType(:FALSE)
const hexint = HeadType(:HEXINT)
const binint = HeadType(:BININT)
const char = HeadType(:CHAR)
const octint = HeadType(:OCTINT)
const operator = HeadType(:OPERATOR)
const left_paren = HeadType(:LPAREN)
const right_paren = HeadType(:RPAREN)
const macrocall = HeadType(:macrocall)
const parameters = HeadType(:parameters)
const kw = HeadType(:kw)
const h_function = HeadType(:function)
const call = HeadType(:call)

to_symbol(value::HeadType)::Symbol = value.type

function Base.:(==)(left::HeadType, right::Symbol)::Bool
    return left.type == right
end

function Base.:(==)(left::Symbol, right::HeadType)::Bool
    return left == right.type
end

function Base.:(==)(left::Any, right::HeadType)::Bool
    return false
end

function Base.:(==)(left::HeadType, right::Any)::Bool
    return false
end

end