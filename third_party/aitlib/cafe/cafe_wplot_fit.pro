;+
; NAME:
;           wplot_fit
;
; PURPOSE:
;           Button to fit selected data points
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +fit+
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           "Fit"
;
; DESCRIPTION:
;           Fit applies the fit function with last defined model
;           to the selected data. Non selected data are not taken
;           into account.
;           For this the function "fit,/selected" is called.
;               
; SIDE EFFECTS:
;           Changes fit results. 
;
;
; HISTORY:
;           $Id: cafe_wplot_fit.pro,v 1.10 2003/04/28 07:45:08 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_fit.pro,v $
; Revision 1.10  2003/04/28 07:45:08  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.9  2003/04/24 13:55:01  goehler
; report of quiet fit
;
; Revision 1.8  2003/04/24 09:55:10  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.7  2003/03/18 08:48:23  goehler
; quiet fit for button
; added hourglass
;
; Revision 1.6  2003/03/17 14:11:39  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:28  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:16  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_fitevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env

    ;; show hourglass:
    widget_control,(*env).widgets.drawID,/hourglass

    ;; report command:
    cafereport,env,'fit,/selected,/quiet',/nocomment

    ;; fit selected datapoints:
    cafe_fit,env,/selected,/quiet

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; FIT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_fit,env,  baseID,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_fit"
    
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
        print, "fit      - fit selected datapoints"
        return
    ENDIF


    buttonID= widget_button(baseID, value=" Fit ", $
                            event_pro="cafe_wplot_fitevent")

END   
