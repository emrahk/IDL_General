function mkdata2img,data,chatty=chatty
;+
; NAME:
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
   intensimage = INTARR(12, 200, 64)
   
   FOR ccd=0, 11 DO BEGIN
       ;;get data for each ccd
       indccd=where(data.ccd EQ ccd, idct)
       vtreffer = LONARR(12800)
       IF (idct GE 2) THEN BEGIN        
           his = HISTOGRAM(data(indccd).line+data(indccd).column*200, $
                           OMIN = tmin, OMAX = tmax)
           vtreffer(tmin:tmax)=his
           intensimage(ccd,*,*)=REFORM(vtreffer, 200, 64)
       ENDIF ELSE BEGIN 
           IF (idct EQ 1) THEN BEGIN 
               vtreffer(data(indccd).line+data(indccd).column*200)=1
               intensimage(ccd,*,*)=REFORM(vtreffer, 200, 64)
           ENDIF ELSE BEGIN 
               IF (keyword_set(chatty)) THEN BEGIN 
                   print,'MKDATA2IMG: No Data in CCD '+STRTRIM(ccd,2)
               ENDIF       
           ENDELSE
       ENDELSE
       
   ENDFOR
   return,intensimage
END

