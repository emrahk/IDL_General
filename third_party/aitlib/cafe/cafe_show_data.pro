PRO  cafe_show_data, env,                        $
  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_data
;
; PURPOSE:
;           displays data of all groups/subgroups
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, data
;
; OUTPUT:
;           Displays for each group:
;           - the group number
;           - Subgroup entries:
;             [subgroup]:file(#n,def, sel) error :<error>
;                subgroup - the subgroup number
;                file     - File name from which data are retrieved
;                           for this subgroup.
;                n        - Number of data points.
;                def      - Number of valid (defined) data points.
;                sel      - Number of selected data points.
;                error    - Whether error is defined, and its mean value.
;                
;                           Empty subgroups are not shown.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_data.pro,v 1.5 2003/03/17 14:11:36 goehler Exp $
;-
;
; $Log: cafe_show_data.pro,v $
; Revision 1.5  2003/03/17 14:11:36  goehler
; review/documentation updated.
;
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
; Revision 1.2  2002/09/09 17:36:11  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_data"

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
        cafereport,env, "data     - show data information"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SHOW FILES
    ;; ------------------------------------------------------------

    cafereport,env, "------------------------------"
    cafereport,env, "Data:"

    FOR group = 0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip empty groups
        IF strjoin((*env).groups[group].data[*].file) EQ "" THEN CONTINUE 

        cafereport,env, "=== GROUP "+strtrim(string(group),2)+" ==="

        ;; show model
        IF (*env).groups[group].model EQ "" THEN  BEGIN 
            cafereport,env, "Model: none"
        ENDIF ELSE BEGIN 
            cafereport,env, "Model: "+(*env).groups[group].model 
        ENDELSE 

        ;; delimiter
        cafereport,env, "---------------" 

        ;; show subgroup information:
        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip empty datasets
            IF (*env).groups[group].data[subgroup].file EQ "" THEN CONTINUE 


            ;; define error:
            IF ptr_valid((*env).groups[group].data[subgroup].err) THEN BEGIN 
                error="<"+$
                  strtrim(string(mean(*(*env).groups[group].data[subgroup].err)),2) $
                  +">"
            ENDIF ELSE BEGIN 
                error="none"
            ENDELSE 

            ;; define valid data point number:
            defined = where(*(*env).groups[group].data[subgroup].def)
            IF defined[0] EQ -1 THEN defined = 0 ELSE defined = n_elements(defined)

            ;; define selected data point number:
            selected = where(*(*env).groups[group].data[subgroup].selected)
            IF selected[0] EQ -1 THEN selected = 0 ELSE selected = n_elements(selected)


            ;; file name:
            cafereport,env, "["+strtrim(string(subgroup),2) +"]: "                   $
              +(*env).groups[group].data[subgroup].file                                 $
              +"  (#"+strtrim(string(n_elements(*(*env).groups[group].data[subgroup].y)),2)$
              +", def: "+strtrim(string(defined),2)                                  $
              +", sel: "+strtrim(string(selected),2)                                 $
              +")"                                                                   $
              +" error: "+error
        ENDFOR        
    ENDFOR
    

END 
