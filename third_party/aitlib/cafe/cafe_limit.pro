PRO  cafe_limit, env, $
                  parameter, min, max,          $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           limit
;
; PURPOSE:
;           limit model parameter to constrain fitting process
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           limit  [,parameter:group][,minlimit][,maxlimit]
;
; OPTIONS:
;       parameter - The parameter to limit. This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 1-7)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters will be asked to change.
;                   If no parameter information is given all
;                   parameters will be asked to changed.
;                       
;           group - The group number defining the model to
;                   change. Default is 0, must be in range [0,29].
;
;        minlimit - Lower limit of selected parameter(s). If not given
;                   (or empty) no limit will be applied. 
;        maxlimit - Upper limit of selected parameter(s). If not given
;                   (or empty) no limit will be applied.
;                   If neither minlimit/maxlimit are given limits are
;                   asked interactively.
;
;
; SIDE EFFECTS:
;           Changes parameter limit ranges. 
;
; EXAMPLE:
;
;               > limit,sin:P:2
;                   sin:P: 0, 1
;               -> changes limit range of parameter sin:P of model in
;                  group 2 at 0..1.   
;
; HISTORY:
;           $Id: cafe_limit.pro,v 1.6 2003/05/09 14:50:08 goehler Exp $
;-
;
; $Log: cafe_limit.pro,v $
; Revision 1.6  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.5  2003/03/17 14:11:29  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="limit"

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
        cafereport,env, "limit    - change parameter limit(s)"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CHECK RANGE, SET DEFAULTS:
    ;; ------------------------------------------------------------


    ;; define default group
    group = (*env).def_grp


    ;; parameter array dimensions:
    param_dim = size((*env).parameter,/dimension)

    ;; set default parameters: all
    IF n_elements(parameter) EQ 0 THEN parameter = "*"

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
    ;; ENTER PARAMETER LIMITS IF NOT GIVEN
    ;; ------------------------------------------------------------            

    IF (n_elements(min) EQ 0) AND (n_elements(max) EQ 0) THEN BEGIN 
        FOR i = 0, n_elements(param_index)-1 DO BEGIN 

            ;; current parameter index (single value)
            pi = param_index[i]

            ;; get model number with a specific model list
            ;; containing in each cell the parameter model number:
            modlist = intarr(param_dim[0],param_dim[1],param_dim[2]) 
            FOR m = 0, n_elements(modlist[0,*,0])-1 DO $
              modlist[*,m,*] = m


            ;; define output for min limit
            IF (*env).parameter[pi].limited[0] THEN BEGIN
                limitstr = string((*env).parameter[pi].limits[0],format="(G15.5)")
            ENDIF ELSE limitstr = "           -inf"

            ;; define output for max limit
            limitstr =limitstr+ "   "
            IF (*env).parameter[pi].limited[1] THEN BEGIN
                limitstr = limitstr+string((*env).parameter[pi].limits[1],format="(G15.5)")
            ENDIF ELSE limitstr = limitstr+"            inf"



            ;; print current parameter:
            cafereport,env,                           $
              "["+strtrim(string(modlist[pi]),2)+"]->" $ ;; model number
              +(*env).parameter[pi].parname              $
              +string((*env).parameter[pi].value)        $
              +limitstr                               

            ;; read string for value/fixed flag:
            input = ""
            caferead, env, input, prompt=(*env).parameter[pi].parname+": "
            

            ;; extract limits:
            input = stregex(input, "^(-?[0-9.eE]+|inf)?(,(-?[0-9.eE]+|inf))?$",/extract,/subexpr)

            ;; set min limit (if any):
            IF input[1] EQ "inf" THEN BEGIN      ;; delete limit
                (*env).parameter[pi].limits[0] = 0
                (*env).parameter[pi].limited[0] = 0
            ENDIF ELSE IF input[1] NE "" THEN BEGIN 
                (*env).parameter[pi].limits[0] = double(input[1])
                (*env).parameter[pi].limited[0] = 1           
            ENDIF 

            ;; set max limit (if any):
            IF input[3] EQ "inf" THEN BEGIN      ;; delete limit
                (*env).parameter[pi].limits[1] = 0
                (*env).parameter[pi].limited[1] = 0
            ENDIF ELSE IF input[3] NE "" THEN BEGIN 
                (*env).parameter[pi].limits[1] = double(input[3])
                (*env).parameter[pi].limited[1] = 1           
            ENDIF  
        ENDFOR  
    ENDIF ELSE BEGIN         

        ;; set min limit (if any):
        IF string(min) EQ "inf" THEN BEGIN      ;; delete limit
            (*env).parameter[param_index].limits[0] = 0
            (*env).parameter[param_index].limited[0] = 0
        ENDIF ELSE IF string(min) NE "" THEN BEGIN 
            (*env).parameter[param_index].limits[0] = double(min)
            (*env).parameter[param_index].limited[0] = 1           
        ENDIF 


        ;; set max limit (if any):
        IF n_elements(max) NE 0 THEN BEGIN 
            IF string(max) EQ "inf" THEN BEGIN      ;; delete limit
                (*env).parameter[param_index].limits[1] = 0
                (*env).parameter[param_index].limited[1] = 0
            ENDIF ELSE IF string(max) NE "" THEN BEGIN 
                (*env).parameter[param_index].limits[1] = double(max)
                (*env).parameter[param_index].limited[1] = 1           
            ENDIF  
        ENDIF 
    ENDELSE 

    ;; show result:
    cafe_show,env,"limit",/transient

  RETURN  
END


