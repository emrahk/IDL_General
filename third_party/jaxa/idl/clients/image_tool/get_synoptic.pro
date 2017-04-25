;---------------------------------------------------------------------------
; Document name: get_synoptic.pro
; Created by:    Liyun Wang, NASA/GSFC, January 15, 1997
;
; Last Modified: Fri Jan 17 17:42:52 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
FUNCTION get_synoptic, start=start, stop=stop, instrume=instrume, $
                       error=error, count=count, private=private
;+
; PROJECT:
;       SOHO
;
; NAME:
;       GET_SYNOPTIC()
;
; PURPOSE:
;       Return list of FITS files for given dates and instrument
;
; CATEGORY:
;       Planning
;
; SYNTAX:
;       Result = get_synoptic()
;
; INPUTS:
;       None required.
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT - String array or scalar containing requested file
;                names; the null string is returned if no files found
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       START    - Starting date from which the files are searched;
;                  default to 3 days before STOP if missing
;       STOP     - End date for which the files are searched; default to
;                  today if missing
;       INSTRUME - Name of instrument; can be one of SOHO instruments
;                  or 'YOHK' for yohkoh SXT images. To get SOHO files,
;                  INSTRUME must be a valid SOHO instrument name (can
;                  be in 1-char format recognized by GET_SOHO_INST
;                  routine); if PRIVATE keyword is not set, summary
;                  data is assumed.
;       PRIVATE  - Set this keyword for SOHO private data; only
;                  effective when INSTRUME is one for SOHO
;       ERROR    - String scalar containing possible error message.
;                  The null string is returned if no error occurrs
;       COUNT    - Number of files returned
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
;       Version 1, January 15, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, January 17, 1997, Liyun Wang, NASA/GSFC
;          Added PRIVATE keyword
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 1
   error = ''
   count = 0
   IF N_ELEMENTS(instrume) EQ 0 THEN instrume = 'EIT'
   IF instrume EQ 'YOHK' THEN BEGIN
      env_path=STRTRIM(GETENV('SYNOP_DATA'), 2)
      IF env_path EQ '' THEN BEGIN
         error = 'Environment variable SYNOP_DATA not set'
         MESSAGE, error, /cont
         RETURN, ''
      ENDIF
      path = concat_dir(env_path, 'yohk', /dir)
   ENDIF ELSE BEGIN
      env = 'SUMMARY_DATA'
      IF KEYWORD_SET(private) THEN env = 'PRIVATE_DATA'
      env_path=STRTRIM(GETENV(env), 2)
      IF env_path EQ '' THEN BEGIN
         error = 'Environment variable '+env+' not set'
         MESSAGE, error, /cont
         RETURN, ''
      ENDIF
      IF STRLEN(instrume) EQ 1 THEN $
         inst_list = get_soho_inst(/short) $
      ELSE $
         inst_list = get_soho_inst()
      ii = WHERE(inst_list EQ instrume, count)
      IF count EQ 0 THEN BEGIN
         error = 'Unrecognized SOHO instrument: '+instrume+'.'
         MESSAGE, error, /cont
         RETURN, ''
      ENDIF
      tmp = get_soho_inst(instrume, /short)
      path = concat_dir(env_path, STRLOWCASE(get_soho_inst(tmp)), /dir)
   ENDELSE

   IF N_ELEMENTS(stop) NE 0 THEN BEGIN
      stop_cur = anytim2utc(stop, /ecs, /date, errmsg=error)
      IF error NE '' THEN BEGIN
         MESSAGE, error, /cont
         RETURN, ''
      ENDIF
   ENDIF
   IF N_ELEMENTS(stop_cur) EQ 0 THEN BEGIN
      get_utc, tt, /ecs
      stop_cur = anytim2utc(tt, /ecs, /date)
   ENDIF

   IF N_ELEMENTS(start) NE 0 THEN BEGIN
      start_cur = anytim2utc(start, /ecs, /date, errmsg=error)
      IF error NE '' THEN BEGIN
         MESSAGE, error, /cont
         RETURN, ''
      ENDIF
      IF start_cur GT stop_cur THEN delvarx, start_cur
   ENDIF

   IF N_ELEMENTS(start_cur) EQ 0 THEN BEGIN
;----------------------------------------------------------------------
;     Set image enquiry start time 3 days before the start time
;----------------------------------------------------------------------
      tt = anytim2utc(stop_cur)
      tt.mjd = tt.mjd-3
      start_cur = anytim2utc(tt, /ecs, /date)
   ENDIF

   files = itool_getfile(start_cur, stop_cur, path, count=count)

   RETURN, files
END

;---------------------------------------------------------------------------
; End of 'get_synoptic.pro'.
;---------------------------------------------------------------------------
