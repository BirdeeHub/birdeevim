; TODO: interpolations and strings

; Don't format strings?
[
  (string_expression)
  (indented_string_expression)
] @leaf

[
  "rec"
  "with"
  "assert"
] @prepend_space @append_space

(_) @allow_blank_line_before

(binary_expression left: (_) @append_space right: (_) @prepend_space)

(binding
  attrpath: (attrpath) @append_space
  expression: (_) @prepend_space
)

(select_expression
  expression: (_) @append_antispace
  attrpath: (attrpath) @prepend_antispace
)
(select_expression
  expression: (_)
  attrpath: (attrpath) @append_space
  default: (_) @prepend_space
)

(let_expression "let" @append_spaced_softline (binding_set)* @do_nothing)
(let_expression
  (binding_set)? @append_spaced_softline @prepend_spaced_softline
  body: (_) @prepend_space
)

(comment) @keep_whitespace @leaf @multi_line_indent_all
(
  (comment) @append_hardline
  (#match? @append_hardline "^#")
)
(
  (comment) @prepend_indent_start @append_indent_end
  (binding_set)
)
(
  (binding_set)
  (comment) @prepend_indent_start @append_indent_end
)

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
    (_)? @prepend_spaced_softline
  )
)
(function_expression
  formals: (formals
    formal: (formal)*
    formal: (formal) @append_delimiter
    .
    ","* @do_nothing
    !ellipses
    (#delimiter! ",")
  )
)
(function_expression
  formals: (formals
    "{" @append_indent_start
    "}" @prepend_indent_end @prepend_spaced_softline
    .
  )
)
(function_expression body: (function_expression) @prepend_space)

(binding
  (function_expression
    body: (_
      (binding_set)* @do_nothing
      !formals !universal !body
    ) @prepend_indent_start @append_indent_end @prepend_spaced_softline
  )
)
