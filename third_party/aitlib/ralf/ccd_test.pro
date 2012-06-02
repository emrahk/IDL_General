PRO CCD_TEST, num
;+
; NAME:
;	CCD_TEST
;
; PURPOSE:
;	Create a number of FITS images with two gaussian sources.
;	Background/pixel is file number *10.
;	Lower source is constant with total flux 1.0d4.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	 CCD_TEST, [ num ]
;
; INPUTS:
;	NONE.
; 
; OPTIONAL INPUTS:
;	NUM : Number of images, defaulted to 50.
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
;       NONE.
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
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(num) then num=50
w=100
a=dblarr(num+w,w)

get_lun,unit
openw,unit,'ccd.cat'
printf,unit,'% Catalog of simulated CCD frames.'

for i=1,num do begin
   message,'Creating file : '+STRTRIM(STRING(i),2),/inf
   
   ;create minimal fits header
   mkhdr,h,a
   SXADDPAR,h,'EXPTIME',40.0,'actual integration time'
   SXADDPAR,h,'DATE-OBS','27/02/96','date (dd/mm/yy) of obs.'
   SXADDPAR,h,'UT','12:00:'+STRTRIM(STRING(i),2),'universal time'

   ;background
   a(*,*)=10.0d0*i

   ;add stars
   psf1=PSF_GAUSSIAN(npixel=[num+w,w],fwhm=4, $
        centroid=[20.0d0+i+RANDOMU(seed),10.0+RANDOMU(seed)],/normalize)
   psf2=PSF_GAUSSIAN(npixel=[num+w,w],fwhm=4, $
        centroid=[20.0d0+i+RANDOMU(seed),30.0+RANDOMU(seed)],/normalize)
   psf3=PSF_GAUSSIAN(npixel=[num+w,w],fwhm=4, $
        centroid=[20.0d0+i+RANDOMU(seed),50.0+RANDOMU(seed)],/normalize)
   psf4=PSF_GAUSSIAN(npixel=[num+w,w],fwhm=4, $
        centroid=[20.0d0+i+RANDOMU(seed),70.0+RANDOMU(seed)],/normalize)
   psf5=PSF_GAUSSIAN(npixel=[num+w,w],fwhm=4, $
        centroid=[20.0d0+i+RANDOMU(seed),90.0+RANDOMU(seed)],/normalize)

   a=a+psf1*1.0d4+psf2*1.0d2*i+psf3*2.0d2*i+psf4*3.0d2*i+psf5*4.0d2*i

   name='ccd_test_'+STRTRIM(STRING(i),2)+'.fits'

   WRITEFITS,name,a,h
   printf,unit,name

endfor
free_lun,unit


RETURN
END
