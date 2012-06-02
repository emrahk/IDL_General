PRO TRIPP_WRITE_ZERO_LOG, logName
;+
; NAME:
;           TRIPP_WRITE_ZERO_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           zero/dark series from terminal an write them in a log file.. 
;           Definition of each structure element: see below   
;
;
; INPUTS:
;           logName : Name of reduction log file 
;
;
; RESTRICTIONS:
;           file typ            : FITS
;           rule for image names: xyz0001.fits 
;                                 i.e. four digits - dot - extension 
;
;
; OUTPUTS:
;           logName : Log file containing all parameters for the reduction
;
; FUNCTIONS AND PROCEDURES:: 
;           TRIPP_ZEROLOG_TYPE
;           TRIPP_ZEROLOG_GUI
;           TRIPP_READ_ZERO_LOG
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;                        2001/02   , SLS, added messages
;                        2001/02   , SLS, graphical interface 
;                        2001/05   , SLS, adapted to nomeclature of BUSCA
;-
 
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs

  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_ZERO_LOG:  No logfile name has been specified.'
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
     log = TRIPP_ZEROLOG_TYPE()
   ENDIF ELSE BEGIN
     TRIPP_READ_ZERO_LOG, logname, log
   ENDELSE
   

;; ---------------------------------------------------------
;; --- READ IN LOG PARAMETERS FROM TERMINAL ---
;;
   log_new = TRIPP_ZEROLOG_GUI(log)

   result  = TRIPP_ZEROLOG_TYPE()

   FOR I = 0, N_TAGS(log_new) -4 DO BEGIN
     result.(i) = log_new.(i)
   ENDFOR
   result.(8)  = log_new.(5)
   result.(9) = log_new.(6)

;; ---------------------------------------------------------
;; --- EXTRACT FIRST AND LAST IMAGE NUMBER ---
;;
   fpos           = STRPOS( result.first, '.fits' )
   result.nr_pos  = fpos - 4
   ;; while loop would be more elegant and more general for the following:
   IF FIX(STRMID( result.first, result.nr_pos+3, 1)) EQ 0 AND $
     STRTRIM(STRING(FIX(STRMID( result.first, result.nr_pos+3, 1))),2) NE $
     STRMID( result.first, result.nr_pos+3, 1) THEN BEGIN 
     result.nr_pos = fpos - 5  
;     print,"Warning: If your first image number can be divided by 10, you are in trouble now!"
;     print,"         Adjust tripp_write_zero_log to your needs."
   ENDIF
   
   fnumber        = STRMID( result.first, result.nr_pos, 4)
   result.offset  = fnumber - 1
   
   lnumber        = STRMID( result.last, result.nr_pos, 4)
   result.nr      = lnumber - result.offset
   
   log_new  = result 
   
;; ---------------------------------------------------------
;; --- REMOVE LEADING AND TRAILING BLANKS ---
;;
   log_new.first    = STRTRIM( log_new.first, 2 )
   log_new.last     = STRTRIM( log_new.last, 2 )
   log_new.result   = STRTRIM( log_new.result, 2 )
   log_new.in_path  = STRTRIM( log_new.in_path, 2 )
   log_new.out_path = STRTRIM( log_new.out_path, 2 )
   
;; ---------------------------------------------------------
;; --- WRITE LOG FILE ---
;;
   
   GET_LUN, unit
   OPENW, unit, logname
   
   FOR I = 0, N_TAGS(log_new) - 1 DO BEGIN
     PRINTF, unit, log_new.(I)
   ENDFOR
   
   FREE_LUN, unit


PRINT, ' '
PRINT, '% TRIPP_WRITE_ZERO_LOG: Logfile information saved in ', logname
PRINT, '% ==========================================================================================='
PRINT, ' '

;; ---------------------------------------------------------
;;
END

;; ----------------------------------------





