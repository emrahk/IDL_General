;+
; NAME:
;           wplot_exclude
;
; PURPOSE:
;           Button to exclude non-selected data points
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +exclude+
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           "Exclude"
;
; DESCRIPTION:
;           Exclude not selected data-points. For this the command
;           "ignore,selected eq 0" will be called. This applies for
;           the current group. 
;               
; SIDE EFFECTS:
;           Changes defined flags of data points.
;
;
; HISTORY:
;           $Id: cafe_wplot_exclude.pro,v 1.9 2003/04/28 07:45:08 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_exclude.pro,v $
; Revision 1.9  2003/04/28 07:45:08  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.8  2003/04/24 09:55:10  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.7  2003/03/17 14:11:38  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:28  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/09 17:36:16  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_excludeevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env


    ;; report command:
    cafereport,env,'ignore, "selected eq 0"',/nocomment

    ;; exclude selected datapoints:
    cafe_ignore,env,"selected eq 0"    

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; EXCLUDE - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_exclude,env,  baseID,   help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_exclude"
    
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
        print, "exclude   - exclude selected datapoints"
        return
    ENDIF


    buttonID= widget_button(baseID, value="Exclude", $
                            event_pro="cafe_wplot_excludeevent")

END   
