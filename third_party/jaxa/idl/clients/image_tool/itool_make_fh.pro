;---------------------------------------------------------------------------
; Document name: itool_make_fh.pro
; Created by:    Liyun Wang, NASA/GSFC, September 5, 1997
;
; Last Modified: Fri Sep  5 15:37:27 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_make_fh, csi, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_MAKE_FH()
;
; PURPOSE: 
;       Make a valid FITS header array based on given CSI structure
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       Result = itool_make_fh(csi)
;
; INPUTS:
;       CSI - Coordinate system info structure
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - String vector containing minimum FITS header with
;                required FITS keywords
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       None.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       Only make FITS header for 2D data
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 5, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, 10-Jul-2003, William Thompson, GSFC
;               Write CROTA1,CROTA2 instead of non-standard CROTA
;               Write both DATE_OBS and DATE-OBS
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   error = ''
   IF datatype(csi) NE 'STC' THEN BEGIN
      error = 'CSI structure required.'
      RETURN, ''
   ENDIF
   header = STRARR(36)
   header(0) = 'END' + STRING(REPLICATE(32B,77))
   fxaddpar, header, 'SIMPLE', 'T', 'Header made by ITOOL_MAKE_FH:  '+$
      SYSTIME()
   fxaddpar, header, 'BITPIX', csi.bitpix
   fxaddpar, header, 'NAXIS', 2
   fxaddpar, header, 'NAXIS1', csi.naxis1
   fxaddpar, header, 'NAXIS2', csi.naxis2
   fxaddpar, header, 'CRPIX1', csi.crpix1
   fxaddpar, header, 'CRPIX2', csi.crpix2
   fxaddpar, header, 'CRVAL1', csi.crval1
   fxaddpar, header, 'CRVAL2', csi.crval2
   fxaddpar, header, 'CDELT1', csi.cdelt1
   fxaddpar, header, 'CDELT2', csi.cdelt2
   fxaddpar, header, 'CTYPE1', csi.ctype1
   fxaddpar, header, 'CTYPE2', csi.ctype2
   fxaddpar, header, 'CROTA1', csi.crota
   fxaddpar, header, 'CROTA2', csi.crota
   fxaddpar, header, 'DATE_OBS', csi.date_obs
   fxaddpar, header, 'DATE-OBS', csi.date_obs
   fxaddpar, header, 'ORIGIN', csi.origin
   fxaddpar, header, 'IMAGTYPE', csi.imagtype
   RETURN, header
END

;---------------------------------------------------------------------------
; End of 'itool_make_fh.pro'.
;---------------------------------------------------------------------------
