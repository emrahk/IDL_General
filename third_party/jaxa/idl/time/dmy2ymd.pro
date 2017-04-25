;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: dmy2ymd.pro
; Created by:    Liyun Wang, GSFC/ARC, September 26, 1994
;
; Last Modified: Mon Jul 31 13:40:30 1995 (lwang@achilles.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
FUNCTION DMY2YMD, date, quiet=quiet
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:	
;       DMY2YMD()
;
; PURPOSE:
;       To convert date string DD-MM-YY format to YY/MM/DD format.
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       Result = DMY2YMD(date)
;
; INPUTS:
;       DATE -- A string scalar in DD-MM-YY or DD/MM/YY format.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       Result -- A string scalar in 19YY/MM/DD format.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       None.
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
;       Written September 26, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, September 26, 1994
;-
;
   ON_ERROR, 2
   IF N_ELEMENTS(date) EQ 0 THEN BEGIN
      IF NOT KEYWORD_SET(quiet) THEN BEGIN
         PRINT, 'DMY2YMD -- Syntax error.'
         PRINT, '   Usage: result = DMY2YMD(date), '
         PRINT, ' '
      ENDIF
      RETURN, -1
   ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  According to the FITS standard, if DATE-OBS is used, it is in the 
;  format of DD/MM/YY, which is different from the date part of CCSDS
;  format. We need to reorder that string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
   d_arr = str_sep(date,'/')    ; Assume separator is "/"
   IF N_ELEMENTS(d_arr) NE 3 THEN BEGIN ; Try "-" as the separator
      d_arr = str_sep(date,'-')
      IF N_ELEMENTS(d_arr) NE 3 THEN BEGIN ; Not a valid string for date
         IF NOT KEYWORD_SET(quiet) THEN PRINT, $
            'Input parameter is in wrong format!'
         RETURN, -1
      ENDIF 
   ENDIF
   
   d_arr(0) = STRTRIM(d_arr(0),2)
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Check to see if the name of month is in numerical format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
   IF STRMID(d_arr(1),0,1) GT STRING(58b) THEN BEGIN
      CASE STRUPCASE(d_arr(1)) OF
         'JAN': d_arr(1) = '01'
         'FEB': d_arr(1) = '02'
         'MAR': d_arr(1) = '03'
         'APR': d_arr(1) = '04'
         'MAY': d_arr(1) = '05'
         'JUN': d_arr(1) = '06'
         'JUL': d_arr(1) = '07'
         'AUG': d_arr(1) = '08'
         'SEP': d_arr(1) = '09'
         'OCT': d_arr(1) = '10'
         'NOV': d_arr(1) = '11'
         'DEC': d_arr(1) = '12'
      ENDCASE
   ENDIF ELSE BEGIN
      IF STRMID(d_arr(1),0,1) EQ ' ' THEN $
         d_arr(1) = '0'+STRMID(d_arr(1),1,1) 
   ENDELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  For non-standard FTIS headers, people may use four digits for year
;  number, in this case, don't attach "19" to it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
   IF STRLEN(d_arr(2)) GT 2 THEN $
      date_new = STRTRIM(d_arr(2),2)+'/'+d_arr(1)+'/'+d_arr(0) $
   ELSE date_new = '19'+d_arr(2)+'/'+d_arr(1)+'/'+d_arr(0)
   RETURN, date_new
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of 'dmy2ymd.pro'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
