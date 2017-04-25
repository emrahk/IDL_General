;+
; NAME:
;       igamma2
; PURPOSE:
;      compute incomplete gamma function
; CALLING SEQUENCE:
;      z=igamma2(a,x)
; INPUTS:
;      a = positive exponent
;      x = independent variable (array or scalar; max value lt 35)
; OUTPUTS:
;      z = integral from 0 to X of EXP(-T) T^(A-1) for A > 0.
; MODIFICATION HISTORY:     
;      DMZ (ARC) Aug'92
;      Adapted from Numerical Recipes in C (p.171)
;-


function igamma2,a,z   ;incomplete gamma function

on_error,1
if a le 0 then message,'exponent must be positive'
s=size(z)              
a=double(a) & z=double(z) 
if s(0) eq 0 then z=replicate(z,1)
np=n_elements(z) & val=dblarr(np) & gama=gamma(a)
coeff=exp(-z)*z^a 
kmax=100 & eps=3.e-7
for i=0,np-1 do begin
 x=z(i)
 if x eq 0. then begin val(i)=0. & goto,quit & endif
 
 if x lt (a+1.) then begin                        ;-- use power series
  ap=a & sum=1./a & del=sum
  for k=1,kmax do begin
   ap=ap+1 & del=del*x/ap & sum=sum+del
   if (abs(del) lt abs(sum)*eps) then begin
    val(i)=coeff(i)*sum & goto,quit
   endif
  endfor
 endif else begin                              ;-- use continued fraction

  a1=x 
  gold=0 & fac=1. & b1=1. & b0=0. & a0=1. 
  for k=1,kmax do begin
   an=float(k) & ana=an-a
   a0=(a1+a0*ana)*fac
   b0=(b1+b0*ana)*fac
   anf=an*fac
   a1=x*a0+anf*a1
   b1=x*b0+anf*b1
   if (a1 gt 0.) then begin
    fac=1./a1
    g=b1*fac
    if abs((g-gold)/g) lt eps then begin
     val(i)=gama-coeff(i)*g & goto,quit
    endif 
    gold=g
   endif
  endfor
 endelse
 quit: 
endfor

if n_elements(val) eq 1 then val=val(0)
return,val
end
  


