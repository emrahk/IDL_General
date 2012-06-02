PRO getnoisehbr,rawnoise,ccdid,noise=noise,energy=energy,$
                 chatty=chatty
;+
; NAME: getnoisehbr
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
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
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-   
   IF (keyword_set(chatty)) THEN BEGIN
       chatty=1
   END ELSE BEGIN
       chatty=0
   END
   
   IF (chatty EQ 1) THEN BEGIN 
       print,'GETNOISEHBR: Extracting Noise-Map of CCD '+STRTRIM(ccdid,2)
   ENDIF 
   geteventdata,rawnoise,0,1,reddata=noi

   energy=noi.energy
   energy=reform(energy)
   ;; 13000 events -> ERROR !!!!!!!!!!!!!!!!!
   noise=transpose(reform(energy,64,200))
   noise=sqrt(noise/100.d0)
   ;; ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   
END





