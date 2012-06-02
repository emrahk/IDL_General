PRO hexdeadpsd,navg,xf,freq,corr
;+
; NAME:
;	   hexdeadpsd
;
;
; PURPOSE:
;         To calculate the dead-time correction to the Leahy power spectrum
;	  of HEXTE light curves. Semi-emprical formula applies both to
;	  Cluster A and B, with different normalizations set in 
;	  psdcorr_hexte.pro. 
;
;         IMPORTANT : THIS IS AN UNPUBLISHED RESULT AND
;	  I DO NOT GUARANTEE THAT IT WORKS CORRECTLY FOR ALL HEXTE SOURCES.
;	  PLEASE CONTACT ME BEFORE USING, ESPECIALLY IF YOU INTEND TO PUBLISH 
;	  A PAPER. -->  Emrah Kalemci emrahk@mamacass.ucsd.edu
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          hexdeadpsd,navg,xf,freq,corr
;           
; INPUTS:
;          navg : Average count rate per detector
;	     xf : The emprical normalization factor for the correction, differs
;                 for Cluster A and Cluster B and depends on the XULD rates
;	   freq : Fourier frequency array for the PSD 
;
; OPTIONAL INPUTS:
;          none 
;	
; KEYWORD PARAMETERS: 
;
; OUTPUTS:
;          corr : Leahy normalized PSD of the noise including the dead-time
;	          effects 
;
; OPTIONAL OUTPUTS:
;          none
;
; COMMON BLOCKS:
;          none 
;
;
; SIDE EFFECTS:
;          none
;
;
; RESTRICTIONS:
;          none
;
; PROCEDURE:
;          none 
;
; EXAMPLE:
;          hexdeadpsd,30.,1.,f,corr
;
;
; MODIFICATION HISTORY:
;          2001/12/20, Emrah KALEMCI  CASS : Header added
;-

  
ta_fit=[2.5,4.,5.,7.,10.,14,25,35]    ; Emprical XULD dead-times
rv_fit=[90.3*4.8+25.35,35.6*4.8+12.38,30.1*4.8+10.51,7.79*4.8+26.07,$
        13.25+25.,16.,8.,3.]*0.12*xf  ; Semi-emprical fit to the background
 				      ;	lightcurves   

nf=n_elements(freq)
corr=fltarr(nf)   ; is double necessary?

FOR i=0,7 DO BEGIN
    corr=corr+2.*rv_fit(i)*navg*sin(!PI*ta_fit(i)*1e-3*freq)^2/(!PI*!PI*freq*freq)  ; Correction based on Morgan's PCA formula
ENDFOR


END 
