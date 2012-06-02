PRO CCD_GJD, file, gjd , SHIFT=shift
;
;+
; NAME:
;	CCD_GJD
;
; PURPOSE:   
;	Extract GeocenJD of CENTER of exposure from a BDF/FITS
;	image header, using CCD_TBDF and CCD_TFITS.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_GJD, file, [ gjd , SHIFT=shift ]
;
; INPUTS:
;	FILE : Name of BDF/FITS file.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	SHIFT : Add shift [hours] to GeocenJD to correct for time zones.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS:
;	GJD : GeocenJD of center of exposure.
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

if not EXIST(file) then message,'File missing'

FDECOMP,file,disk,dir,name,qual,version

case STRLOWCASE(qual) of
'bdf'  : CCD_TBDF,file,gjd,shift=shift
'fits' : CCD_TFITS,file,gjd,shift=shift
endcase

RETURN
END
