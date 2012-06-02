;+
; NAME:
;           wplot_shiftright
;
; PURPOSE:
;           Button to change view of data
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +shiftright+
;
; SUBCATEGORY:
;           wplot button
;
; BUTTON LABEL:
;           ">>"
;
; DESCRIPTION:
;           Shift viewed portion right by 75% of displayed plot range.
;               
; SIDE EFFECTS:
;           Changes xposition of displayed plot.
;
; HISTORY:
;           $Id: cafe_wplot_shiftright.pro,v 1.9 2003/04/28 07:45:10 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_shiftright.pro,v $
; Revision 1.9  2003/04/28 07:45:10  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.8  2003/04/24 09:55:10  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.7  2003/04/03 10:03:00  goehler
; do not plot when setplot is performed
;
; Revision 1.6  2003/03/17 14:11:41  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:30  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:17  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;







;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_shiftrightevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env


    ;; set new x position:
    (*env).plot.xpos =            $
      (*env).plot.xpos + 0.75*(*env).plot.xwidth

    
    ;; set current range:
    xrange=[(*env).plot.xpos-(*env).plot.xwidth/2.D0, $
            (*env).plot.xpos+(*env).plot.xwidth/2.D0]

    ;; store it:
    cafe_setplot,env,"xrange=["+string(xrange[0])+","+ $
      string(xrange[1])+"]",/quiet,/report


    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet
END  


;; ------------------------------------------------------------
;; SHIFTRIGHT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_shiftright,env,  baseID,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_shiftright"
    
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
        print, "shiftright   - shift right button"
        return
    ENDIF


    buttonID= widget_button(baseID, value="  >>  ", $
                            event_pro="cafe_wplot_shiftrightevent")

END   
