PRO CCD_PHOTO, image, RAD=rad , BRAD=brad, $
               SUB=sub, FWHM=fwhm, ZOOM=zoom, N_SIGMA=n_sigma, $
               GAIN=gain, NR=nr, NT=nt
;
;+
; NAME:
;	CCD_PHOTO
;
; PURPOSE:   
;	Determine flux from source interactively on frame.
;	Errors of flux are calculated, when GAIN [e/ADU] is given,
;	this assumes a bias and dark subtracted frame.
;	Errors of bias and flat are neglected.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_PHOTO, image, [ RAD=rad , BRAD=brad, BNUM=bnum, $
;                  SUB=sub, FWHM=fwhm, ZOOM=zoom, N_SIGMA=n_sigma, $
;                  GAIN=gain, NR=nr, NT=nt ]
;
; INPUTS:
;	IMAGE : 2D image array.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	RAD     : Radius of source aperture [pixel].
;	SUB     : Divide original pixel into sub^2 subpixel for flux 
;	          determination, defaulted in CCD_FLUX, if not given.
;	BRAD    : Background rectangle side length is (2*long(BRAD)+1).
;       FWHM    : FWHM of star images [pixel], if not given,
;                 program asks for it.
;	ZOOM    : Zoom interactively into frame before flux determination.
;	N_SIGMA : Filter limit in CCD_BFILT for background calculation.
;	GAIN    : Gain [e/ADU].
;	NT      : Dark current [ADU] per pixel in frame,
;		  if not given, set 0.
;       NR      : RMS readout noise [e] per pixel in frame,
;		  if not given, set 0.
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
;       Uses CCD_TV, deletes and opens new window device 0, or
;       uses CCD_ZOOM, deletes and opens new window device 1.
;	May delete and open new window device 3 for profile plot.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


;on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then message,'Image file missing' else begin $
si=size(image)
if si(0) ne 2 then $
message,'Image array must be 2 dimensional'
endelse

CCD_TV,image,xmax=900,ymax=900

if EXIST(zoom) then begin
   message,'Click at lower left corner of zoom area',/inf
   cursor,xl,yl,/data
   wait,0.5

   message,'Click at upper right corner of zoom area',/inf
   cursor,xr,yr,/data

   ima=image(xl:xr,yl:yr)

   CCD_TV,ima,xmax=900,ymax=900
endif else ima=image

if not EXIST(brad) then $
read,'% CCD_PHOTO: Background rectangle side length (odd) : ',side
brad=long(side/2.0d0)

if not EXIST(rad) then $
read,'% CCD_PHOTO: Aperture radius [pixel] for source : ',rad
rad=double(rad)

if not EXIST(n_sigma) then n_sigma=3


repeat begin

   repeat CCD_CENT,ima,xcen,ycen,fwhm=fwhm until xcen ne -1
   wait,0.5

   CCD_CIRC,rad,xcen,ycen

   CCD_FLUX,ima,rad,xcen,ycen,flux_s,area_s,sub=sub,/silent

   maxfl=max(ima(xcen-rad:xcen+rad,ycen-rad:ycen+rad))
   message,'Center background: Left mouse button, EXIT: middle button',/inf
   area_b=0.0d0
   flux_b=0.0d0
   count=1

   repeat begin
      message,'Center background no. : '+strtrim(string(count),2),/inf
      cursor,xb,yb,/data
      wait,0.5
      mouse=!err
      if mouse ne 2 then begin
         count=count+1
         CCD_QUAD,brad,xb,yb

         CCD_FLUX,ima,brad,xb,yb,flux,area, $
                  sub=sub,n_sigma=n_sigma,/quad,/silent

         flux_b=flux_b+flux
         area_b=area_b+area
      endif      
   endrep until mouse eq 2

   if count eq 1 then begin
      message,'Not sufficient background',/inf
      goto,NSOURCE
   endif

   ;source flux with background subtracted
   flux_sb=flux_s-area_s*flux_b/area_b

   ;calculate sigma of source flux
   if EXIST(gain) then begin

      if not EXIST(nt) then begin
         message,'Ignoring dark current',/inf
         nt=0.0d0
      endif

      if not EXIST(nr) then begin
         message,'Ignoring readout noise',/inf
         nr=0.0d0
      endif

      ;sigma of integrated flux [both ADUs]
      sigma=1.0d0/gain*sqrt(flux_sb*gain+area_s* $
                (1.0d0+area_s/area_b)*(2.0d0*nt*gain+flux_b*gain/area_b+nr^2))

      print,'% CCD_PHOTO: Source flux within aperture [ADU] : ',flux_sb   
      print,'% CCD_PHOTO: Sigma error of flux [ADU]         : ',sigma
      print,'% CCD_PHOTO: Max. flux [ADU]                   : ',maxfl

   endif else $
   print,'% CCD_PHOTO: Source flux within aperture : ',flux_sb

NSOURCE:
c=''
read,'$ CCD_PHOTO: New source (y/n) ? ',c

endrep until ((c eq 'n') or (c eq 'N'))

RETURN
END
