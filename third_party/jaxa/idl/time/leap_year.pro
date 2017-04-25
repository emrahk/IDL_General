;---------------------------------------------------------------------------
; Document name: leap_year.pro
; Created by:    Liyun Wang, GSFC/ARC, April 3, 1996
;
; Last Modified: Tue Sep  5 2000
;---------------------------------------------------------------------------
;
FUNCTION leap_year, year
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       LEAP_YEAR()
;
; PURPOSE: 
;       Check if a given year number is a leap year
;
; CATEGORY:
;       Utility, time
; 
; SYNTAX: 
;       Result = leap_year(year)
;
; INPUTS:
;       YEAR - Integer scalar, year number
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - 1 or 0,  if YEAR is or is not a leap year
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, April 3, 1996, Liyun Wang, GSFC/ARC. Written
;       Version 2, September 5, 2000, D. Biesecker
;             (corrected 100 yr/400 yr bug)
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   yr = LONG(year)
   IF ((yr/4)*4 EQ yr) THEN BEGIN
      IF ((yr/100)*100 EQ yr) THEN $
         IF ((yr/400)*400 NE yr) THEN RETURN, 0
      RETURN, 1
   ENDIF ELSE RETURN, 0
END
;---------------------------------------------------------------------------
; End of 'leap_year.pro'.
;---------------------------------------------------------------------------
