PRO TRIPP_READ_IMAGE_LOG, logName, result
;+
; NAME:
;           TRIPP_READ_IMAGE_LOG
;
;
; PURPOSE:
;           Read all parameters concerning the reduction of an 
;           image series. 
;           Definition of each structure element: see TRIPP_WRITE_IMAGE_LOG
;
;
; INPUTS:
;           logName : Name of reduction log file 
;
;
; RESTRICTIONS:
;   
;           file typ            : FITS
;           rule for image names: xyz0001.fits 
;                                 i.e. four digits - dot - extension 
;
; OUTPUT:
;           result : Structure containing all parameters for the reduction
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 1999/29/05, Jochen Deetjen 
;           Version 1.1, 1999/05/07, Jochen Deetjen 
;   
;-

 
  on_error,2                    ;Return to caller if an error occurs

;; ---------------------------------------------------------
;; --- READ IN LOG FILE ---
;;
   
   result = tripp_log_type()
   
   GET_LUN, unit
   OPENR, unit, logName

   FOR I = 0, N_TAGS(result) -1  DO BEGIN
       dummy = result.(I)
       READF, unit, dummy
       result.(I) = dummy
   ENDFOR

   FREE_LUN, unit

   
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------
