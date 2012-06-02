PRO  cafe_curvefit, env, $
                  iter,  selected=selected, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           curvefit
;
; PURPOSE:
;           perform fit process with IDL CURVEFIT
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           curvefit, [iterations][,/selected]
;
; INPUTS:
;           iterations - (optional) Number of iterations to perform
;                         before query to prolong.
;
; OPTIONS:
;           selected   - Apply fit to selected data points only.
;
; REMARKS:
;           Seems to produce better hessian errors but may fail to
;           converge if data errors are not estimated properly. 
;
;           Tied/bound parameters are not supported. It is recomended
;           to use the fit command instead which uses the mpfit
;           library.
;
;           This command was added for cases in which the mpfit
;           library is not available but the cafe environment should be
;           used nevertheless. 
;
; SIDE EFFECTS:
;           Changes parameter values/errors in environment
;           according fit result. 
;
; EXAMPLE:
;           > model, "sin+lin", 2
;           > curvefit
;                 -> fit result
;
; HISTORY:
;           $Id: cafe_curvefit.pro,v 1.9 2003/04/29 07:58:18 goehler Exp $
;-
;
; $Log: cafe_curvefit.pro,v $
; Revision 1.9  2003/04/29 07:58:18  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.8  2003/04/25 07:32:56  goehler
; updated documentation
;
; Revision 1.7  2003/03/17 14:11:27  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:21  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="curvefit"

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
        cafereport,env, "curvefit - perform fit with IDL curvefit"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER LIST
    ;; ------------------------------------------------------------

    ;; use all valid and free parameters:
    param_index = cafegetvalidparam(env,/free,selected=selected)


    ;; check for valid parameter existence:
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: No model/valid parameter found"
        return
    ENDIF


    ;; check for tied parameter:
    IF (where((*env).parameter.tied NE ""))[0] NE -1 THEN BEGIN 
        cafereport,env, "Error: Tied parameter not supported for curvefit"
        return
    ENDIF

    ;; set parameter info -> all valid parameters
    parinfo = (*env).parameter[param_index]


    ;; ------------------------------------------------------------
    ;; CLEAR ERROR INFORMATION
    ;; ------------------------------------------------------------

    ;; error computed with error becomes invalid:
    (*env).parameter[*,*,*].errmin = 0.
    (*env).parameter[*,*,*].errmax = 0.
    (*env).parameter[*,*,*].errmininfo = 0
    (*env).parameter[*,*,*].errmaxinfo = 0


    ;; ------------------------------------------------------------
    ;; BUILD MEASURE ARRAYS AS NEEDED FOR CURVEFITFUN
    ;; ------------------------------------------------------------

    ;; dummy startup values:
    y=0.D0
    err=0.D0

    FOR group=0, n_elements((*env).groups)-1 DO BEGIN 

        ;; skip groups without model:
        IF (*env).groups[group].model EQ "" THEN CONTINUE


        ;; set selected flag
        (*env).fitresult.selected = keyword_set(selected)


        ;; ------------------------------------------------------------
        ;; COMPUTE Y/ERROR VALUE FOR  EACH SUBGROUP:
        ;; ------------------------------------------------------------

    
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
            
            y = [y,(*(*env).groups[group].data[subgroup].y)[def_index]]
            

            ;; add error if existing
            IF PTR_VALID((*env).groups[group].data[subgroup].err) THEN BEGIN 
                err = [err,(*(*env).groups[group].data[subgroup].err)[def_index]]
            ENDIF ELSE BEGIN
                interr = dblarr(n_elements(def_index))
                interr[*] = 1.D0
                err = [err,interr]
            ENDELSE 
        ENDFOR 
    ENDFOR


    ;; check for datapoints, remove first dummy one:
    IF n_elements(y) GT n_elements(parinfo) THEN BEGIN 
        y =y[1:*]
        err =err[1:*]
        
    ENDIF ELSE BEGIN
        cafereport,env, "Error: Insufficient defined datapoints"
        return
    ENDELSE



    ;; ------------------------------------------------------------
    ;; PERFORM FIT
    ;; ------------------------------------------------------------

    
    ;; default iterations
    IF n_elements(iter) EQ 0 THEN iter = 200


    ;; set up parameter start values:
    A = parinfo.value


    y  = CURVEFIT( env,      $ ; x-value
                   y, 1.D0/err^2, $  ; error value squared
                   A, sigma,                        $
                   FUNCTION_name='cafecurvefitfun', $
                   itmax=iter, iter=n_iter,/noderivative)


    ;; ------------------------------------------------------------
    ;; STORE PARAMETER RESULTS:
    ;; ------------------------------------------------------------


    (*env).parameter[param_index].value = A

    (*env).parameter[param_index].error = sigma
    
    ;; ------------------------------------------------------------
    ;; SHOW FIT RESULTS:
    ;; ------------------------------------------------------------    


    ;; print iterations:
    cafereport,env, "Iterations: "+strtrim(string(n_iter),2)
    

    ;; display result:
    cafe_show,env,"param+result",/transient


  RETURN  
END


