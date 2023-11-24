; a = angle of turn
; R = vector from the point of turn
; to center of circle with r=1 tangent to both lines
; (if you want a different sized circle, multiply R by the radius you want)
;
; tl;dr:
; R = (sqrt (+ (square (tan (/ a 2))) 1))
; 
; When making a 45-degree turn, R = 1.082

(tan (/ pi 4))
; = 1

(defun square (x) (* x x))
(defun diag (x y) (sqrt (+ (* x x) (* y y ))))

; R based on knowing that d = (sqrt 2) when ang = 45 degrees
(diag 1 (- (sqrt 2) 1))
; = 1.082

; d according to new formula
(tan (/ pi 8))
; = 0.414; correct

; R according to new calculation
(sqrt (+ (square (tan (/ pi 8))) 1))

; Okay so how to determine a?
(defun angle-of (vec)
  (+ (cond ((< (car vec) 0)
	    (cond ((< (cadr vec) 0) (- 0 pi))
		  (t pi)))
	   (t 0))
     (atan (/ (cadr vec) (car vec)))))
(angle-of (list -1 -1))

; That seems to work but it's ugly!
; According to the Handbook of Chemistry and Phsyics, 37th edition, p321,
; tan(x/2) = += sqrt( (1-cos(x))/(1+cos(x)) ) = (1-cos(x))/sin(x) = sin(x)/(1 + cos(x))
; With that, we don't need to convert to an angle and back!
; ...at least not if our first line is along the X axis.

(defun calc-big-R (vec2) (sqrt (+ (square (/ (sin (car vec2)) (cos (cadr vec2)))) 1)))

; Dad says i should be able to do all of this without resorting
; to any trigonometry functions.
; In analytic geometry they just use a lot of X and Ys and maybe some sqrts
; Maybe try googling "circle tangent to two lines"

(calc-big-R (list 1 1))
; = 1.85.  Well that's wrong.
