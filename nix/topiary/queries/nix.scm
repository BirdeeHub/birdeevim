[
  "="
  ">"
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
] @prepend_space @append_space

(attrset_expression
  (binding_set
    (binding [
      (attrpath)
      (identifier)
    ]* . "=" . (_) ";") @append_spaced_softline
  ) @prepend_indent_start @append_indent_end
) @multi_line_indent_all

; Don't format strings or comments
[
  (string_expression)
  (comment)
] @leaf

[
  "."
] @prepend_antispace @append_antispace

(function_expression
  formals: (formals
    ((formal (identifier)) ","?)*
    .
    (ellipses)?
  ) @prepend_hardline @leaf
  ":" @append_hardline
)
