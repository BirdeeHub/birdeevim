[
  "rec"
  "with"
  "assert"
] @prepend_space @append_space

(binary_expression left: (_) @append_space right: (_) @prepend_space)

(binding
  attrpath: (attrpath) @append_space
  expression: (_) @prepend_space
)

(select_expression
  expression: (_) @append_antispace
  attrpath: (attrpath) @append_space @prepend_antispace
  default: (_) @prepend_space
)

(let_expression (binding_set) @append_spaced_softline @prepend_spaced_softline body: (_) @prepend_space)

; Don't format strings or comments?
[
  (string_expression)
  (indented_string_expression)
  (comment)
] @leaf

(parenthesized_expression
  "(" @append_antispace
  ")" @prepend_antispace
)

(apply_expression
  function: (_) @append_space
  (_)* @append_space
  .
  (_)
)

"!" @prepend_space @append_antispace
[
  ","
  ";"
  ":"
] @prepend_antispace @append_space

(attrset_expression
  .
  (_) @prepend_spaced_softline
)
(attrset_expression
  (_) @append_spaced_softline
  .
)
(binding_set) @prepend_indent_start @append_indent_end
(binding_set (binding expression: (function_expression) @prepend_indent_start @append_indent_end))
(binding_set (binding) @prepend_spaced_softline @append_spaced_softline)

(list_expression
  "[" @append_indent_start
  (_)* @prepend_spaced_softline
  "]" @prepend_indent_end
)
(list_expression
  (_) @append_spaced_softline
  .
)
(list_expression) @prepend_space @append_space

(inherit_from
  "(" @append_antispace @prepend_space
  .
  expression: (_)
  .
  ")" @prepend_antispace
  attrs: (_)
)
(inherited_attrs attr: (_)* @prepend_space)

(if_expression
  "if" @append_indent_start @prepend_space
  condition: (_) @prepend_space @append_space
  "then" @append_indent_start @prepend_indent_end
  consequence: (_) @prepend_spaced_softline @append_spaced_softline
  "else" @prepend_indent_end
  alternative: (_) @append_space
)
(if_expression
  "else" @append_indent_start
  alternative: (_ !condition !consequence !alternative) @prepend_spaced_softline @append_indent_end
)

(function_expression "@" @prepend_antispace @append_antispace ":" @prepend_antispace)
(function_expression
  formals: (formals
    formal: (formal)? @prepend_spaced_softline
    ellipses: (ellipses)? @prepend_spaced_softline @append_spaced_softline
  )
)
(function_expression
  formals: (formals
    "}" @prepend_indent_end
    .
  ) @prepend_indent_start
)
(function_expression
  body: (_ !formals !universal !body) @prepend_spaced_softline
)
(function_expression
  body: (function_expression) @prepend_space
)
