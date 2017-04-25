function track_h2a, times0, helio0, date_helio0, qstop=qstop
;+
;NAME:
;	track_h2a
;PURPOSE:
;	Given a heliocentric coordinate and a set of dates, track the 
;	angular position on the sun as it moves with differential rotation.
;SAMPLE CALLING SEQUENCE:
;	ang = track_h2a(times, helio, date_helio)
;INPUTS:
;	times	- An array of times in any of the 3 standard formats
;	helio	- The heliocentric coordinates in a 2 element array
;                       (0) = longitude (degrees) W positive
;                       (1) = latitude (degrees) N positive
;                 They can also be strings in the form 'N30W23'.
;	date_helio - The date for the heliocentric coordinates
;OUTPUTS:
;	ang	- Returns the angle as seen from the earth
;                       (0,*) = angle in E/W direction (arcseconds) W positive
;                       (1,*) = angle in N/S direction (arcseconds) N positive
;HISTORY:
;	Written 20-Jun-93 by M.Morrison using Metcalf ALIGN_AR as starting point
;-
;
times = anytim2ints(times0)
date_helio = anytim2ints(date_helio0)
siz = size(helio0)
typ = siz( siz(0)+1 )
if (typ eq 7) then helio = conv_hs2h(helio0) else helio = helio0
;
n = n_elements(times)
out = fltarr(2,n)
;
dday = int2secarr(times, date_helio)/86400.		;days past the reference date/time
for i=0,n-1 do begin
    lat = helio(1)
    lon = helio(0) + diff_rot(dday(i), lat)

    helio00 = [lon, lat]
    out(*,i) = conv_h2a(helio00, times(i))
end
;
if (keyword_set(qstop)) then stop
return, out
end
