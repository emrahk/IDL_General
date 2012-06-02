FUNCTION dip_cycles, time, mjd=mjd, rjd=rjd, helio=helio
;+
; NAME: dip_cycles
;
;
;
; PURPOSE: return cycle for given dip
;
;
;
; CATEGORY: RX J1940.1-1025
;
;
;
; CALLING SEQUENCE:
;          cycle=dip_cycle(time, /mjd, /helio)
;
;
;
; INPUTS:
;       time - time in JD of dip start time for for which the cycle
;              will be computed.
;              If /MJD is specified the time is given in MJD
;              If /Helio is specified the time is heliocenter corrected
;
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;       /mjd - time is given in  MJD 
;       /rjd - time is given in  RJD 
;       /helio-time is given in in helio center time
;
;
;
; OUTPUTS:

;
;
;
; OPTIONAL OUTPUTS:
;       date - string of date corresponding to given time
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
;        05/22/2002, EG: initial, derived from dips.pro
;
;-

; object coordinates:
RA=295.047750
DEC=-10.42363


; default: use time as is:
time1=time

; period of dips:
 period = 12116.29579D0 / 86400.D0

; if specified: switch to MJD
IF keyword_set(mjd) THEN time1 = time + 2400000.5D0 

; if specified: switch to RJD
IF keyword_set(rjd) THEN time1 = time + 2400000.D0 



; convert time to heliocenter system via helio_jd.
IF keyword_set(HELIO) EQ 0 THEN BEGIN
  time1 = time1 + HELIO_JD(time1-2400000.D0,RA,DEC,/TIME_DIFF) / 86400.D0
ENDIF


;basetime=9568.509764D0 + 2440000.0D0
; Start time of dips (1993-04-01), in HJD
basetime=2449078.94991D0

cycle=0

; compute cycle
cycle = floor((time1-basetime)/period)

  RETURN, cycle
END







