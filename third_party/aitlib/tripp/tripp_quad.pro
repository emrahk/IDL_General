PRO TRIPP_QUAD, rad, xcen, ycen, _EXTRA=extra,$
                linestyle=linestyle,color=color,thick=thick, circ=circ
;
;+
; NAME:
;	TRIPP_QUAD
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
;	TRIPP_QUAD, rad, xcen, ycen
;
; INPUTS:
;	RAD  : Rectangle with side length = 2*long(rad)+1
;	XCEN : X center = long(xcen)
;	YCEN : Y center = long(ycen)
;
; OPTIONAL INPUTS:
;	linestyle = linestyle
;       color     = color   
;       thick     = thick 
;       circ      = circ
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
;       SLS  2001/02     - adapted for TRIPP from former CCD_QUAD    
;                        - added graphics and circ keyword (from CCD_CIRC)
;-


on_error,2                      ;Return to caller if an error occurs

IF NOT KEYWORD_SET(circ) THEN BEGIN

  xmi=long(xcen)-long(rad)
  xma=long(xcen)+long(rad)+1
  ymi=long(ycen)-long(rad)
  yma=long(ycen)+long(rad)+1
  
  oplot,[xmi,xma,xma,xmi,xmi],[ymi,ymi,yma,yma,ymi],_extra=extra,$
    linestyle=linestyle,color=color,thick=thick

ENDIF ELSE BEGIN

  num=50
  phi=2.0d0*!pi*findgen(num+1)/double(num)
  
  x=xcen+rad*cos(phi)
  y=ycen+rad*sin(phi)
  
  oplot,x,y,_extra=extra,$
    linestyle=linestyle,color=color,thick=thick
  
ENDELSE

RETURN
END




