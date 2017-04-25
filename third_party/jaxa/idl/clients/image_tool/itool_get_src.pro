;---------------------------------------------------------------------------
; Document name: itool_get_src.pro
; Created by:    Liyun Wang, NASA/GSFC, September 5, 1997
;
; Last Modified: Fri Sep  5 15:24:55 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION itool_get_src, header, file=file, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_GET_SRC()
;
; PURPOSE: 
;       Get 4-char image origin code
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       Result = itool_get_src(header)
;
; INPUTS:
;       HEADER - Header of FITS file that contains the image data
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - Image origin code (4-char or null)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       FILE   - Name of the FITS file
;       ERROR  - Named variable containing any error message
;
; COMMON:
;       ITOOL_SRC_COM
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 5, 1997, Liyun Wang, NASA/GSFC. Written
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   COMMON itool_src_com, src_code
   ON_ERROR, 2
   error = ''
   src = ''

   IF N_ELEMENTS(header) EQ 0 THEN BEGIN
      error = 'FITS header not passed in.'
      RETURN, src
   ENDIF
   IF N_ELEMENTS(src_code) EQ 0 THEN src_code = itool_img_src(/stc)

   type_list = ['ORIGIN','TELESCOP','INSTRUME']
   FOR i=0, N_ELEMENTS(type_list)-1 DO BEGIN
      tmp = STRUPCASE(STRTRIM(STRING(fxpar(header, type_list(i))), 2))
      temp = grep(tmp, src_code.code, /exact)
      IF temp(0) NE '' THEN RETURN, temp(0)
      IF !err NE -1 THEN BEGIN
         CASE (tmp) OF
            'KPNO-IRAF': src = 'kpno'
            'MT. WILSON': src = 'mwno'
            'KIS 15 CM COUDE': src = 'kisf'
            'KANZELHOEHE HALPHA PATROL': src = 'kanz'
            'NOBEYAMA RADIO OBS': src = 'nobe'
            'PIC DU MIDI OBSERVATORY': src = 'pdmo'
            'MEUDON OBSERVATORY': src = 'meud'
            'TRACE': src='STRA'
            'TRACE': src='TRACE'
            'SOHO': BEGIN 
               tmp = fxpar(header, 'INSTRUME')
               IF !err NE -1 THEN $
                  src = 'S'+STRMID(tmp,0,3) $
               ELSE src = 'SOHO'
            END
            ELSE:
         ENDCASE
      ENDIF
   ENDFOR

   IF src EQ '' AND N_ELEMENTS(file) NE 0 THEN BEGIN
      break_file, file, dlog, dir, filnam, ext
      str = STRUPCASE(STRMID(filnam, 0, 4))
      temp = grep(str, src_code.code, /exact)
      IF temp(0) NE '' THEN src = temp(0)
   ENDIF
   IF src EQ '' THEN MESSAGE, 'Unknown image source.', /cont
   RETURN, src
END

;---------------------------------------------------------------------------
; End of 'itool_get_src.pro'.
;---------------------------------------------------------------------------
