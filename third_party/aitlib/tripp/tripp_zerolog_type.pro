FUNCTION TRIPP_ZEROLOG_TYPE
;+
; NAME:
;           TRIPP_ZEROLOG_TYPE
;
;
; PURPOSE:
;           Definition of a structure containing all information needed
;           by the TRIPP routines
;
;
; INPUTS:
;           none
;
;
; RESTRICTIONS:
;
;   
; OUTPUT:
;           result: Structure (type: tripp_log_type) containing the default
;                   values of this new type.
;
;
; MODIFICATION HISTORY:
;   
;           version 1.0, 2001/02, Sonja L. Schuh 
;   
;-
   
  on_error,2                    ;Return to caller if an error occurs
   

  ;; ---------------------------------------------------------
  ;; --- DEFINE LOG_TYPE ---
  ;;
  zero = { ZERO_LOG, first    : '', $
           last     : '', $
           result   : '', $
           in_path  : '', $
           out_path : '', $  
           nr_pos   :  0, $
           nr       :  0, $
           offset   :  0, $
           xsize    :  0, $
           ysize    :  0  }
  
  return, zero
  
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------

