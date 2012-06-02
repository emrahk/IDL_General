


FUNCTION zhangfunction,k,nind,deadt,incrate,bt

;+
; NAME:
;         zhangfunction  
;
;
; PURPOSE:
;         calculate and return the value of the defined ancillary
;         functions  to obtain the autocovariance function in the
;         nonparalyzable dead time case, for the article of Zhang et
;         al., "Dead-time modifications to fast Fourier transform
;         power spectra", The Astrophysical Journal, 449:930-935, 1995
;         
;
;
; CATEGORY:
;         timing tools
;
;
; CALLING SEQUENCE:
;         zhangfunction(k,nind,deadt,incrate,bt)
;
; 
; INPUTS:
;         k       : autocovariance function index, k = 0,.....nbin-1
;         nind    : summation index, n = 1,....infinite 
;         deadt   : length of deadtime
;         incrate : mean incident event rate of lightcurve
;         bt    : bintime of lightcurve
; 
; OPTIONAL INPUTS:
;         none
;
;	
; KEYWORD PARAMETERS:
;         none
;
;
; OUTPUTS:
;         zhangfunction : h(k,n), eq. 35 in ApJ 449, 930, 1995
;                             
;
; OPTIONAL OUTPUTS:
;         none
;
;
; COMMON BLOCKS:
;         none
;
;
; SIDE EFFECTS:
;         none
;
;
; RESTRICTIONS:
;         see procedure zhangpsd 
;
;
; PROCEDURE:
;         none
;
;
; EXAMPLE:
;         zhangfunction(2,4,10E-6,20000,1E-6)
;
;
; MODIFICATION HISTORY:
;         Version, 1998/03/12, Sara Benlloch (IAAT)
;                              (benlloch@astro.uni-tuebingen.de)     
;-




   tau=1./incrate
   t=k*bt-nind*deadt             ;variable Tetha function
   x=t/tau                         ;variable G function (eq. 34)
   ;Tetha function (IF t LT 0 function(t)=0, IF t GE 0 function(t)=1) 
   IF t GE 0. THEN BEGIN  
       ;Zhang eq. 34
       g=0.
       n=fix(nind)
       FOR s=0L,n-1 DO BEGIN 
          g=g+(double(n-s)/factorial(s))*x^s
       ENDFOR  
       gg=exp(-x)*g
       ;Zhang eq. 35
       zhangfunctionresult=k-nind*(deadt+tau)/bt+(tau/bt)*gg

   ENDIF ELSE BEGIN     
       zhangfunctionresult =0
   ENDELSE    
   return,zhangfunctionresult
END  










