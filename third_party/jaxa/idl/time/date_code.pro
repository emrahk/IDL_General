;---------------------------------------------------------------------------
; Document name: DATE_CODE.PRO
; Created by:    Liyun Wang, GSFC/ARC, April 24, 1995
;
; Last Modified: Mon Aug 21 12:01:13 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION DATE_CODE, time, error=error
;+
; PROJECT:
;       SOHO - SUMER
;
; NAME:	
;       DATE_CODE()
;
; PURPOSE:
;       Convert any date/time value into YYYYMMDD format.
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = DATE_CODE(time)
;
; INPUTS:
;       TIME - The date/time in any of the standard CDS time formats
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Result - A string with 'YYYYMMDD' format. If error occurs, a null
;                string is returned.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       ANYTIM2UTC
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written April 24, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, April 24, 1995
;       Version 2, August 21, 1995, Liyun Wang, GSFC/ARC
;          Added ERROR keyword
;
; VERSION:
;       Version 2, August 21, 1995
;-
;
   ON_ERROR, 2
   error = ''
   IF N_ELEMENTS(time) EQ 0 THEN BEGIN
      error = 'Syntax: result =date_code(time)'
      MESSAGE, error, /cont
      RETURN, ''
   ENDIF
   
   tstring = anytim2utc(time, /ecs, err = error)
   IF error NE '' THEN BEGIN
      MESSAGE, 'Error: '+error, /cont
      RETURN, ''
   ENDIF
   date = STRMID(tstring,0,4)
   month = STRMID(tstring,5,2)
   day = STRMID(tstring,8,2)
   RETURN, date+month+day
END

;---------------------------------------------------------------------------
; End of 'DATE_CODE.PRO'.
;---------------------------------------------------------------------------
