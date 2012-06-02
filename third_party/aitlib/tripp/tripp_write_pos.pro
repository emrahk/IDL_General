PRO tripp_write_pos, log, files, rx, ry, posfile, silent=silent
;+
; NAME:
;                     TRIPP_WRITE_POS
;
;
; PURPOSE:
;                     Write posfile
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
;                     log, files, rx, rx
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
; OUTPUTS:            posfile (name)
;                     
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
;; --- CONSTRUCT POSFILE NAME
  posFile = STRTRIM( log.out_path, 2 ) + '/' + STRTRIM( log.pos, 2 )
  IF NOT KEYWORD_SET(silent) THEN $
    PRINT,"% TRIPP_WRITE_POS: Writing position reference file ",posfile
  
;; --- CUT ADDITIONAL PATH INFORMATION
  FOR idx = 0, log.nr-1 DO BEGIN
    sep   = STR_SEP( STRTRIM( STRCOMPRESS( files[idx] ),2),'/')
    files[idx] = sep[n_elements(sep)-1]
  ENDFOR

;; --- WRITE FILE
  GET_LUN, unit
  OPENW, unit, posFile
  
  sde  = '% TRIPP_REDUCTION: Pos.ref.star ID : ' + log.starID
  
  PRINTF, unit, sde
  PRINTF, unit, '% TRIPP_REDUCTION: Number of images : ', log.nr
  PRINTF, unit, '% TRIPP_REDUCTION: Columns          : image ID, x, y [pixel]'
  
  FOR idx = 0, log.nr-1 DO BEGIN
    PRINTF, unit, files[idx]+' '+$
      STRTRIM(STRING( rx[idx] ),2) + ' ' + STRTRIM(STRING( ry[idx] ),2)
  ENDFOR
  
  FREE_LUN, unit

END
