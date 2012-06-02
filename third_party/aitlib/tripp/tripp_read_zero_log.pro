PRO TRIPP_READ_ZERO_LOG, logName, zero
;+
; NAME:
;           TRIPP_READ_ZERO_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           zero/dark series. 
;           Definition of each structure element: see TRIPP_WRITE_ZERO_LOG
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
;           zero : Structure containing all parameters for the reduction
;
;
; MODIFICATION HISTORY:
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;           Version 2.0, 2001/02   , SLS, use TRIPP_ZEROLOG_TYPE now; 
;                                    reading-in has changed appropriately
;
;-

  
  on_error,2                    ;Return to caller if an error occurs
  
;; ---------------------------------------------------------
;; --- STRUCTURE DEFINITION ---
;;
  zero = tripp_zerolog_type()

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
   GET_LUN, unit
   OPENR, unit, logName

   FOR I = 0, N_TAGS(zero) -1  DO BEGIN
       dummy = zero.(I)
       READF, unit, dummy
       zero.(I) = dummy
   ENDFOR

   FREE_LUN, unit
  
  
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------



