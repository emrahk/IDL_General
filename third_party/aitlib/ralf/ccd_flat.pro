PRO CCD_FLAT, image, flat, OUT=out
;+
; NAME:
;	CCD_FLAT
;
; PURPOSE:   
;	Flat field a FITS frame with filename image with flat flat
;	and store resulting frame either with same name or name out,
;	including old frame FITS header + History.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_FLAT, [ image, flat, OUT=out ]
;
; INPUTS:
;	NONE.
; 
; OPTIONAL INPUTS:
;       IMAGE : Image file name, defaulted to interactive loading.
;       FLAT  : Flat file name, defaulted to interactive loading.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;       OUT    : Name for flat fielded output frame,
;		 defaulted to xxx_f.***, where xxx.*** is input frame.
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
;	Allows FITS files only currently.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then $
image=pickfile(title='Input Frame',filter='*.fits')

if not EXIST(flat) then $
flat=pickfile(title='Master Flat',filter='*.fits')

if (not EXIST(out) and EXIST(image)) then out=CCD_APP(image,app='f')
if (not EXIST(out) and not EXIST(image)) then out='ccd.fits'
message,'Input image name  : '+image,/inf
message,'Flat image name   : '+flat,/inf
message,'Output image name : '+out,/inf

ima=READFITS(image,h_ima)
fla=READFITS(flat,h_fla)

hist1='Processed version of '+image
hist2='Flat frame '+flat
SXADDHIST,[hist1,hist2],h_ima

si_i=size(ima)
si_f=size(fla)
if ((si_i(1) ne si_f(1)) and (si_i(2) ne si_f(2))) then $
message,'Image and flat dimensions not compatible'

ima=ima/fla

WRITEFITS,out,ima,h_ima

RETURN
END
