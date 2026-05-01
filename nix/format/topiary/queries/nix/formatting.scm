(indented_string_expression
  .
  "''" @append_indent_start
  "''" @prepend_indent_end
  .
)
(interpolation
  .
  "${" @append_antispace
  "}" @prepend_antispace
  .
)
; new and improved multi_line_indent_all
(_ (string_fragment) @leaf @multi_line_indent_all)
(_ (string_fragment) @keep_whitespace .)
; (_ (string_fragment) @append_empty_input_softline)
; (string_expression (string_fragment) @leaf)

"!" @prepend_space @append_antispace
[
  ","
  ";"
  ":"
] @prepend_antispace @append_space

(with_expression
  "with" @append_space @prepend_space
  body: (_) @prepend_input_softline
)
(assert_expression
  "assert" @append_space @prepend_spaced_softline @prepend_indent_start
  condition: (_) @append_indent_end
  body: (_) @prepend_spaced_softline
)

; attr ? idk
(has_attr_expression
  expression: (_) @append_space
  attrpath: (attrpath) @prepend_space
)

; don't scrunch it
(_) @allow_blank_line_before

(binary_expression left: (_) @append_space right: (_) @prepend_space)

; attr.path
(select_expression
  expression: (_) @append_antispace
  attrpath: (attrpath) @prepend_antispace
)
; attr.path or default
(select_expression
  expression: (_)
  attrpath: (attrpath) @append_space
  default: (_) @prepend_space
)

; comments without them collapsing to 1 line or losing indentation
(comment) @keep_whitespace @multi_line_indent_all @leaf
(comment) @prepend_input_softline
(
  (comment) @append_hardline
  (#match? @append_hardline "^#")
)
(
  (comment)? @prepend_indent_start @append_indent_end
  (binding_set)
  (comment)? @prepend_indent_start @append_indent_end
)

(parenthesized_expression
  "(" @append_antispace
  ")" @prepend_antispace
)
(parenthesized_expression
  "(" @append_empty_softline @append_indent_start
  (_ (binding_set) @do_nothing)?
  (list_expression)? @do_nothing
  (parenthesized_expression)? @do_nothing
  (apply_expression function: (_ !formals !universal) . argument: [ (_ (binding_set)) (indented_string_expression) (parenthesized_expression (function_expression)) ] . )? @do_nothing
  (function_expression body: [ (_ (binding_set)) (indented_string_expression) ] . )? @do_nothing
  ")" @prepend_empty_softline @prepend_indent_end
  (#multi_line_only!)
)

; calling functions
(apply_expression
  function: (_) @append_space
  (_)* @append_spaced_softline
  (_)
  .
)

(let_attrset_expression
  (_) @prepend_spaced_softline
)
(let_attrset_expression
  (_) @append_spaced_softline
  .
)
(let_attrset_expression "let" @append_space)
(rec_attrset_expression "rec" @append_space)
(rec_attrset_expression
  (_) @prepend_spaced_softline
)
(rec_attrset_expression
  (_) @append_spaced_softline
  .
)
(attrset_expression
  (_) @prepend_spaced_softline
)
(attrset_expression
  (_) @append_spaced_softline
  .
)
(binding_set) @prepend_indent_start @append_indent_end
(binding_set (binding) @prepend_spaced_softline @append_input_softline)
(binding_set (comment) @append_spaced_softline)
(binding_set (inherit) @prepend_spaced_softline @append_input_softline)
(binding_set (inherit_from) @prepend_spaced_softline @append_input_softline)
(binding
  attrpath: (attrpath) @append_space
  (_)* @prepend_space
)

(let_expression "let" @append_spaced_softline (binding_set)? @do_nothing)
(let_expression
  (binding_set)? @append_spaced_softline @prepend_spaced_softline
  body: (_) @prepend_space
)

; lists without making comments be moved to the next line
(list_expression
  .
  "[" @append_indent_start
  "]" @prepend_indent_end
  .
)
(list_expression
  element: (_)? @prepend_spaced_softline
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
(inherited_attrs attr: (_)* @prepend_spaced_softline)

(if_expression
  "if" @append_indent_start @prepend_space
  condition: (_) @prepend_space @append_space
  "then" @append_indent_start @prepend_indent_end
  consequence: (_) @prepend_spaced_softline @append_spaced_softline
  "else" @prepend_indent_end @append_space
  alternative: (_) @append_space
)
; control indenting of else based on what is there so that `if ... then\n...\nelse if ... then` and bindings return to normal and stuff
(if_expression
  "else" @append_indent_start
  alternative: (_
    (string_fragment)? @do_nothing
    !condition !consequence !alternative
  ) @prepend_empty_softline @append_indent_end
)
(if_expression
  "else" @append_indent_start
  alternative: (indented_string_expression) @append_indent_end
)
(if_expression
  "else" @append_indent_start
  alternative: (string_expression) @prepend_empty_softline @append_indent_end
)

; formal (attrset destructuring) args formatting (general)
(function_expression "@" @prepend_antispace @append_antispace ":" @prepend_antispace)
(function_expression
  formals: (formals
    formal: (_)? @prepend_spaced_softline
    (comment)? @prepend_input_softline
    ellipses: (ellipses)? @prepend_spaced_softline
  )
)
; adds trailing , if no ... and no ,
(function_expression
  formals: (formals
    formal: (formal) @append_delimiter
    .
    (comment)? @do_nothing
    .
    ","? @do_nothing
    .
    (comment)? @do_nothing
    !ellipses
    (#delimiter! ",")
    .
  )
)
; , stdenv
; # args below:
; , lua_interpreter ? lua5_2
; # into
; stdenv,
; # args below:
; lua_interpreter ? lua5_2,
; i.e. it moves the , around the comment
(function_expression
  formals: (formals
    formal: (formal) @append_delimiter
    .
    ","? @do_nothing
    .
    (comment)
    .
    "," @delete
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
; { somearg ? default, ... }:
(formal
  name: (_) @append_space
  default: (_) @prepend_space
)

; adds an extra level of indent for the body of function if it is in a binding and is not also a function/binding set
(binding
  (function_expression
    body: (_
      (binding_set)? @do_nothing
      !formals !universal !body
    ) @prepend_indent_start @append_indent_end @prepend_spaced_softline
  )
)
; usually I want multi args on 1 line, but if they are both formals I want a newline
(function_expression body: (function_expression) @prepend_space)
(function_expression
  body: (function_expression
    formals: (formals)
  ) @prepend_empty_input_softline
)
