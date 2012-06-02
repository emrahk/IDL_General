PRO CCD_FWHM, image, fwhm, X=x, Y=y, SILENT=silent ,NOWIN=nowin, $
              FWHMG=fwhmg
;
;+
; NAME:
;	CCD_FWHM	
;
; PURPOSE:   
;	Calculate FWHM of sources in field either by giving
;	approximate coordinates of a bright source or interactively.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_FWHM, image, [ fwhm, X=x, Y=y, SILENT=silent, FWHMG=fwhmg ]
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
;	X      : Approximate x coordinate for source, if not existing,
;                use cursor for interactive determination.
;	Y      : Approximate y coordinate for source.
;	SILENT : No output of coordinates on screen.
;       NOWIN  : Reuse old window instead of deleting it.
;	FWHMG  : Approximate value for FWHM, defaulted to interactive input.
;
; OUTPUTS:
;	Draws source profile along pixel row.
;
; OPTIONAL OUTPUT PARAMETERS:
;	FWHM : FWHM of source.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       If /NOWIN is not set, new window device 3 is created,
;       else if /SILENT is not set, window device number is set to 3.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

;approximate fwhm value for CCD_CNTRD routine
if not EXIST(fwhmg) then $
read,'% CCD_FWHM: approx. FWHM of source : ',fwhmg

if not EXIST(image) then message,'Image file missing' else begin $
si=size(image)
if si(0) ne 2 then $
message,'Image array must be 2 dimensional'
endelse

if (not EXIST(x) or not EXIST(y)) then $
repeat CCD_CENT,image,xcen,ycen,fwhm=fwhm until xcen ne -1 else $
CCD_CNTRD,image,x,y,xcen,ycen,fwhmg

if xcen ne -1 then begin
   if not EXIST(silent) then begin
      if not EXIST(nowin) then begin
         wdelete,3
         window,3
         wset,3
         loadct,3
      endif else wset,3
   CLEANPLOT
   endif

   si=size(image)
   xsize=si(1)
   ysize=si(1)
   xpix=indgen(xsize)
   xpix=xpix(long(xcen)-long(3.0d0*fwhmg):long(xcen)+long(3.0d0*fwhmg))
   flux=image(long(xcen)-long(3.0d0*fwhmg):long(xcen)+long(3.0d0*fwhmg), $
              long(ycen))
 
   xres=GAUSSFIT(xpix,flux,a)
   xfwhm=2.0d0*a(2)*sqrt(2.0d0*alog(2.0d0))

   ypix=indgen(ysize)
   ypix=ypix(long(ycen)-long(3.0d0*fwhmg):long(ycen)+long(3.0d0*fwhmg))
   flux=image(long(xcen), $
              long(ycen)-long(3.0d0*fwhmg):long(ycen)+long(3.0d0*fwhmg))

   yres=GAUSSFIT(ypix,flux,a)
   yfwhm=2.0d0*a(2)*sqrt(2.0d0*alog(2.0d0))

   if not EXIST(silent) then begin
      plot,xpix,flux,xtitle='X [pixel]',ytitle='Intensity',charsize=2, psym=10
      oplot,xpix,xres,color=150
   endif

   if not EXIST(silent) then begin
      message,'X FWHM [pixel] : '+strtrim(string(xfwhm),2),/inf
      message,'Y FWHM [pixel] : '+strtrim(string(yfwhm),2),/inf
   endif

endif else begin
   message,'Error centering source',/inf
   xfwhm=0.0d0
   yfwhm=0.0d0
endelse

RETURN
END
