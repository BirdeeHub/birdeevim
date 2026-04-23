; NOTE: This doesn't work btw but maybe I'll get to it eventually

[
  "=="
  "&&"
  "||"
  "="
  ">"
  "->"
  "<"
  "+"
  "-"
  "*"
  "if"
  "then"
  "else"
  "let"
  "inherit"
  "in"
  "rec"
  "with"
  "assert"
  "or"
  (identifier)
] @prepend_space @append_space

; Don't format strings or comments
[
  (string_expression)
  (comment)
] @leaf

[
  "."
  "@"
] @prepend_antispace @append_antispace

[
  ","
  ";"
  ":"
] @prepend_antispace @append_space

(binding_set) @prepend_indent_start @append_indent_end

(binding_set (binding) @prepend_spaced_softline @append_spaced_softline)

(if_expression
  "if" @append_indent_start
  condition: (_) @prepend_spaced_softline @append_spaced_softline
  "then" @append_indent_start @prepend_indent_end
  consequence: (_) @prepend_spaced_softline @append_spaced_softline
  "else" @append_indent_start @prepend_indent_end
  alternative: (_) @append_indent_end
)
(if_expression
  alternative: (_ !condition !consequence !alternative) @prepend_spaced_softline
)

(function_expression
  formals: (formals
    formal: (formal)? @prepend_spaced_softline
    ellipses: (ellipses)? @prepend_spaced_softline @append_spaced_softline
  )
)
(function_expression
  formals: (formals
    "}" @prepend_indent_end
  ) @prepend_indent_start
)
(function_expression
  body: (_) @prepend_spaced_softline
)
