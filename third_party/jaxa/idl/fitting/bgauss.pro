;+
; Project     : SOHO-CDS
;    
; Name        : BGAUSS
;
; Purpose     : Compute multiple CDS broadened gauss functions with quadratic background
;
; Explanation : Program checks no. of elements in a, of which there must
;               at least 6. First three elements define background. Remaining
;               elements define broadened gauss function(s) which must come in 
;               multiples of 3
;
; Category    : fitting
;
; Syntax      : f=bgauss(x,a,pder)
;
; Inputs      : x = dependent variable
;               a(0,1,2)=coefficients of quadratic background
;               a(3)= line intensity
;               a(4)= line center
;               a(5)= Doppler width = sqrt(2) * Gaussian width
;
; Outputs     : f = 'n' broadened gauss functions + quadratic background
;
; Opt Outputs : pder = partial derivatives wrt 'a'
;
; Keywords    : NIS = output value of 1 or 2 signalling if NIS1 or NIS2
;
; History     : Version 1,  13-Sept-1999,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;- 

 function bgauss,x,a,pder,err=err,extra=extra,nis=nis

 on_error,1
 err=''
 a=double(a) & na=n_elements(a) & np=n_elements(x)
 if na lt 6 then begin
  err='input parameter vector must contain at least 6 values'
  message,err,/cont
  return,0
 endif

 b=(a(0)+a(1)*x+a(2)*x^2)       ;compute background
 nr=na-3                        ;total no. of gaussian function parameters
 if (nr mod 3) ne 0 then begin
  err='input parameter vector must contain at least 1 gaussian cmpt'
  message,err,/cont
  return,0
 endif
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

;-- fix asymmetries according to NIS band
;   (assume x units are wavelength)

 chk= where( (x le 379) and (x ge 305),count)
 nis1=(count gt 0)
 chk= where( (x le 633) and (x ge 513),count)
 nis2=(count gt 0)
 if (nis1 eq nis2) then begin
  err='input dependent x-array does not fall within valid NIS1 or NIS2 wavelength range'
  message,err,/cont
  return,0
 endif

 if (nis1) then begin
  nis=1
  def_wing = 0.8
  def_asym = 1.0
 endif else begin
  nis=2
  def_wing = 0.317 
  def_asym = 0.279
 endelse

;-- now compute functions and partials

 g=fltarr(np) 
 for i=0,nr-1,3 do begin

;-- convert to Gaussian width for compatibility with comp_bgauss

  width=par(i+2)/sqrt(2.) 
  tpar=[par(i),par(i+1),width,def_wing,def_asym]
  comp_bgauss,x,tpar,prof,tpder
  if partial and exist(tpder) and exist(pder) then begin
   pder((i+3)*np)=tpder(*,0)
   pder((i+4)*np)=tpder(*,1)
   pder((i+5)*np)=tpder(*,2)
  endif
  g=g+prof
 endfor
 g=g+b                          ;add background

 return,g
 end
