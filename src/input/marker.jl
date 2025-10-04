struct Marker
    value::Symbol
end

const marker_const = Marker(:const)
const marker_filename = Marker(:filename)
const marker_macro = Marker(:macro)
const marker_macrocall = Marker(:macrocall)
const marker_function = Marker(:function)
const marker_anonymous_function = Marker(:anonymous_function)
const marker_do = Marker(:do)