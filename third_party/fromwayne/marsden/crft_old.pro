function crft,x,y,wd,a,afit,sigmaa,tlive,function_name,iter,chisqr,nfree
;*****************************************************************************
; Program performs a non-linear least squares fit to a function of
; an arbitrary number of parameters, Thefunction may be any non-linear
; function where the partial derivatives are known or can be approximated.
; based on Bevington (237-239).
; Variables are:
;             x...............array of independent variables
;             y...............array of dependent variables
;            wd...............array of data weights (w=1 no weight)
;            bw...............flag(1=model weight,0=data weight)
;             a...............initial guess for each parameter
;          afit...............elements of a to fit (1 = fit it)
;         tlive...............livetime for finding model weights
; function_name...............procedure for fit function (see below)
; Outputs are:
;          yfit...............vector of best-fit values
;             a...............vector of best fit parameter values
;        sigmaa...............vector of errors on a
; Restrictions on funct:
; The function to be fit must be written separately as a procedure in
; terms of the parameters a, expressing functional value f as a function of 
; independent variables x. The partial derivatives of the function with 
; respect to the parameters pder must be included as well, evaluated at 
; the points x. Example : Funct,x,a,f,pder 
; Additional notes:
;       Written originally by DMS,RSI in 9/82
;       Modifications suggested by LAF 4/93,11/93
;
; First do preliminary stuff
;         nterms.........# of parameters
;          nfree.........# degrees of freedom
;        flambda.........step size
;           diag.........subscripts of diagonal elements
;****************************************************************************
pfl = 1
anz = where(a ne 0.)
if (anz(0) eq -1)then return,a
w = wd & bw = 0
fz = where(afit eq 0)
ft = where(afit ne 0)
if (fz(0) eq -1)then nm_ft=n_elements(a) else $
nm_ft=n_elements(a)-n_elements(fz)
if n_elements(function_name) le 0 then function_name = 'funct'
nterms = nm_ft
nfree = (n_elements(y)<n_elements(x)) - nterms
if nfree le 0 then stop,'CRFT - NOT ENOUGH DATA POINTS'
flambda = .001
diag = indgen(nterms)*(nterms+1)
wm = fltarr(n_elements(x))
a = 1.*a
b = a
;***************************************************************************
; Evaluate alpha and beta matrices
;         chisq1..........present chi squared
;              b..........new parameters
;             wm..........model weight
;             wd..........data weight
;***************************************************************************
for iter = 1,20 do begin
 call_procedure,function_name,x,a,yfit,tlive,wm,pder
 pder = pder(*,ft)
 if (bw eq 0) then begin                       ; data weight
    print,'USING DATA WEIGHTS'
    beta = transpose((y - yfit)*wd) # pder
    alpha = transpose(pder) # (wd # (fltarr(nterms) + 1)*pder)
 endif else begin
    print,'USING MODEL WEIGHTS'
    b_f = .5*(wm + wd)*(wm/wd)
    a_f = (wm/wd)*(y/yfit)*(y/yfit)    
    beta = transpose((y - yfit)*b_f) # pder
    alpha = transpose(pder)#(wd*a_f#(fltarr(nterms)+1)*pder)
 endelse
 chisq1 = total(w*(y - yfit)^2)/nfree
;****************************************************************************
; Check for a good initial fit
;****************************************************************************
 if chisq1 lt total(abs(y))/1e7/nfree then begin
    sigmaa = fltarr(nterms)  ; return all 0's
    return,yfit
 endif
;****************************************************************************
; Invert modified curvature matrix to find new parameters
;****************************************************************************
 repeat begin
    c = sqrt(alpha(diag) # alpha(diag))
    array = alpha/c
    array(diag) = 1. + flambda
    if (n_elements(ft) eq 1)then array=1./array else array=invert(array) 
    b(ft) = a(ft) + array/c # transpose(beta)
    call_procedure,function_name,x,b,yfit,tlive,wm
    chisqr = total(w*(y - yfit)^2)/nfree
    flambda = flambda*10.
    endrep until chisqr le chisq1
 flambda = flambda/100.
 a(ft) = b(ft)
 print,'ITERATION =',iter,' ,CHISQR/DOF =',chisqr,' DOF=',nfree
 print,a
;***************************************************************************
; Check if finished and wrap it up. Modifications in original routine
; due to LAF. 
; 8/16/93 switches to model weighting if close to fit
;***************************************************************************
 if ((abs(chisq1-chisqr)/chisq1) le .001 and bw eq 1 and $
      (chisq1 - chisqr)*nfree le .01 and flambda le pfl) then goto,done
 pfl = flambda
 if (abs(chisq1 - chisqr)/chisq1 le .1)then bw = 1
endfor
message,'FAILED TO CONVERGE',/informational
done: array = alpha/c
      sigmaa = fltarr(n_elements(a))
      if(n_elements(ft) eq 1)then array=1./array else array=invert(array)
      covmat = array/c
      sigmaa(ft) = sqrt(covmat(diag))
      return,yfit
;***************************************************************************
; Thats all ffolks
;***************************************************************************
end
