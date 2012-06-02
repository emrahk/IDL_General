PRO tcchisq, hist, curve, min=min, max=max, chisq=chisq, pars=pars, redchisq=redchisq, pr=pr
   
;+
; NAME:            tcchisq
;
;
;
; PURPOSE:
;		   Calculate Chisquared
;
;
; CATEGORY:
;                  Data Analysis
;
;
; CALLING SEQUENCE:
;                  
;
; 
; INPUTS:
;                  hist: histogram
;                  curve: curve fitted to histogram
;
;
; OPTIONAL INPUTS:
;                  min, max: min. and max. of histogram position used
;                            for calculation
;                  pars: number of parameters in fit
;   
;
; KEYWORD PARAMETERS:
;                  pr: print results
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;		   chisq: Chisquared
;                  redchisq: Reduced Chisquared
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  For calculation of reduced chisquared, pars must be
;                  given 
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 04.05.00 T. Clauss first version
;-
   
   IF NOT keyword_set(min) THEN min=0
   IF NOT keyword_set(max) THEN max=n_elements(hist)-1
   
   chisq=0.D
   
   FOR i=min,max DO chisq=chisq+((hist(i)-curve(i))^2)/hist(i)
   
   IF keyword_set(pr) THEN print,'%TCCHISQ: chisq: ',strtrim(chisq,2)
   
   IF keyword_set(pars) THEN BEGIN
       redchisq=chisq/(max-min+1-pars)
       IF keyword_set(pr) THEN print,'%TCCHISQ: reduced chisq: ',strtrim(redchisq,2)
   ENDIF
      
END
