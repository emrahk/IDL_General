PRO CCD_ZERO, image, zero, OUT=out
;+
; NAME:
;	CCD_ZERO
;
; PURPOSE:   
;	Subtract from a FITS frame with filename image a zero frame
;	and store resulting frame either with same name or name out,
;	including old frame FITS header.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_ZERO, [ image, zero, OUT=out ]
;
; INPUTS:
;	NONE.
; 
; OPTIONAL INPUTS:
;       IMAGE : Image file name, defaulted to interactive loading.
;       FLAT  : Zero file name, defaulted to interactive loading.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;       OUT    : Name for output frame, defaulted to xxx_z.***,
;		 with the frame file name xxx.***.
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
;	Allows FITS files only.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then $
image=pickfile(title='Input Frame',filter='*.fits')

if not EXIST(zero) then $
zero=pickfile(title='Master Zero',filter='*.fits')

if (not EXIST(out) and EXIST(image)) then out=CCD_APP(image,app='z') $
else out='ccd.fits'
message,'Input image name  : '+image,/inf
message,'Zero image name   : '+zero,/inf
message,'Output image name : '+out,/inf

ima=READFITS(image,h_ima)
zer=READFITS(zero,h_zer)

hist1='Processed version of '+image
hist2='Zero frame '+zero
SXADDHIST,[hist1,hist2],h_ima

si_i=size(ima)
si_f=size(zer)
if ((si_i(1) ne si_f(1)) and (si_i(2) ne si_f(2))) then $
message,'Image and zero dimensions not compatible'

ima=ima-zer

WRITEFITS,out,ima,h_ima

RETURN
END
