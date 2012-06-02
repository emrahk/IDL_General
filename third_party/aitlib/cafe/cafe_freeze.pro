PRO  cafe_freeze, env, $
                  parameter,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           freeze
;
; PURPOSE:
;           fixes model parameter
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           freeze  [,parameter[:group]]
;
; OPTIONS:
;           parameter - The parameter to fix. This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 0-3)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters are fixed.
;                       
;           group - The group number defining the model to
;                   change. Default is the current group which may be
;                   changed with "chgrp". The group must be in range [0,29].
;
; REMARK:
;           The fixed flag can also be set when changing a parameter
;           value. 
;
; SIDE EFFECTS:
;           Changes parameter fixed flags. 
;
; EXAMPLE:
;
;               > freeze,lin:m:4
;               -> fixes Parameter lin:m of model in group 4
;
; HISTORY:
;           $Id: cafe_freeze.pro,v 1.5 2003/03/17 14:11:29 goehler Exp $
;-
;
; $Log: cafe_freeze.pro,v $
; Revision 1.5  2003/03/17 14:11:29  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="freeze"

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
        cafereport,env, "freeze   - fixes parameter"
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
        return
    ENDIF 


    ;; ------------------------------------------------------------
    ;; FREEZE PARAMETER
    ;; ------------------------------------------------------------            


    (*env).parameter[param_index].fixed = 1

    ;; show result:
    cafe_show,env,"param",/transient

  RETURN  
END

