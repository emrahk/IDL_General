PRO TRIPP_READ_FLAT_LOG, logName, flat

;+
; NAME:
;           TRIPP_READ_FLAT_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           flat series. 
;           Definition of each structure element: see TRIPP_WRITE_FLAT_LOG
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
;           flat : Structure containing all parameters for the reduction
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;           Version 2.0, 2001/02   , SLS, use TRIPP_FLATLOG_TYPE now; 
;                                    reading-in has changed appropriately
;-
 
  on_error,2                    ;Return to caller if an error occurs

;; ---------------------------------------------------------
;; --- STRUCTURE DEFINITION ---
;;
  flat = TRIPP_FLATLOG_TYPE()

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
   GET_LUN, unit
   OPENR, unit, logName

   FOR I = 0, N_TAGS(flat) -1  DO BEGIN
       dummy = flat.(I)
       READF, unit, dummy
       flat.(I) = dummy
   ENDFOR

   FREE_LUN, unit

;; ---------------------------------------------------------
;;
END

;; ----------------------------------------



