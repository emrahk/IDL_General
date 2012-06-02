PRO lorenzc, x, a, f, pder
; x is an array containing values at which to evaluate function
; a is an array of function parameters
; f is an array containing result of evaluating function

; for lorenz_c parameters are
; a[0] centriod frequency of lorentzian
; a[1] width of lorentzian
; a[2] normalization of lorentzian
; a[3] additive constant 

  lor = 1.0/(1.0+2.0*((x-a[0])/a[1])^2)
  f = a[2]*lor + a[3]   

  ; If the procedure is called with four parameters, 
  ; then calculate the partial derivatives.
  IF n_params() ge 4 THEN BEGIN

    pder= [[8.0*a[2]*(x-a[0])*(lor^2)/(a[1]^2)], $
           [8.0*a[2]*((x-a[0])^2)*(lor^2)/(a[1]^3)], $
           [lor], $
           [replicate(1.0, N_ELEMENTS(X))]]
  ENDIF
  ;print, 'lorenzc ', a
  ;STOP
END
