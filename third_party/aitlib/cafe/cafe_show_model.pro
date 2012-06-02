PRO  cafe_show_model, env,                        $
  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_model
;
; PURPOSE:
;           displays model of different groups
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, model
;
; OUTPUT:
;           Displays for each group:
;                model - The complete model string
;                        Empty groups are not shown.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_model.pro,v 1.5 2003/03/04 16:45:00 goehler Exp $
;-
;
; $Log: cafe_show_model.pro,v $
; Revision 1.5  2003/03/04 16:45:00  goehler
;  bug fix: pointer to environment not dereferenced with (*env).
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
; Revision 1.2  2002/09/09 17:36:12  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_model"

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
        cafereport,env, "model     - show models"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SHOW MODELS
    ;; ------------------------------------------------------------
    
    cafereport,env, "------------------------------"
    cafereport,env, "Models using:"

    FOR group = 0, n_elements((*env).groups)-1 DO BEGIN 
        
        ;; SKIP EMPTY MODELS
        IF (*env).groups[group].model EQ "" THEN CONTINUE 
        CAFEREPORT,ENV, "=== GROUP "+STRTRIM(STRING(GROUP),2)+" ==="
        
        CAFEREPORT,ENV, (*ENV).GROUPS[GROUP].MODEL
    ENDFOR


END 




