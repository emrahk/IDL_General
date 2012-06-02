PRO TRIPP_TIMING, logName, scargle=scargle, dynscargle=dynscargle, $
                  epoc=epoc, dynepoc=dynepoc, sinfit=sinfit

;+
; NAME:                  
;                        TRIPP_TIMING
;
;
;
; PURPOSE:               
;                        Provide an easy-to use interface for all sorts
;                        of timing analysis tools with data junks
;                        obtained from photometry with TRIPP or any time
;                        series 
;
;
;
; CATEGORY:              
;
;
;
; CALLING SEQUENCE:      
;                        TRIPP_TIMING, logName,[/scargle, dynscargle,
;                        /epoc, dynepoc, /sinfit]
;
;
;
; INPUTS:                
;                       logname: Name of data file or a log file
;                       (finfile: *_idl.fin from TRIPP_WRITE_FINAL  
;                                 if log file is specified - has to
;                                 exist but is not given as an
;                                 explicit input) 
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:    
;                        /scargle    : 
;                        /dynscargle :
;                        /epoc       :
;                        /dynepoc    :
;                        /sinfit     :
;
;
; OUTPUTS:               
;                        IDL SAVE file,
;                        x,y ASCII data file, 
;                        and PS File
;
;                        each with extensions depending on the
;                        keywords set:  *.psd, *.chi, *.sin
;
;
; OPTIONAL OUTPUTS:      
;                        none
;
;
;
; COMMON BLOCKS:         
;                        none
;
;
;
; SIDE EFFECTS:          
;                        (?)
;
;
;
; RESTRICTIONS:          
;                        Uses *_idl.fin IDL SAVE file exclusively if
;                        logName is a true log file, not a data file.
;                        If logName is a data file, it has to be a
;                        simple x,y table without header or trailing
;                        information. 
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
;                        2001/02 Sonja L. Schuh
;
;-

  
  
;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_TIMING:     No logfile or datafile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_TIMING:     The specified logfile or datafile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0] 
      PRINT, '% TRIPP_TIMING:     Using logfile/datafile ', logname 
    ENDIF
  ENDELSE


;; BEFORE CONTINUING, remember that save files should not be used any
;; more! Change data formats before attempting to continue on this routine.

  
;; ---------------------------------------------------------
;; --- TIMING ANALYSIS OPTIONS
;;

  IF KEYWORD_SET(scargle) THEN BEGIN
                               ;; evoke gui there to give the possibility to 
                               ;; change the just calculated suggestions for the defaults?
    TRIPP_CALC_SCARGLE,logName ;;                    ---> * _idl.psd, *.psd
    TRIPP_SHOW_SCARGLE,logName ;; old tripp_show_all ---> *_psd.ps
  ENDIF
  IF KEYWORD_SET(dynscargle) THEN BEGIN
    TRIPP_SHOW_SCARGLE,logName,/dyn ;;               ---> *ps
  ENDIF
  IF KEYWORD_SET(epoc) THEN BEGIN
    TRIPP_CALC_EPOC,logName    ;;                    ---> *_idl.chi, *.chi
    TRIPP_SHOW_EPOC,logName    ;; old tripp_show_epoc---> *_chi.ps
  ENDIF
  IF KEYWORD_SET(dynepoc) THEN BEGIN
    TRIPP_SHOW_EPOC,logName,/dyn
  ENDIF
  IF KEYWORD_SET(sinfit) THEN BEGIN
    TRIPP_CALC_SINFIT,logName  ;; old tripp_sinfit   ---> *_idl.sin, *.sin
    TRIPP_SHOW_SINFIT,logName  ;; old tripp_show_sinfit
  ENDIF



PRINT, " "
PRINT, "% TRIPP_TIMING: Done."
PRINT, "% ==========================================================================================="
PRINT, " "




;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------

