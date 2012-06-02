pro tct_time,tct,time_str
;***************************************************************************
; Program converts 32 bit timer count to data/time string.
; Adapted from C (G.H) to idl 9/1/93
; 1/15/94 Subtract one day (DCM) 
; Variables are:
;         tct..............32 bit timer count
;    time_str..............Time string of form xx-month-xx xx:xx:xx
; First get the date constants:
;***************************************************************************
yearb = 1992 & yeare = 2009
spm = 60. & sph = long(60.*60.) & spd = long(24.*60.*60.)
moy=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']   
dom = intarr(2,12)
dom(0,*) = [31,28,31,30,31,30,31,31,30,31,30,31] ; For non-leap year
dom(1,*) = [31,29,31,30,31,30,31,31,30,31,30,31] ; for leap years
;***************************************************************************
; Extract decimal date from tct. The tct is in units of 1/8 seconds
; starting on 1 Jan 92 00:00:00.
;           sec............seconds since initial
;           day............days      "      "
;           sel............seconds of the fractional day
;***************************************************************************
num_read,32,tct,tct_bits
sec = .125*total(tct_bits*2.^dindgen(32))
day = sec/spd
sel = long((day - long(day))*spd)
day = long(day)
;***************************************************************************
; Get the current year. Condition for leap year is year mod 400 = 0
; or (year mod 4 = 0 and year mod 100 ne 0).
;            diy...........day in year
;***************************************************************************
year = yearb
diy = 0.
while(diy le day) do begin
  leap = (year mod 4) eq 0
  diy = 365 + leap
  year = year + 1
  day = day - diy
endwhile
;**************************************************************************
; Compute month of year and day of month
;**************************************************************************
month = 0
while(day ge dom(leap,month)) do begin
   day = day - dom(leap,month)
   month = month + 1
endwhile
;*************************************************************************
; Calculate the hours,minutes,seconds from sel
;*************************************************************************
hour = long(sel/sph)
mn =  (float(sel)/float(sph) - float(hour))*60. 
sec = long((mn -  long(mn))*60.)
mn = long(mn)
;*************************************************************************
; Construct the date string
;*************************************************************************
time_str = ''
if (day lt 10) then d_str='0'+string(day) else d_str=string(day)
if (year mod 100 lt 10) then begin
   y_str = '0' + string(year mod 100)
endif else begin
   y_str = string(year mod 100)
endelse
if (hour lt 10) then h_str = '0' + string(hour) else h_str = string(hour)
if (mn lt 10) then m_str = '0' + string(mn) else m_str = string(mn)
if (sec lt 10) then s_str = '0' + string(sec) else s_str = string(sec)
time_str1 = strcompress(d_str+'-'+moy(month)+'-'+y_str,/remove_all)
time_str2 = strcompress(h_str+':'+m_str+':'+s_str,/remove_all)
time_str = time_str1 + ' ' + time_str2
;*************************************************************************
; Thats all return
;*************************************************************************
return
end 
