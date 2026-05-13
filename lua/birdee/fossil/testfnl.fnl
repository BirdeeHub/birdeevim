(import-macros {: -|> : -?|>} :birdee.utils)

(local s "hi there")
(print (-|> "hi there" (:upper) (:sub 3 8) (:reverse)))
(print (: (: (: "hi there" :upper) :sub 3 8) :reverse))


(local sh (doto
  ((. (require :shelua) :add_reprs) ((require :sh)) "uv")
  (tset :shell :uv)
  (tset :proper_pipes true)
))
(var res (-|> (sh.CD :/home)
  (:ls :-la)
  (:cat
    (-|> (sh.CD :/home/birdee) (:pwd))
    (sh.echo "Hello fennel")
  )
  (:sed :s/Hello/Goodbye/g)
))
(set res (.. res "\n"
  (-|> (sh.CD :/home)
    (:ls :-la)
    (:cat
      (-|> (sh.CD :/home/birdee) (:pwd))
      (sh.echo "Hello fennel")
    )
    (:sed :s/Hello/Goodbye/g)
  )
  "\n" (vim.inspect { :hi "hello" })
  "\n" (vim.inspect (table.pack ...))
))
(set res (.. res "\n ITER TEST \n"))
(each [i v (ipairs [8 38 28 2 2 1 4 nil 12345 12345 12345])]
  (set res (.. res "\n" (vim.inspect i) " : " (vim.inspect v)))
)
res
