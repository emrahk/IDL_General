PRO  cafe_show_set, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_set
;
; PURPOSE:
;           Displays all setup definitions.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, set
;
; OUTPUT:
;           Displays all common set definitions.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_set.pro,v 1.1 2003/05/06 13:17:39 goehler Exp $
;-
;
; $Log: cafe_show_set.pro,v $
; Revision 1.1  2003/05/06 13:17:39  goehler
; - added result group which can be set with chres
; - added global setup information which can be used by certain
;   data processing commands.
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_set"

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
        cafereport,env, "set         - show global setup parameters"
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
    cafereport,env, "Setup definitions:"      
        cafereport,env, "  "+$
                   transpose([strsplit((*env).setup,itemsep,/extract),""])
        

END 


