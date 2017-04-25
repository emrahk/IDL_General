;+
; Project:  YOHKOH-BCS
;
; Name:     VOIGT_FIT
;
; Purpose:  Single voigt function fit to line profile
;
; Syntax:   v=voigt_fit(x,y,a,sigmaa,damp=damp)
;
; Category: Fitting
;
; Inputs:
;       y = data to fit
;       x = bin or wavelength
;
; Outputs:
;       background=a(0)+a(1)*x+a(2)*x^2
;       a(3) = total intensity (1)
;       a(4) = center (1)
;       a(5) = doppler width (1)
;       a(6) = damping width (1)
;
; Opt. Outputs:
;      sigmaa = sigma errors
;
; Keywords:
;       damp   = damping width
;       fixp   = vector of parameters to keep fixed 
;                (e.g. fixp=[0,1,3] to fix parameters 1,2 and 4)
;       last   = use latest parameter values as new first guesses.
;       weights = data weights
;       nfree  = number of free parameters
;       chi2   = chi^2
;       corr   = link matrix
;
; Common: None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; History:      Version 1,  17-July-1993,  D M Zarro.  Written
;
; Contact:      DZARRO@SOLAR.STANFORD.EDU
;-            

 function voigt_fit,x,y,a,sigmaa,damp=damp,fixp=fixp,weights=weights,$
           chi2=chi2,last=last,nfree=nfree

 if not keyword_set(last) or (n_elements(a) eq 0) then begin
  g=gauss_fit(reform(x),reform(y),fit_par,fixp=[1,2],weights=weights)
  if n_elements(damp) eq 0 then damp=.01*fit_par(5)
  a=[fit_par,damp]
  a(3)=a(3)*a(5)*sqrt(!pi)
 endif


 v=funct_fit(reform(x),reform(y),weights=weights,a,sigmaa,funct='mvoigt',$
         fixp=fixp,chi2=chi2,nfree=nfree)

 return,v
 end

