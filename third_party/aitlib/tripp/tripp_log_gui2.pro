FUNCTION TRIPP_LOG_GUI2, log
;+
; NAME:
;           TRIPP_LOG_GUI2
;
;
; PURPOSE:
;           Definition of a graphical user interface for the second
;           part of the log files needed by the TRIPP routines
;
;
; INPUTS:
;           log: structure (type: tripp_log_type) containing either default 
;           values or values from a previous session. 
;
;
; RESTRICTIONS:
;           structure: TAG NAMES in log must correspond to those
;                      defined in tripp_log_type.
;
;   
; OUTPUT:
;           result: Structure (type: tripp_log_type) containing the second 
;                   part of the tripp_log_type structure.
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 1999/05/07, Jochen Deetjen 
;   
;-
   
  on_error,2                    ;Return to caller if an error occurs
   

   ;; ---------------------------------------------------------
   ;; --- DEFINE FORM SHEET ---
   ;;
   gui_sheet = [ '1, BASE,,ROW',        $
                 $
                 '1, BASE,,COLUMN, FRAME',      $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(0))+', LABEL_LEFT=Comparison Star #1      : ,' $      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_0', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(1))+', LABEL_LEFT=Comparison Star #2      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_1', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(2))+', LABEL_LEFT=Comparison Star #3      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_2', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(3))+', LABEL_LEFT=Comparison Star #4      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_3', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(4))+', LABEL_LEFT=Comparison Star #5      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_4', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(5))+', LABEL_LEFT=Comparison Star #6      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_5', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(6))+', LABEL_LEFT=Comparison Star #7      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_6', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(7))+', LABEL_LEFT=Comparison Star #8      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_7', $
                 '0,FLOAT  ,'+STRING(log.relflx_ref(8))+', LABEL_LEFT=Comparison Star #9      : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_8', $
                 '2,FLOAT  ,'+STRING(log.relflx_ref(9))+', LABEL_LEFT=Comparison Star #10     : ,' $
                 + 'WIDTH=8, TAG=relflx_ref_9', $
                 $
                 '2, BASE,,COLUMN', $
                 '1, BASE,,ROW', $
                 '0, BUTTON, OK, QUIT,TAG=OK']
   
   
   ;; ---------------------------------------------------------
   ;; --- CREATE INSTANCE OF FROM SHEET DEFINED ABOVE --
   ;;
   log_gui2 = CW_FORM(gui_sheet, /COLUMN, title="Log File Interface")
   
   RETURN, log_gui2
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------
