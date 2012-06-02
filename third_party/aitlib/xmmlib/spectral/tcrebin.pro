FUNCTION tcrebin,spec,binarr,specerr=specerr,xxx=xxx,xbinsize=xbinsize,binspecerr=binspecerr
   
;+
; NAME:            
;                  tcrebin
;
;
; PURPOSE:
;		   Dynamical rebinnig of a histogram
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  binspec=tcrebin,histogram(0:4095),[0,1, 100,5, 1000,10, 4090,5],$
;                                  xxx=xxx,xbinsize=xbinsize 
;
; 
; INPUTS:
;                  spec : histogram with binsize 1 over the whole range
;                  binarr : array with channel numbers and binsizes
;                           of the form [ (starting channel), (new binsize 1),
;                                         (starting channel), (new binsize 2), ...]
;                           histogram is rebinned with the new binsize
;                           between one starting channel and the next.
;   
;
;
; OPTIONAL INPUTS:
;                  none
;   
;
; KEYWORD PARAMETERS:
;                  none
;
;
; OUTPUTS:
;                  the rebinned spectrum
;
;
; OPTIONAL OUTPUTS:
;		   xxx :  the middle of each new bin in channels of
;		          the histogram
;                  xbinsize :  the binsize of each new bin
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
;                  the number of channels between two given starting
;                  channels must be a multiplier of the given new binsize;   
;                  the number of channels between the last given
;                  starting channel and the total number of channels
;                  must be a multiplier of the last new binsize   
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
; V1.0 10.07.00 T. Clauss initial version
; V1.1 20.07.00 T. Clauss added error calculation
   
   
   IF binarr(n_elements(binarr)-2) GT n_elements(spec)-1 THEN BEGIN 
       print,'%TCREBIN: last binning region beyond dimension of spectrum. Returning...'
       return,-1
   ENDIF
   
   IF binarr(n_elements(binarr)-2) NE n_elements(spec)-1 THEN $
     binarr=[binarr,n_elements(spec),0]  ;; add last border
   
   xdim=0
   
   FOR i=0,n_elements(binarr)-3,2 DO BEGIN
       IF binarr(i+2) LE binarr(i) THEN BEGIN 
           print,'%TCREBIN: binning regions not valid. Returning...'
           return,-1
       ENDIF
       IF ((binarr(i+2)-binarr(i)) MOD binarr(i+1)) NE 0 THEN BEGIN
           print,'%TCREBIN: wrong binsize in region no. ',strtrim(i/2,2),'. Returning...'
           return,-1
       ENDIF
       xdim=xdim+(binarr(i+2)-binarr(i))/binarr(i+1)
   ENDFOR
   
   errcalc=0 
   IF keyword_set(specerr) THEN BEGIN 
       errcalc=1
       binspecerr=fltarr(xdim)
   ENDIF
      
   xxx=fltarr(xdim)
   xbinsize=fltarr(xdim)
   binspec=fltarr(xdim)
   x=0
   
   FOR i=0,n_elements(binarr)-3,2 DO BEGIN
       FOR j=binarr(i),binarr(i+2)-1,binarr(i+1) DO BEGIN
           xbinsize(x)=float(binarr(i+1))
           xxx(x)=j+(xbinsize(x)-1)/2
           binspec(x)=total(spec(j:j+binarr(i+1)-1))
           IF errcalc EQ 1 THEN binspecerr(x)=sqrt(total(specerr(j:j+binarr(i+1)-1)^2))
           x=x+1
       ENDFOR
   ENDFOR
   
   return,binspec
END


   
