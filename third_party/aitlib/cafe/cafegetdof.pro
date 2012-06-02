FUNCTION  cafegetdof, env, selected=selected
;+
; NAME:
;           cafegetdof
;
; PURPOSE:
;           compute degree of freedom for current settings
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show/fit
;
; SYNTAX:
;           param=cafegetdof( env)
;
; INPUTS:
;           env      - Environment containing parameters.  
;           selected - Compute DOF for selected data points only
;
; OUTPUT:
;           Returns degree of freedom, i.e. number of data points less
;           free parameters.
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafegetdof.pro,v 1.9 2003/04/29 07:58:19 goehler Exp $
;
;
; $Log: cafegetdof.pro,v $
; Revision 1.9  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.8  2003/04/28 07:42:39  goehler
; bug fix: must not count parameters of models without data
;
; Revision 1.7  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.6  2002/09/10 13:24:36  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.4  2002/09/09 17:36:19  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; ------------------------------------------------------------
    ;; COUNT FREE PARAMETER
    ;; ------------------------------------------------------------

    ;; number of  non-fixed/tied parameters (if none -> 0):
    param_num = cafegetvalidparam(env,selected=selected,/free)

    ;; total number of data points used
    point_num=0l

    ;; ------------------------------------------------------------
    ;; COUNT VALID DATA POINTS:
    ;; ------------------------------------------------------------

    FOR group=0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip groups without model:
        IF (*env).groups[group].model EQ "" THEN CONTINUE
   
        ;; check all subgroups, build y/error array
        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip not defined data sets (subgroups)
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].y)  THEN CONTINUE

            ;; index for defined values:
            IF keyword_set(selected) THEN BEGIN 
                def_index = where(*(*env).groups[group].data[subgroup].def AND $
                                  *(*env).groups[group].data[subgroup].selected)
            ENDIF ELSE BEGIN 
                def_index = where(*(*env).groups[group].data[subgroup].def)
            ENDELSE 


            ;; no index found -> next data set
            IF def_index[0] EQ -1 THEN CONTINUE 

            ;; summ up defined data points in current group
            point_num=point_num+n_elements(def_index)           
        ENDFOR
    ENDFOR


    ;; get number of data points by executing fit function, count
    ;; number of y values.
    ;; DOF = Y-value-number  - parameter number
    return, point_num - n_elements(param_num)
END 
