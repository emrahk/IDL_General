
PRO troughs, cycle, time, mjd=mjd,  date=date, helio=helio,$
             basetime=basetime,period=period, pdot=pdot
;+
; NAME: troughs
;
;
;
; PURPOSE: print trough times
;
;
;
; CATEGORY: RX J1940.1-1025
;
;
;
; CALLING SEQUENCE:
;          troughs, cycle, time, /mjd, period=period, date=date
;
;
;
; INPUTS:
;       cycle - number of desired cycle
;
;
; OPTIONAL INPUTS:
;       /mjd - print out time in MJD 
;       /helio - print out time in helio center time, 
;                otherwise correct it. 
;       basetime- time of cycle 0 in JD of RXJ1940
;       period - period in JD of RXJ1940
;       pdot   - period change in days/day of RXJ1940
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       time - time in JD of trough time for given cycle
;              If /MJD is specified the time is given in MJD
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
;        02/20/2002, EG: subtract (and not add) helio jd difference
;        05/17/2002, EG: New basetime
;
;-

; object coordinates:
RA=295.047750
DEC=-10.42363


;basetime=9568.509764D0 + 2440000.0D0
; Start time of trough (about 52000 MJD), in HJD


; default basetime according diss geckeler
if n_elements(basetime) eq 0 then basetime =  2449638.8242296550D0

IF n_elements(period) EQ 0 THEN period = 0.1406261194

IF n_elements(pdot) EQ 0 THEN pdot=  -3.0223080D-09


time  =  basetime + double(cycle)*period + double(cycle)^2*period*pdot/2.D0


; convert to geocenter system via (inverse) call of helio_jd.  caveat:
; helio_jd converts from geo->helio center, so we make a small error
; when putting in helio center time.  But: the error is small: Maximal
; when d sin(t)/dt = 1 (45 deg), max time shift: ~ 500sec, period: 365
; days => 500sec/364days = 1.5E-5 (small).
; Then: subtract time according position of RXJ 1940
IF not keyword_set(HELIO)  THEN BEGIN
  time = time - HELIO_JD(TIME-2400000.D0,RA,DEC,/TIME_DIFF) / 86400.D0
ENDIF


; convert jd to date:
;IF n_elements(date) NE 0 THEN BEGIN
  date=""
  daycnv, time, yr,mn,day,hr
  date= string(yr,format='(I4)') + "/" + string(mn,format='(I2.2)') $
           + "/" + string(day,format='(I2.2)') + $
       "  " + string(floor(hr)      ,format='(I2.2)') + ":" + $
              string(hr*60 MOD 60   ,format='(I2.2)') + ":" +  $
              string(hr *3600 MOD 60,format='(I2.2)')
;ENDIF 


; if specified: switch to MJD
IF keyword_set(mjd) THEN time = time - 2400000.5D0 

  RETURN
END







