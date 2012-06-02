PRO CCD_QUAD, rad, xcen, ycen, _EXTRA=extra
;
;+
; NAME:
;	CCD_QUAD
;
; PURPOSE:   
;	Overplot rectangle with side length 2*long(rad)+1,
;	centered at long(xcen),long(ycen), as used in CCD_FLUX.
;       The quadrangle includes only whole pixels (speed), therefore
;	the center of the quadrangle may be shiftet by a fraction of a
;	pixel in x/y.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_QUAD, rad, xcen, ycen
;
; INPUTS:
;	RAD  : Rectangle with side length = 2*long(rad)+1
;	XCEN : X center = long(xcen)
;	YCEN : Y center = long(ycen)
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

xmi=long(xcen)-long(rad)
xma=long(xcen)+long(rad)+1
ymi=long(ycen)-long(rad)
yma=long(ycen)+long(rad)+1

oplot,[xmi,xma,xma,xmi,xmi],[ymi,ymi,yma,yma,ymi],_extra=extra

RETURN
END
