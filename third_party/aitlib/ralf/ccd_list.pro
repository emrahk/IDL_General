PRO CCD_LIST, EXT=ext, OUT=out
;+
; NAME:
;	CCD_LIST
;
; PURPOSE:   
;	Create an image file list of frames with extension ext.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_LIST, EXT=ext, OUT=out
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
;	OUT : Output file name, defaultet to CCD.CAT.
;	EXT : Extension of file for interactive search.
;	      Allowed file types: BDF, FITS.
;	      If not given, all files of FITS type are shown
;	      for selection.
;
; OUTPUTS:
;	NONE.

; OPTIONAL OUTPUT PARAMETERS:
;	NONE.
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

if EXIST(ext) then filter='*.'+ext else filter='*.fits'

if not EXIST(out) then out='ccd.cat'

a=findfile(filter)

get_lun,unit
openw,unit,out
for i=0,n_elements(a)-1 do printf,unit,a(i)
free_lun,unit

message,'Creating file catalog '+out,/inf

RETURN
END
