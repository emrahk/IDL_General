PRO  cafe_thaw, env, $
                  parameter        ,            $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           thaw
;
; PURPOSE:
;           releases fixed model parameter
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           thaw  [,parameter[:group]]
;
; OPTIONS:
;           parameter - The parameter to give free. This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 3-4)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters are unfixed.
;                          If "*" is given all parameters in current
;                          group are thawed.
;                       
;           group - The group number defining the model to
;                   change. Default is 0, must be in range [0,29].
;
;
; SIDE EFFECTS:
;           Changes parameter fixed flags. 
;
; EXAMPLE:
;
;               > thaw,parabel:c:3
;               -> unfix Parameter parabel:c of model in group 3
;
; HISTORY:
;           $Id: cafe_thaw.pro,v 1.5 2003/03/17 14:11:37 goehler Exp $
;-
;
; $Log: cafe_thaw.pro,v $
; Revision 1.5  2003/03/17 14:11:37  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:14  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="thaw"

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
        cafereport,env, "thaw     - releases fixed parameter"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; CHECK RANGE, SET DEFAULTS:
    ;; ------------------------------------------------------------

    ;; define default group
    group = (*env).def_grp



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
    ;; RELEASE PARAMETER
    ;; ------------------------------------------------------------            

    (*env).parameter[param_index].fixed = 0

    ;; show result:
    cafe_show,env,"param",/transient

  RETURN  
END
