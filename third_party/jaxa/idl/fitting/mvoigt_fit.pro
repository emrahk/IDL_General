;+
; Project:  YOHKOH-BCS
;
; Name:     MVOIGT_FIT
;
; Purpose:  multiple voigt function fit to line profile
;
; Explanation : 
;
; There must be at least 7 elements in the variable 'a'. First three elements 
; define background. Remaining elements define voigt function(s) 
; which must come in multiples of 4 with:
;   a(3) = total wavelength integrated line strength
;   a(4) = line center
;   a(5) = doppler width (1/e width)
;   a(6) = damping width (Lorentzian broadening parameter
;          expressed as a 1/e value in the same units as the doppler width. 
;
; Syntax:   v=mvoigt_fit(x,y,a,sigmaa)
;
; Category: Fitting
;
; Inputs:
;       y = data to fit
;       x = bin or wavelength
;
; Outputs:
;       background=a(0)+a(1)*x+a(2)*x^2
;       a(3) = total intensity
;       a(4) = center 
;       a(5) = doppler width 
;       a(6) = damping width
;
; Opt. Outputs:
;      sigmaa = sigma errors
;
; Keywords:
;       fixp   = vector of parameters to keep fixed 
;                (e.g. fixp=[0,1,3] to fix parameters 1,2 and 4)
;       weights = data weights
;       nfree  = number of free parameters
;       chi2   = chi^2
;       same_damp = keep damping width the same for all profiles
;               
; History:      Written 12-Dec-1998, Zarro (SMA/GSFC) 
;
; Contact:      DZARRO@SOLAR.STANFORD.EDU
;-            

 function mvoigt_fit,x,y,a,sigmaa,fixp=fixp,weights=weights,$
           chi2=chi2,nfree=nfree,same_damp=same_damp

 na=n_elements(a) & np=n_elements(x)
 if na lt 7 then begin
  message,'insufficient parameters - need 3 background + 4 line parameters',/cont
  return,0
 endif

;-- total no. of voigt function parameters

 nr=na-3  
 if (nr mod 4) ne 0 then begin
  message,'need at least 1 profile to fit',/cont
  return,0
 endif

;-- fix damping parameter to that of last profile (if same for each profile)

 if keyword_set(same_damp) then begin
  corr=fltarr(na,na)
  for i=na-1,0,-4 do begin
   if (i gt 2) and (i lt (na-1)) then corr(i,na-1)=1.
  endfor
 endif

 v=funct_fit(x,y,weights=weights,a,sigmaa,funct='mvoigt',$
         fixp=fixp,chi2=chi2,nfree=nfree,corr=corr,/verbose)

 return,v
 end

