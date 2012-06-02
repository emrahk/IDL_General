PRO CCD_CENT, image, xcen, ycen, X=x, Y=y, $
              FWHM=fwhm, SILENT=silent, SEARCH=search
;
;+
; NAME:
;	CCD_CENT	
;
; PURPOSE:   
;	Find centroid of star image with DAOPHOT algorithm CCD_CNTRD,
;	works either by giving approximate coordinates (x,y) or
;	interactively by cursor.
;
; CATEGORY:
;	Astronomical Photometry
;
; CALLING SEQUENCE:
;	CCD_CENT, image, [ xcen, ycen, X=x, Y=y, $
;                 FWHM=fwhm, SILENT=silent, SEARCH=search ]
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
;		 use cursor for interactive determination.
;	Y      : Approximate y coordinate for source.
;       FWHM   : FWHM of star images [pixels], if not given,
;                program asks for it.
;       SEARCH : If search at x,y fails, use area with rectangle side
;                length 2*SEARCH [pixel] around x,y for further trials.
;       SILENT : No output of coordinates on screen.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	XCEN : Centroid x coordinate of source by CCD_CNTRD.
;       YCEN : Centroid y coordinate of source by CCD_CNTRD.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then message,'Image file missing' else begin $
si=size(image)
if si(0) ne 2 then $
message,'Image array must be 2 dimensional'
endelse

if ((not EXIST(x)) or (not EXIST(y))) then begin
   message,'Mark source with cursor',/inf
   cursor,x,y,/data
endif

if not EXIST(search) then $
CCD_CNTRD,image,x,y,xcen,ycen,fwhm,/silent else begin

   for xshift=0,long(search) do begin
      for yshift=0,long(search) do begin

         CCD_CNTRD,image,x+xshift,y+yshift,xcen,ycen,fwhm,/silent
         if xcen eq -1 then $
         CCD_CNTRD,image,x-xshift,y+yshift,xcen,ycen,fwhm,/silent
         if xcen eq -1 then $
         CCD_CNTRD,image,x+xshift,y-yshift,xcen,ycen,fwhm,/silent
         if xcen eq -1 then $
         CCD_CNTRD,image,x-xshift,y-yshift,xcen,ycen,fwhm,/silent

         if xcen ne -1 then goto,ENDLOOP
      endfor
   endfor

ENDLOOP:
endelse

if not EXIST(silent) then begin
   if xcen ne -1 then begin
      message,'X centroid : '+strtrim(string(xcen),2),/inf
      message,'Y centroid : '+strtrim(string(ycen),2),/inf
      oplot,[xcen],[ycen],psym=1,symsize=5
   endif else message,'Centroid not found',/inf
endif   

RETURN
END
