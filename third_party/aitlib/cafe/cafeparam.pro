FUNCTION   cafeparam, env, param, group, options=options
;+
; NAME:
;           cafeparam
;
; PURPOSE:
;           converts parameter to an index referencing this parameter
;           in environment parameter list
;
; CATEGORY:
;           CAFE
;
; SUBCATEGORY:
;           AUXILIARY ROUTINE
;
; SYNTAX:
;           index=cafeparam(env, string, group,options=options)
;
; INPUTS:
;
;           env      - The fit environment as defined in
;                      cafeenv__define. Contains the parameters.
;           param    - The parameter(s) to look for. These can be
;                      either:
;                        - The absolute parameter number in the
;                          current model.
;                        - An parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-".
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters tied.
;                          Using the parameter name "*" matches all
;                          parameters in current group.
;           group    - The group to use as default.
;
;
; OUTPUT:
;           Returns index array referring a parameter in
;           (*env).parameter. Returns -1 if nothing found.
;
; OPTIONAL OUTPUT:
;
;           options  - String defining options to the parameter
;                      which are given by strings in brackets (eg:
;                      test[foo;bar]). If not defined the string is
;                      empty. 
;
; HISTORY:
;           $Id: cafeparam.pro,v 1.6 2003/03/03 11:18:34 goehler Exp $
;             
;
;
; $Log: cafeparam.pro,v $
; Revision 1.6  2003/03/03 11:18:34  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.4  2002/09/09 17:36:20  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;
    ;; ------------------------------------------------------------
    ;; CONFIGS:
    ;; ------------------------------------------------------------
    
    ;; dimensions of parameter array (needed for array copying):
    param_dim = size((*env).parameter,/dimension)


    ;; ------------------------------------------------------------
    ;; MAKE SHURE PARAMETER IS STRING (may be integer):
    ;; ------------------------------------------------------------

    param=strtrim(string(param),2)


    ;; ------------------------------------------------------------
    ;; EXTRACT  PARAMETER/OPTIONS/GROUP of PARAM:
    ;; ------------------------------------------------------------        


    ;; extract components of parameter:
    param_comps=stregex(param,                             $
                        "^([*a-zA-Z:]*|[0-9\-]*)(\[(.*)\])?(:([0-9]+))?$",$ ; string/num+options+group
                        /extract,/subexpr) 

    ;; component contains group -> extract it
    IF param_comps[5] NE "" THEN BEGIN 

        ;; set new group:
        group = fix(param_comps[5]) 

    ENDIF

    ;; parameter is the first part of the components
    param=param_comps[1]

    ;; options is the parameter part in "[]"
    options = param_comps[3]
        

    
    ;; ------------------------------------------------------------
    ;; LOOK FOR PARAMETER
    ;; ------------------------------------------------------------        

    ;; list to be used to select single group index only
    reflist = bytarr(param_dim[0],param_dim[1],param_dim[2]) 

    ;; get parameter index for param:
    reflist[*,*,group] = 1    
    param_index = where(((*env).parameter.parname NE "") AND reflist) 

    ;; check no parameter condition:
    IF param_index[0] EQ -1 THEN BEGIN
        CAFEREPORT,ENV, "Error: No parameter "+string(param)+" found"
        RETURN, -1 
    ENDIF


    ;; ------------------------------------------------------------
    ;; LOOK FOR PARAMETER
    ;;  1.) INTEGER VALUE
    ;; ------------------------------------------------------------        

    ;; check form = int or int-int:
    IF stregex(param, '^[0-9]+(-[0-9]+)?$',/boolean) THEN BEGIN 

        ;; actually split parameter into start/stop value:
        param=stregex(param, '^([0-9]+)-?([0-9]+)?$',/extract,/subexpr)        
        
        ;; compute index of first parameter
        r_index = fix(param[1])

        ;; compute index of last parameter, if not given -> first parameter
        IF param[2] EQ "" THEN l_index = r_index ELSE l_index = fix(param[2])

        ;; warning for invalid ranges:
        IF r_index GT l_index THEN BEGIN 
            cafereport,env, "Error: Invalid Parameter range "
            return, -1            
        ENDIF  

        ;; parameter index too large
        IF l_index GE n_elements(param_index) THEN BEGIN 
            cafereport,env, "Error: No parameter index " + $
                         strtrim(string(param),2)
            return, -1
        ENDIF

        
        ;; compute range:
        param_index = param_index[indgen(l_index - r_index + 1)+r_index]
    ENDIF 

    ;; ------------------------------------------------------------
    ;; LOOK FOR PARAMETER
    ;;  2.) STRING VALUE
    ;; ------------------------------------------------------------        

    ;; dimensions/type = string
    IF ((size(param))[0] EQ 0 ) AND ((size(param))[1] EQ 7) THEN BEGIN 

        
        ;; matches everything -> we have already the complete list
        IF param NE "*" THEN  BEGIN 

            ;; index to list of parameters which match somehow:
            match_index = where(strpos((*env).parameter[param_index].parname,$
                                       param) NE -1)            

            ;; nothing found -> exit
            IF match_index[0] EQ -1 THEN BEGIN 
                cafereport,env, "Error: Parameter "+param+" not found"
                return, -1
            ENDIF
        
            ;; restrict parameter index:
            param_index = param_index[match_index]
        ENDIF 
    ENDIF 


    ;; param_index is the desired index to return
    return, param_index

END 
