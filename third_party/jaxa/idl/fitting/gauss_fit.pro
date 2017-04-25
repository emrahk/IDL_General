;+
; Project     :  YOHKOH-BCS
;
; Name	      :  GAUSS_FIT
;
; Purpose     : Gaussian function fit to line profile
;;
; Category    : fitting
;
; Syntax      : g=gauss_fit(x,y,a,sigmaa)
;
; Inputs      : y = data to fit
;               x = bin or wavelength
;
; Outputs     : background=a(0)+a(1)*x+a(2)*x^2
;               a(3) = peak intensity
;               a(4) = center
;               a(5) = doppler width
;               a(6) = peak intensity (2nd cmpt)
;               a(7) = center (2nd cmpt)
;               a(8) = doppler width (2nd cmpt)
;
; Opt. Outputs: sigmaa = sigma errors
;
; Keywords    : weights = data weights
;               nfree  = number of free parameters
;               chi2   = chi^2
;               last   = set to use input 'a' values as starting values
;               fixp   = indicies of parameters to fix
;               status = 1/0 converged/not converged
;               broad  = 1 for broadened GAUSSIAN (CDS-NIS only)
;               no_back = do not fit background
;               double  = try double gauss fit
;               last    = use last fitted parameters as starting guess
;               err= 0 for success, 1 for fail
; Restrictions: 
;               The peak or minimum of the Gaussian must be the largest
;	        or smallest point in the Y vector.
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;               Version 2,  14-Sept-1999, Zarro (SM&A) - incorporated
;                          broadened gaussian function
;               11-June-2000, Zarro (EIT/GSFC) - added /double
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function gauss_fit, x, y, a,sigmaa,chi2=chi2,weights=weights,nfree=nfree,$
                    no_back=no_back,err=err,double=double,$
                    fixp=fixp,last=last,status=status,broad=broad,_extra=extra
err=0

;-- only try parameter guessing for single or double component fits

if n_elements(x) ne n_elements(y) then begin
 err=1 & message,'# of data and fit coordinates must match',/cont
 return,0
endif

get_guess=(1-keyword_set(last)) or (1-exist(a))
if exist(a) then asave=a
na=n_elements(a) & guessed=0
if get_guess and (na le 9) then begin
 if na eq 9 then double=1
 guess_fit_par,x,y,aguess,double=double 
 guessed=1
endif else aguess=a

if exist(fixp) and exist(asave) then begin
 chk=where( (fixp lt n_elements(a)) and (fixp ge 0),count)
 if count gt 0 then aguess(fixp(chk))=asave(fixp(chk))
endif

;-- try CDS broadened GAUSS

if keyword_set(broad) then begin
 funct='bgauss'  
 f=bgauss(x,aguess,err=berr,nis=nis)
 if berr ne '' then begin
  err=1
  return,0
 endif
endif else funct='mgauss'


;-- switch-off background fit

if keyword_set(no_back) then begin
 aguess(0:2)=0 & fixp=[0,1,2]
endif

dprint,'% aguess: ',aguess

fit=funct_fit(x,y,aguess,sigmaa,weights=weights,fixp=fixp,_extra=extra,$
		funct = funct,chi2=chi2,nfree=nfree,status=status) 

a=aguess

return,fit

end

