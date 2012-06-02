PRO  cafe_copy, env, $
                  subgroup, destgroup, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           copy
;
; PURPOSE:
;           copy one data set to another group.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           copy, subgroup[:group],destgroup
;
; INPUTS:
;           subgroup - (optional) The data set (subgroup) from which
;                      data are copied. This can be either the
;                      subgroup number or the file name representing
;                      the data set. 
;                      It is possible to set more than one subgroup,
;                      either with numbers in brackets ([]) separated
;                      with ",";  or denoting filenames with wildcards
;                      ("*"). Default are all subgroups in current
;                      used group.                                                    
;
;           group    - (optional) The data group from which the data
;                      is copied.
;                      Default is the current group. Must be in
;                      range [0..29].                      
;
;           destgroup- The data group to which the data
;                      is copied. Must be in range [0..29].                      
;
;
; SIDE EFFECTS:
;           Adds a new data set to destination group.
;
; EXAMPLE:
;           > copy, "test.dat",1
;               -> copy all  values of data set "test.dat" in
;                  current group to group 1
;
; HISTORY:
;           $Id: cafe_copy.pro,v 1.5 2003/03/17 14:11:27 goehler Exp $
;-
;
; $Log: cafe_copy.pro,v $
; Revision 1.5  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="copy"

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
        cafereport,env, "copy     - copy data set to another group"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; SET GROUP/SUBGROUP 
    ;; ------------------------------------------------------------


    ;; define destination group
    IF n_elements(destgroup) EQ 0 THEN BEGIN 
        cafereport,env, "Error: Missing destination group"
        return
    ENDIF

    ;; check destination group boundary:
    IF (destgroup GE n_elements((*env).groups)) OR (destgroup LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid destination group number"
        return
    ENDIF


    ;; define default source group
    group = (*env).def_grp

    ;; extract subgroup/group:
    subgroup = stregex(subgroup, "^([^:]*)(:([0-9]+))?$",$ ; subgroup string+group
                      /extract,/subexpr) 

    ;; set group if given
    IF subgroup[2] NE "" THEN group = fix(subgroup[3])

    ;; set subgroup
    subgroup = subgroup[1]

    ;; check boundary:
    IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid source group number"
        return
    ENDIF


    ;; define default subgroup -> all valid subgroups
    IF subgroup EQ "" THEN BEGIN 
        subgroup = where((*env).groups[group].data[*].file NE "")
    ENDIF

    


    ;; subgroup given as string -> look for matching file:
    IF stregex(subgroup,"[0-9]+",/boolean) EQ 0 THEN BEGIN  

        ;; look for subgroups containing this string:
        subgroup = where(strmatch((*env).groups[group].data[*].file,subgroup))

        IF subgroup[0] EQ  -1 THEN BEGIN 
            cafereport,env, "Error: Subgroup file not found"
            return
        ENDIF
        
    ENDIF ELSE BEGIN 
    ;; subgroup given as number -> set it:
        subgroup = fix(subgroup)

    ENDELSE 
    
    ;; check boundary:
    IF (where(subgroup GE n_elements((*env).groups[group].data) $
              OR (subgroup LT 0)))[0] NE -1  THEN BEGIN 
        cafereport,env, "Error: invalid subgroup(s)"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; COPY DATAPOINTS FOR EACH SUBGROUP
    ;; ------------------------------------------------------------

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 
        
        ;; select subgroup:
        sg = subgroup[i]
        
        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE

        ;; look for next free destination subgroup:
        FOR destsubgroup = 0, n_elements((*env).groups[group].data)-1 DO $
          IF NOT PTR_VALID((*env).groups[destgroup].data[destsubgroup].def)  THEN BREAK
        
        IF destsubgroup GE n_elements((*env).groups[group].data) THEN BEGIN 
            cafereport,env, "Error: maximal destination subgroup number expired"
            return
        ENDIF
        
        ;; print subgroup information:
        cafereport,env, "Subgroup "+strtrim(string(sg),2)$
          +"  ["+(*env).groups[group].data[sg].file+"] -> " $
          +strtrim(string(destsubgroup),2)                $
          +":"+strtrim(string(destgroup),2)
        
        ;; allocate measure points:
        (*env).groups[destgroup].data[destsubgroup].x = PTR_NEW(*(*env).groups[group].data[sg].x) 
        (*env).groups[destgroup].data[destsubgroup].y = PTR_NEW(*(*env).groups[group].data[sg].y) 

        IF ptr_valid((*env).groups[group].data[sg].err) THEN $
          (*env).groups[destgroup].data[destsubgroup].err = PTR_NEW(*(*env).groups[group].data[sg].err) 

        ;; allocate defined measure point array (default all defined):
        (*env).groups[destgroup].data[destsubgroup].def = PTR_NEW(*(*env).groups[group].data[sg].def) 
        (*(*env).groups[destgroup].data[destsubgroup].def)[*]=1

        ;; allocate selected point array (none selected):
        (*env).groups[destgroup].data[destsubgroup].selected = PTR_NEW(*(*env).groups[group].data[sg].selected) 
        (*(*env).groups[destgroup].data[destsubgroup].selected)[*]=0
    
        ;; set file name:
        (*env).groups[destgroup].data[destsubgroup].file = (*env).groups[group].data[sg].file
        
        
    ENDFOR             
END

