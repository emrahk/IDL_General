;+
; Project     :  YOHKOH-BCS
;
; Name	      :  FBLUE_FIT
;
; Purpose     :  Fit double gaussian + quadratic using a blueshift model
;
; Explanation:
;
; Category    : fitting
;
; Syntax      : yfit = fblue_fit(x,y,a,fac=fac)
;
; Inputs      : y = data to fit
;               x = bin or wavelength
;
; Outputs     : yfit, a = fitted function + parameters
;               yfit = a(0)+a(1)*x+a(2)*x^2+a(3)*exp -[(x-a(4))/a(5)]^2 +
;                      a(6)*exp -[(x-a(4)+a(7))/f*a(7)]^2

; Opt. Outputs: sigmaa = sigma errors
;
; Keywords    : weights = data weights
;               nfree  = number of free parameters
;               chi2   = chi^2
;               last   = set to use input 'a' values as starting values
;               fixp   = indicies of parameters to fix
;               fac    = doppler broadening = fac * blueshift [def=1]
;
; Restrictions: Input spectrum must at least look asymmetric
;
; Side effects: None
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                            
function fblue_fit, x, y, a,sigmaa,fac=fac,chi2=chi2,$
                    weights=weights,nfree=nfree,last=last,fixp=fixp

common fblue,f1

if n_elements(fac) eq 0 then fac=1
f1=fac

if (not keyword_set(last)) or (n_elements(a) eq 0) then begin
 guess_fit_par,x,y,fit_par,/blue
 bshift=fit_par(4)-fit_par(7)
 a=[fit_par(0:6),bshift]
endif

f=funct_fit(x,y,a,sigmaa,funct = 'fblue',chi2=chi2,weights=weights,$
            fixp=fixp,nfree=nfree)

return,f

end
