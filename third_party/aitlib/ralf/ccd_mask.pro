PRO CCD_MASK, image, OUT=out, FWHM=fwhm, ZOOM=zoom
;
;+
; NAME:
;	CCD_MASK	
;
; PURPOSE:   
;	Create and store aperture pattern for automatic CCD
;	time series reduction. Aperture file is used in CCD_PRED.
;	Click on same position reference source as used in CCD_A/MCAT.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_MASK, image, [ OUT=out, FWHM=fwhm, ZOOM=zoom ]
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
;       OUT  : Name of IDL save file with aperture pattern,
;              defaulted to 'CCD.APS'.
;       FWHM : FWHM of star images [pixels], if not given,
;              program asks for it.
;	ZOOM : Zoom interactively into frame before mask is created.
;
; OUTPUTS:
;	IDL save '*.APS' containing aperture patterns.
;
; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	Uses CCD_TV, deletes and opens new window device 0, or
;	uses CCD_ZOOM, deletes and opens new window device 1.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(out) then out='ccd.aps'
message,'Output file name for aperture masks : '+out,/inf

outps=CCD_APP(out,app='mask',ext='ps')

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

   CCD_ZOOM,image,wxmi=xl,wxma=xr,wymi=yl,wyma=yr,xmax=900,ymax=900
endif

source_n=1
back_n=1
side=1

read,'% CCD_MASK: Background rectangle side length (odd) : ',side
qside=fix(side/2.0d0)

rad=dblarr(2)
read,'% CCD_MASK: Expected min. and max. radius [pixel] : ',rad

read,'% CCD_MASK: Number of sources            : ',source_n
read,'% CCD_MASK: Number of backgrounds/source : ',back_n
sx=dblarr(source_n)
sy=dblarr(source_n)
sname=strarr(source_n)
bx=dblarr(source_n,back_n)
by=dblarr(source_n,back_n)
sn=''

message,'Left mouse click   : Find/position source/background',/inf
message,'Middle mouse click : Accept source/background',/inf

for i=0,source_n-1 do begin
   message,'Source no. : '+strtrim(string(i+1),2),/inf

   repeat begin
      cursor,x,y,/data
      mouse=!err
      wait,0.5
      if mouse eq 1 then begin
         CCD_CNTRD,image,x,y,xcen,ycen,fwhm
         oplot,[xcen],[ycen],psym=1,symsize=5
      endif
   endrep until ((xcen ne -1) and (mouse eq 2))

   sx(i)=xcen
   sy(i)=ycen
   CCD_CIRC,rad(0),xcen,ycen   
   CCD_CIRC,rad(1),xcen,ycen

   read,'% CCD_MASK: Source ID name : ',sn
   sname(i)=sn

   for b=0,back_n-1 do begin
      message,'Mark background no. : '+strtrim(string(b+1),2),/inf

      repeat begin
         cursor,xb,yb,/data
         mouse=!err
         wait,0.5
         if mouse eq 1 then begin
            CCD_QUAD,qside,xb,yb
            xb_sav=xb
            yb_sav=yb
         endif
      endrep until mouse eq 2

      bx(i,b)=xb_sav
      by(i,b)=yb_sav
      CCD_QUAD,qside,xb_sav,yb_sav
   endfor
endfor

prefname=''
message,'Click on position reference star',/inf
read,'% CCD_MASK: name of POSITION REFERENCE star : ',prefname

repeat begin
   cursor,x,y,/data
   mouse=!err
   wait,0.5
   if mouse eq 1 then begin
      CCD_CNTRD,image,x,y,refx,refy,fwhm
      oplot,[refx],[refy],psym=1,symsize=5
   endif
endrep until ((refx ne -1) and (mouse eq 2))

;create postscript file of aperture mask
for i=0,source_n-1 do begin
   XYOUTS,sx(i),sy(i),'  '+sname(i),charsize=2,charthick=3

   CCD_CIRC,rad(0),sx(i),sy(i),thick=3
   CCD_CIRC,rad(1),sx(i),sy(i),thick=3

   for b=0,back_n-1 do $
   CCD_QUAD,qside,bx(i,b),by(i,b),thick=3
endfor

XYOUTS,refx,refy,'  Pos. Ref:!C  '+prefname,charsize=2,charthick=3
XYOUTS,2,2,' Mask generated: '+STRCOMPRESS(systime(0)), $
       charsize=2,charthick=2

CCD_SCREEN,outps



;source coordinates are relative to position reference star
;background coordinates are relative to source itself
for k=0,source_n-1 do begin
   bx(k,*)=bx(k,*)-sx(k)
   by(k,*)=by(k,*)-sy(k)
endfor
sx=sx-refx
sy=sy-refy

SAVE,/xdr,sx,sy,bx,by,qside,sname,fwhm,prefname,filename=out,/verbose

RETURN
END
