

FUNCTION V2LAMB, V, LAMBDA

;+
; NAME
;
;      v2lamb()
;
; EXPLANATION
;
;      Converts a velocity to a wavelength shift.
;
; INPUTS
;
;      V        The velocity, km/s.
;
;      LAMBDA   The line's rest wavelength, angstroms.
;
; OUTPUT
;
;      The wavelength shift corresponding to the velocity.
;
; HISTORY
;
;      Ver.1, Peter Young, 20-Oct-2000
;      Ver.2, Peter Young, 4-Feb-2008
;        corrected typo for c (2.9978 instead of 2.9979).
;-

IF n_params() LT 2 THEN BEGIN
  print,'Use:  IDL> shift=v2lamb(v,lambda)'
  return,0.
ENDIF


v = DOUBLE(v)
lambda = DOUBLE(lambda)

c = 2.997924580d5     ; km/s

dlambda = v/c * lambda

return, dlambda

END
