PRO tripp_read_pos, log, files, rx, ry, start, silent=silent
;+
; NAME:
;                     TRIPP_READ_POS
;
;
; PURPOSE:
;                     Read in posfile and return entries as well as
;                     possible difference to expected number of
;                     entries from logfile 
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:             
;                     log
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;                     /silent
;
;
; OUTPUTS:            
;                     files, rx, ry, start
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;                       2001/05,  Author: Sonja L. Schuh
;-
;; --- DECLARATIONS
  rx       = DBLARR( log.nr )
  ry       = DBLARR( log.nr )
  files    = STRARR( log.nr )
  line     = ""
  start    = log.nr

;; --- CONSTRUCT POSFILE NAME
  posFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.pos, 2 )
  IF NOT KEYWORD_SET(silent) THEN $
  print,"% TRIPP_READ_POS: Reading position reference file ",posfile

;; --- READ IN FILE 
  GET_LUN, unit
  OPENR, unit, posFile
  
  FOR i=0,2 DO READF, unit, line
  
  FOR idx = 0, log.nr-1 DO BEGIN
    IF NOT EOF(unit) THEN BEGIN
      READF, unit, line
      line_sep   = STR_SEP( STRTRIM( STRCOMPRESS( line ),2),' ')
      files[idx] = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( line_sep[0], 2 )
      rx[idx]    = line_sep[1]
      ry[idx]    = line_sep[2]
      start      = idx+1
    ENDIF
  ENDFOR
  
  FREE_LUN, unit

end
