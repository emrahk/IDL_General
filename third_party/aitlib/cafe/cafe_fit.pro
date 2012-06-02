PRO  cafe_fit, env, $
                  iter, quiet=quiet, selected=selected, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           fit
;
; PURPOSE:
;           perform fit process of given model to data
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           fit, [iterations][,/selected][,/quiet]
;
; INPUTS:
;           iterations - (optional) Number of iterations to perform
;                         before query to prolong.
;
; OPTIONS:
;           quiet      - Do not show fit processing.
;           selected   - Apply fit to selected data points only.
;
; DESCRIPTION:
;           The fit command performs the actual data fitting for given
;           models. All groups containing (defined) data and a model
;           are taken into account. The result are the best fit
;           parameters with errors estimated from the inverted
;           covariance matrix (the hessian).
;           Fit results may be shown with "> show,result". The
;           data/model distance is plotted with the plot model "res".
;
;           During fitting parameter handling is as follows:
;           - if a parameter is frozen (fixed flag = 1) the parameter
;             will not be touched while fitting.
;             
;           - if a parameter is tied to another parameter this
;             parameter will copy the latter parameter value (in case
;             of expressions the value will be mapped with this
;             expression).
;
;           - groups which contain a model but no valid data points
;             are ignored. In case of the selected flag (s.a.) only
;             selected data points are taken into account, i.e. if no
;             data points are selected the group is ignored.
;
;           - groups which contain valid data points but no model are
;             ignored. 
;
; SIDE EFFECTS:
;           Changes parameter values/errors in environment
;           according fit result. 
;
; REMARK:
;           Long lasting fit processes may be interrupted with
;           "Ctrl-G". (Not possible in idlwave). 
;
; EXAMPLE:
;
;               > model, "sin+lin", 2
;               > fit
;                 -> fit result
;               > plot,data+model,res 
;
; HISTORY:
;           $Id: cafe_fit.pro,v 1.15 2003/04/29 07:58:18 goehler Exp $
;-
;
; $Log: cafe_fit.pro,v $
; Revision 1.15  2003/04/29 07:58:18  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.14  2003/04/25 12:45:50  goehler
; do not store invalid parameter results
;
; Revision 1.13  2003/04/16 15:49:07  goehler
; fix: reject fit only when degree of freedom le 0.
;
; Revision 1.12  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.11  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.10  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="fit"

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
        cafereport,env, "fit      - perform fit process"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; set selected flag
    (*env).fitresult.selected = keyword_set(selected)


    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER LIST
    ;; ------------------------------------------------------------

    ;; use all valid parameters which are named (and therefore used in a
    ;; model)
    param_index = cafegetvalidparam(env,selected=selected)

    ;; check for valid parameter existence:
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: No model/valid parameter found"
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
    ;; BUILD MEASURE ARRAYS AS NEEDED FOR MPFITFUN
    ;; ------------------------------------------------------------

    ;; dummy startup values:
    y=0.D0
    err=0.D0

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


    ;; check for degree of freedom, remove first dummy one:
    IF n_elements(y) GT n_elements(param_index) THEN BEGIN 
        y =y[1:*]
        err =err[1:*]
        
    ENDIF ELSE BEGIN
        cafereport,env, "Error: Insufficient defined datapoints"
        return
    ENDELSE



    ;; ------------------------------------------------------------
    ;; PERFORM FIT
    ;; ------------------------------------------------------------


    IF n_elements(iter) EQ 0 THEN iter = 200
    
    result_val = MPFITFUN( "cafefitfun", 0,                           $ ; dummy x value=0
                           y,err, FUNCTARGS={env:env},                $
                           maxiter = iter,                            $
                           status=status, perror=perror,              $
                           parinfo=parinfo,quiet=quiet,               $
                           bestnorm=bestnorm, /iterstop)

    ;; ------------------------------------------------------------
    ;; SHOW FIT STATUS:
    ;; ------------------------------------------------------------    

    CASE status OF 
        0 : cafereport,env, "Error: Fit report improper input parameters"
        1 : cafereport,env, "Status: Both actual and predicted relative reductions"$
          + " in the sum of squares are at most FTOL."
         
        2:  cafereport,env, "Status: Relative error between two consecutive iterates" $
          +" is at most XTOL"
         
        3:  cafereport,env, "Status: Both actual and predicted relative reductions"$
          + " in the sum of squares are at most FTOL AND"                           $
          +" relative error between two consecutive iterates"               $
          +" is at most XTOL"
        
        4:  cafereport,env, "Status:the cosine of the angle between fvec and any" $
          +" column of the jacobian is at most GTOL in" $
          +" absolute value."
         
        5:  cafereport,env, "Status: The maximum number of iterations has been reached" 
          
        6:  cafereport,env, "Status: FTOL is too small. no further reduction in" $
          +" the sum of squares is possible."
         
        7:  cafereport,env, "Status: XTOL is too small. no further improvement in" $
          +" the approximate solution x is possible."
         
        8:  cafereport,env, "Status: GTOL is too small. fvec is orthogonal to the" $
          +" columns of the jacobian to machine precision."
        ELSE: cafereport,env, "Status: Undefined"
    ENDCASE 
    

    ;; ------------------------------------------------------------
    ;; STORE PARAMETER RESULTS:
    ;; ------------------------------------------------------------

    ;; all values proper:
    IF total(finite(result_val)) EQ n_elements(result_val) THEN BEGIN         
        (*env).parameter[param_index].value = result_val
    ENDIF ELSE BEGIN 
        cafereport,env, "Error: Some parameter values were infinite/not defined:"
        
        index = where(NOT finite(result_val))
        cafereport,env,string(parinfo[index].parname, result_val[index], $
                  format="(A20,F18.5)")
        return  
    ENDELSE 


    IF n_elements(perror) NE 0 THEN BEGIN 
        (*env).parameter[param_index].error = perror
    ENDIF ELSE BEGIN 
        cafereport,env, "Error: Could not compute parameter error"
        return
    ENDELSE 


    ;; ------------------------------------------------------------
    ;; SHOW FIT RESULTS:
    ;; ------------------------------------------------------------    

    ;; display result:
    cafe_show,env,"param+result",/transient


  RETURN  
END


