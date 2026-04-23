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

(binding_set (binding) @prepend_spaced_softline @append_spaced_softline) @prepend_indent_start @append_indent_end

(if_expression
  condition: (_) @prepend_spaced_softline @append_spaced_softline
  consequence: (_) @prepend_spaced_softline @append_spaced_softline
  alternative: (_)
)
(if_expression
  alternative: (_ !condition !consequence !alternative) @prepend_spaced_softline
)

(function_expression
  formals: (formals
    formal: (formal) @prepend_spaced_softline @prepend_indent_start @append_indent_end
    ellipses: (ellipses)? @prepend_spaced_softline @append_spaced_softline
  )
)
(function_expression
  universal: (identifier) @prepend_spaced_softline
  .
  formals: (formals)
  body: (_) @prepend_spaced_softline
)
(function_expression
  formals: (formals)
  .
  universal: (identifier)?
  body: (_) @prepend_spaced_softline
)
