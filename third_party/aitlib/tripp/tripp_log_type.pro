FUNCTION TRIPP_LOG_TYPE
;+
; NAME:
;           TRIPP_LOG_TYPE
;
;
; PURPOSE:
;           definition of a structure containing all information needed
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
;           Version 1.0, 1999/05/07, Jochen Deetjen 
;           Version 1.0, 1999/08/10, Stefan Dreizler
;           Version 1.0, 1999/01/12, Sonja Schuh 
;           Version 1.0, 2001/02     Sonja L. Schuh 
;   
;-
   
   

   ;; ---------------------------------------------------------
   ;; --- DEFINE LOG_TYPE ---
   ;;
   log = { LOG_TYPE, $
           instrument: 'CA2.2', $
           first    : '0001.fits', $
           last     : '0002.fits', $
           in_path  : '../data', $
           out_path : '../data_reduced', $  
           zero     : 'Zero_', $
           zero_corr: 'no', $
           flat     : 'Flat_', $
           flat_corr: 'no', $
           starID   : '', $
           block    : '', $
           pos      : '', $
           mask     : '', $
           flux     : '', $
           relflx   : '', $
           stat     : '', $ 
           ft       : '', $
           lc       : '', $
           data     : '', $
           xsize    :  0,  $
           ysize    :  0,  $
           mask_nrs :   2, $
           mask_sr  : 5.0, $
           mask_dist:  12, $
           mask_bw  :   7, $
           extr_nrr :  10, $
           extr_minr:   1, $
           extr_maxr:  11, $
           extr_tshft: 0.0, $
           relflx_sr : 5.0, $
           relref_lth: 1, $
           ft_min    : 1000.0, $
           ft_max    : 10000.0, $
           relflx_ref: MAKE_ARRAY(1,10,/INT,value=0),$
           nr_pos    : 0, $
           offset    : 0, $
           nr        : 0}
   
   return, log
   
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------

