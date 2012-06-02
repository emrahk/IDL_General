PRO  cafe_show_plot, env,                        $
                     help=help,shorthelp=shorthelp
;+
; NAME:
;           show_plot
;
; PURPOSE:
;           Displays all plot panels
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, plot
;
; OUTPUT:
;           Displays for all defined plot panels their plot type.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_plot.pro,v 1.1 2003/05/05 09:27:21 goehler Exp $
;-
;
; $Log
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_plot"

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
        cafereport,env, "plot     - show plot panels"
        return
    ENDIF



  ;; ------------------------------------------------------------
  ;; REPORT SETTINGS
  ;; ------------------------------------------------------------

    cafereport,env, "------------------------------"
    cafereport,env, "Plot panels:"      
    FOR i=0,n_elements((*env).plot.panels)-1 DO BEGIN 
        IF (*env).plot.panels[i] EQ "" THEN CONTINUE 
        cafereport,env,"Panel: ", $
                   string(i,": " + (*env).plot.panels[i],format="(I2,A)")
    ENDFOR 

END 







