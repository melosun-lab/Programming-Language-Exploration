#lang racket
(provide (all-defined-out))

(define (lambda? x)
  (member x '(lambda λ))
)

(define (expr-compare x y)
  (cond
    [(equal? x y) x]
    [(and (boolean? x) (boolean? y))
      (if x '% '(not %))]
    [(or (or (not (list? x)) (not (list? y)) (not (equal? (length x) (length y)))))
      (list 'if '% x y)]
    [#t (check x y)]
  )
)

(define (check x y)
  (let ((hdx (car x)) (hdy (car y)))
    (cond
      [(and (lambda? hdx) (lambda? hdy))
        (if (not (equal? (length (cadr x)) (length (cadr y)))) 
          (list 'if '% x y)
          (lambda-case x y)
        )
      ]
      [(or (lambda? hdx) (lambda? hdy))
        (list 'if '% x y)]
      [(or (equal? hdx 'quote) (equal? hdy 'quote))
        (list 'if '% x y)]
      [(and (not (equal? hdx hdy)) (or (equal? hdx 'if) (equal? hdy 'if)))
        (list 'if '% x y)]
      [(and (not (equal? hdx hdy)) (and (list? hdx) (list? hdy)))
        (cons (expr-compare hdx hdy) (expr-compare (cdr x) (cdr y)))]
      [#t
        (tail-case x y)]
    )
  )
)


(define (tail-case x y)
  (if (null? y)
    null
    (let ((hdx (car x)) (hdy (car y)))
      (cond
        [(equal? hdx hdy)
	  (cons hdx (tail-case (cdr x) (cdr y)))]
        [(and (list? hdx) (list? hdy))
	  (cons (expr-compare hdx hdy) (tail-case (cdr x) (cdr y)))]
        [(and (boolean? hdx) (boolean? hdy)) 
	  (cons (if hdx '% '(not %)) (tail-case (cdr x) (cdr y)))]
        [#t
	  (cons (list 'if '% hdx hdy) (tail-case (cdr x) (cdr y)))]
      )
    )
  )
)

(define (get-args x y)
  (if (null? x)
    x
    (let ([hdx (car x)] [hdy (car y)] [tlx (cdr x)] [tly (cdr y)])
      (if (equal? hdx hdy)
        (cons hdx (get-args tlx tly))
        (cons (get-bound hdx hdy) (get-args tlx tly))
      )
    )
  )
)

(define (get-bound bx by)
  (string->symbol (string-append (symbol->string bx) "!" (symbol->string by)))
)

(define (get-hash cur ref)
  (if (null? cur)
    (hash)
    (hash-set (get-hash (cdr cur) (cdr ref)) (car cur) (car ref))
  )
)
 
(define (lambda-case x y)
  (let ([argx (cadr x)] [argy (cadr y)] [hdx (car x)] [hdy (car y)])
    (let ([args (get-args argx argy)])
      (let ([hashx (get-hash argx args)] [hashy (get-hash argy args)])
        (let ([xcheck (check-args argx hashx)] [ycheck (check-args argy hashy)] [xmatch (lambda-match #t (caddr x) hashx)] [ymatch (lambda-match #t (caddr y) hashy)])
          (if (and (equal? hdx 'lambda) (equal? hdy 'lambda))
            (cons 'lambda (cons (expr-compare xcheck ycheck) (cons (expr-compare xmatch ymatch) '())))
            (cons 'λ (cons (expr-compare xcheck ycheck) (cons (expr-compare xmatch ymatch) '())))
          )
        )
      )
    )
  )
)

(define (check-args args ref)
  (if (null? args)
    null
    (cons (hash-ref ref (car args) "Not found") (check-args (cdr args) ref))
  )
)

(define (lambda-match active tar ref)
  (cond
    [(null? tar)
     null]
    [(not (list? tar))
     (cond
       [(equal? (hash-ref ref tar "Not found") "Not found")
        tar]
       [#t
        (hash-ref ref tar "Not found")]
       )]
    [(equal? (car tar) 'quote)
     (cons (car tar) (cons (cadr tar) (lambda-match active (cddr tar) ref)))]
    [(and active (list? (car tar)))
     (cons (lambda-match active (car tar) ref) (lambda-match active (cdr tar) ref))]
    [#t
     (let ([match (hash-ref ref (car tar) "Not found")] [fst (car tar)] [snd (cdr tar)])
       (if (equal? match "Not found")
           (if (lambda? fst)
               (cons fst (lambda-match #f snd ref))
               (cons fst (lambda-match active snd ref))
               )
           (if (lambda? match)
               (cons match (lambda-match #f snd ref))
               (cons match (lambda-match active snd ref))
               )
           )
       )]
    )
)

(define (test-expr-compare x y) 
  (and (equal? (eval x)
               (eval `(let ((% #t)) ,(expr-compare x y))))
       (equal? (eval y)
               (eval `(let ((% #f)) ,(expr-compare x y))))))

(define test-expr-x '(lambda (x y) (lambda (x z) (if z #f (cons (quote CS) 90)))))
(define test-expr-y '(lambda (y x) (λ (y z) (if z #t (cons (quote 131) 80)))))
