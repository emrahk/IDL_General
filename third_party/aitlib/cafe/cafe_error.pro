PRO  cafe_error, env, param,                                   $
                  iter=iter, delchi=delchi, verbose=verbose,   $
                 selected=selected,                            $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           error
;
; PURPOSE:
;           compute errors for fit using the chi^2 distribution.
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           error [,parameter][,iterations][,delchi][,/verbose][,/selected]
;
; INPUTS:
;           parameter  -  (optional) The parameter to compute the error
;                         for. Default are all parameters.
;           iterations -  (optional) Number of iterations to perform
;                         before query to prolong.
;           delchi     -  (optional) Delta chi^2 to be used for the determination of
;                         the uncertainty. Default: 1, corresponding to 1
;                         sigma errors. Use 2.71 for 90% uncertainty
;                         (in general, delchi=chisqr_dvf(1-prob,1) where
;                         prob is the probability that the n dimensional
;                         parameter space spanned by the uncertainties
;                         contains the real value).
;           verbose    -  Show fit process output.
;           selected   -  Compute error for selected data points only.
;
; DESCRIPTION:
;           This command tries to estimate the error by stepping
;           through the Chi^2 distribution and getting the confidence
;           range for a certain delta chi (s.a. delchi). This approach
;           is more error prone than using the hessian values from the
;           fit command. 
;           Sometimes this error computation fails. In this case it is
;           recomended to use the steppar command and analyse the
;           resulting Chi^2 distribution manually.
;
;           When performing the error process the given parameter is
;           stepped while leaving the other free for fit. For these 
;           parameters apply the following rules:
;
;           - if a parameter is frozen (fixed flag = 1) the parameter
;             will not be touched during the error computation.
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
;
; SIDE EFFECTS:
;           Changes parameter error values. Because the confidence
;           range may be asymetric both lower and upper limit are
;           stored. For reference the larger deviation is given.
;
; REMARK:
;           The error determination may fail if the previous fit
;           contained bad hessian error estimations. It is recomended
;           to run the fit process before.
;           
;           Long lasting fit processes may be interrupted with
;           "Ctrl-G". (Not possible in idlwave). 
;
; EXAMPLE:
;           > model, "parabel", 1
;           > fit
;           > error
;                 -> compute errors for parameter
;
; HISTORY:
;           $Id: cafe_error.pro,v 1.13 2003/04/29 07:58:18 goehler Exp $
;-
;
; $Log: cafe_error.pro,v $
; Revision 1.13  2003/04/29 07:58:18  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.12  2003/03/17 14:40:02  goehler
;  bug fix: error/steppar modified environment via pointer.
;  fixed by copying environment.
;
; Revision 1.11  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2003/02/18 13:54:48  goehler
; updated documentation
;
; Revision 1.8  2002/09/09 17:36:03  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="error"

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

    ;; set 1-sigma delchi
    IF n_elements(delchi) EQ 0 THEN delchi = 1.


    ;; default group setting:
    group = (*env).def_grp


    ;; set selected flag
    (*env).fitresult.selected = keyword_set(selected)


    ;; ------------------------------------------------------------
    ;; DEFINE TOTAL PARAMETER LIST
    ;; ------------------------------------------------------------

    ;; compute index for all valid parameters:
    param_index =  cafegetvalidparam(env,selected=selected); index of all valid parameters

    ;; check for valid parameter existence:
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: No model/valid parameter found"
        return
    ENDIF

    ;; set parameter info -> all  valid parameters
    parinfo = (*env).parameter[param_index]


    ;; compute free paramters:
    free_index =   cafegetvalidparam(env,/free)

    ;; check for valid parameter existence:
    IF n_elements(free_index) LT 2  THEN BEGIN 
        cafereport,env, "Error: Insufficient (<2) free parameter found"
        return
    ENDIF

    IF n_elements(cafefitfun(env=env)) EQ 1 THEN BEGIN 
        cafereport,env, "Error: Insufficient defined datapoints"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER LIST
    ;; ------------------------------------------------------------

    ;; no parameter specified -> test all parameters:
    IF n_elements(param) EQ 0 THEN BEGIN 

        ;; use all valid parameters:
        interest_index = cafegetvalidparam(env,/free)

    ENDIF ELSE BEGIN ;; parameter range given -> check these only:

        ;; compute index of parameters as being requested with parameter
        ;; given 
        interest_index = cafeparam(env,param,group)

        ;; no valid parameter given -> thats it. (report already in cafeparameter)
        IF interest_index[0] EQ -1 THEN return 

        ;; restrict interesting parameters to free parameters
        ;; if none -> finish
        interest_index = cafegetvalidparam(env,interest_index,/free)
        IF interest_index[0] EQ -1 THEN BEGIN 
            cafereport,env, "Error: Parameter(s) not free"
            return
        ENDIF 

    ENDELSE 

    ;; convert parameter index to absolute parameter number:
    interest_index = cafeconvertparamtoabs(env, interest_index)



    ;; error needed for first approximation:
    perror = (*env).parameter[param_index].error


    ;; ------------------------------------------------------------
    ;; BUILD MEASURE ARRAYS AS NEEDED FOR MPFITERROR
    ;; ------------------------------------------------------------

    ;; dummy startup values:
    x=0.D0
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

            ;; check error existence
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].err) THEN BEGIN 
                cafereport,env, "Error: Missing error column for group "+$
                           strtrim(string(group),2)+                  $
                           ", subgroup "+strtrim(string(subgroup),2)
                return                
            ENDIF 
            
            x = [x,(*(*env).groups[group].data[subgroup].x)[def_index]]
            y = [y,(*(*env).groups[group].data[subgroup].y)[def_index]]
            err = [err,(*(*env).groups[group].data[subgroup].err)[def_index]]
        ENDFOR 
    ENDFOR

    ;; check for datapoints, remove first dummy one:
    IF n_elements(x) GT 1 THEN BEGIN 
        x =x[1:*]
        y =y[1:*]
        err =err[1:*]
        
    ENDIF ELSE BEGIN
        cafereport,env, "Error: Insufficient defined datapoints"
        return
    ENDELSE


    ;; ------------------------------------------------------------
    ;; PERFORM ERROR DETERMINATION
    ;; ------------------------------------------------------------


    ;; copy environment which should be kept:
    env_copy = ptr_new(*env)

    IF n_elements(iter) EQ 0 THEN iter = 200
    
    result_err = mpfiterror( "cafefitfun", x,y,err,FUNCTARGS={env:env_copy},    $
                             bestnorm = cafegetchisq(env,selected=selected),$
                             intpar = interest_index,                      $
                             delchi=delchi,                                $
                             maxiter = iter,                               $
                             status=status,                                $
                             perror=perror,                                $
                             parinfo=parinfo,                              $
                             quiet=(keyword_set(verbose) EQ 0),            $
                             /iterstop)


    ;; ------------------------------------------------------------
    ;; STORE PARAMETER RESULTS:
    ;; ------------------------------------------------------------


    ;; save error range as is in parameter structure:
    (*env).parameter[param_index].errmin = result_err[*].min
    (*env).parameter[param_index].errmax = result_err[*].max

    ;; save information about this error range (how reliable it is):
    (*env).parameter[param_index].errmininfo = result_err[*].mininfo
    (*env).parameter[param_index].errmaxinfo = result_err[*].maxinfo
    
    ;; ------------------------------------------------------------
    ;; SHOW FIT RESULTS:
    ;; ------------------------------------------------------------    

    ;; display result:
    cafe_show,env,"error",/transient


  RETURN  
END


