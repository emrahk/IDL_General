;---------------------------------------------------------------------------
; Document name: sec2dhms.pro
; Created by:    Liyun Wang, GSFC/ARC, March 25, 1996
;
; Last Modified: Tue Mar 26 09:34:23 1996 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION sec2dhms, seconds, upper=upper, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       SEC2DHMS()
;
; PURPOSE:
;       Convert time in sec to string in 'xxDxxHxxMxxS' (DHMS) format
;
; CATEGORY:
;       Utility
;
; SYNTAX:
;       Result = sec2dhms(seconds)
;
; INPUTS:
;       SECONDS - Integer scalar, time in seconds
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - String scalar, time string in DHMS format (if an
;                error occurs, a null string is returned)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       UPPER - Uppercase the returned time string
;       ERROR - Error message returned; a null string if no error
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
;       Version 1, March 25, 1996, Liyun Wang, GSFC/ARC. Written
;
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   day = 86400L
   hour = 3600L
   mini = 60L
   out = ''
   error = ''
   
   IF N_ELEMENTS(seconds) EQ 0 THEN BEGIN
      error = 'Sytax: a = sec2dhms(time_in_seconds)'
      MESSAGE, error, /cont
      RETURN, out
   ENDIF
   sec = LONG(seconds)

   iday = sec/day
   IF iday NE 0 THEN BEGIN
      sec = sec-iday*day
      out = out+STRTRIM(STRING(iday),2)+'d'
   ENDIF

   ihour = sec/hour
   sec = sec-ihour*hour
   IF ihour EQ 0 THEN BEGIN 
      IF iday NE 0 AND sec NE 0 THEN out = out+STRTRIM(STRING(ihour),2)+'h'
   ENDIF ELSE out = out+STRTRIM(STRING(ihour),2)+'h'

   imini = sec/mini
   sec = sec-imini*mini
   IF imini EQ 0 THEN BEGIN
      IF (iday NE 0 OR ihour NE 0) AND sec NE 0 THEN $
         out = out+STRTRIM(STRING(imini),2)+'m'
   ENDIF ELSE out = out+STRTRIM(STRING(imini),2)+'m'
   
   IF sec NE 0 THEN out = out+STRTRIM(STRING(sec), 2)+'s'

   IF KEYWORD_SET(upper) THEN RETURN, STRUPCASE(out) ELSE RETURN, out
END

;---------------------------------------------------------------------------
; End of 'sec2dhms.pro'.
;---------------------------------------------------------------------------
