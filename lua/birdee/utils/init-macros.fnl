;; threader.fnl
(fn idempotent-expr? [x]
  "Checks if an object is an idempotent expression. Returns the object if it is."
  (let [t (type x)]
    (or (= t :string) (= t :number) (= t :boolean)
        (and (sym? x) (not (multi-sym? x))))))

(fn -|> [val ...]
  "Lua index method chain val(\"a\"):val2(\"b\"):val3(\"c\")
Like -> except it inserts the method as well.
Take the first value insert it into the second form as its first argument.
The value of the second form is spliced into the first arg of the third, etc."
  (var x val)
  (each [_ e (ipairs [...])]
    (let [elt (if (list? e) e (list e))]
      (table.insert elt 1 x)
      (table.insert elt 1 (sym ":"))
      (set x elt)))
  x)

(fn -?|> [val ?e ...]
  "Nil-safe index method chain macro.
Same as -|> except will short-circuit with nil when it encounters a nil value."
  (if (= nil ?e)
      val
      (not (idempotent-expr? val))
      ;; try again, but with an eval-safe val
      `(let [tmp# ,val]
        (-?|> tmp# ,?e ,...))
      (let [call (if (list? ?e) ?e (list ?e))]
        (table.insert call 1 val)
        (table.insert call 1 (sym ":"))
        `(if (not= nil ,val)
             ,(-?|> call ...)))))

{: -|> : -?|> : idempotent-expr?}
