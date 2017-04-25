;+
;
; NAME: 
;	GRWCH_ST
;
; PURPOSE:
;	This function returns the apparent RA of the meridian at Greenwich in degrees
;	at the input time.
;
; CATEGORY:
;	GEN, EPHEMERIDES
;
; CALLING SEQUENCE:
;	RA = GRWCH_ST( UT )
;
; CALLS:
;	ANYTIM
;
; INPUTS:
;       UT - time in ANYTIM format.
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Function returns the right ascencion in degrees.
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Uses a formula which may have been taken from the Astronomical Almanac.
; 	print, grwch_st('1-jan-86 00:00:00.000')
; 	100.35282  ;degrees
;
; MODIFICATION HISTORY:
;  	Version 1 documented 29 May 1996, first written ~1987
;-


;Routine: GRWCH_ST
;
;Usage:  RA = GRWCH_ST(UT)
;
; At UT find the apparent RA of the meridian at Greenwich in degrees
; ut is the universal time in any accepted ANYTIM format
; fiducial point is defined for 00 hours on Jan. 1, 1986
;
function grwch_st,ut 

day = anytim(ut,/sec)/86400. - 2556.0
hrs = 24*(day - long(day))
day = day - hrs/24.

return,15.*(6.6244781+.0657098242*day+1.00273791*hrs)
end

;function scradec,long,lat,day,hrs
;given the spacecraft long east of Greenwich and the latitude in degrees
;on day number (day) decimal hour (hrs) return the RA and DEC in degrees
;of the center of the Earth as seen from the spacecraft
;return,[(grwch_st(day,hrs)+long+180.) mod 360.,-lat]
;end

;function ground,ra,dec,day,hrs
;given ra and dec of the earth center as seen from the sc return
;the ground track in degrees, i. e. inverse of scradec
;return,[(ra-180.-grwch_st(day,hrs)) mod 360.,-dec]
;end
