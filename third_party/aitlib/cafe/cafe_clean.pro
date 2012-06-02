PRO  cafe_clean, env, $
                  subgroup, group, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           clean
;
; PURPOSE:
;           removes undefined datapoints
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           clean, [,subgroup][,group]
;
; INPUTS:
;
;           subgroup - (optional) The data set (subgroup) which should
;                      be cleaned from undefined datapoints.
;                      This can be either the subgroup number or the
;                      file name representing the data set. It is
;                      possible to delete more than 
;                      one subgroup, either with numbers in brackets
;                      ([]) separated with ",";  or denoting filenames
;                      with wildcards ("*"). 
;                      Default is the first subgroup in current used
;                      group.                                                     
;
;           group    - (optional) The data group which should be cleaned.
;                      The default may be changed with the command
;                      chgrp. Must be in range [0..29].                      
;
;
; SIDE EFFECTS:
;           Removes irrecoverable undefined (ignored) datapoints (!!)
;
; EXAMPLE:
;           > ignore, y gt 200
;           > clean
;                 -> remove all datapoints whose y-value is greater
;                 than 200
;
; HISTORY:
;           $Id: cafe_clean.pro,v 1.4 2003/03/17 14:11:27 goehler Exp $
;-
;
; $Log: cafe_clean.pro,v $
; Revision 1.4  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.3  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.2  2002/09/09 17:36:01  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="clean"

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
        cafereport,env, "clean    - remove undefined datapoints"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; SET GROUP/SUBGROUP 
    ;; ------------------------------------------------------------


    ;; define default group
    IF n_elements(group) EQ 0 THEN group = (*env).def_grp

    ;; check boundary:
    IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF


    ;; define default subgroup -> first valid subgroup
    IF n_elements(subgroup) EQ 0 THEN BEGIN 
        subgroup = where((*env).groups[group].data[*].file NE "")
        subgroup = subgroup[0]
    ENDIF 


    ;; subgroup given as string -> look for matching file:
    IF ((SIZE(subgroup))[0] EQ 0 ) AND ((SIZE(subgroup))[1] EQ 7) THEN BEGIN  

        ;; look for subgroups containing this string:
        subgroup = where(strmatch((*env).groups[group].data[*].file,subgroup))

        IF subgroup[0] EQ  -1 THEN BEGIN 
            cafereport,env, "Error: Subgroup file not found"
            return
        ENDIF
        
    ENDIF         
    
    ;; check boundary:
    IF (where(subgroup GE n_elements((*env).groups[group].data) $
              OR (subgroup LT 0)))[0] NE -1  THEN BEGIN 
        cafereport,env, "Error: invalid subgroup(s)"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; REMOVE UNDEFINED DATAPOINTS FOR EACH SUBGROUP
    ;; ------------------------------------------------------------

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 

        ;; select subgroup:
        sg = subgroup[i]

        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE

        index = where(*(*env).groups[group].data[sg].def)

        ;; print subgroup information:
        cafereport,env, "Subgroup "+strtrim(string(sg),2)$
                     +"  ["+(*env).groups[group].data[sg].file+"]:"

        ;; no datapoints -> remove data set:
        IF index[0] EQ -1 THEN BEGIN 
            cafereport,env, "No valid data points -> remove data set"            
            
            ;; free data:
            PTR_FREE, (*env).groups[group].data[sg].x
            PTR_FREE, (*env).groups[group].data[sg].y 
            PTR_FREE, (*env).groups[group].data[sg].err 
            PTR_FREE, (*env).groups[group].data[sg].def 
      
            ;; remove title
            (*env).groups[group].data[sg].file = ""
            
            CONTINUE 
        ENDIF 
        
        
        *(*env).groups[group].data[sg].x = (*(*env).groups[group].data[sg].x)[index]
        *(*env).groups[group].data[sg].y = (*(*env).groups[group].data[sg].y)[index]
        *(*env).groups[group].data[sg].def = (*(*env).groups[group].data[sg].def)[index]
        *(*env).groups[group].data[sg].selected = (*(*env).groups[group].data[sg].selected)[index]

        IF ptr_valid((*env).groups[group].data[sg].err) THEN $
          *(*env).groups[group].data[sg].err = (*(*env).groups[group].data[sg].err)[index]

        cafereport,env, " -> Cleaned"            

    ENDFOR             
END
