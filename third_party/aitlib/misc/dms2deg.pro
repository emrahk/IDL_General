FUNCTION dms2deg,d,m,s
;+
; NAME:
;          dms2deg
;
;
; PURPOSE:
;          Convert coordinates in dms-Format to degrees
;
;
; CATEGORY:
;          General Utility
;
;
; CALLING SEQUENCE:
;          dms2deg,d,[m,[s]]
;
; 
; INPUTS:
;          d: degree
;          m: minute
;          s: second
;
; OPTIONAL INPUTS:
;          m and s are optional
;
;	
; KEYWORD PARAMETERS:
;          none
;
;
; OUTPUTS:
;          The function returns (d+m/60+s/3600), taking care of the sign.
;
;
; OPTIONAL OUTPUTS:
;          none
;
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
;
; PROCEDURE:
;          trivial
;
;
; EXAMPLE:
;          print,hms(19,58,21.72)
;
;
; MODIFICATION HISTORY:
;          Version 1.0: 1997/06/24, Joern Wilms (wilms@astro.uni-tuebingen.de)
;-

   IF (n_elements(h) EQ 0) THEN h=0.
   IF (n_elements(m) EQ 0) THEN m=0.
   IF (n_elements(s) EQ 0) THEN s=0.

   sign=+1
   IF (d LT 0.) THEN BEGIN 
       sign=-1
       IF (m LT 0 OR s LT 0) THEN message,'Problem with sign in dms2deg'
   ENDIF 
   IF (d EQ 0.) THEN BEGIN 
       IF (m LT 0) THEN BEGIN 
           sign=-1.
           IF (s LT 0) THEN  message,'Problem with sign in dms2deg'
       ENDIF 
       IF (m EQ 0) THEN BEGIN 
           IF (s LT 0) THEN sign=-1.
       ENDIF 
   ENDIF 

   return,sign*(abs(d)+abs(m)/60.+abs(s)/3600.)
END 
   
