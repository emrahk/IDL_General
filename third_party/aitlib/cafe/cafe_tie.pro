PRO  cafe_tie, env, $
                  param1, param2,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           tie
;
; PURPOSE:
;           links parameters to other 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           tie, <param1>[:group1], <param2>[:group2], 
;
; INPUTS:
;           param1 - The parameter(s) which will be tied to another parameter.
;                    This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 2-5)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters are tied.
;                          Using the parameter name "*" matches all
;                          parameters.
;           group1 - The group of param1 to tie to another
;                    parameter. This allows bindings across 
;                    groups.
;           param2 - The parameter to link param1 to. Syntax as param1.
;
;                    Parameter expressions:
;                    Additional there is the possibility to use as
;                    param2 a complete expression which may contain
;                    all valid IDL operators/functions. The parameter
;                    are referred with their absolute number in "P(<number>)".
;                    It is possible to combine several other
;                    Parameters.
;                    Example:     tie, 5, "0.5*P(2) + sin(P(3))"
;                               -> tie parameter 5 with parameters 2 and 3 within a 
;                                  complex formula.                    
;                    
;           group2 - The group of param2. It is not possible for
;                    tie expressions to refer to different groups. 
;
;
; SIDE EFFECTS:
;           Changes parameter tied tag.
; 
;
; EXAMPLE:
;
;               > tie, 0:0, 0:1
;                 -> Parameter 0 of group 0 becomes parameter 0 of
;                    group 1, i.e. while fitting the first parameter
;                    will be changed as the second parameter, and the
;                    degree of freedoms will be reduced.
;
; HISTORY:
;           $Id: cafe_tie.pro,v 1.5 2003/03/17 14:11:37 goehler Exp $
;-
;
; $Log: cafe_tie.pro,v $
; Revision 1.5  2003/03/17 14:11:37  goehler
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
    name="tie"

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
        cafereport,env, "tie      - links one parameter to another"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; CONFIG
    ;; ------------------------------------------------------------

    ;; dimensions of parameter array (needed for array copying):
    param_dim = size((*env).parameter,/dimension)



    ;; ------------------------------------------------------------
    ;; GET PARAM 1
    ;; ------------------------------------------------------------

    ;; set default group
    group1 = (*env).def_grp

    ;; get parameter index
    param_index1 = cafeparam(env,param1,group1)

    ;; exit in error case (error already reported)
    IF param_index1[0] EQ -1 THEN return


    ;; ------------------------------------------------------------
    ;; GET PARAM 2
    ;; ------------------------------------------------------------

    ;; set default group
    group2 = (*env).def_grp

    ;; parameter 2 is an expression:
    IF stregex(param2,"P\([0-9]+\)",/boolean) THEN BEGIN 

        ;; extract group manually:
        param_comps=stregex(param2,                             $
                            "^([^:]*)(:([0-9]+))?$",$ ; string+group
                            /extract,/subexpr) 
        param2 = param_comps[1]
        IF param_comps[3] NE "" THEN group2 = fix(param_comps[3])

        ;; set parameter expression:
        (*env).parameter[param_index1].tied = param2        
        
        ;; thats all
        return
        
    ;; parameter 2 is not an expression (standard case)
    ENDIF ELSE BEGIN 

        ;; get parameter index
        param_index2 = cafeparam(env,param2,group2)
    
        ;; exit in error case (error already reported)
        IF param_index2[0] EQ -1 THEN return
    ENDELSE 

    ;; ------------------------------------------------------------
    ;; COMPUTE PARAMETER TO LINK TO
    ;; ------------------------------------------------------------        

    ;; check range:
    IF n_elements(param_index1) NE n_elements(param_index2) THEN BEGIN 
        cafereport,env, "Error: Parameter number not equal"
        return        
    ENDIF 

    ;; check for self reference:
    total_index = [param_index1,param_index2]
    total_index = total_index(sort(total_index))

    ;; -> total number of independend numbers not sum of components
    ;; -> parameter indices are equal
    IF  n_elements(uniq(total_index)) LT 2*n_elements(param_index1) THEN BEGIN 
        cafereport,env, "Warning: Parameter(s) possibly linked to itself"
    ENDIF 


    ;; find absolute index of param2:
    ;; -> we already have the index within all parameters of those to
    ;;    link to. But we need the index of the parameter list of all
    ;;    defined parameters (which have nonzero parameter name).
    ;;    Therefore we must convert the index to the truncated
    ;;    parameter list. 

    ;; create index list of all parameters:
    indlist = indgen(param_dim[0],param_dim[1],param_dim[2])    

    ;; set all these indices which represent non-zero parameters at
    ;; the parameter number
    ;; (safe, parameter existence already checked above)
    def_param_ind = where((*env).parameter.parname NE "")
    indlist[def_param_ind] = indgen(n_elements(def_param_ind))

    ;; create parameter 2 indices:
    param_index2 = indlist[param_index2]

    ;; ------------------------------------------------------------
    ;; SET TIE TAG AT INDEX FOUND
    ;; ------------------------------------------------------------        
        
    (*env).parameter[param_index1].tied = "P("+strtrim(string(param_index2),2)+")"

    ;; show result:
    cafe_show,env,"param",/transient

    
    return  
END 





