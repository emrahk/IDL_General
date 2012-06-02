FUNCTION tcreadgain,file,bin=bin,chatty=chatty
   
;+
; NAME:            
;                  tcreadgain
;
;
; PURPOSE:
;		   Read gain file  
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tcreadgain,"Gain_30_HK000126_000.dat"
;
; 
; INPUTS:
;                  file :  name of file containing gain values 
;
;
; OPTIONAL INPUTS:
;                  none
;   
;
; KEYWORD PARAMETERS:
;                  bin :  binary file
;                  chatty :  display gain values   
;
;
; OUTPUTS:
;                  gain : FLTARR(64) containing gain values
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
; V1.0 25.01.00  T. Clauss initial version derived from mkreadgain
;-
   
   
   IF (keyword_set(bin)) THEN BEGIN
       openr,unit,file,/XDR,ERROR=err,/get_lun
       IF (err NE 0) THEN BEGIN 
           print,'% TCREADGAIN: ERROR opening Gain-File: '+file
           print,'% TCREADGAIN: '+ !ERR_STRING
           return, -1
       ENDIF ELSE BEGIN 
           gain = FLTARR(64)
           readu,unit, gain
           free_lun,unit
       ENDELSE
   ENDIF ELSE BEGIN
       openr,unit,file,ERROR=err,/get_lun
       IF (err NE 0) THEN BEGIN 
           print,'% TCREADGAIN: ERROR opening Gain-File: '+file
           print,'% TCREADGAIN: '+ !ERR_STRING
           return, -1
       ENDIF ELSE BEGIN 
           gain = FLTARR(64)
           readf,unit, gain
           free_lun,unit
       ENDELSE
   ENDELSE
   
   IF (keyword_set(chatty)) THEN BEGIN
       FOR i=0,63 DO BEGIN
           print,'% TCREADGAIN: Column Nr. ',strtrim(i,2),' : Gain :  ',gain(i)
       ENDFOR 
   ENDIF
   
   return,gain
   
END
