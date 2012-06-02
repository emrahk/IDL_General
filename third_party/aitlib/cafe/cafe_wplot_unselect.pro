;+
; NAME:
;           wplot_unselect
;
; PURPOSE:
;           Button to unselect all data points
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +unselect[group]+
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           "unselect"
;
; DESCRIPTION:
;           Clear all selection marks on data in current group.
;
; PARAMETER:
;           group - Group number on which the unselect command should work. 
;                   Default: current group.
;               
; SIDE EFFECTS:
;           Changes selected flag of data points
;
;
; HISTORY:
;           $Id: cafe_wplot_unselect.pro,v 1.9 2003/04/28 07:45:11 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_unselect.pro,v $
; Revision 1.9  2003/04/28 07:45:11  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.8  2003/04/24 17:12:37  goehler
; added option to define group for unselecting
;
; Revision 1.7  2003/04/24 09:55:11  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.6  2003/03/17 14:11:44  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:31  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:34  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:18  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_unselectevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env

    ;; define group:
    group = strsplit(buttonvalue,":",/extract)
    IF n_elements(group) LT 2 THEN group = (*env).def_grp $
    ELSE                           group = fix(group[1])

    ;; report command:
    cafereport,env,'unselect,*,*',/nocomment

    ;; unselect  datapoints:
    cafe_unselect,env,"*","*", group

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; UNSELECT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_unselect,env,  baseID, group,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_unselect"
    
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
        print, "unselect   - unselect all datapoints"
        return
    ENDIF

    ;; optional parameter value (group):
    IF n_elements(group) NE 0 THEN paramval=":"+strtrim(string(group),2) $
    ELSE                           paramval=""

    buttonID= widget_button(baseID, value="Unselect"+paramval, $
                            event_pro="cafe_wplot_unselectevent")

END   
