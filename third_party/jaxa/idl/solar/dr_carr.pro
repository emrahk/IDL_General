
;       (22-may-92)
  function dr_carr,lat,arg,ang2tim=ang2tim,rad=rad,period=period
;+
; NAME:
;       DR_CARR
;
; PURPOSE:
;	If ARG is a time interval (in decimal days) this routine
;	calculates the Carrington differential rotation for the
;	latitude specified by LAT (in degrees, default is 0).
;
;	If ARG is an angle (in either degrees or radians), this
;	routine calculates the time interval (in decimal days)
;	required for Carrington rotation by that angle at a
;	latitude specified by LAT.
;
; CATEGORY:
;       Solar astronomy trivia.
;
; CALLING SEQUENCE:
;	OUT = dr_carr([lat,arg,ang2tim=ang2tim,rad=rad])
;
; INPUTS:
;	LAT:		Latitude in degrees
;       ARG:		Either a time difference (if ANG2TIM is not
;			present or is zero), or a rotation angle in
;			degrees or radians (if ANG2TIM is present
;			and non-zero).
;
; OPTIONAL INPUT PARAMETERS:
;       None.
;
; KEYWORDS:
;	ANG2TIM:	If present and non-zero then ARG is interpreted
;			as a rotation angle, and the time in decimal days
;			required for rotation by angle ARG (in either
;			degrees or radians) is returned.
;	RAD:		If present and non-zero then if ARG is non-zero
;			the returned rotation angle is in radians. If ARG
;			is absent then the returned rotation rate is in
;			microradians per second.  If RAD is zero or absent
;			then the returned rotation angle or rate is in
;			degrees or degrees per day.
;	PERIOD:		If present and non-zero then if ARG is absent
;			the rotation period in days at latitude LAT is
;			returned.  If PERIOD is zero or absent then if ARG
;			is absent the rotation rate in microradians per sec
;			is returned.
;
; OUTPUTS:
;	OUT:		Either rotation angle or time in decimal days
;			necessary to rotate by angle ARG, depending on the
;			value of ANG2TIM.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       The sidereal Carrington rotation rate is 2.666 microradians/sec.
;	We have borrowed the higher order coefficients for photospheric
;	differential rotaion from Howard and Harvey (1970):
;
;	omega_sidereal =  2.865 - 0.351(+/-0.03)*sin(beta)^2
;			  - 0.443(+/-0.05)*sin(beta)^4	microradians/sec
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;       Aug, 1992.     Written by GLS, LMSC.
;
;-

  if n_elements(lat) eq 0 then lat = 0.
  if n_elements(ang2tim) eq 0 then ang2tim = 0.
  if n_elements(rad) eq 0 then rad = 0.
  if n_elements(period) eq 0 then period = 0.

  latrad = lat/!radeg
  sid_sun =  2.865 - 0.351*(sin(latrad))^2 - 0.443*(sin(latrad))^4
  sid_earth = (2*!pi*1e6)/(365.25*86400.)
  omega = sid_sun - sid_earth
  if n_elements(arg) eq 0 then begin    ; Rotation rate at latitude LAT
					;   was requested
    if period ne 0 then return, 2e6*!pi/omega/86400 else $
    if rad eq 0 then return, omega/1e6*180/!pi*86000 else $
    return, omega
  endif

  if ang2tim eq 0 then begin
    out = omega*arg*.0864		; Rotation angle in radians
    if rad eq 0 then out = out*!radeg	; Convert to degrees if requested
  endif else begin
    out = arg/omega/.0864		; Required rotation time in days
    if rad eq 0 then out = out/!radeg	; Input was in actually in degrees
  endelse

  return, out
  end

