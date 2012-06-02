;+
; NAME:
;           wplot_rotright
;
; PURPOSE:
;           Button to rotate 3-dim pictures anticlock wise
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +rotright+
;
; SUBCATEGORY:
;           wplot button
;
; BUTTON LABEL:
;           "rot->"
;
; DESCRIPTION:
;           Rotate displayed plot window 10deg right.
;               
; SIDE EFFECTS:
;           Changes view of displayed plot. For this setplot parameter
;           "AZ" will be increased by 10. 
;
;
; HISTORY:
;           $Id: cafe_wplot_rotright.pro,v 1.6 2003/04/28 07:45:09 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_rotright.pro,v $
; Revision 1.6  2003/04/28 07:45:09  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.5  2003/04/24 09:55:10  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.4  2003/04/03 10:02:59  goehler
; do not plot when setplot is performed
;
; Revision 1.3  2003/03/17 14:11:40  goehler
; review/documentation updated.
;
; Revision 1.2  2003/03/03 11:18:30  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2003/02/12 12:39:38  goehler
; initial rotation buttons
;
;
;







;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_rotrightevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env

    ;; set new x position:
    (*env).plot.az =            $
      (*env).plot.az + 10

    ;; store it:
    cafe_setplot,env,"az="+string((*env).plot.az),/quiet,/report


    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; ROTRIGHT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_rotright,env,  baseID,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_rotright"
    
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
        print, "rotright   - rotate right button"
        return
    ENDIF


    buttonID= widget_button(baseID, value="  rot->  ", $
                            event_pro="cafe_wplot_rotrightevent")

END   
