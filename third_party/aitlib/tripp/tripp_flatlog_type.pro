FUNCTION TRIPP_FLATLOG_TYPE
;+
; NAME:
;           TRIPP_FLATLOG_TYPE
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
;           result: Structure (type: tripp_flatlog_type) containing the default
;                   values of this new type.
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 2001/02, Sonja L. Schuh 
;   
;-
   
  on_error,2                    ;Return to caller if an error occurs
   

  ;; ---------------------------------------------------------
  ;; --- DEFINE LOG_TYPE ---
  ;;
  flat = { FLAT_LOG, first   : '', $
           last     : '', $
           result   : '', $
           in_path  : '', $
           out_path : '', $  
           zero     : '', $
           nr_pos   :  0, $
           nr       :  0, $
           offset   :  0, $
           xsize    :  0, $
           ysize    :  0  }

  return, flat
  
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------


