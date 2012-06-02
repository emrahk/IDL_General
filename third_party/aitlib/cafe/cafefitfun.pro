FUNCTION  cafefitfun, x, parameter, env=env

;+
; NAME:
;           cafefitfun
;
; PURPOSE:
;           main fitting function
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           cafefitfun, parameter, env=env
;
; INPUTS:
;           x         - (dummy) independent array which must have the
;                       same size as the resultant y axis. 
;           parameter - (variable) list of parameter according MPFIT
;                       procedure. If not given startup parameters are
;                       used. 
;           env       - Environment structure containing all relevant
;                       static properties of cafe. Does also contain
;                       pointer to x/y data sets and the fit model so
;                       this function is able to construct a y
;                       output.
;
; OUTPUT:
;           Returns function values (y) less the model weighted with
;            error. 
;
;
; SIDE EFFECTS:
;           Stores parameters in parameter list for all groups in (*env).
;
;
; HISTORY:
;           $Id: cafefitfun.pro,v 1.9 2003/04/29 07:58:19 goehler Exp $
;
;
; $Log: cafefitfun.pro,v $
; Revision 1.9  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.8  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.7  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.6  2002/09/09 17:36:19  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; ------------------------------------------------------------
    ;; UPDATE PARAMETERS ACCORDING LIST GIVEN
    ;; ------------------------------------------------------------

    IF n_elements(parameter) GT 0 THEN $
      (*env).parameter[ cafegetvalidparam(env,                               $
                                          selected=(*env).fitresult.selected)$
                      ].value = parameter


    ;; ------------------------------------------------------------
    ;; CALL MODEL FUNCTION, BUILD MODEL Y VALUES
    ;; ------------------------------------------------------------

    ;; dummy startup values for resulting y/error arrays:
    result = 0.D0

    
    FOR group=0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip groups without model:
        IF (*env).groups[group].model EQ "" THEN CONTINUE

        ;; ------------------------------------------------------------
        ;; COMPUTE Y/ERROR VALUE FOR  EACH SUBGROUP:
        ;; ------------------------------------------------------------

    
        ;; check all subgroups, build y/error array
        FOR subgroup = 0, n_elements((*env).groups[group].data)-1 DO BEGIN 

            ;; skip not defined data sets (subgroups)
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].y)  THEN CONTINUE

            ;; index for defined values:
            IF (*env).fitresult.selected THEN BEGIN 
                def_index = where(*(*env).groups[group].data[subgroup].def AND $
                                  *(*env).groups[group].data[subgroup].selected)
            ENDIF ELSE BEGIN 
                def_index = where(*(*env).groups[group].data[subgroup].def)
            ENDELSE 


            ;; no index found -> next data set
            IF def_index[0] EQ -1 THEN CONTINUE 
            
            ;; compute model:
            result = [result,                                           $
                      (cafemodel(env,                                 $
                                 (*(*env).groups[group].data[subgroup].x), $
                                 group))[def_index]]
        ENDFOR
    ENDFOR


    ;; error case: no datapoints given
    IF n_elements(result) EQ 1 THEN  return, result

    ;; remove first dummy element
    result = result[1:*]


    ;; return weighted difference, avoid division by zero:
    RETURN, result

END


