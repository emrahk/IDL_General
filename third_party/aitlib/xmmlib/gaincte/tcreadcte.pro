FUNCTION tcreadcte,file,bin=bin,chatty=chatty
   
;+
; NAME:            
;                  tcreadcte
;
;
; PURPOSE:
;		   Read cte file  
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  cte=tcreadcte,"CTE_30_HK000126_000.dat"
;
; 
; INPUTS:
;                  file :  name of file containing cte values 
;
;
; OPTIONAL INPUTS:
;                  none
;   
;
; KEYWORD PARAMETERS:
;                  bin :  binary file
;                  chatty :  display cte values   
;
;
; OUTPUTS:
;                  cte : FLTARR(64) containing cte values for each column
;
;
; OPTIONAL OUTPUTS:
;		   none   
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
;                  none
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
; V1.0 25.01.00  T. Clauss initial version
;-

   
   IF (keyword_set(bin)) THEN BEGIN
       openr,unit,file,/XDR,ERROR=err,/get_lun
       IF (err NE 0) THEN BEGIN 
           print,'% TCREADCTE: ERROR opening CTE-File: '+file
           print,'% TCREADCTE: '+ !ERR_STRING
           return, -1
       ENDIF ELSE BEGIN 
           cte = FLTARR(64)
           readu,unit,cte
           free_lun,unit
       ENDELSE
   ENDIF ELSE BEGIN
       openr,unit,file,ERROR=err,/get_lun
       IF (err NE 0) THEN BEGIN 
           print,'% TCREADCTE: ERROR opening CTE-File: '+file
           print,'% TCREADCTE: '+ !ERR_STRING
           return, -1
       ENDIF ELSE BEGIN 
           cte = FLTARR(64)
           readf,unit,cte
           free_lun,unit
       ENDELSE
   ENDELSE
   
   IF (keyword_set(chatty)) THEN BEGIN
       FOR i=0,63 DO BEGIN
           print,'% TCREADCTE: Column Nr. ',strtrim(i,2),' : CTE :  ',cte(i)
       ENDFOR 
   ENDIF
   
   return,cte
   
END
