PRO CCD_SHUT, image, shutter, OUT=out
;+
; NAME:
;	CCD_SHUT
;
; PURPOSE:   
;	Shutter correct a FITS frame with name image with SCF shutter
;	and store resulting frame either with same name or name out,
;	including old frame FITS header.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_SHUT, [ image, shutter, OUT=out ]
;
; INPUTS:
;	NONE.
; 
; OPTIONAL INPUTS:
;       IMAGE    : Image file name, defaulted to interactive loading.
;       SHUTTER  : SCF file name, defaulted to interactive loading.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;       OUT    : Name for output frame, defaulted to xxx_s.***,
;	         with the input frame name xxx.***.
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
;	Allowed file formats, see optional keyword EXT.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then $
image=pickfile(title='Input Frame',filter='*.fits')

if not(EXIST(shutter)) then $
shutter=pickfile(title='Shutter Correction Frame',filter='*.fits')

if (not EXIST(out) and EXIST(image)) then out=CCD_APP(image,app='s') $
else out='ccd.fits'
message,'Output image name : '+out,/inf

ima=READFITS(image,h_ima)
shu=READFITS(shutter,h_shu)

hist1='Processed version of '+image
hist2='ShuttCorr frame '+shutter
SXADDHIST,[hist1,hist2],h_ima

si_i=size(ima)
si_f=size(shu)
if ((si_i(1) ne si_f(1)) and (si_i(2) ne si_f(2))) then $
message,'Image and shutter frame dimensions not compatible'

CCD_FHRD,ima,'EXPTIME',exposure

;correction with McDonald PFC IRAF shutter correction frame
ima=ima/(1.0d0+shu/exposure)

WRITEFITS,out,ima,h_ima

RETURN
END
