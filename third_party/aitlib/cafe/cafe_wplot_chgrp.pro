;+
; NAME:
;           wplot_chgrp
;
; PURPOSE:
;           Button to change group
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +chgrp[group]+
;           
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           "[group]"
;
; DESCRIPTION:
;           This button will change the default group (as being
;           used by other processing commands).
;           With the group parameter it is possible to define the
;           group to change to and to allocate more than one
;           button.
;
; PARAMETER:
;           group: The group to change to. Must between 0 and 29 or
;           the keywords "prev" or "next". 
;
;               
;               
; SIDE EFFECTS:
;           Changes file content. 
;
;
; HISTORY:
;           $Id: cafe_wplot_chgrp.pro,v 1.9 2003/04/28 07:45:08 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_chgrp.pro,v $
; Revision 1.9  2003/04/28 07:45:08  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.8  2003/04/24 09:55:09  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.7  2003/03/18 08:47:39  goehler
; removed debug line
;
; Revision 1.6  2003/03/17 14:11:38  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2003/02/26 16:09:45  goehler
; automatic plot update when changing group
;
; Revision 1.3  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.2  2002/09/09 17:36:15  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_chgrpevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env

    ;; extract group:
    group = (stregex(buttonvalue,"\[([0-9a-z]+)\]",/extract,/subexpr))[1]

    ;; increment/decrement support
    IF strtrim(string(group),2) EQ "next" THEN BEGIN
        group = ((*env).def_grp+1) < (n_elements((*env).groups)-1)
    ENDIF 

    IF strtrim(string(group),2) EQ "prev" THEN BEGIN
        group = ((*env).def_grp-1) > 0
    ENDIF     
    
    ;; set current group to use:
    (*env).def_grp = fix(group)

    cafereport,env, "chgrp," +  $
               strtrim(string(group),2),/nocomment

    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; CHGRP - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_chgrp,env,  baseID, group,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_chgrp"
    
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
        print, "chgrp   - change default group"
        return
    ENDIF


    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp    

    ;; string of length 0 -> default group
    IF strtrim(string(group),2) EQ "" THEN group = (*env).def_grp    

    ;; check boundary if number:
    IF    ((SIZE(subgroup))[0] EQ 0 )             $ ; one element
      AND ((SIZE(subgroup))[1] EQ 2) THEN BEGIN     ; integer
        IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
            cafereport,env, "Error: invalid group number"
            return
        ENDIF
    ENDIF 

    ;; allocate widget
    buttonID= widget_button(baseID, value="["+strtrim(string(group),2)+"]", $
                            event_pro="cafe_wplot_chgrpevent")

END   
