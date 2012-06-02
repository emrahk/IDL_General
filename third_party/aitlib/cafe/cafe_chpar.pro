PRO  cafe_chpar, env, $
                  parameter, value, fixed,          $
                  quiet=quiet, add=add, help=help,shorthelp=shorthelp
;+
; NAME:
;           chpar
;
; PURPOSE:
;           change model parameter
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           chpar  [,parameter:group][,value][,fix][,/quiet]
;
; INTPUT:
;       parameter - The parameter to change. This can be either:
;                     - The absolute parameter number in the
;                       current model.
;                     - A parameter number range, defined by the
;                       first parameter and last parameter,
;                       separated with "-". (e.g. 1-7)
;                     - A string designating the parameter
;                       name. The parameter name is usually
;                       "model:parname". If this parameter name is
;                       not unique in current model all matching
;                       parameters will be asked to change.
;                       If no parameter information is given all
;                       parameters will be asked to changed.
;                       
;           group - The group number defining the model to
;                   change. Default is 0, must be in range [0,29].
;
;           value - The value to set the parameter at. If not given it
;                   will be asked interactively. 
;
;           fix   - Fix flag. May be 0 or 1. If 1 the parameter is
;                   fixed (freezed).
;                   If not given it may be set interactively after
;                   entering the parameter value (separated with ","). 
;
; OPTIONS:
;           quiet - Do not report changed parameters.
;           
;           add   - Add the new value to the former one.
;           
; SIDE EFFECTS:
;           Changes parameter start values/fixed flags. 
;
; EXAMPLE:
;
;               > chpar,sin:P:2
;                   sin:P: 22.5, 1
;               -> changes Parameter sin:P of model in group 2 at 22.5
;                  and fixed.  
;
; HISTORY:
;           $Id: cafe_chpar.pro,v 1.8 2003/05/09 14:50:07 goehler Exp $
;-
;
; $Log: cafe_chpar.pro,v $
; Revision 1.8  2003/05/09 14:50:07  goehler
;
; updated documentation in version 4.1
;
; Revision 1.7  2003/04/29 12:09:03  goehler
; - added /quiet option
; - added /add option to change delta parameters.
;
; Revision 1.6  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.5  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/09 17:36:01  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="chpar"

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
        cafereport,env, "chpar    - change parameter(s)"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CHECK RANGE, SET DEFAULTS:
    ;; ------------------------------------------------------------


    ;; define default group
    group = (*env).def_grp


    ;; parameter array dimensions:
    param_dim = size((*env).parameter,/dimension)

    ;; ------------------------------------------------------------
    ;; GET PARAMETER INDEX
    ;; ------------------------------------------------------------

    param_index = cafeparam(env,parameter,group)

    ;; check model existence
    IF (*env).groups[group].model EQ "" THEN BEGIN
        cafereport,env, "Error: No model given in group", group
        return
    ENDIF

    ;; invalid parameter
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: Invalid parameter specified"
        return
    ENDIF 

        
    ;; ------------------------------------------------------------
    ;; ENTER PARAMETER IF NOT GIVEN
    ;; ------------------------------------------------------------            

    IF n_elements(value) EQ 0 THEN BEGIN 
        FOR i = 0, n_elements(param_index)-1 DO BEGIN 

            ;; current parameter index (single value)
            pi = param_index[i]

            ;; get model number with a specific model list
            ;; containing in each cell the parameter model number:
            modlist = intarr(param_dim[0],param_dim[1],param_dim[2]) 
            FOR m = 0, n_elements(modlist[0,*,0])-1 DO $
              modlist[*,m,*] = m
            

            ;; print current parameter:
            cafereport,env,                           $
              "["+strtrim(string(modlist[pi]),2)+"]->" $ ;; model number
              +(*env).parameter[pi].parname                $
              +string((*env).parameter[pi].value)          $
              +string((*env).parameter[pi].error)          $
              +string((*env).parameter[pi].fixed)

            ;; read string for value/fixed flag:
            input = ""
            caferead, env, input, prompt=(*env).parameter[pi].parname+": "
            
            ;; separate value/fixed flag:
            input = strsplit(input,",",/extract,/preserve_null)            


            ;; set value parameter (if any):
            IF stregex(input[0], "^[-0-9.eE]+$",/boolean) THEN BEGIN 
                IF NOT keyword_set(add) THEN BEGIN 
                    (*env).parameter[pi].value = double(input[0])
                ENDIF ELSE BEGIN 
                    (*env).parameter[pi].value = double(input[0]) + $
                      (*env).parameter[pi].value
                ENDELSE  

                ;; error computed with error becomes invalid:
                (*env).parameter[pi].errmin = 0.
                (*env).parameter[pi].errmax = 0.
                (*env).parameter[pi].errmininfo = 0
                (*env).parameter[pi].errmaxinfo = 0
            ENDIF 

            ;; set fixed flag (if any):
            IF (n_elements(input) EQ 2) THEN $
              IF stregex(input[1], "^[01]$",/boolean) THEN $
              (*env).parameter[pi].fixed = fix(input[1])
        ENDFOR  
    ENDIF ELSE BEGIN         

        ;; set parameter value if already given:
        IF NOT keyword_set(add) THEN BEGIN 
            (*env).parameter[param_index].value = value
        ENDIF ELSE BEGIN 
            (*env).parameter[param_index].value = value + $
              (*env).parameter[param_index].value
        ENDELSE   
        
        ;; set fixed value if given
        IF n_elements(fixed) NE 0 THEN $
          (*env).parameter[param_index].fixed = fixed

        ;; error computed with error becomes invalid:
        (*env).parameter[param_index].errmin = 0.
        (*env).parameter[param_index].errmax = 0.
        (*env).parameter[param_index].errmininfo = 0
        (*env).parameter[param_index].errmaxinfo = 0

    ENDELSE 

    ;; show result:
    IF NOT keyword_set(quiet) THEN $
      cafe_show,env,"param",/transient

  RETURN  
END


