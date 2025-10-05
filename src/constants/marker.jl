module marker

struct Marker
    value::Symbol
end

const m_const = Marker(:const)
const filename = Marker(:filename)
const m_macro = Marker(:macro)
const macrocall = Marker(:macrocall)
const m_function = Marker(:function)
const anonymous_function = Marker(:anonymous_function)
const m_do = Marker(:do)

to_symbol(value::Marker)::Symbol = value.value

function Base.:(==)(left::Marker, right::Symbol)::Bool
    return left.value == right
end

function Base.:(==)(left::Symbol, right::Marker)::Bool
    return left == right.value
end

end