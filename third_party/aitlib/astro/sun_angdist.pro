PRO sun_angdist,time,ra_obj,dec_obj,angdist,      $
                ra_sun=ra_sun,dec_sun=dec_sun,    $
                radians=radians
;+
; NAME:
;         sun_angdist
;
;
; PURPOSE:
;         calculate the angular separation between the Sun and a
;         celestial body
;
;
; CATEGORY:
;         Astronomy
;
;
; CALLING SEQUENCE:
;         sun_angdist,time,ra_obj,dec_obj,angdist, $
;                     ra_sun=ra_sun,dec_sun=dec_sun,radians=radians 
;
;
; INPUTS:
;         time      : Date array in JD. 
;         ra_obj    : The right ascension of the celestial body in DEGREES.
;         dec_obj   : The declination of the celestial body in DEGREES.
;
; OPTIONAL INPUTS:
;         none
;
;
; KEYWORD PARAMETERS:
;         radians   : If this keyword is set, then all output
;                     variables are given in Radians rather than Degrees.     
;
;
; OUTPUTS:
;         angdist   : The angular distance between the Sun and the
;                     celestial body in DEGREES, 
;                     double precision, same number of  elements as time
;
; OPTIONAL OUTPUTS:
;         ra_sun
;         dec_sun
;
; COMMON BLOCKS:
;         none
;
;
; SIDE EFFECTS:
;         none
;
;
; RESTRICTIONS:
;         none
;
;
; PROCEDURE:
;         Requires the sunpos procedure.
;
;
; EXAMPLE:
;         sun_angdist,time,ra_obj,dec_obj,angdist
;
;
; MODIFICATION HISTORY:
;         Version 0.0: 1999/12/03: Sara Benlloch
;-
        
   ;; Angular separation between Sun and object
   jdtime = double(time)        ; time in JD 
   
   rra_obj  = double(ra_obj) * !DPI / 180D ; in radians
   rdec_obj = double(dec_obj) * !DPI / 180D 
   
   ;; jd = julianische Data for the sun
   sunpos,jdtime,ra,dec         ; ra und dec in degrees
   
   rra_sun  = ra * !DPI / 180D 
   rdec_sun = dec * !DPI / 180D  ; in radians
   
   cosangdist = sin(rdec_sun)*sin(rdec_obj)+ $
     cos(rdec_sun)*cos(rdec_obj)*cos(rra_sun-rra_obj)
   
   IF NOT keyword_set(radians) THEN BEGIN 
       angdist = acos(cosangdist) * 180D / !DPI ; in degrees
       ra_sun  = ra
       dec_sun = dec
   ENDIF ELSE BEGIN 
       angdist = acos(cosangdist) ; in radians
       ra_sun  = rra_sun
       dec_sun = rdec_sun 
   ENDELSE 
END  








