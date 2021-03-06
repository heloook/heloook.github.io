;;;allow facts that are duplicates
(defrule start
 (declare (salience 1000))
 (initial-fact)
 =>
 (set-fact-duplication TRUE))


;;;deftemplate example
;;;modify if needed
(deftemplate oav (slot object) (slot attribute) (slot value) (slot cf))



;combine positive or zero certainty facts
(defrule combine-positive-cf
  ?f1 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf1&:(>= ?cf1 0)))
  ?f2 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf2&:(>= ?cf2 0)))
  (test (neq ?f1 ?f2))
  =>
  (retract ?f1)
  (modify ?f2 (cf =(+ ?cf2 (/ (* ?cf1 (- 100 ?cf2)) 100)))))


;combine negative cf
(defrule combine-neg-cf
  (declare (salience -1))
  ?f1 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf1&:(<= ?cf1 0)))
  ?f2 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf2&:(<= ?cf2 0)))
  (test (neq ?f1 ?f2))
  =>
  (retract ?f1)
  (modify ?f2 (cf =(+ ?cf2 (/ (* ?cf1 (+ 100 ?cf2)) 100)))))

;combine one positive and one negative cf whose sum is positive
(defrule neg-pos-cf
  (declare (salience -1))
  ?f1 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf1))
  ?f2 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf2))
  (test (neq ?f1 ?f2))
  (test (< (* ?cf1 ?cf2) 0))
  (test (>= (+ ?cf1 ?cf2) 0))
  (test (>= (abs ?cf1) (abs ?cf2)))
  =>
  (retract ?f1)
  (modify ?f2 (cf =(/ (- (* (+ ?cf1 ?cf2) 100) 
			       (/ (- 100 (abs ?cf2)) 2)) (- 100 (abs ?cf2))))))


(defrule neg-neg-cf
  (declare (salience -1))
  ?f1 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf1))
  ?f2 <- (oav (object ?o) (attribute ?a) (value ?v) (cf ?cf2))
  (test (neq ?f1 ?f2))
  (test (< (* ?cf1 ?cf2) 0))
  (test (<= (+ ?cf1 ?cf2) 0))
  (test (>= (abs ?cf1)(abs ?cf2)))
  =>
  (retract ?f1)
  (modify ?f2 (cf =(/ (+ (* (+ ?cf1 ?cf2) 100)
			       (/ (- 100 ?cf2) 2)) (- 100 ?cf2)))))



;;;example facts to use in testing the CF rules
(deffacts test_of_cf
 (oav (object cat)(attribute color)(value black)(cf 25))
 (oav (object cat)(attribute color)(value black)(cf 45))
 (oav (object cat)(attribute color)(value black)(cf 35))
 (oav (object cat)(attribute color)(value black)(cf 35))
 (oav (object cat)(attribute color)(value black)(cf -35))
 (oav (object cat)(attribute color)(value black)(cf -45))
 (oav (object cat)(attribute color)(value black)(cf -35))
)
