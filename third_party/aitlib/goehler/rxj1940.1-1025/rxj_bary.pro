FUNCTION rxj_bary, time, mjd=mjd
;+
; NAME:
;          rxj_bary
;
; PURPOSE:
;          converts time to helio bary center 
;
;
;
; CATEGORY:
;          RX J1940.1-1025
;
;
;
; CALLING SEQUENCE:
;          rxj_bary, time
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
;       helio_time - time converted to helio bary center
;                    If /MJD is specified the time is given in MJD.
;                    For ephemerides file
;                    /usr/local/share/lheasoft/refdata/de200_new.fits
;                    is used. 
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
  BARY_TIME = BARYCEN(corr_time,RA, DEC)
;ENDFOR 

; convert time from RJD:
IF keyword_set(mjd) NE 0 THEN BARY_TIME = BARY_TIME - 0.5D0 $    ; -> MJD
                         ELSE BARY_TIME = BARY_TIME + 2400000.D0 ; -> JD


RETURN, BARY_TIME

END
