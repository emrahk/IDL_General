;+
; NAME:
;           wplot_sliderrotx
;
; PURPOSE:
;           Slider to rotate around x-range
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +sliderrotx+
;
; SUBCATEGORY:
;           wplot slider
;
;
; DESCRIPTION:
;           Moving the slider rotates the view around the x axis
;           allowing inspection of 3 dimensional data. Does not affect
;           2 dimensional plots.
;           Rotating around x axis allows face-on views of data
;           (usefull for contour plots).
;               
; SIDE EFFECTS:
;           Changes viewpoint of displayed plot via setplot of "AX"
;           keyword. 
;
;
; HISTORY:
;           $Id: cafe_wplot_sliderrotx.pro,v 1.6 2003/04/28 07:45:10 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_sliderrotx.pro,v $
; Revision 1.6  2003/04/28 07:45:10  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.5  2003/04/24 09:55:11  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.4  2003/04/03 10:03:00  goehler
; do not plot when setplot is performed
;
; Revision 1.3  2003/03/17 14:11:41  goehler
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
;; CAFE_WPLOT_SLIDERROTXEVENT --- EVENT PROCEDURE WHEN Z-SLIDER MOVED
;; ------------------------------------------------------------

PRO cafe_wplot_sliderrotxevent, ev

    ;; get environment:
    widget_control,ev.top,get_uvalue=env

    ;; get value:
    widget_control,ev.id,get_value=pos

    ;; set new z position (in range 0..2*360):
    (*env).plot.ax =  ev.value 
   
    ;; store it:
    cafe_setplot,env,"ax="+string((*env).plot.ax),/quiet,/report

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
;; SLIDERROTX - THE MAIN FUNCTION WHICH ALLOCATES A NEW SLIDER
;; ------------------------------------------------------------

PRO cafe_wplot_sliderrotx,env,  baseID,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_sliderrotx"
    
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
        print, "sliderrotx   - slider rotating around x axis"
        return
    ENDIF

    ;; install slider:
    ZsliderID=widget_slider(baseID, $
                            event_PRO="cafe_wplot_sliderrotxevent",$
                            maximum=90, $
                            minimum=-90, $
                            /drag,value=30,/suppress_value)
END   





