;
; Absorb.pro: Absorb a spectrum with a certain NH using the
; approximation by Brown and Gould, 1970...
;
PRO absorb, spec, nh
  spec.f = spec.f * exp(-nh*7E-23/spec.e(*)^3.)
END 
