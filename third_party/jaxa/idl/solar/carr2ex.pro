;+
;NAME
;    CARR2EX
;PURPOSE
;    Estimate the time of central meridian passage of a Carrington
;      rotation number
;INPUT
;    NCARR - Vector of Carrington rotation numbers (may be non-integral)
;OUTPUT
;    Time in external format
;OPTIONAL KEYWORDS
;    OFFSET - Reference heliographic longitude(s).  The default is 0
;	     (central meridian).  For example, if offset = 90, then
;	     the time at which the supplied Carrington rotation number
;	     passed 90 deg heliographic longitude is returned.
;    DD    - If set, return time as a string giving
;	       decimal day, month, and year
;CALLING SEQUENCE
;    TIME = CARR2EX(1850.26)
;HISTORY
;    Feb 11, 1994 - GLS - Written as a generalized version of H. Hara's
;		    CARR2BTIME to handle non-integral Carrington numbers.
;    Feb 23, 1994 - GLS - Accepts vector input as well as scalar.
;    May 28, 1997 - SLF - removed references to 'dd79' SW (use anytim.pro)
;    Oct  6, 1999 - SLF - made return INT instead of FLOAT
;                         To match definition of 'EXTERNAL FORMAT'
;-  

function carr2ex,carr_arr,offset=offset,dd=dd

num_carr = n_elements(carr_arr)
dd=keyword_set(dd)
if dd then time_arr = strarr(num_carr) else $
  time_arr = fltarr(7,num_carr)
off_arr = fltarr(num_carr)
if (n_elements(offset) gt 0) then $
  if ( (n_elements(offset) eq 1) or $
      ((n_elements(offset) gt 1) and $
       (n_elements(offset) eq num_carr)) ) then $
         off_arr = off_arr + offset else $
         stop,' OFFSET vector must be scalar or have same length ' + $
	   ' as CARR_ARR.  Stopping.'

for i=0,num_carr-1 do begin
  ncarr = carr_arr(i) - off_arr(i)/360.

  carr1 = 1840
  l_ref = 360.-((ncarr-fix(ncarr))*360.)
  l0=0
  dd79=  anytim('11-mar-91 06:56:24')/(86400.0)+1.
  while abs(ncarr-carr1) gt 0.0001 do begin
    dd79 = dd79+(ncarr-carr1)*27.2375/10000.0*9999.
    time = anytim((dd79-1)*86400.0,/ext)
    sun_data = get_sun(time,carr=carr,he_lon=l0)
    carr1 = carr(0)
  endwhile

  l_err = l0(0)-l_ref
  while abs(l_err) gt 0.0001 do begin
    if abs(l_err) gt 180 then $
      l_err = (abs(l_err)/l_err) * (360.-abs(l_err)) *(-1)
    dd79 = dd79+l_err/13.2/10000.0*9999.
    time = anytim((dd79-1)*86400.0,/ext)
    sun_data = get_sun(time,carr=carr,he_lon=l0)
    l_err = l0(0)-l_ref
  endwhile

  if dd then begin
    int_time = anytim2ints(time)
    ex_time = anytim2ex(time)
    fracday = double(int_time.time)/86400000d
    day = float(ex_time(4))+fracday
    str_day = string(day,'$(f6.3)')
    time_arr(i) = str_day + strmid(fmt_tim(time),2,7)
  endif else time_arr(*,i) = time

endfor

if not dd then time_arr=fix(round(time_arr))

return,time_arr

end

