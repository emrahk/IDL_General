PRO CCD_ZOOM, ima, xcen, ycen, DIAM=diam, WXMI=wxmi, WYMI=wymi, $
              WXMA=wxma, WYMA=wyma, RAD=rad, QUAD=quad, INTERP=interp, $
              NOWIN=nowin, LO=lo, HI=hi, XMAX=xmax, YMAX=ymax, CROSS=cross
;
;+
; NAME:
;	CCD_ZOOM
;	
; PURPOSE:   
;	Zoom in on a portion of a CCD image alternatively :
;	a) centered at (xcen,ycen) with approximate diameter diam.
;	b) zoom area with lower left corner (wx/wymi) and
;	   upper right corner (wx/wyma).
;	A coordinate system with pixel coordinates is established -
;	coordinates (0,0) are lower left corner of pixel 0,0
;	in the ORIGINAL, UNZOOMED frame.
;	Picture is autoscaled, maintaining relative scales of both axes.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	PRO CCD_ZOOM, ima, [ xcen, ycen, DIAM=diam, WXMI=wxmi, WYMI=wymi, $
;		      WXMA=wxma, WYMA=wyma, RAD=rad, QUAD=quad, $
;                     INTERP=interp, NOWIN=nowin, LO=lo, HI=hi, $
;		      XMAX=xmax, YMAX=ymax, CROSS=cross ]
;
; INPUTS:
;	IMA    : 2D image array.
;
; OPTIONAL INPUTS:
;	X/YCEN : center of zoom area [pixel]. If none are given,
;		 interactive determination with mouse.		 
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	RAD     : Overplot circular aperture with radius rad [pixel].
;       DIAM    : approximate diameter of area to be zoomed [pixel],
;                 program may choose a slightly larger (1-2 pixels) area.
;                 Applies only, if wxmi,wymi and wxma,wyma (coordinates of
;                 corners of zoom area) are not given.
;	WX/WYMI : Coordinates of lower left corner of zoom area.
;	WX/WYMA : Coordinates of upper roght corner of zoom area.
;       QUAD    : Overplot rectangle with area [2*rad+1]^2 instead of circle.
;                 NOTE - in QUAD mode, the quadrangle includes only
;                        whole pixels (see CCD_FLUX), therefore the center
;                        of the mask may be shiftet by a fraction of a
;                        pixel in x/y and rad is converted to an integer
;	NOWIN   : Reuse old window instead of deleting it.
;	LO      : Lower cut for display data with lookup table
;	          is lo*sigma below mean, defaulted to 1.0.
;       HI      : Upper cut for display data with lookup table
;                 is hi*sigma above mean, defaulted to 5.0.
;	XMAX    : Maximum allowed x size of window for autoscaling.
;	YMAX    : Maximum allowed y size of window for autoscaling.
;	INTERP  : Use interpolation to enlarge frame.
;	CROSS   : Draw cross at coordinates xcen,ycen.
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
;	else window device number is set to 1.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


;on_error,2                      ;Return to caller if an error occurs

if not EXIST(ima) then message,'Image file missing'

si=size(ima)
xsize=si(1)
ysize=si(2)

if EXIST(diam) then begin
   if (not EXIST(xcen) or not EXIST(ycen)) then begin
      CCD_TV,ima
      message,'Click on zoom center',/inf
      cursor,xcen,ycen,/data
   endif

   wxmi=long(xcen-diam/2.0d0)>0
   wxma=long(xcen+diam/2.0d0+1)<xsize-1

   wymi=long(ycen-diam/2.0d0)>0
   wyma=long(ycen+diam/2.0d0+1)<ysize-1

endif else $
if (not EXIST(wxmi) or not EXIST(wxma) or $
    not EXIST(wymi) or not EXIST(wxmi)) then $
message,'No zoom area choosen'

wxmi=long(wxmi)
wxma=long(wxma)
wymi=long(wymi)
wyma=long(wyma)

image=ima(wxmi:wxma,wymi:wyma)

si=size(image)
xsize=si(1)
ysize=si(2)

if not EXIST(xmax) then xmax=300.0d0 else xmax=double(xmax)
if not EXIST(ymax) then ymax=300.0d0 else ymax=double(ymax)

scale=(xmax/xsize)<(ymax/ysize)

if not EXIST(nowin) then begin
   wdelete,1
   window,1,xsize=long(scale*xsize),ysize=long(scale*ysize)	
   wset,1
   loadct,3
endif else wset,1

if not EXIST(lo) then lo=1.0d0	;display cut determination
if not EXIST(hi) then hi=5.0d0
SKY,image,skymode,skysig   
lowcut=skymode-lo*skysig
highcut=skymode+hi*skysig

tv,congrid(bytscl(image,lowcut,highcut),$
           long(scale*xsize),long(scale*ysize),interp=interp)

!x.margin=[0,0]
!y.margin=[0,0]
plot,[0,1],[0,1],/noerase,/nodata,xsty=1,ysty=1,xrange=[wxmi,wxma+1]$
,yrange=[wymi,wyma+1] ;set axis scales

if EXIST(cross) then begin
   oplot,[xcen,xcen],[ycen-diam,ycen+diam]
   oplot,[xcen-diam,xcen+diam],[ycen,ycen]
endif

if (not EXIST(quad) and EXIST(rad)) then CCD_CIRC,rad,xcen,ycen
if (EXIST(quad) and EXIST(rad)) then CCD_QUAD,rad,xcen,ycen

RETURN
END
