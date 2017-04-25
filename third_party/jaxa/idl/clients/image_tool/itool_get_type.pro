FUNCTION itool_get_type, header, file=file, error=error
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       ITOOL_GET_TYPE()
;
; PURPOSE: 
;       Get 5-char image type code
;
; CATEGORY:
;       Image Tool
; 
; SYNTAX: 
;       Result = itool_get_type(header)
;
; INPUTS:
;       HEADER - Header of FITS file that contains the image data
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       RESULT - Image type code (5-char or null)
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       FILE   - Name of the FITS file
;       ERROR  - Named variable containing any error message
;
; COMMON:
;       ITOOL_TYPE_COM
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, September 5, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, 1998 June 5, Zarro (SAC/GSFC) -- added TRACE type
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   COMMON itool_type_com, src_code
   error = ''
   src = ''
   IF N_ELEMENTS(header) EQ 0 THEN BEGIN
      error = 'FITS header not passed in.'
      RETURN, src
   ENDIF

   IF N_ELEMENTS(src_code) EQ 0 THEN src_code = itool_img_type(/stc)

   
   type_list = ['IMAGTYPE','TYPE-OBS','DATA-TYP','TYPE1','WAVELNTH',$
                'TELESCOP', 'LAMBDA','WAVE_LEN']
   FOR i=0, N_ELEMENTS(type_list)-1 DO BEGIN
      tmp = STRUPCASE(STRTRIM(STRING(fxpar(header, type_list(i))), 2))
      temp = grep(tmp, src_code.code,/exact)        
      IF temp(0) NE '' THEN RETURN, temp(0)
       
;-- try old pre-grep way

         CASE (tmp) OF
            'K': src = 'caiik'
            'W': src = 'white'
            'W.L.': src = 'white'
            'KLINE': src = 'caiik'
            'HACL': src = 'halph'
            'HA': src = 'halph'
            'NEUT-L': src = 'halph'
            'MAGNETIC': src = 'magmp'
            'MAGNTO': src = 'magmp'
            'MAGNETOGRAM': src = 'magmp'
            'AVG MAGNETOGRAM': src = 'magmp'
            'DOPPLERGRAM': src = 'doppl'
            'INTENSITYGRAM': src = 'igram'
            'HE10830': src = '10830'
            'CORO H-ALPHA': src = 'cogha'
            '171': src = '00171'
            '195': src = '00195'
            '284': src = '00284'
            '304': src = '00304'
            '1216': src = '01216'
            '1550': src = '01550'
            '1600': src = '01600'
            '1700': src = '01700'
            'WL':src='white'
            '656.28': src = 'halph'
            '393.32': src = 'caiik'
            '393.37': src = 'cak3l'
            '5895.90': src = 'magna'
            ELSE: src = ''
         ENDCASE
    if src ne '' then return,src
   ENDFOR

;-- try figure image type from filename

   IF src EQ '' AND N_ELEMENTS(file) NE 0 THEN BEGIN
      break_file, file, dlog, dir, filnam, ext
      str = STRUPCASE(STRMID(filnam, 5, 5))
      temp = grep(str, src_code.code, /exact)
      IF temp(0) NE '' THEN src = temp(0)
   ENDIF

   IF src EQ '' THEN MESSAGE, 'Unknown image type.', /cont
   RETURN, src
END

;---------------------------------------------------------------------------
; End of 'itool_get_type.pro'.
;---------------------------------------------------------------------------
