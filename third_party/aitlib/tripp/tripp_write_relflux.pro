PRO TRIPP_WRITE_RELFLUX, logName,no_norm=no_norm,norm=norm
;+
; NAME:
;	TRIPP_WRITE_RELFLUX
;
; PURPOSE:   
;   
;	Write IDL-saved flux data (*.rms-file) from
;	photometrical time series to ascii 
;
; CATEGORY:
;   
;	Astronomical Photometry.
;
;
; CALLING SEQUENCE:
;   
;       TRIPP_WRITE_RELFLUX, LOGNAME = logName
;   
; INPUTS:
;	
;       IDL SAVE file *.RMS
;
;
; OUTPUTS:
;   
;	ASCII file '*.DAT' containing reduced data as x,y- table:
;       x corresponds to time, y corresponds to relative flux
;
;	
; RESTRICTIONS:
;   
;       file type:      RMS as produced by TRIPP_CALC_RELFLUX (or ccd_rms
;                       or ccd_rms_multi, in principle) 
;	Input directory and filename structure as specified in Log  
;
; REVISION HISTORY:
;   
;       Version 1.0, 1999/06, Sonja Schuh
;                    2001/02, SLS, added messages 
;       Version 1.0, 2001/02, SLS, new handling for no_norm / norm:
;                             new keyword norm
;                             default is now NO normalisation
;                             no_norm will have no further effect
;                             norm will force the normalisation to be done
;                    2001/05, SLS, bug fix: norm had not worked properly 
;-


;; ---------------------------------------------------------
;; --- PREPARATIONS
;;

  on_error,2                    ;Return to caller if an error occurs
  
  IF n_elements(logname) EQ 0 THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_RELFLUX:   No logfile name has been specified.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF
  IF (findfile(logname))[0] EQ '' THEN BEGIN
    PRINT, ' '    
    PRINT,   '% TRIPP_WRITE_RELFLUX:   The specified logfile does not exist.'
    PRINT, ' '    
    PRINT,   '%                        Exiting program now.'    
    return
  ENDIF ELSE BEGIN
    IF logname NE (findfile(logname))[0] THEN BEGIN
      logname=(findfile(logname))[0]
      PRINT, '% TRIPP_WRITE_RELFLUX:   Using Logfile ', logname 
    ENDIF
  ENDELSE


IF NOT EXIST(no_norm) THEN no_norm = 1
IF NOT EXIST(   norm) THEN    norm = 0
IF norm EQ 0 THEN no_norm = 1
IF norm EQ 1 THEN no_norm = 0

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
TRIPP_READ_IMAGE_LOG, logName, log


;; ---------------------------------------------------------
;; --- READ RMS FILE ---
;;
rmsFile         = log.out_path + '/' + log.relflx
datFile         = log.out_path + '/' + log.data
idlFile         = log.out_path + '/' + log.block + "_idl.dat" 

RESTORE, rmsFile


PRINT, " "
PRINT, "% TRIPP_WRITE_RELFLUX: Input rms  file      : " + rmsFile
PRINT, "% TRIPP_WRITE_RELFLUX: Output data files    : " + datFile
PRINT, "% TRIPP_WRITE_RELFLUX:                        " + idlFile
PRINT, " "

;; ---------------------------------------------------------
;; --- CLEAN DATA
;;    
idx     = where (fneu[0,*] NE 0.)
fclean  = fneu [0,idx]
tclean  = time [idx]  

dim     = size (tclean)


;; ---------------------------------------------------------
;; --- CORRECT FOR TIME SHIFT 
;;
tshift  = log.extr_tshft/86400.
tclean = tclean + tshift

;; ---------------------------------------------------------
;; --- NORMALIZE FLUX 
;;
IF (no_norm EQ 0) THEN BEGIN
    m      = mean( fclean )
    fclean = fclean / m
ENDIF
    
;; ---------------------------------------------------------
;; --- WRITE RESULT TO ASCII DAT FILE
;;

GET_LUN, unit
OPENW, unit, datFile

FOR  k = 0, dim[1] -1  DO BEGIN
    PRINTF, unit, tclean[k], fclean[k] ,format='(f14.6,f14.6)'
ENDFOR

FREE_LUN, unit


PRINT, " "
PRINT, "% TRIPP_WRITE_RELFLUX: DATA WRITTEN TO FILE " + datFile

;; ---------------------------------------------------------
;; --- SAVE RESULT TO IDL SAVE FILE
;;

tclean=reform(tclean)
fclean=reform(fclean)
SAVE, filename = idlFile, tclean, fclean


PRINT, " "
PRINT, "% TRIPP_WRITE_RELFLUX: DATA WRITTEN TO FILE " + idlFile
PRINT, "% ==========================================================================================="
PRINT, " "
PRINT, "% TRIPP_WRITE_RELFLUX: TO CONTINUE, YOU MAY USE "
PRINT, " "
PRINT, "                       restore, '"+idlFile+"'"
PRINT, " "

;; ---------------------------------------------------------
;; --- END ---
;;
END

;; -------------------------------------






