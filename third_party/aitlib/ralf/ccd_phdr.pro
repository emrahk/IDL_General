PRO CCD_PHDR, image, OUT=out
;+
; NAME:
;	CCD_PHDR
;
; PURPOSE:   
;	Create an ascii file *.HDR with data from FITS file header
;	of image.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_PHDR, [ image, OUT=out ]
;
; INPUTS:
;	NONE.
; 
; OPTIONAL INPUTS:
;       IMAGE : Image file name, defaulted to interactive loading.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;       OUT    : Name for output file of header data,
;		 defaulted to *.hdr
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

if not EXIST(out) then out=CCD_APP(image,ext='hdr')
message,'Output file name : '+out,/inf

hdr=HEADFITS(image)

get_lun,unit
openw,unit,out
printf,unit,'>>> '+image+' <<<'
for i=0,n_elements(hdr)-1 do printf,unit,STRTRIM(STRCOMPRESS(hdr(i)),2)
free_lun,unit


RETURN
END
