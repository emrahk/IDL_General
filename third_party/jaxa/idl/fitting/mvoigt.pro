;+
; Project     : YOHKOH-BCS
;    
; Name        : MVOIGT
;
; Purpose     : Compute multiple voigt functions with quadratic background
;
; Explanation : Program checks no. of elements in a, of which there must
;               at least 7. First three elements define background. Remaining
;               elements define voigt function(s) which must come in 
;               multiples of 4.
;
; Category    : fitting
;
; Syntax      : v=mvoigt(x,a,pder)
;
; Inputs      : x =dependent variable
;               a(0,1,2)=coefficients of quadratic background
;               a(3)= line intensity
;               a(4)= line center
;               a(5)= 1/e doppler width 
;               a(6)= rocking width (1/e units)
;
; Outputs     : v = n voigt functions + quadratic background
;
; Opt Outputs : PDER = partial derivatives wrt 'a'
;
; Keywords    : EXTRA = extra optional variable in which user can return
;               miscellaneous information.
;
; Restrictions: None.
;
; Side effects: None.
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;- 

 function mvoigt,x,a,pder,extra=extra          ;voigt functions + background
 on_error,1

 getout='not enough parameters buddy !'
 sqpi=sqrt(!pi)
 a=double(a) & na=n_elements(a) & np=n_elements(x)
 if na lt 7 then begin
  message,getout,/cont
  return,0
 endif

 b=(a(0)+a(1)*x+a(2)*x^2)        ;compute background
 nr=na-3                        ;total no. of voigt function parameters
 if (nr mod 4) ne 0 then message,getout
 nv=nr/4                        ;total no. of voigt functions
 par=a(3:2+4*nv)                ;strip off voigt function parameters

;-- compute partials for background first

 if n_params() gt 2 then partial=1 else partial=0

 if partial then begin
  pder=dblarr(np,na)
  pder(0)=replicate(1.,np)
  pder(np)=x
  pder(2*np)=x*x
 endif

;-- now compute functions and partials

 g=fltarr(np)                   ;initialize array to store Voigt functions
 for i=0,nr-1,4 do begin       
  stren=par(i) & cent=par(i+1) & doppw=par(i+2) & rockw=par(i+3)
  v=(x-cent)/doppw
  aa=abs(rockw/doppw)
  pvoigt,aa,v,h,f
  dhdv=2.*(aa*f-v*h)
  dhda=2.*(aa*h+v*f-1./sqpi)
  dvdw=-v/doppw
  dadw=-aa/doppw
  rat=stren/doppw/sqpi
  prof=rat*h
  g=g+prof
  if partial then begin
   pder((i+3)*np)=h/doppw/sqpi
   pder((i+4)*np)=-rat*dhdv/doppw
   pder((i+5)*np)=-prof/doppw+rat*(dhda*dadw+dhdv*dvdw)
   pder((i+6)*np)=rat*dhda/doppw
  endif
 endfor
 g=g+b                          ;add background

 return,g
 end
