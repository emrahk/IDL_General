;+
; NAME:
;           wplot_sliderz
;
; PURPOSE:
;           Slider to shift z-range
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +sliderz+
;
; SUBCATEGORY:
;           wplot slider
;
;
; DESCRIPTION:
;           Supplies slider for shifting data in z direction (3-dim).
;               
; SIDE EFFECTS:
;           Changes zposition of displayed plot.
;
;
; HISTORY:
;           $Id: cafe_wplot_sliderz.pro,v 1.6 2003/04/28 07:45:11 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_sliderz.pro,v $
; Revision 1.6  2003/04/28 07:45:11  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.5  2003/04/24 09:55:11  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.4  2003/04/03 10:03:00  goehler
; do not plot when setplot is performed
;
; Revision 1.3  2003/03/17 14:11:42  goehler
; review/documentation updated.
;
; Revision 1.2  2003/03/03 11:18:31  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2003/02/13 14:44:48  goehler
; added slider for wplot (may be added as buttons)
;






;; ------------------------------------------------------------
;; CAFE_WPLOT_SLIDERZEVENT --- EVENT PROCEDURE WHEN Z-SLIDER MOVED
;; ------------------------------------------------------------

PRO cafe_wplot_sliderzevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get value:
    widget_control,ev.id,get_value=pos

    ;; set new z position (in range 0..10000):
    (*env).plot.zpos =            $
      ev.value * ((*env).plot.range[5] - (*env).plot.range[4]) / 10000.D0 $
      + (*env).plot.range[4]

    
    ;; set current range:
    zrange=[(*env).plot.zpos-(*env).plot.zwidth/2.D0, $
            (*env).plot.zpos+(*env).plot.zwidth/2.D0]

    ;; store it:
    cafe_setplot,env,"zrange=["+string(zrange[0])+","+ $
      string(zrange[1])+"]",/quiet,/report

    ;; plot on pixmap:
    wset, (*env).widgets.pixID
    cafe_plot,env,/quiet

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID    

    ;; copy pixmap -> window
    device,copy=[0,0,(*env).widgets.xsize, $
                 (*env).widgets.ysize,0,0,$
                 (*env).widgets.pixID]

END 


;; ------------------------------------------------------------
;; SLIDERZ - THE MAIN FUNCTION WHICH ALLOCATES A NEW SLIDER
;; ------------------------------------------------------------

PRO cafe_wplot_sliderz,env,  baseID,   help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_sliderz"
    
    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env, name
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; SHORT HELP
    ;; ------------------------------------------------------------
    IF keyword_set(shorthelp) THEN BEGIN  
        print, "sliderz   - slider for z range"
        return
    ENDIF


    ;; force exact data range:
    cafe_setplot,(env),"zstyle=1",/quiet,/report

    ;; install slider:
    ZsliderID=widget_slider(baseID, $
                            event_PRO="cafe_wplot_sliderzevent",$
                            maximum=10000, $
                            minimum=0, $
                            /drag,value=5000,/suppress_value)
END   





