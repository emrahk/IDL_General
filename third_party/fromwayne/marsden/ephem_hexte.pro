function ephem_hexte,jdutc,frc,rce,rcs,etut,vce
;***********************************************************************
; GRO program modified unmercifully to conform to HEXTE data
; Interpolates ephemeris data, returning positions of the Earth 
; and Sun with respect to the Solar System barycenter (SSBC).
; For variable explanations please see hexte_bary.pro
; Needs ephemeris file de200_new.fits
; First define common block:
;***********************************************************************
common ephem,earth,sun,tdbtdt
;***********************************************************************
; Now define a bunch of constants.
;*********************************************************************** 
num = n_elements(jdutc)
ephem_file = '/d3/gof/orbit/de200_new.fits'
jd0  =  2.4369130000000000E+06
jd1   =  2.4519100000000000E+06
rce = dblarr(3,num)
rcs = dblarr(3,num)
vce = dblarr(3,num)
ndaych = 14998
daysec = 1.d0 / 86400.d0
jdch0 = 0l
jdmin = min(long(jdutc))
jdmax = max(long(jdutc))
if (n_elements(earth) eq 0)then begin
;***********************************************************************
; Read the data from the ephemeris file if it hasn't been done yet
;***********************************************************************
   tdbdot=dblarr(ndaych)
   tdtut=dblarr(ndaych)
   hdr = headfits(ephem_file)
   tab = readfits(ephem_file,hdr,ext=1)
   earth = fits_get(hdr,tab,1)
   earth = reform(earth,3,4,ndaych)
   sun = fits_get(hdr,tab,2)
   tdbtdt = fits_get(hdr,tab,3)
endif
;***********************************************************************
; Make the arrays for the earth, sun, time difference (tdbtdt), 
; derivative of the time difference (tdbdot) vectors for each photon 
; time. The appelation "_e" on the variables denontes "per event", as 
; opposed to per day record in the ephemeris.  
;***********************************************************************
earth_e = dblarr(3,4,num)
sun_e = dblarr(3,num)
tdbtdt_e = dblarr(num)
tdbdot_e = dblarr(num)
;***********************************************************************
; Check date is in range of ephemeris; if not, report an error.
;***********************************************************************
if (jdutc(0) lt jd0 or jdutc(num-1) gt jd1) then return,-6
;***********************************************************************
; Figure out which day(s) to use.
;***********************************************************************
jdephem = jd0 + findgen(ndaych)  
in_max = min(where(jdephem ge jdmax))
in_min = max(where(jdephem le jdmin))
if (in_min eq -1 or in_max eq -1)then return,-6
if (in_min eq in_max)then inday = replicate(in_max(0),num) else begin
   in1 = where(jdutc lt jdephem(in_max))
   in2 = where(jdutc ge jdephem(in_max))
   inday = fltarr(num)
   inday(in1) = in_max
   inday(in2) = in_min
endelse
;***********************************************************************
; For each ephemeris day covered by the photon times, fill the 
; "per event" arrays with the appropriate values:
;***********************************************************************
nn = long(in_max - in_min)
for i = 0l,nn do begin
 in = where(inday eq in_min + i,n)
 if (in(0) ne -1)then begin
    temp = dblarr(3,4,n)
    for j = 0l,long(n)-1l do temp(*,*,j) = earth(*,*,in_min + i)
    earth_e(*,*,in) = temp
    sun_e(*,in) = reform(sun(*,in_min + i))#double(replicate(1.,n))
    tdbtdt_e(in) = tdbtdt(in_min + i)
    tdbdot_e(in) = tdbtdt(in_min + i + 1l) - tdbtdt(in_min + i)
 endif
endfor
;***********************************************************************
; Now use Taylor series to get the coordinates at the desired time:
;***********************************************************************
dt = frc
dt2 = dt*dt
dt3 = dt2*dt
etut = tdbtdt_e + dt*tdbdot_e
rcs = sun_e
for i = 0,2 do begin
 a = reform(earth_e(i,0,*))
 b = reform(earth_e(i,1,*))
 c = reform(earth_e(i,2,*))
 d = reform(earth_e(i,3,*))
 rce(i,*) = a + dt*b + dt2*c/2d + dt3*d/6d
 vce(i,*) = (b + dt*c + dt2*d/2d)*daysec
endfor
;***********************************************************************
; That's all ffolks.
;***********************************************************************
return,1
end
