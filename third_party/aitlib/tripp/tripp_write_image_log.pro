PRO TRIPP_WRITE_IMAGE_LOG, logName
;+
; NAME:
;           TRIPP_WRITE_IMAGE_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           image series from terminal and write them to a log file. 
;           Definition of each structure element: see below   
;
;
; INPUTS:
;           logName : Name of reduction log file    
;
;
; RESTRICTIONS:
;   
;           file type            : FITS
;           rule for image names: xyz0001.fits 
;                                 i.e. four digits - dot - extension 
;
; OUTPUTS:
;           logName : Log file containing all parameters for the reduction
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;           Version 1.1, 1999/05/07, Jochen Deetjen 
;                        2001/02   , SLS, added messages 
;-
   
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_IMAGE_LOG: No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF

;; ---------------------------------------------------------
;; --- TEST: DOES LOGFILE ALREADY EXIST?
;;
   test = findfile(logname)
   test = test[0]
   
   IF (test EQ '') THEN BEGIN
       log = TRIPP_LOG_TYPE() 
   ENDIF ELSE BEGIN
       TRIPP_READ_IMAGE_LOG, logname, log
   ENDELSE
   
;; ---------------------------------------------------------
;; --- WRITE NEW / CHANGE EXISTING LOG FILE ---
;;
   log1_new = TRIPP_LOG_GUI(log)
   log2_new = TRIPP_LOG_GUI2(log)
   log_new  = TRIPP_LOG_COMBINE(log1_new, log2_new)
   
   
;; ---------------------------------------------------------
;; --- WRITE LOG FILE ---
;;
   GET_LUN, unit
   OPENW, unit, logName

   FOR I = 0, N_TAGS(log_new) - 1 DO BEGIN
       PRINTF, unit, log_new.(I)
   ENDFOR

   FREE_LUN, unit
   
PRINT, ' '
PRINT, '% TRIPP_WRITE_IMAGE_LOG: Logfile information saved in ', logname
PRINT, '% ==========================================================================================='
PRINT, ' '

;; ---------------------------------------------------------
;;
END

;; ----------------------------------------


