function doy2ex, doy, year, string=string
;
;+
;NAME:
;	doy2ex
;PURPOSE:
;	To convert from day of year to internal structure format or string
;	format
;SAMPLE CALLING SEQUENCE:
;	daytim = doy2ex(doy, year)
;	print, doy2ex(doy, /string)
;INPUT:
;	doy	- The day of year
;OPTIONAL INPUT:
;	year	- The year.  If not passed, it assumes the current year
;OPTIONAL KEYWORD INPUT:
;	string	- If set, return the answer in a string format
;HISTORY:
;	Written 15-Dec-93 by M.Morrison
;-
;
if (n_elements(year) eq 0) then begin
    tarr = anytim2ex(!stime)
    year = tarr(6)
end
;
daytim_jan1 = anytim2ints('1-jan-' + strtrim( year, 2) )
out = daytim_jan1
out.day = out.day + (doy-1)	;1-jan is DOY=1, don't increment
out = anytim2ex(out)
;
if (keyword_set(string)) then out = gt_day(out, /str)
return, out
end
