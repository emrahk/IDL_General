;+
; NAME:
;           wplot_exec
;
; PURPOSE:
;           Button to perform any (fixed) cafe command.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           +exec["command"]+
;
; SUBCATEGORY:
;           wplot add-on button
;
; BUTTON LABEL:
;           Depends on parameter: The button will be labeled according
;           the command given. 
;
; DESCRIPTION:
;           This button allows to support any cafe commands. For this
;           the parameter will be executed as an command. 
;           
; PARAMETER:
;           The command+arguments to execute. If missing no-operation
;           will be aplied. 
;           THIS PARAMETER MUST BE QUOTED!
;               
; SIDE EFFECTS:
;           Executes the command given as parameter. The plot also
;           will be redrawn.
;
;
; HISTORY:
;           $Id: cafe_wplot_exec.pro,v 1.5 2003/04/28 07:45:08 goehler Exp $
;             
;-
;
; $Log: cafe_wplot_exec.pro,v $
; Revision 1.5  2003/04/28 07:45:08  goehler
; new parameter setting scheme: parameters are set as in usual functions
;
; Revision 1.4  2003/04/24 09:55:10  goehler
; Report actions done into log file. This allows reprocessing log files as batch files.
;
; Revision 1.3  2003/03/17 14:11:39  goehler
; review/documentation updated.
;
; Revision 1.2  2003/03/03 11:18:28  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.1  2003/02/25 09:56:10  goehler
; initial version of versatile add-on button which executes any command
;
;
;
;


;; ------------------------------------------------------------
;; CAFE_WPLOT_BUTTONEVENT --- EVENT PROCEDURE WHEN BUTTON PRESSED
;; ------------------------------------------------------------

PRO cafe_wplot_execevent, ev

    ;; get value of button (if it is one):
    widget_control,ev.id,get_value=buttonvalue

    ;; get environemnt pointer:
    widget_control,ev.top,get_uvalue=env


    ;; set window at draw widget:
    widget_control,(*env).widgets.drawID,get_value=winId
    wset, winID

    ;; report command:
    cafereport,env,'exec,'+buttonvalue+',/single',/nocomment

    ;; execute command:
    cafe_exec,env,buttonvalue,/single

    ;; thats all for plotting (!)
    cafe_plot,env,/quiet

END  


;; ------------------------------------------------------------
;; FIT - THE MAIN FUNCTION WHICH ALLOCATES A NEW BUTTON
;; ------------------------------------------------------------

PRO cafe_wplot_exec,env,  baseID, cmd,  help=help, shorthelp=shorthelp

    ;; command name of this source (needed for automatic help)
    name="wplot_exec"
    
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
        print, "exec      - execute command"
        return
    ENDIF


    buttonID= widget_button(baseID, value=cmd, $
                            event_pro="cafe_wplot_execevent")

END   
