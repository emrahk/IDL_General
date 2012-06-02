PRO CCD_CIRC, rad, xcen, ycen, _EXTRA=extra
;
;+
; NAME:
;	CCD_CIRC
;
; PURPOSE:   
;	Overplot circle with radius rad centered at xcen,ycen.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_CIRC, rad, xcen, ycen
;
; INPUTS:
;	RAD  : Radius [pixel].
;	XCEN : X center.
;	YCEN : Y center.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	NONE.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Oplots on current graphics device.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

num=50
phi=2.0d0*!pi*findgen(num+1)/double(num)

x=xcen+rad*cos(phi)
y=ycen+rad*sin(phi)

oplot,x,y,_extra=extra

RETURN
END
