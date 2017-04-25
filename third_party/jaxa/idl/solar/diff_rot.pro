;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       DIFF_ROT()
;
; PURPOSE:
;     Computes the differential rotation of the sun
;       
; CALLING SEQUENCE: 
;       Result = DIFF_ROT(ddays,latitude)
;
; INPUTS:
;       DDAYS    --  number of days to rotate
;       LATITUDE --  latitude in DEGREES
;       
; OUTPUTS:
;       Result -- Change in longitude over ddays days in DEGREES
;
; KEYWORD PARAMETERS: 
;       ALLEN    -- use values from Allen, Astrophysical Quantities, 1973
;       HOWARD   -- use values for small magnetic features from Howard et al.
;                   (DEFAULT)
;       SIDEREAL -- use sidereal rotation rate (DEFAULT)
;       SYNODIC  -- use synodic rotation rate
;       CARRINGTON -- use rate in Carrington coordinates.
;       RIGID    -- rotate as rigid body
;       RATE     -- user specified rotation rate in degrees per day
;                   (only used if /RIGID)
;
; PREVIOUS HISTORY:
;       Written T. Metcalf  June 1992
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, November 17, 1994
;          Incorporated into the CDS library
;       Version 2, Zarro, GSFC, 1 July 1997 - made Howard the default
;       Version 3, Zarro, GSFC, 19 Sept 1997 - corrected Howard coeff's
;       Version 4, Zarro (EER/GSFC) 22 Feb 2003 - added /RIGID
;       Version 5, Zarro (EER/GSFC) 29 Mar 2003 - added /RATE
;       Version 6, William Thompson, GSFC, 3-Mar-2009, Added
;       /CARRINGTON
;       Modified, 23 October 2011, Zarro (ADNET)
;          - optimized memory management
;       Modified, 22 October 2014, Zarro (ADNET)
;          - use double-precision arithmetic
;-

FUNCTION DIFF_ROT, ddays, latitude, howard=howard, allen=allen,debug=debug,$
                   synodic=synodic, sidereal=sidereal,rigid=rigid,rate=rate,$
                   carrington=carrington

;-- check if rotating as rigid body

   if keyword_set(rigid) then begin
    sz=size(latitude) 
    if n_elements(sz) lt 4 then sin2l=0.d else $
     sin2l=make_array(size=size(latitude),/nozero)
     sin4l=sin2l
    if is_number(rate) then begin
     if keyword_set(debug) then message,'using rigid rate of '+trim(rate),/cont
     if rate gt 0 then return,ddays*rate+sin2l
    endif else if keyword_set(debug) then message,'using rigid body rotation',/cont
   endif else begin
    sin2l = (SIN(DOUBLE(latitude*!dtor)))^2
    sin4l = sin2l*sin2l
   endelse

   IF KEYWORD_SET(allen) THEN BEGIN

;  Allen, Astrophysical Quantities

    rotation = ddays*(14.44d0 - 3.d0*sin2l)
   ENDIF ELSE BEGIN

;  Small magnetic features 
;  (Howard, Harvey, and Forgach, Solar Physics, 130, 295, 1990)

    rotation = (1.d-6)*ddays*(2.894d0 - 0.428d0*sin2l - 0.37d0*sin4l)*24.d0*3600.d0/!dtor
   ENDELSE

   IF KEYWORD_SET(synodic) THEN BEGIN
    rotation = temporary(rotation) - 0.9856d0*ddays
   END ELSE IF KEYWORD_SET(carrington) THEN BEGIN
    rotation = temporary(rotation) - (360.d0/25.38d0)*ddays
   ENDIF 

   RETURN, rotation
END

