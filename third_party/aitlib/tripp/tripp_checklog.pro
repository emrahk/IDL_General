PRO TRIPP_CHECKLOG, logname
;+
; NAME:
;                     TRIPP_CHECKLOG
;
;
; PURPOSE:
;                     Check whether a logfile has been specified, 
;                     check existence of logfile, 
;                     complete logfile name if necessary
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:   TRIPP_CHECKLOG, logname
;
;
;
; INPUTS:             
;                     logname
;
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:            
;                     completed logname or error message
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
;                       2001/07,  Author: Sonja L. Schuh
;-


IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_CHECKLOG: No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                 Exiting program now.'    
    retall
ENDIF
IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_CHECKLOG: The specified logfile: ', logname 
    PRINT,   '                  does not exist.'
    PRINT, ' '    
    PRINT,   '%                 Exiting program now.'    
    retall
ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
        logname=(findfile(logname))[0]
        PRINT, '% TRIPP_CHECKLOG: Using Logfile ', logname 
    ENDIF
ENDELSE


END