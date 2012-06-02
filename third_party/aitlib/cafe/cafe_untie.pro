PRO  cafe_untie, env,                        $
                  parameter,                   $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           untie
;
; PURPOSE:
;           releases binding of  model parameter
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           untie  [,parameter:group]]
;
; OPTIONS:
;           parameter - The parameter to untie. This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 2-5)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters are fixed.
;                       
;           group - The group number defining the model to
;                   change. Default is 0, must be in range [0,9].
;
;
; SIDE EFFECTS:
;           Changes parameter fixed flags. 
;
; EXAMPLE:
;
;               > tie,lin:m:1,lin:m:0
;               > untie,lin:m:1
;               -> releases binding of  Parameter lin:m in group 1
;
; HISTORY:
;           $Id: cafe_untie.pro,v 1.5 2003/03/17 14:11:38 goehler Exp $
;-
;
; $Log: cafe_untie.pro,v $
; Revision 1.5  2003/03/17 14:11:38  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:15  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="untie"

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
        cafereport,env, "untie    - removes parameter binding"
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

    ;; invalid parameter, error reported in cafeparam.
    IF param_index[0] EQ -1 THEN BEGIN 
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; UNTIE PARAMETER
    ;; ------------------------------------------------------------            


    (*env).parameter[param_index].tied = ""

    ;; show result:
    cafe_show,env,"param",/transient

  RETURN  
END
