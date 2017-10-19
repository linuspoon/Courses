#lang racket #| Definitions in LC. |#

#| We still have one operation that is shorthand for something we can write in just LC: define.

 The way we use define implicitly contains two other operations, which will then be made explicit. |#

; Consider two definitions
(define two 2)
(define double (λ (x) (* two x)))
;  and a computation involving them:
(double two)

; That computation is "parameterized" by the meaning of the names, in other words it's a function of
;  the values of the names:
((λ (two double) (double two)) ; A computation, based on the values of ‘two’ and ‘double’.
                               ; an expression that combines 2 expressions
 2 ; The value of ‘two’.
 (λ (x) (* two x))) ; The value of ‘double’.

; Parameters already give us the ability to name a value and use that value by name.
; Let's make an expression form for that.
(define-syntax Let
  (syntax-rules ()
    [(Let [id e]
          e′)
     ((λ (id) e′)
      e)]))

; Now we can write
(Let [two 2]
     (Let [double (λ (x) (* two x))]
          (double two)))
;  to mean
((λ (two)
   ((λ (double)
      (double two))
    (λ (x) (* two x))))
 2)


; Let's try that with a recursive definition.
#;(define ! (λ (n) (cond [(zero? n) 1]
                         [else (* n (! (sub1 n)))])))
#;(! 5)


#;(Let [! (λ (n) (cond [(zero? n) 1]
                       [else (* n (! (sub1 n)))]))]
       (! 5))
; That gets rewritten to:
#;((λ (!) (! 5))
   (λ (n) (cond [(zero? n) 1]
                [else (* n (! (sub1 n)))])))
; Now we have a problem: ‘!’ doesn't have a meaning in
#;(λ (n) (cond [(zero? n) 1]
               [else (* n (! (sub1 n)))]))


; Here's the trick: write the function with an extra parameter to refer to itself,
;  and call it by telling the function about itself.
(Let [!′ (λ (! n)
           (cond [(zero? n) 1]
                 ; Also has to then pass itself to itself.
                 [else (* n (! ! (sub1 n)))]))]
     (!′ !′ 5))
; That gets rewritten to:
((λ (!′) (!′ !′ 5))
 (λ (! n) (cond [(zero? n) 1]
                [else (* n (! ! (sub1 n)))])))
; Y combinator ... 