FUNCTION TRIPP_ZEROLOG_GUI, log
;+
; NAME:
;           TRIPP_ZEROLOG_GUI
;
;
; PURPOSE:
;           Definition of a graphical user interface for the zero
;           version of the log files needed by the TRIPP routines
;
;
; INPUTS:
;           log: structure (type: tripp_zerolog_type) containing either default 
;           values or values from a previous session. 
;
;
; RESTRICTIONS:
;           structure: TAG NAMES in log must correspond to those
;                      defined in tripp_zerolog_type.
;
;   
; OUTPUT:
;           result: Structure (type: tripp_flatlog_type) containing the zero 
;                   version of the tripp_zerolog_type structure.
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 2001/02 SLS
;   
;-
  
  on_error,2                    ;Return to caller if an error occurs
  
  
  ;; ---------------------------------------------------------
  ;; --- DEFINE FORM SHEET ---
  ;;
  gui_sheet = [ '1, BASE,,ROW',        $
                $
                '1, BASE,,COLUMN, FRAME',      $
                '0,TEXT   ,'+STRING(log.first)+', LABEL_LEFT=Name of first image              (e.g DF_0001.fits): ,' $ : ,'$
                + 'WIDTH=55, TAG=first', $
                '0,TEXT   ,'+STRING(log.last)+', LABEL_LEFT=Name of last image               (e.g DF_0050.fits): ,' $
                + 'WIDTH=55, TAG=last', $
                '0,TEXT   ,'+STRING(log.result)+', LABEL_LEFT=Output file name            (e.g flat_median.fits) : ,' $
                + 'WIDTH=55, TAG=result', $
                '0,TEXT   ,'+STRING(log.in_path)+', LABEL_LEFT=Path to original images         (e.g. /data/May23) : ,' $
                + 'WIDTH=55, TAG=in_path', $
                '0,TEXT   ,'+STRING(log.out_path)+', LABEL_LEFT=Path to reduced images  (e.g. /data/May28_reduced) : ,' $
                + 'WIDTH=55, TAG=out_path', $
                '0,FLOAT  ,'+STRING(log.xsize)+', LABEL_LEFT=CCD-Chip x-size                        (e.g. 1083) : ,' $
                + 'WIDTH=55, TAG=xsize', $
                '0,FLOAT  ,'+STRING(log.ysize)+', LABEL_LEFT=CCD-Chip y-size                        (e.g. 1024) : ,' $
                + 'WIDTH=55, TAG=ysize', $
                '2, BASE,,COLUMN', $
                '1, BASE,,ROW', $
                '0, BUTTON, OK, QUIT,TAG=OK' ]
  
  
  ;; ---------------------------------------------------------
  ;; --- CREATE INSTANCE OF FROM SHEET DEFINED ABOVE --
  ;;
  log_gui = CW_FORM(gui_sheet, /COLUMN, title="Log File Interface")
  
  RETURN, log_gui
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------






