;+
; Project     :	SOHO / STEREO
;
; Name        :	ANYTIM2WEEK
;
; Purpose     :	Returns the ISO-8601 week number for a given date
;
; Category    :	Time
;
; Explanation :	Returns the ISO-8601 week number associated with a given
;               calendar date.  ISO-8601 defines week 1 as the week containing
;               the first Thursday of the year.  In the Gregorian calendar,
;               this is equivalent to the week which includes January 4th.
;
; Syntax      :	WEEK = ANYTIM2WEEK( DATE  [, YEAR_OUT ] )
;
; Examples    :	WEEK = ANYTIM2WEEK( '1-Jan-2006', YEAR_OUT )
;               PRINT, WEEK, YEAR_OUT
;                         52    2005
;
; Inputs      :	DATE    = The date, in any format supported by ANYTIM2UTC
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the week number.
;
; Opt. Outputs:	YEAR_OUT = The year that this week is associated with, which
;                          might be the previous or next year, depending on the
;                          date.  See the above example.
;
; Keywords    :	None.
;
; Calls       :	ANYTIM2UTC, WEEK2UTC
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
FUNCTION anytim2week, date, year_out
  
  utc = anytim2utc(date)
  year = strmid(anytim2utc(utc,/ecs),0,4)
  utc_week1 = week2utc(year,1)
  utc_week1next = week2utc(year+1,1)
  year_out = fix(year)
  
  IF utc_week1next.mjd LE utc.mjd THEN BEGIN
     year_out = year+1
     utc_week1 = utc_week1next
  END
  
  IF utc_week1.mjd GT utc.mjd THEN BEGIN
     year_out = year-1
     utc_week1 = week2utc(year_out,1)
  END
  
  return,(utc.mjd-utc_week1.mjd)/7+1
END

