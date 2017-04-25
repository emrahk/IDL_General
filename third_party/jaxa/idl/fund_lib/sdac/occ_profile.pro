;+
;
; NAME: 
;	OCC_PROFILE
;
; PURPOSE:
; 	This procedure calculates the occultation profile for a source in orbit
;	about the Earth.  Takes into account the oblateness of the Earth.
;
; CATEGORY:
;	BATSE
;
; CALLING SEQUENCE:
;	occ_profile, sdir, xx, occprofile, height=height
;
; CALLS:
;       ATMOS
;
; INPUTS:
; 	sdir - 3 vector in J2000 coordinates for source
;	xx    - spacecraft position in J2000 coordinate system, expressed in km
;	          fltarr(3, n)
; OPTIONAL INPUTS:
;       none
;
; OUTPUTS:
; 	Occprofile - transmission through atmos for each position vector.
;		ranges from 0 (occult) to 1 (above horizon)
;
; OPTIONAL OUTPUTS:
;       none
;
; KEYWORDS:
;       HEIGHT - 50% extinction height above the Earth, default 70 km,
;		This is the 50% height for a 31.7 keV photon.
; 	ENERGY - Make profile for this energy using routine ATMOS.
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       none
;
; PROCEDURE:
;       none
;
; MODIFICATION HISTORY:
;	Version 1, RAS, taken from a BATSE occultation team routine provided by Mark Finger
;-
pro occ_profile, sdir, xx, occprofile, height=height, energy=energy

A = 6378.137D+00        ; Equatorial radius of the Earth
f = 1.0D+00/298.257D+00 ;flattening factor (A-C)/A
checkvar,height, 70.0D+00       ;Occultation altitude (50% transmission)


alpha = (A+height)/(A*(1-f)+height)

min_dh = -40.0D+00
scale_height=7.5D+00

lambda = [sdir(0),sdir(1),sdir(2)*alpha^2] # xx
occprofile=fltarr(n_elements(lambda))
nw = where(lambda gt 0.0D+00)
if(nw(0) gt -1) then begin
   occprofile(nw) = 1.0
endif
w = where(lambda le 0.0D+00)
dh = sqrt(([1.0,1.0,alpha^2]#xx(*,w)^2) $
       -lambda(w)^2/(sdir(0)^2+sdir(1)^2+sdir(2)^2*alpha^2))-(A+height)
dh = dh*(dh gt min_dh)+min_dh*(dh le min_dh)

if keyword_set(energy) then dh = dh * atmos(energy)/atmos(31.7)

occprofile(w) = exp(-alog(2.0)*exp(-dh/scale_height))

end
