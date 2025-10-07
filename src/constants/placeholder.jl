module placeholder

struct PlaceHolder 
    identity::String
end

const variable = PlaceHolder("variable")
const string = PlaceHolder("string")
const string_interpolation = PlaceHolder("string_with_interpolation")
const vararg_variable = PlaceHolder("varag_variable")

to_string(value::PlaceHolder)::String = value.identity

function Base.:(==)(left::PlaceHolder, right::String)::Bool
    return left.identity == right
end

function Base.:(==)(left::String, right::PlaceHolder)::Bool
    return left == right.identity
end

Base.show(io::IO, value::PlaceHolder) = print(io, to_string(value))

end