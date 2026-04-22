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

(attrset_expression) @multi_line_indent_all

(binding_set (binding) @prepend_spaced_softline @append_spaced_softline)

(function_expression
  formals: (formals
    formal: (formal) @prepend_spaced_softline
    universal: (identifier)? @prepend_spaced_softline
    ellipses: (ellipses)? @prepend_spaced_softline @append_spaced_softline @append_indent_end
  ) @prepend_hardline @prepend_indent_start
  ":" @append_hardline
) @multi_line_indent_all
