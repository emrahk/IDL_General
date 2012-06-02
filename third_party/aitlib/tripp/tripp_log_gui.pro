FUNCTION TRIPP_LOG_GUI, log
;+
; NAME:
;           TRIPP_LOG_GUI
;
;
; PURPOSE:
;           Definition of a graphical user interface for the first
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
;           result: Structure (type: tripp_log_type) containing the first 
;                   part of the tripp_log_type structure.
;
;
; MODIFICATION HISTORY:
;   
;           Version 1.0, 1999/05/07, Jochen Deetjen 
;           Version 2.0, 2001/02   , SLS, smaller GUI
;
;-
   
  on_error,2                    ;Return to caller if an error occurs
   

   ;; ---------------------------------------------------------
   ;; --- DEFINE FORM SHEET ---
   ;;
   gui_sheet = [ '1, BASE,,ROW',        $
                 $
                 '1, BASE,,COLUMN',      $
                 '1, BASE,,COLUMN, FRAME',      $
                 '0, TEXT,'+log.instrument +' , LABEL_LEFT=Name of instrumentation     (e.g CA1.2 or  SA_CCD) : ,' $
                 + 'WIDTH=55, TAG=instrument', $
                 '0, TEXT,'+log.first      +' , LABEL_LEFT=Name of first image         (e.g PG1336_0001.fits) : ,' $
                 + 'WIDTH=55, TAG=first', $
                 '0, TEXT,'+log.last       +' , LABEL_LEFT=Name of last image          (e.g PG1336_0050.fits) : ,' $ 
                 + 'WIDTH=55, TAG=last', $
                 '0, TEXT,'+log.in_path    +' , LABEL_LEFT=Path to original images     (e.g.     /data/May28) : ,' $ 
                 + 'WIDTH=55, TAG=in_path', $
                 '0, TEXT,'+log.out_path   +' , LABEL_LEFT=Path to reduced images  (e.g. /data/May28_reduced) : ,' $ 
                 + 'WIDTH=55, TAG=out_path', $
                 '0, TEXT,'+log.zero       +' , LABEL_LEFT=Name of zero image          (e.g. zero_May28.fits) : ,' $ 
                 + 'WIDTH=55, TAG=zero', $
                 '0, TEXT,'+log.zero_corr  +' , LABEL_LEFT=Zero correction:            yes/no/overscan        : ,' $ 
                 + 'WIDTH=55, TAG=zero_corr', $
                 '0, TEXT,'+log.flat       +' , LABEL_LEFT=Name of flat image          (e.g. flat_May28.fits) : ,' $ 
                 + 'WIDTH=55, TAG=flat', $
                 '0, TEXT,'+log.flat_corr  +' , LABEL_LEFT=Flat correction:            yes/no                 : ,' $ 
                 + 'WIDTH=55, TAG=flat_corr', $
                 '0, TEXT,'+log.starID     +' , LABEL_LEFT=Object name                 (e.g           PG1316) : ,' $ 
                 + 'WIDTH=55, TAG=starID', $
                 '2, TEXT,'+log.block      +' , LABEL_LEFT=Observation Block ID  -  no changes allowed later! : ,' $ 
                 + 'WIDTH=55, TAG=block',  $
                 '2, BASE,,ROW', $
                 '1, BASE,,ROW',      $
                 '1, BASE,,COLUMN',      $
                 '1, BASE,,COLUMN, FRAME',      $
                 '0,INTEGER,'+STRING(log.mask_nrs)  +', LABEL_LEFT=MASK: Number of sources            : ,' $
                 + 'WIDTH=8, TAG=mask_nrs', $
                 '0,INTEGER,'+STRING(log.mask_sr)   +', LABEL_LEFT=MASK: Peak search radius   [pixel] : ,' $
                 + 'WIDTH=8, TAG=mask_sr', $
                 '0,INTEGER,'+STRING(log.mask_dist) +', LABEL_LEFT=MASK: Distance source - background : ,' $
                 + 'WIDTH=8, TAG=mask_dist', $
                 '0,INTEGER,'+STRING(log.mask_bw)   +', LABEL_LEFT=MASK: Background field side length : ,' $
                 + 'WIDTH=8, TAG=mask_bw', $
                 '0,INTEGER,'+STRING(log.extr_nrr)  +', LABEL_LEFT=EXTRACT: Number of aperture radii  : ,' $
                 + 'WIDTH=8, TAG=extr_nrr', $
                 '0,FLOAT  ,'+STRING(log.extr_minr) +', LABEL_LEFT=EXTRACT: Minimum radius    [pixel] : ,' $
                 + 'WIDTH=8, TAG=extr_minr', $
                 '0,FLOAT  ,'+STRING(log.extr_maxr) +', LABEL_LEFT=EXTRACT: Maximum radius    [pixel] : ,' $
                 + 'WIDTH=8, TAG=extr_maxr', $
                 '0,FLOAT  ,'+STRING(log.extr_tshft)+', LABEL_LEFT=WRITE  : Time shift      [seconds] : ,' $
                 + 'WIDTH=8, TAG=extr_tshft', $
                 '0,FLOAT  ,'+STRING(log.relflx_sr) +', LABEL_LEFT=RELFLUX: Selection Radius  [pixel] : ,' $
                 + 'WIDTH=8, TAG=relfl_sr', $
                 '0,INTEGER,'+STRING(log.relref_lth)+', LABEL_LEFT=RELFLUX: Number of comparison stars: ,' $
                 + 'WIDTH=8, TAG=relref_lth', $
                 '0,FLOAT  ,'+STRING(log.ft_min)    +', LABEL_LEFT=SHOW   : Min. frequency      [mHz] : ,' $
                 + 'WIDTH=8, TAG=ft_min', $
                 '2,FLOAT  ,'+STRING(log.ft_max)    +', LABEL_LEFT=SHOW   : Max. frequency      [mHz] : ,' $
                 + 'WIDTH=8, TAG=ft_max', $
                 $
                 '2, BUTTON, OK, QUIT,TAG=OK', $
                 '1, BASE,,ROW']
   
   ;; ---------------------------------------------------------
   ;; --- CREATE INSTANCE OF FROM SHEET DEFINED ABOVE --
   ;;
   log_gui = CW_FORM(gui_sheet, /COLUMN, title="Log File Interface")


   RETURN, log_gui
;; ---------------------------------------------------------
;;
END

;; ----------------------------------------

