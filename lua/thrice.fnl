;; thrice.fnl
(fn thrice-if [condition result]
  (fn step [i]
    (if (< 0 i)
        `(if ,condition (do ,result ,(step (- i 1))))))
  (step 3))

(local margs [...])

(fn check-margs [] margs)

{: thrice-if : check-margs}
