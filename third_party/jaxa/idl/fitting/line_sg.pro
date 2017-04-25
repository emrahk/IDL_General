
;+
; NAME
;
;    LINE_SG
;
; EXPLANATION
;
;    Defines a straight line to be used as the background when performing
;    Gaussian fits with the SPEC_GAUSS suite of IDL routines.
;
;    The format is that required by the MPFIT routines.
;
; INPUTS
;
;    X   The points at which the function is evaluated. Typically these
;        will be wavelength values.
;
;    P   A two element array that describes the straight line. P[0] is the
;        value of the function at X=MIN(X) and P[1] is the value at X=MAX(X).
;
; OUTPUT
;
;    The values of the linear function defined by P at the input values X.
;
; HISTORY
;
;    Ver.1, Peter Young, 5-Aug-2005
;-

FUNCTION line_sg, x, p
;
; this is needed by mpfitexpr
; Note that min(x) is the x-value at which y=p[0], and max(x) is the 
; x-value at which y=p[1]
;
f=(x-min(x))*(p[1]-p[0])/(max(x)-min(x)) + p[0]
return,f
END

