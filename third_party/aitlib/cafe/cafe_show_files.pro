PRO  cafe_show_files, env,                        $
  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_files
;
; PURPOSE:
;           displays files using in different subgroups
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, files
;
; OUTPUT:
;           Displays for each group:
;                subgroup - the number of the subgroup
;                file     - File name from which data are retrieved
;                           for this subgroup.
;                           Empty subgroups are not shown.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_files.pro,v 1.4 2003/03/03 11:18:26 goehler Exp $
;-
;
; $Log: cafe_show_files.pro,v $
; Revision 1.4  2003/03/03 11:18:26  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/10 13:24:32  goehler
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
    name="show_files"

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
        cafereport,env, "files     - show data files name"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SHOW FILES
    ;; ------------------------------------------------------------

    cafereport,env, "------------------------------"
    cafereport,env, "Files using:"

    FOR group = 0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip empty groups
        IF strjoin((*env).groups[group].data[*].file) EQ "" THEN CONTINUE 

        cafereport,env, "=== GROUP "+strtrim(string(group),2)+" ==="

        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip empty datasets
            IF (*env).groups[group].data[subgroup].file EQ "" THEN CONTINUE 

            cafereport,env, "["+strtrim(string(subgroup),2) +"]: "$
                         +(*env).groups[group].data[subgroup].file            
        ENDFOR        
    ENDFOR
    

END 
