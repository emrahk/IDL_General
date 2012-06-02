PRO TRIPP_FIT_SINUS, x,a,f,pder
;+
; NAME:                      
;                            TRIPP_FIT_SINUS
;
;
;
; PURPOSE:                   
;                            provide sinus function as needed for
;                            input by TRIPP_CURVEFIT
;
;
;
; CATEGORY:                  
;                            auxilary fitting routine
;
;
;
; CALLING SEQUENCE:          
;                            tripp_fit_sinus,x,a,f,pder
;
;
;
; INPUTS:                    
;                            x   : 
;                            a   :
;                            f   :
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;                            pder: 
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:  
;       Version 1.0, 1999/07,Stefan Dreizler
;       Version 1.1, 2001/02,Stefan Dreizler, corrected sign error
;
;-

on_error,2                      ;Return to caller if an error occurs

pi=!dpi

nterms  = n_elements(a)
npoints = n_elements(x)

sum2 = 0.
FOR j=1,(nterms-4)/3 DO BEGIN
    jj = 3*(j - 1)+4
    sum2=sum2+a[jj]*sin(2.*pi*(x/a[jj+1]-a[jj+2]))
ENDFOR

f = sum2 + a[0] + x*(a[1] + x*(a[2] + x*a[3]))


dfda0 = dblarr(npoints)
dfda1 = dblarr(npoints)
dfda2 = dblarr(npoints)
dfda3 = dblarr(npoints)
dfda4 = dblarr(npoints)
dfda5 = dblarr(npoints)
dfda6 = dblarr(npoints)

FOR j=1,(nterms-4)/3 DO BEGIN
    jj = 3*(j - 1)+4
    dfda0(*) = 1.      
    dfda1(*) = x      
    dfda2(*) = x*x 
    dfda3(*) = x*x*x
    dfda4(*) =       sin(2.*pi*(x/a[jj+1]-a[jj+2])) 
    dfda5(*) =-a[jj]*cos(2.*pi*(x/a[jj+1]-a[jj+2]))*2.*pi*x/a[jj+1]/a[jj+1]
    dfda6(*) =-a[jj]*cos(2.*pi*(x/a[jj+1]-a[jj+2]))*2.*pi
    IF (j EQ 1) THEN pder  = [[dfda0],[dfda1],[dfda2],[dfda3],[dfda4],[dfda5],[dfda6]]
    IF (j GT 1) THEN pder  = [[pder],[dfda4],[dfda5],[dfda6]]
ENDFOR

END
