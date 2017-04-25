;+
; Project:  YOHKOH-BCS
;
; Name:     DVOIGT_FIT
;
; Purpose:  Double voigt function fit to line profile
;
; Syntax:   v=dvoigt_fit(x,y,a,sigmaa,damp=damp)
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
;       a(7) = intensity (2)
;       a(8) = center (2)
;       a(9) = width (2)
;       a(10) = damping width (2)
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
; History:      Version 1,  17-July-1987,  D M Zarro.  Written
;
; Contact:      DZARRO@SOLAR.STANFORD.EDU
;-            

 function dvoigt_fit,x,y,a,sigmaa,damp=damp,fixp=fixp,weights=weights,$
           chi2=chi2,last=last,nfree=nfree,corr=corr

 if not keyword_set(last) or (n_elements(a) eq 0) then begin
  guess_fit_par,x,y,fit_par,/double
  if n_elements(damp) eq 0 then damp=.01*fit_par(5)
  a=[fit_par(0:5),damp,fit_par(6:8),damp]
  a(3)=sqrt(!pi)*a(5)*a(3)       ;--- total line strength (1)
  a(7)=sqrt(!pi)*a(9)*a(7)       ;--- total line strength (2)
 endif

 v=funct_fit(x,y,weights=weights,a,sigmaa,funct='mvoigt',$
         fixp=fixp,chi2=chi2,nfree=nfree,corr=corr,/verbose)

 return,v
 end

