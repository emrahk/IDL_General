PRO TRIPP_FLUX, ima, rad, xcen, ycen, flux, area, MAXINT=maxint, $
             SUB=sub, QUAD=quad, SILENT=silent, N_SIGMA=n_sigma
;
;+
; NAME:
;	TRIPP_FLUX
;	
; PURPOSE:   
;	Integrates flux in circular or rectangular aperture
;	centered on xcen, ycen. See following descriptions
;	for details of centering and subpixels.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	TRIPP_FLUX, ima, rad ,xcen ,ycen , MAXINT=maxint, $
;		[ flux, area, SUB=sub, QUAD=quad, SILENT=silent, $
;                 N_SIGMA=n_sigma ]
;
; INPUTS:
;	IMA    : 2D image array.
;	RAD    : Radius of circular aperture [pixel] for flux integration.
;	X/YCEN : Center of aperture, (0,0) is lower left corner of lower 
;		 left pixel in frame.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	SUB     : Number of subpixels = sub^2 for division of original pixel,
;	          defaulted to 5.
;       QUAD    : Use rectangle with area [2*rad+1]^2 instead of circle.
;                 NOTE - in QUAD mode, the quadrangle includes only
;                        whole pixels (speed), therefore the center of the
;		         mask may be shiftet by a fraction of a pixel in x/y
;                        and rad is converted to an integer.
;	N_SIGMA : Cut value for sigma filtering (IF /QUAD SET ONLY)
;		  aperture, see CCD_BFILT.
;
; OUTPUTS:
;	FLUX : Integrated flux in the defined aperture.
;	AREA : Area in defined aperture [original (not subdivided) pixels].
;
; OPTIONAL OUTPUT PARAMETERS:
;	MAXINT : Max. Intensity [ADU] in aperture.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       Uses CCD_ZOOM, deletes and opens new window device 0,
;	if /SILENT is not set.
;	
; RESTRICTIONS:
;	SATURATED PIXEL ARE DEFINED AS THOSE ABOVE 65000. !
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;                          original name was ccd_flux
;       Stefan  Dreizler - 12/1999: use median of background instead of mean
;-


on_error,2                      ;Return to caller if an error occurs

if (not EXIST(ima) or not EXIST(rad) or $
    not EXIST(xcen) or not EXIST(ycen)) then $
message,'Parameters missing'

if not EXIST(sub) then sub=5

si=size(ima)
if si[0] ne 2 then $
message,'Image array must be 2 dimensional'
xsize=si[1]
ysize=si[2]

if not EXIST(quad) then begin

   ;array limits inside aperture with 1 pixel safety margin
   xmi=long(xcen)-long(rad)-1
   xma=long(xcen)+long(rad)+1

   ymi=long(ycen)-long(rad)-1
   yma=long(ycen)+long(rad)+1

   if ((xmi ge 0) and (xma lt xsize) and (ymi ge 0) and (yma lt ysize)) $
   then begin

      ;new image size after zoom
      size=(2*long(rad)+3)*long(sub)
      image=congrid(ima[xmi:xma,ymi:yma],size,size)

      ;center of aperture in zoomed image
      x_cen=(double(xcen)-double(xmi))*double(sub)
      y_cen=(double(ycen)-double(ymi))*double(sub)

      ;create mask with distances from x_cen,y_cen
      DIST_CIRCLE,mask,size,x_cen,y_cen
   
      ind=where(mask lt double(rad)*double(sub),numpix)
      if ind[0] ne -1 then BEGIN
          ind2 = where(image[ind] LT 65000.,numpix) ; cut saturated pixel 
          if ind2[0] ne -1 then BEGIN
              area=double(numpix)/double(sub)^2
              flux=total(image[ind[ind2]])/double(sub)^2
              maxint=max(image[ind[ind2]])
          endif else begin
              area=0.0d0
              flux=0.0d0
              maxint=0.0d0
          endelse
      endif else begin
          area=0.0d0
          flux=0.0d0
          maxint=0.0d0
      endelse

      if not EXIST(silent) then begin
         message,'Aperture radius [pixel] : '+strtrim(string(rad),2),/inf
         message,'Area [pixel]            : '+strtrim(string(area),2),/inf
         message,'Flux                    : '+strtrim(string(flux),2),/inf
         message,'Max. Intensity [ADU]    : '+strtrim(string(maxint),2),/inf
         CCD_ZOOM,ima,diam=rad*2,xcen,ycen,rad=rad
      endif

   endif else begin
      area=0.0d0
      flux=0.0d0
      maxint=0.0d0
      if not EXIST(silent) then $
      message,'Flux aperture outside frame',/inf
   endelse

endif else begin

   ;zoom array limits
   xmi=long(xcen)-long(rad)
   xma=long(xcen)+long(rad)

   ymi=long(ycen)-long(rad)
   yma=long(ycen)+long(rad)

   if ((xmi ge 0) and (xma lt xsize) and (ymi ge 0) and (yma lt ysize)) $
   then begin

      area=(2.0d0*double(long(rad))+1.0d0)^2
      maxint=max(ima[xmi:xma,ymi:yma])
; R.D.G.     flux=total(ima(xmi:xma,ymi:yma))
; S.D.
      flux=median(ima[xmi:xma,ymi:yma])*area

      if EXIST(n_sigma) then $
      CCD_BFILT,ima[xmi:xma,ymi:yma],flux,area,sigma,n_sigma=n_sigma,/silent

      if not EXIST(silent) then begin
         message,'Rectangle side [pixel]  : '+ $
                  strtrim(string(2*long(rad)+1),2),/inf
         message,'Area [pixel]            : '+strtrim(string(area),2),/inf
         message,'Flux                    : '+strtrim(string(flux),2),/inf
         message,'Max. Intensity [ADU]    : '+strtrim(string(maxint),2),/inf
         message,'Flux/area               : '+ $
                  strtrim(string(flux/area),2),/inf
         CCD_ZOOM,ima,diam=rad*2+2,xcen,ycen,rad=rad,/quad
      endif

   endif else begin
      area=0.0d0
      flux=0.0d0
      maxint=0.0d0
      if not EXIST(silent) then $
      message,'Flux aperture outside frame',/inf
   endelse

endelse

RETURN
END
