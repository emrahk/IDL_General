PRO CCD_IMRD, image, FILE=file, EXT=ext
;+
; NAME:
;	CCD_IMRD
;
; PURPOSE:   
;	Read an image file with extension ext. If filename file is not
;	explicitly given, the file can be choosen interactively.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_IMRD, [ image, FILE=file, EXT=ext ]
;
; INPUTS:
;	NONE.

; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;		
; OPTIONAL KEYWORDS:
;       FILE : Name of file to read, defaulted to interactive loading.
;	EXT  : Extension of file for interactive search.
;	       Allowed file types: BDF, FITS.
;	       If not given, all files of FITS type are shown
;	       for selection.
;
; OUTPUTS:
;	NONE.

; OPTIONAL OUTPUT PARAMETERS:
;	IMAGE : Array containing image section of file.
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

if EXIST(ext) then filter='*.'+ext else filter='*.fits'

if not EXIST(file) then $
file=pickfile(title='Select Frame',filter=filter)

FDECOMP,file,disk,dir,name,qual,version

case STRLOWCASE(qual) of
'bdf'  : MID_RD_IMAGE,file,image,n,nxy
'fit'  : image=READFITS(file,h)
'fits' : image=READFITS(file,h)
endcase

RETURN
END
