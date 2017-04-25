FUNCTION GAMINC,P,X
;+
; NAME:
;   GAMINC
; PURPOSE:
;   Compute the function = exp(X) / X^P * Int[exp(-X)*X^(P-1)dx]
;                                       (Int = Integrate from X to Infinity)
; CALLING SEQUENCE:
;   Result = gaminc(P,X)                ; X>0
;
; INPUTS:
;   X and P     See expression above for details
; RETURNS:
;       Expression returned is a vector the same length as X.
; HISTORY:
;    1-sep-93, J.R. Lemen (LPARL), Converted from a very old SMM Fortran program
;   14-Mar-94, Zarro (ARC) substituted routines from Numerical Recipes
;-

on_error,1

out=dblarr(n_elements(x))

;-- error checks

if n_elements(p) ne 1 then begin
 message,'input exponent must be scalar',/contin
 return,out
endif

if p lt 0 then begin
 message,'input exponent must be > 0',/contin
 return,out
endif

good=where(x gt 0.,count)
if count eq 0 then begin
 message,'input x must be > 0',/contin
 return,out
endif

y=double(x(good))

;-- if p=0 then compute first order exponential integral otherwise
;   compute complement of the incomplete gamma function

if p eq 0 then temp=y*alog10(exp(1))+alog10(nr_expint(1,y)) else $  
 temp=y*alog10(exp(1))-p*alog10(y)+alog10((gamma(p)-igamma2(p,y)))

out(good)=(10.d)^temp
return,out
end
