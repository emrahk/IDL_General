;+
; Project     : YOHKOH-BCS
;    
; Name        : MGAUSS
;
; Purpose     : Compute multiple gauss functions with quadratic background
;
; Explanation : Program checks no. of elements in a, of which there must
;               at least 6. First three elements define background. Remaining
;               elements define gauss function(s) which must come in 
;               multiples of 3.
;
; Category    : fitting
;
; Syntax      : f=mgauss(x,a,pder)
;
; Inputs      : x = dependent variable
;               a(0,1,2)=coefficients of quadratic background
;               a(3)= line intensity
;               a(4)= line center
;               a(5)= 1/e doppler width 
;
; Outputs     : f = n gauss functions + quadratic background
;
; Opt Outputs : pder = partial derivatives wrt 'a'
;
; Keywords    : extra = extra optional variable in which user can return
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

 function mgauss,x,a,pder,extra=extra         
 on_error,1

 getout='not enough parameters buddy !'

 a=double(a) & na=n_elements(a) & np=n_elements(x)
 if na lt 6 then begin
  message,getout,/cont
  return,0
 endif

 b=(a(0)+a(1)*x+a(2)*x^2)       ;compute background
 nr=na-3                        ;total no. of gaussian function parameters
 if (nr mod 3) ne 0 then message,getout
 nv=nr/3                        ;total no. of gaussians
 par=a(3:2+3*nv)                ;strip off parameters

;-- compute partials for background first

 if n_params() gt 2 then partial=1 else partial=0

 if partial then begin
  pder=dblarr(np,na)
  pder(0)=replicate(1.,np)
  pder(np)=x
  pder(2*np)=x*x
 endif

;-- now compute functions and partials

 g=fltarr(np)                   ;initialize array to store gaussian functions
 for i=0,nr-1,3 do begin       
  stren=par(i) & cent=par(i+1) & doppw=par(i+2)
  sdiff=(x-cent)/doppw
  diff=abs(sdiff) < 5.
  term=exp(-diff*diff)
  rat=stren/doppw
  prof=stren*term
  g=g+prof
  if partial then begin
   pder((i+3)*np)=term
   temp=2.*rat*sdiff*term
   temp2=temp*sdiff
   pder((i+4)*np)=temp
   pder((i+5)*np)=temp2
  endif
 endfor
 g=g+b                          ;add background

 return,g
 end
