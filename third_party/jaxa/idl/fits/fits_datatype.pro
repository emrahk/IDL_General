;---------------------------------------------------------------------------
; Document name: fits_datatype.pro
; Created by:    Liyun Wang, NASA/GSFC, August 14, 1997
;
; Last Modified: Thu Aug 14 11:43:02 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION fits_datatype, bitpix, flag, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       FITS_DATATYPE()
;
; PURPOSE: 
;       Return datatype of FITS data for the given BITPIX value
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       Result = fits_datatype(bitpix)
;
; INPUTS:
;       BITPIX - Integer, value of keyword BITPIX in FITS header
;
; OPTIONAL INPUTS: 
;       FLAG   - Integer flag for output format described below
;                (consistent with the one used in DATATYPE); default to 0 
;
; OUTPUTS:
;       RESULT - Either a string or integer of the data type specified
;                by BITPIX. Depending on the value of FLAG, the result
;                will be one of the values from the following table:
;
;                FLAG = 0       FLAG = 1           FLAG = 2       FLAG = 3
;
;                UND            Undefined          0              UND
;                BYT            Byte               1              BYT
;                INT            Integer            2              INT
;                LON            Long               3              LON
;                FLO            Float              4              FLT
;                DOU            Double             5              DBL
;
;                For invalid value of BITPIX, datatype is assumed undefined.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       ERROR - Named variable containing error message. If no error
;               occurs, the null string is returned.
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, August 14, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 1
   IF N_ELEMENTS(flag) EQ 0 THEN flag = 0
   error = ''
   IF flag LT 0 OR flag GT 3 THEN BEGIN
      MESSAGE, 'Unrecognized format flag; default to format #0.', /cont
      flag = 0
   ENDIF

   CASE (bitpix) OF 
      8:   dtype = 1
      16:  dtype = 2
      32:  dtype = 3
      -32: dtype = 4
      -64: dtype = 5
      ELSE: BEGIN
         dtype = 0
         error = 'Invalid value for BITPIX: '+STRTRIM(STRING(bitpix),2)
         MESSAGE, error, /cont
      END
   ENDCASE
   IF flag EQ 2 THEN RETURN, dtype
   
   CASE (flag) OF
      0: BEGIN
         CASE (dtype) OF
            0: RETURN, 'UND'
            1: RETURN, 'BYT'
            2: RETURN, 'INT'
            3: RETURN, 'LON'
            4: RETURN, 'FLO'
            5: RETURN, 'DOU'
         ENDCASE
      END
      1: BEGIN
         CASE (dtype) OF
            0: RETURN, 'Undefined'
            1: RETURN, 'Byte'
            2: RETURN, 'Integer'
            3: RETURN, 'Long'
            4: RETURN, 'Float'
            5: RETURN, 'Double'
         ENDCASE
      END
      3: BEGIN
         CASE (dtype) OF
            0: RETURN, 'UND'
            1: RETURN, 'BYT'
            2: RETURN, 'INT'
            3: RETURN, 'LON'
            4: RETURN, 'FLT'
            5: RETURN, 'DBL'
         ENDCASE
      END
   ENDCASE
END

;---------------------------------------------------------------------------
; End of 'fits_datatype.pro'.
;---------------------------------------------------------------------------
