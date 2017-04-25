

FUNCTION LAMB2V, DLAMBDA, LAMBDA

;+
; NAME
;
;      LAMB2V()
;
; EXPLANATION
;
;      Converts a wavelength to a velocity.
;
; INPUTS
;
;      DLAMBDA  A line shift.
;
;      LAMBDA   The line's rest wavelength.
;
; OUTPUT
;
;      The velocity corresponding to the line shift, in km/s.
;
; HISTORY
;
;      Ver.1, Peter Young, 20-Oct-2000
;      Ver.2, Peter Young, 4-Feb-2008
;        corrected typo for c (2.9978 instead of 2.9979).
;-

IF n_params() LT 2 THEN BEGIN
  print,'Use:  IDL> velocity=lamb2v(dlambda,lambda)'
  return,0.
ENDIF

dlambda = DOUBLE(dlambda)
lambda = DOUBLE(lambda)

c = 2.997924580d5     ; km/s

velocity = dlambda/lambda * c

return, velocity

END
