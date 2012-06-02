FUNCTION rxj_helio, time, mjd=mjd
;+
; NAME: rxj_helio
;
;
;
; PURPOSE: converts time to helio center 
;
;
;
; CATEGORY: RX J1940.1-1025
;
;
;
; CALLING SEQUENCE:
;          rxj_helio, time
;
;
;
; INPUTS:
;       time - array containing JD/MJD time 
;              (non-helio/bary center corrected)
;
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;       /mjd - use time in MJD, default is JD
;
;
;
; OUTPUTS:
;       helio_time - time converted to helio center
;              If /MJD is specified the time is given in MJD
;
;
;
; COMMON BLOCKS: -
;
;
;
; SIDE EFFECTS: -
;
;
;
; RESTRICTIONS: -
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

; object coordinates:
RA=295.047750
DEC=-10.42363

; convert time to RJD:
IF keyword_set(mjd) THEN corr_time = TIME + 0.5D0 $     ; MJD -> RJD 
                    ELSE corr_time = TIME - 2400000.D0  ; JD  -> RJD



;FOR I=0,N_ELEMENTS(TIME)-1 DO BEGIN

  ; subtract time according position of RXJ 1940
  HELIO_TIME = HELIO_JD(corr_time,RA, DEC)
;ENDFOR 

; convert time from RJD:
IF keyword_set(mjd) NE 0 THEN HELIO_TIME = HELIO_TIME - 0.5D0 $    ; -> MJD
                         ELSE HELIO_TIME = HELIO_TIME + 2400000.D0 ; -> JD


RETURN, HELIO_TIME

END
