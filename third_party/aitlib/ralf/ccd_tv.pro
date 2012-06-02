PRO CCD_TV, image, NOWIN=nowin, LO=lo, HI=hi, RAD=rad, QUAD=quad,$
            XMAX=xmax, YMAX=ymax, XCEN=xcen, YCEN=ycen, $
            window=window
;
;+
; NAME:
;	CCD_TV
;	
; PURPOSE:   
;	Display a CCD image. A coordinate system with pixel
;	coordinates is established - coordinates (0,0) are lower
;	left corner of pixel 0,0.
;	Picture is autoscaled, maintaining relative scales of both axes.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_TV, image, [ NOWIN=nowin, LO=lo, HI=hi, RAD=rad, QUAD=quad, $
;               XMAX=xmax, YMAX=ymax, XCEN=xcen, YCEN=ycen ]
; 
; INPUTS:
;       IMAGE : 2D image array.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	X/YCEN: Coordinates for overplotting circle or rectangle.
;	RAD   : Overplot circular aperture with radius rad [pixel].
;       QUAD  : Overplot rectangle with area [2*rad+1]^2 instead of circle.
;               NOTE - in QUAD mode, the quadrangle includes only
;                      whole pixels (see CCD_FLUX), therefore the center
;                      of the mask may be shiftet by a fraction of a
;                      pixel in x/y and rad is converted to an integer.
;	NOWIN : Reuse old window instead of deleting it.
;	LO    : Lower cut for display data with lookup table
;	        is lo*sigma below mean, defaulted to 1.0.
;       HI    : Upper cut for display data with lookup table
;               is hi*sigma above mean, defaulted to 5.0.
;	XMAX  : Maximum allowed x size of window for autoscaling.
;	YMAX  : Maximum allowed y size of window for autoscaling.
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
;	If /NOWIN is not set, new window device is created,
;	else window device number is set to 0
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;       Joern Wilms/Stefan Dreizler: April 1999, removed setting of
;              system variables
;       Joern Wilms: February 2000: added window keyword
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then message,'Image file missing' else begin $
si=size(image)
if si(0) ne 2 then $
message,'Image array must be 2 dimensional'
endelse

IF (n_elements(window) EQ 0) THEN window=0

si=size(image)
xsize=si(1)
ysize=si(2)

if not EXIST(xmax) then xmax=700.0d0 else xmax=double(xmax)
if not EXIST(ymax) then ymax=700.0d0 else ymax=double(ymax)

scale=(xmax/xsize)<(ymax/ysize)

if not EXIST(nowin) then begin
;   wdelete,window
   window,window,xsize=long(scale*xsize),ysize=long(scale*ysize)	
   wset,window
   loadct,3
endif else wset,window

if not EXIST(lo)  then lo=1.0d0	;display cut determination
if not EXIST(hi)  then hi=5.0d0
SKY,image,skymode,skysig   
lowcut=skymode-lo*skysig
highcut=skymode+hi*skysig

tv,congrid(bytscl(image,lowcut,highcut),long(scale*xsize),long(scale*ysize))

plot,[0,1],[0,1],/noerase,/nodata,xsty=1,ysty=1,xrange=[0,xsize],$
  yrange=[0,ysize],position=[0.,0.,1.,1.]              ;set axis scales

if (EXIST(xcen) and EXIST(ycen)) then begin
    if (not EXIST(quad) and EXIST(rad)) then CCD_CIRC,rad,xcen,ycen
    if (EXIST(quad) and EXIST(rad)) then CCD_QUAD,rad,xcen,ycen
endif

RETURN
END
