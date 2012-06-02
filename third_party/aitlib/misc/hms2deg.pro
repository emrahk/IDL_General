FUNCTION hms2deg,h,m,s
;+
; NAME:
;          hms2deg
;
;
; PURPOSE:
;          Convert coordinates in hms-Format to degrees
;
;
; CATEGORY:
;          General Utility
;
;
; CALLING SEQUENCE:
;          hms2deg,h,[m,[s]]
;
; 
; INPUTS:
;          h: hour
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
;          The function returns (h+m/60+s/3600)*15
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
;          hms are assumed to be positive
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

   IF (h LT 0 OR m LT 0 OR s LT 0) THEN BEGIN
       message,'Only positive inputs are allowed in hms2deg'
   END 

   return,(h+m/60.+s/3600.)*15.
END 
   
