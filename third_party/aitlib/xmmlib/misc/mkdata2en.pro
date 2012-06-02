function mkdata2en,data,chatty=chatty
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
   energyimage = INTARR(12, 200, 64)
   
   FOR ccd=0, 11 DO BEGIN
       ;;get data for each ccd
       indccd=where(data.ccd EQ ccd, idct)
       vtreffer = LONARR(12800)
       his=intarr(12800)
       IF (idct GE 1) THEN BEGIN 
           his(data(indccd).line+data(indccd).column*200) = data(indccd).energy
	   tmin=min(his)
	   tmax=max(his)
           vtreffer=his
           energyimage(ccd,*,*)=REFORM(vtreffer, 200, 64)
       ENDIF ELSE BEGIN 
           IF (keyword_set(chatty)) THEN BEGIN 
               print,'MKDATA2IMG: No Data in CCD '+STRTRIM(ccd,2)
           ENDIF 
       ENDELSE
   ENDFOR
   return,energyimage
END

