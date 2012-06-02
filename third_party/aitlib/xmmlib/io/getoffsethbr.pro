PRO getoffsethbr,rawoffset,ccdid,offset=offset,energy=energy,$
                 chatty=chatty
;+
; NAME: getoffsethbr
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
;               Do not use getcountinfo just before this function
;               Do not use for offset, noise or dslin maps
;               Not split event correction
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
       print,'GETOFFSETHBR: Extracting Offset-Map of CCD '+STRTRIM(ccdid,2)
   ENDIF 
   geteventdata,rawoffset,256,1,reddata=off
   indccd=where(off.ccd EQ ccdid)
   energy=off(indccd).energy
   energy=reform(energy)
   offset=transpose(reform(energy,64,200))   
END


