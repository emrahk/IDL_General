PRO  cafe_sort, env, $
                  subgroup, group, $
                  help=help, shorthelp=shorthelp
;+
; NAME:
;           sort
;
; PURPOSE:
;           sort datapoints in ascending x order. Plots look better
;           doing this. 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           sort, [,subgroup][,group]
;
; INPUTS:
;
;           subgroup - (optional) The data set (subgroup) which should
;                      be sorted. This can be either the
;                      subgroup number or the file name representing
;                      the data set. It is possible to sort more than
;                      one subgroup, either with numbers in brackets
;                      ([]) or denoting filenames with wildcards
;                      ("*"). 
;                      Default is the first defined subgroup in group
;                      given.                   
;
;           group    - (optional) The data group which should be sorted.
;                      Default is the current group which can be
;                      changed with "chgrp". Must be in range [0..29].
;
;
; SIDE EFFECTS:
;           Changes order of data points. 
;
; EXAMPLE:
;           > data,test.dat
;           > sort, test.dat
;              -> sort all datapoints in test.dat so being in
;                 ascending order in respect of the x-value.
;
; HISTORY:
;           $Id: cafe_sort.pro,v 1.4 2003/03/17 14:11:37 goehler Exp $
;-
;
; $Log: cafe_sort.pro,v $
; Revision 1.4  2003/03/17 14:11:37  goehler
; review/documentation updated.
;
; Revision 1.3  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.2  2002/09/09 17:36:13  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="sort"

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
        cafereport,env, "sort     - sort datapoints"
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
    ;; SORT DATAPOINTS FOR EACH SUBGROUP
    ;; ------------------------------------------------------------

    ;; for each subgroup:
    FOR i =0,n_elements(subgroup)-1 DO BEGIN 

        ;; select subgroup:
        sg = subgroup[i]

        ;; check data set existence:
        IF NOT PTR_VALID((*env).groups[group].data[sg].def)  THEN CONTINUE

        index = sort(*(*env).groups[group].data[sg].x)
        
        *(*env).groups[group].data[sg].x = (*(*env).groups[group].data[sg].x)[index]
        *(*env).groups[group].data[sg].y = (*(*env).groups[group].data[sg].y)[index]

        IF ptr_valid((*env).groups[group].data[sg].err) THEN $
          *(*env).groups[group].data[sg].err = (*(*env).groups[group].data[sg].err)[index]

    ENDFOR             
END
