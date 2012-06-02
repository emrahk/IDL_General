PRO  cafe_show_setplot, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_setplot
;
; PURPOSE:
;           Displays all setplot definitions.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, setplot
;
; OUTPUT:
;           Displays all setplot definitions for all panels in
;           current session.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_setplot.pro,v 1.6 2003/05/06 13:14:46 goehler Exp $
;-
;
; $Log: cafe_show_setplot.pro,v $
; Revision 1.6  2003/05/06 13:14:46  goehler
; use newline as item separator
;
; Revision 1.5  2003/03/17 14:11:36  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.2  2002/09/09 17:36:13  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_setplot"

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
        cafereport,env, "setplot     - show global plot parameters"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SEPARATOR FOR  ITEMS (newline)
    ;; ------------------------------------------------------------

    itemsep = String(10B)

  ;; ------------------------------------------------------------
  ;; REPORT SETTINGS
  ;; ------------------------------------------------------------

    cafereport,env, "------------------------------"
    cafereport,env, "Setplot definitions:"      
    FOR i=0,n_elements(where((*env).plot.panels NE ""))-1 DO BEGIN 
        cafereport,env,"Panel: ", string(i,format="(I2)")
        cafereport,env, "  "+$
                   transpose([strsplit((*env).plot.plotparams[i],itemsep,/extract),""])
    ENDFOR 

END 


