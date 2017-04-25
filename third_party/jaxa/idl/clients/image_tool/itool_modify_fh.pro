;---------------------------------------------------------------------------
; Document name: itool_modify_fh.pro
; Created by:    Liyun Wang, NASA/GSFC, August 13, 1997
;
; Last Modified: Fri Sep  5 10:32:40 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_MODIFY_FH
;
; PURPOSE:
;       Modify header of given FITS file
;
; CATEGORY:
;       IMAGE TOOL
;
; SYNTAX:
;       itool_modify_fh, file, image, header, csi, error=error
;
; EXAMPLES:
;
; INPUTS:
;       FILE   - Name of FITS file
;       IMAGE  - data array
;       HEADER - Original FITS header
;       CSI    - CSI structure, containing coordinate related
;                information which is supposed to be different from
;                that in FITS header
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       ERROR - A named variable containing possible error messages
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       Write privilege required to update FITS header in the file
;
; SIDE EFFECTS:
;       If data type of array IMAGE does not match BITPIX value, IMAGE
;       is converted into the data type compatible with BITPIX
;
; HISTORY:
;       Version 1, August 13, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
PRO itool_modify_fh, file, image, header, csi=csi, error=err, modify=modify
   ON_ERROR, 2
   err = ''
   IF N_PARAMS() LT 2 THEN BEGIN
      err = 'Incorrect number of input parameters.'
      RETURN
   ENDIF
   IF N_ELEMENTS(header)*N_ELEMENTS(csi) EQ 0 THEN BEGIN
      err = 'You must pass in a FITS header or CSI structure!'
      RETURN
   ENDIF
   
   IF KEYWORD_SET(modify) OR N_ELEMENTS(header) EQ 0 THEN BEGIN
      IF datatype(csi) NE 'STC' THEN BEGIN
         err = 'CSI must be passed in and be a CSI structure.'
         RETURN
      ENDIF
   ENDIF

   IF NOT test_open(file, /write) THEN BEGIN
      err = 'You cannot open the file '+file+' for writing!'
      MESSAGE, err, /cont
      RETURN
   ENDIF

;---------------------------------------------------------------------------
;  If HEADER not passed in, build one with CSI
;---------------------------------------------------------------------------
   IF N_ELEMENTS(header) EQ 0 THEN header = itool_mk_header(csi)

   dtype = fits_datatype(csi.bitpix, 2, error=err)
   IF dtype EQ 0 THEN RETURN

   IF dtype NE datatype(image, 2) THEN BEGIN
;---------------------------------------------------------------------------
;     Data type does not match BITPIX value; try to fix it
;---------------------------------------------------------------------------
      CASE (dtype) OF
         1: image = BYTE(TEMPORARY(image))
         2: image = FIX(TEMPORARY(image))
         3: image = LONG(TEMPORARY(image))
         4: image = FLOAT(TEMPORARY(image))
         5: image = DOUBLE(TEMPORARY(image))
      ENDCASE
   ENDIF

   fxwrite, file, header, image, err=err
   IF err NE '' THEN BEGIN
      MESSAGE, err, /cont
      RETURN
   ENDIF

   IF KEYWORD_SET(modify) THEN BEGIN
      fxhmodify, file, 'CRPIX1', csi.crpix1, err=err
      fxhmodify, file, 'CRPIX2', csi.crpix2
      fxhmodify, file, 'CRVAL1', csi.crval1
      fxhmodify, file, 'CRVAL2', csi.crval2
      fxhmodify, file, 'CDELT1', csi.cdelt1
      fxhmodify, file, 'CDELT2', csi.cdelt2

;---------------------------------------------------------------------------
;  Update header
;---------------------------------------------------------------------------
      OPENU, unit, file, /block, /GET_LUN
      fxhread, unit, header_tmp, status
      FREE_LUN, unit
      IF status EQ 0 THEN BEGIN
         header = header_tmp
      ENDIF ELSE BEGIN
         err = 'FITS Header not modified.'
      ENDELSE
   ENDIF
END

;---------------------------------------------------------------------------
; End of 'itool_modify_fh.pro'.
;---------------------------------------------------------------------------
