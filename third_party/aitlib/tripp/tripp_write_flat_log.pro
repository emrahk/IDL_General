PRO TRIPP_WRITE_FLAT_log, logName
;+
; NAME:
;           TRIPP_WRITE_FLAT_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           flat series from terminal an write them in a log file.. 
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
; FUNCTIONS AND PROCEDURES: 
;           TRIPP_FLATLOG_TYPE
;           TRIPP_FLATLOG_GUI
;           TRIPP_READ_FLAT_LOG
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;                        2001/02   , SLS, added messages
;                        2001/02   , SLS, graphical interface 
;                        2001/02   , SLS, added overscan handling
;                        2001/05   , SLS, adapted to nomeclature of BUSCA
;-
 
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  ON_ERROR,2                    ;RETURN TO CALLER IF AN ERROR OCCURS

  IF N_ELEMENTS(LOGNAME) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_FLAT_LOG:  No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    RETURN
  ENDIF

;; ---------------------------------------------------------
;; --- TEST: DOES LOGFILE ALREADY EXIST?
;;
   TEST = FINDFILE(LOGNAME)
   TEST = TEST[0]
   
   IF (TEST EQ '') THEN BEGIN
     LOG = TRIPP_FLATLOG_TYPE()
   ENDIF ELSE BEGIN
     TRIPP_READ_FLAT_LOG, LOGNAME, LOG
   ENDELSE
   
   
;; ---------------------------------------------------------
;; --- READ IN LOG PARAMETERS FROM TERMINAL ---
;;
   LOG_NEW = TRIPP_FLATLOG_GUI(LOG)

   RESULT  = TRIPP_FLATLOG_TYPE()

   FOR I = 0, N_TAGS(LOG_NEW) -4 DO BEGIN
     RESULT.(I) = LOG_NEW.(I)
   ENDFOR
   RESULT.(9)  = LOG_NEW.(6)
   RESULT.(10) = LOG_NEW.(7)


;; ---------------------------------------------------------
;; --- EXTRACT FIRST AND LAST IMAGE NUMBER ---
;;
   FPOS           = STRPOS( RESULT.FIRST, '.fits' )
   RESULT.NR_POS  = FPOS - 4
   ;; while loop would be more elegant and more general for the following:
   IF  fix(STRMID( RESULT.FIRST, RESULT.NR_POS+3, 1)) EQ 0 AND $
     STRTRIM(string(fix(STRMID( RESULT.FIRST, RESULT.NR_POS+3, 1))),2) NE $
     STRMID( RESULT.FIRST, RESULT.NR_POS+3, 1) THEN BEGIN
     result.nr_pos = fpos - 5
;     print,"Warning: If your first image number can be divided by 10, you are in trouble now!"
;     print,"         Adjust tripp_write_flat_log to your needs."
   ENDIF
   
   
   FNUMBER        = STRMID( RESULT.FIRST, RESULT.NR_POS, 4)
   RESULT.OFFSET  = FNUMBER - 1
   
   LNUMBER        = STRMID( RESULT.LAST, RESULT.NR_POS, 4)
   RESULT.NR      = LNUMBER - RESULT.OFFSET
   
   LOG_NEW  = RESULT 
   
;; ---------------------------------------------------------
;; --- REMOVE LEADING AND TRAILING BLANKS ---
;;
   LOG_NEW.FIRST    = STRTRIM( LOG_NEW.FIRST, 2 )
   LOG_NEW.LAST     = STRTRIM( LOG_NEW.LAST, 2 )
   LOG_NEW.RESULT   = STRTRIM( LOG_NEW.RESULT, 2 )
   LOG_NEW.IN_PATH  = STRTRIM( LOG_NEW.IN_PATH, 2 )
   LOG_NEW.OUT_PATH = STRTRIM( LOG_NEW.OUT_PATH, 2 )
   LOG_NEW.ZERO     = STRTRIM( LOG_NEW.ZERO, 2 )
   ;; --- free overscan from ""
   new=STR_SEP(LOG_NEW.ZERO,'"')
   IF n_elements(new) GT 1 THEN LOG_NEW.ZERO     = new[1]
   
;; ---------------------------------------------------------
;; --- WRITE LOG FILE ---
;;
   
   GET_LUN, UNIT
   OPENW, UNIT, LOGNAME
   
   FOR I = 0, N_TAGS(LOG_NEW) - 1 DO BEGIN
     PRINTF, UNIT, LOG_NEW.(I)
   ENDFOR
   
   FREE_LUN, UNIT
   
   
   PRINT, ' '
   PRINT, '% TRIPP_WRITE_FLAT_LOG: Logfile information saved in ', LOGNAME
   PRINT, '% ==========================================================================================='
   PRINT, ' '
   
;; ---------------------------------------------------------
;;
 END

;; ----------------------------------------


