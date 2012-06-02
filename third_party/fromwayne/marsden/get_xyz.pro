pro get_xyz,idf,xyz,t0=t0,manual=manual
;******************************************************************
; Program ephemeris data from an XTE orbit file and 
; determines the cartesian geocentric coordinates x,y, and z
; of the spacecraft at a given time. Also determines 
; the clock correction MET-->TT. Variables are:
;         idf...........IDF (double, SCT/16d)
;         xyz...........Output sc coordinates (m)
;          t0...........Clock correction
;      manual...........Don't find UTCF corrections
; First do common block:
;******************************************************************
common orbit,time,x,y,z,time2,utcf,delta
on_ioerror,dumb
;******************************************************************
; Next do usage
;******************************************************************
if (n_elements(idf) eq 0)then begin
   print,'USAGE: get_xyz,idf,output_xyz,[t0=],[manual=]'
   return
endif
;******************************************************************
; Make sure the photons times are within the period covered by 
; the orbit ephemeris and the clock arrays.
;******************************************************************
if (ks(manual) eq 0)then phot_time = 16d*idf else $
phot_time = 16d*idf + manual
num = n_elements(idf)
if (n_elements(time) ne 0)then begin
   a = min(phot_time) lt min(time)
   b = max(phot_time) gt max(time)
   if (a or b)then new = 1 else new = 0
endif else new = 1
if (n_elements(time2) ne 0)then begin
   a = min(phot_time) lt min(time2)
   b = max(phot_time) gt max(time2)
   if (a or b)then new2 = 1 else new2 = 0
endif else new2 = 1
;******************************************************************
; If new data is needed figure out the orbit file to use 
; from the IDF #. Read the orbit data from two consecutive 
; days into the common block, if the times span one mission 
; day. On second thought, just read in one day, and assume 
; the coverage into the next day will be sufficient.
;******************************************************************
if (n_elements(time) eq 0 or new)then begin
   orbit_file = '/d3/gof/orbit/FPorbit_Day'
   day_min = long(phot_time(0)/86400d)
   day_max = long(phot_time(num-1)/86400d)
   day = day_min
   if (day lt 1000l)then day = $
   strcompress('0' + string(day),/remove_all) else $
   day = strcompress(string(day),/remove_all)
   orbit_files = orbit_file + day
;******************************************************************
; Read the orbit data. Must filter out 'NaN' entries in orbit 
; files, which can scew up spline fits
;******************************************************************
   print,'Reading Orbit Files ',orbit_files
   if (n_elements(day) gt 1)then begin
      for i = 0,1 do begin
       hdr = headfits(orbit_files(i))
       tab = readfits(orbit_files(i),hdr,ext=1)
       time = fits_get(hdr,tab,1)
       x = fits_get(hdr,tab,2)
       y = fits_get(hdr,tab,3)
       z = fits_get(hdr,tab,4)
       xcheck = strcompress(x,/remove_all) ne 'NaN'
       ycheck = strcompress(y,/remove_all) ne 'NaN'
       zcheck = strcompress(z,/remove_all) ne 'NaN'
       incheck = where(xcheck ne 0 and ycheck ne 0 and zcheck ne 0)
       x = x(incheck)
       y = y(incheck)
       z = z(incheck)
       time = time(incheck)
       if (i eq 0)then begin
          x_ = x & y_ = y & z_ = z
          time_ = time
       endif else begin
          x_ = [temporary(x_),x] & y_ = [temporary(y_),y]
          z_ = [temporary(z_),z]
          time_ = [temporary(time_),time]
       endelse
      endfor
      x = x_ & y = y_ & z_ = z
      time = time_
   endif else begin
       hdr = headfits(orbit_files)
       tab = readfits(orbit_files,hdr,ext=1)
       time = fits_get(hdr,tab,1)
       x = fits_get(hdr,tab,2)
       y = fits_get(hdr,tab,3)
       z = fits_get(hdr,tab,4)
       xcheck = strcompress(x,/remove_all) ne 'NaN'
       ycheck = strcompress(y,/remove_all) ne 'NaN'
       zcheck = strcompress(z,/remove_all) ne 'NaN'
       incheck = where(xcheck ne 0 and ycheck ne 0 and zcheck ne 0)
       x = x(incheck)
       y = y(incheck)
       z = z(incheck)
       time = time(incheck)
   endelse
endif
;******************************************************************
; Do a cubic spline interpolation to find xyz values at the 
; requested times.
;******************************************************************
xyz = dblarr(3,n_elements(idf))
x_spline = spline(time,x,phot_time,.001)
y_spline = spline(time,y,phot_time,.001)
z_spline = spline(time,z,phot_time,.001)
xyz(0,*) = x_spline
xyz(1,*) = y_spline
xyz(2,*) = z_spline
;******************************************************************
; Find the time correction for the data stretch. First get the 
; FPclock files for two consecutive days if the times span 
; two consecutive days.
;******************************************************************
if (n_elements(time2) eq 0 or new and ks(manual) eq 0) then begin
   year = 86400d*365d
   clock_file = '/disk2/hexte/data/Clock/FPclock_Day'
   day_min = long(phot_time(0)/86400d)
   day_max = long(phot_time(num-1)/86400d)
   day = day_min - 1l
   if (day lt 1000l)then day = $
   strcompress('0' + string(day),/remove_all) else $
   day = strcompress(string(day),/remove_all)
   clock_files = clock_file + day
;******************************************************************
; Now read the clock data, including the UTCF correction.
;******************************************************************
   print,'Reading Clock File ',clock_files
   if (n_elements(day) gt 1)then begin
      for i = 0,1 do begin
       hdr = headfits(clock_files(i))
       tab = readfits(clock_files(i),hdr,ext=1)
       time2 = fits_get(hdr,tab,1)
       utcf = double(fits_get(hdr,tab,11)) - year
       delta = double(fits_get(hdr,tab,16))/1000d
       if (i eq 0)then begin
          time_ = time2 & utcf_ = utcf & delta_ = delta
       endif else begin
          time_ = [temporary(time_),time2]
          utcf_ = [temporary(utcf_),utcf]
          delta_ = [temporary(delta_),delta]
       endelse
      endfor
      time2 = time_
      utcf = utcf_
      delta = delta_
   endif else begin
      hdr = headfits(clock_files)
      tab = readfits(clock_files,hdr,ext=1)
      time2 = fits_get(hdr,tab,1)
      utcf = double(fits_get(hdr,tab,11)) - year
      delta = double(fits_get(hdr,tab,16))/1000d
   endelse
   in = where(time2 gt 0d)
   if (in(0) ne -1)then begin
      time2 = time2(in)
      utcf = utcf(in)
      delta = delta(in)
   endif
endif
;******************************************************************
; Now find the UTCF correction t0 (sec) for each photon 
; time. Also find the delta correction. Add these to the 
; photon time, assuming that the number of leapseconds since 
; 1994.0.0 is 2. If UTCF is undefined or negative, replace UTCF 
; by the mean value of the good UTCFs. Interpolate for the UTCF 
; and for the delta correction, and add to phot_time. Return 
; corrected IDF times.
;****************************************************************** 
if (ks(manual) eq 0)then begin
   in = where(utcf ge 0d,n)
   if (in(0) ne -1)then avg_utcf = total(utcf(in))/double(n) else $
   avg_utcf = 0d
   ina = where(time2 ge phot_time(0))
   inb = where(time2 le phot_time(num-1))
   del = min(ina) - max(inb)
   if (del gt 1)then in1 = max(inb) + lindgen(del) $
   else in1 = max(inb)
   n = n_elements(in1)
   utcf_ = utcf(in1)
   in11 = where(utcf lt 0d)
   in12 = where(utcf ge 0d,nn)
   if (in11(0) ne -1 and in12(0) ne -1)then $
   utcf(in11) = total(utcf(in12))/double(nn)
   if (in12(0) eq -1)then utcf(*) = avg_utcf
   if (in1(0) eq -1)then begin
      print,'UTCF = 0!!!'
      t0 = 0d
   endif else begin
      for i = 0,n-1 do begin
       z1 = phot_time ge time2(in1(i))
       z2 = phot_time le time2(in1(i)+1)
       if (z1(0) ne -1 and z2(0) ne -1)then begin
          in = where(z1 and z2)
          f = $
          (phot_time(in)-time2(in1(i)))/(time2(in1(i)+1)-time2(in1(i)))
          du = utcf(in1(i)+1) - utcf(in1(i))
          dd = delta(in1(i)+1) - delta(in1(i))
          add_utcf = utcf(in1) + f*du
          add_delta = delta(in1) + f*dd
          phot_time(in) = phot_time(in) + add_utcf + add_delta + 2d          
       endif
      endfor
      idf = phot_time/16d
      t0 = -1
   endelse
endif else t0 = 0d
;******************************************************************
; That's all ffolks
;******************************************************************
return
dumb: print,'!!Cant find files ',orbit_file,' or ',clock_file,'!!'
return
end
