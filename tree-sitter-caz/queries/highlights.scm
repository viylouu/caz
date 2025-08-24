; function names
(function_definition
  name: (identifier) @function)

; function parameters
(parameter_defn
  name: (identifier) @parameter)

; types
(primitive_type) @type
(slice_type) @type

; numbers
(number) @number

; strings
(string) @string

; comments
(comment) @comment

; preprocessor directives
(preproc_import) @include
(preproc_extern) @include

; function calls
(function_call
  name: (identifier) @function.call)

