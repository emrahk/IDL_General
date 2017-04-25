;	Calculate ergs/sec in x-ray range from goes flux
;	yclean - 2 channels of cleaned background-subtracted goes data
; time - 
;	Returns array of energy/sec for each point in original array
;
; Written: Brian Dennis
; Modifications: 
;   2-Dec-2008, Kim Tolbert.  2 channels overlap, so don't add them.  Return n,2 array
;   3-Dec-2008, Kim Tolbert.  Added time keyword, use time to get correct distance from Sun

function goes_lx, yclean, time=time

; Convert to ergs s^-1 from watts m^-2
;Distance to Sun (1 AU) = 1.496 E+13 cm

; 1 watt = 1 joule per second = 10^7 erg s^-1
; 1 watt m^-2 = (2.0 * !pi * au**2 * 1.e7) / 1.e4 erg s^-1

correction = keyword_set(time) ? get_sun(anytim(time,/ext)) : 1.
aucm = 1.496e+13 * correction[0]
wpsm2eps = 2.0 * !pi * aucm^2 * 1.e3
;return, wpsm2eps * total(yclean,2)
return, wpsm2eps * yclean

end