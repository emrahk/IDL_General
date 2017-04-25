;+
; Project     :	SOHO / STEREO
;
; Name        :	WEEK2UTC
;
; Purpose     :	Returns the begin date of an ISO-8601 week number
;
; Category    :	Time
;
; Explanation :	Returns the date associated with the beginning of a year and
;               ISO-8601 week number.  ISO-8601 defines week 1 as the week
;               containing the first Thursday of the year.  In the Gregorian
;               calendar, this is equivalent to the week which includes January
;               4th.  Weeks are defined to start on Monday.
;
; Syntax      :	UTC = WEEK2UTC( YEAR, WEEK  [, keywords ... ] )
;
; Examples    :	PRINT, WEEK2UTC( 2006, 1, /CCSDS, /DATE_ONLY )
;               2006-01-02
;
; Inputs      :	YEAR    = The year, e.g. 2006
;               WEEK    = The week number, from 1 to 52 or 53
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the date of the start
;               (i.e. Monday) of that week.
;
; Opt. Outputs:	None.
;
; Keywords    :	Any keyword accepted by ANYTIM2UTC is supported.
;
; Calls       :	ANYTIM2UTC, UTC2DOW
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Unrecorded.
;
; History     :	Version 1, 24-Jan-2006, S.V. Haugan, ESA
;
; Contact     :	SVHAUGAN
;-
;
FUNCTION week2utc, year, week, _extra=_extra
  
  ;; First, find out what kind of year we have :-)
  jan1dow = utc2dow((jan1utc=anytim2utc(ntrim(year)+'/01/01')))
  IF jan1dow EQ 0 THEN jan1dow = 7
  
  
  ;; If DOW for Jan 1 is Mon..Thu, then beginning of first week is last Monday
  ;; (of previous year, if Jan 1 is not Monday).  If DOW for Jan 1 is
  ;; Fri..Sun, then first week of year starts next Mon.
  
  week1start = jan1utc
  week1start.mjd = week1start.mjd + $
     (jan1dow LE 4 ? - (jan1dow-1) :  (8-jan1dow))
  
  ;; Now, add 7 days for each week, and get the start utc time of week N
  weekNstart = week1start
  weekNstart.mjd = weekNstart.mjd + (week-1)*7
  return,anytim2utc(weekNstart,_extra=_extra)
END


