FUNCTION  cafegetvalidparam, env, params, selected=selected, free=free
;+
; NAME:
;           cafegetvalidparam
;
; PURPOSE:
;           return index for valid parameters
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           fit/error
;
; SYNTAX:
;           param=cafegetvalidparam( env)
;
; INPUTS:
;           env      - Environment containing parameters.
;
;           params   - Index of parameter which should be taken into
;                      account. Only a subset of this indices is
;                      returned.
;                      If not given all parameters are taken into account.
;
; OPTIONS:
;           selected - Take only selected datapoints into account
;           
;           free     - Return only free parameter indices, i.e. those
;                      parameter which are neither tied nor fixed.
;
; OUTPUT:
;           Returns index of parameters which are valid, i.e. could be
;           used for fitting. Valid parameters are those with
;           1.) a defined name
;           2.) belonging to models which could be applied to existing
;               data.
;           If we do not take the latter into account we run into
;           trouble when a model is defined but no data are
;           available. This means that the model will run with free
;           parameters though fitting does not change the Chi^2. 
;           
; SIDE EFFECTS:
;           None. 
;
;
; HISTORY:
;           $Id: cafegetvalidparam.pro,v 1.1 2003/04/29 07:58:19 goehler Exp $
;
;
; $Log: cafegetvalidparam.pro,v $
; Revision 1.1  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
;
;

    ;; ------------------------------------------------------------
    ;; CONFIG
    ;; ------------------------------------------------------------

    ;; dimensions of parameter array (needed for array copying):
    param_dim = size((*env).parameter,/dimension)

    ;; list of all parameters; with 1 for valid parameters
    validparams = make_array(param_dim[0],param_dim[1],param_dim[2],$
                             value=0,/byte)    

    IF n_elements(params) EQ 0 THEN validparams[*] = 1 $
    ELSE                            validparams[params] = 1

    ;; ------------------------------------------------------------
    ;; CHECK WHICH GROUPS HAVE VALID PARAMETERS:
    ;; ------------------------------------------------------------

    FOR grp=0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip groups without model:
        IF (*env).groups[grp].model EQ "" THEN BEGIN

            ;; unset all parameters for current group
            validparams[*,*,grp] = 0
            CONTINUE 
        ENDIF 

        ;; point number in current group:
        group_point_num = 0l
   
        ;; check all subgroups, build y/error array
        FOR subgroup = 0, n_elements((*env).groups[grp].data)-1 DO BEGIN 

            ;; skip not defined data sets (subgroups)
            IF NOT PTR_VALID((*env).groups[grp].data[subgroup].y)  THEN CONTINUE

            ;; index for defined values:
            IF keyword_set(selected) THEN BEGIN 
                def_index = where(*(*env).groups[grp].data[subgroup].def AND $
                                  *(*env).groups[grp].data[subgroup].selected)
            ENDIF ELSE BEGIN 
                def_index = where(*(*env).groups[grp].data[subgroup].def)
            ENDELSE 


            ;; no index found -> next data set
            IF def_index[0] EQ -1 THEN CONTINUE 

            ;; summ up defined data points in current group
            group_point_num=group_point_num+n_elements(def_index)           
        ENDFOR

        ;; if no data points in current group ->
        ;; disable all parameters in current group
        IF group_point_num EQ 0 THEN BEGIN 
            validparams[*,*,grp] = 0
        ENDIF 


    ENDFOR


    ;; if only free parameters are desired exclude frozen/fixed
    ;; parameters:
    IF keyword_set(free) THEN BEGIN 
            
        ;; look for non-free parameters:
        fixedindex = where(((*env).parameter[*].parname EQ "") OR $
                           ((*env).parameter[*].fixed)       OR $
                           ((*env).parameter[*].tied NE ""))

        ;; exclude fixed parameters if any:
        IF fixedindex[0] NE -1 THEN $
          validparams[fixedindex] = 0
    ENDIF 


    ;; result: parameter index for all valid parameters:
    return, where(validparams AND                  $ ; points are valid
                  ((*env).parameter.parname NE ""))  ; and defined

END 
