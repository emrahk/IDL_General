PRO  cafe_steppar, env, param1, param2,                          $
                   plot=plot,verbose=verbose, selected=selected, $
                   help=help,shorthelp=shorthelp
;+
; NAME:
;           steppar
;
; PURPOSE:
;           compute confidence range/contour for fit
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           steppar ,param1["[min;max;step]"][:group1],
;                    param2["[min;max;step"]][:group2][,/verbose][,/plot]
;
; INPUTS:
;           param1,param2 - the parameters to compute the confidence
;                           range/plot for. This may be either:
;                           - The absolute parameter number in the
;                             current model.
;                           - A string designating the parameter
;                             name. The parameter name is usually
;                             "model:parname".
;
;                           If more than two parameter is specified an
;                           error will be raised.
;                           
;            min          - (optional) Defines start point of range to
;                           be computed (for each parameter
;                           defined). Default is parameter value less
;                           3* error value (i.e. 3*sigma).
;                           
;            max          - (optional) Defines end point of range to
;                           be computed (for each parameter
;                           defined). Default is parameter value plus
;                           3* error value (i.e. 3*sigma).
;
;            step         - number of points to use to step from <min>
;                           to <max>. Default is 20.
;
;            group1       - The group number in which the parameter 1
;                           should be looked for. The same applies for
;                           parameter 2/group2. 
;                           
; SETPLOT PARAMETER:
;           Because the computation of contour levels
;           immediately influence the plotting of contour
;           plot style it is possible to set the contour grid
;           ranges with the setplot command. The parameters
;           are:
;             par1min   - Start value as above for parameter 1, min
;             par1max   - End value as above for parameter 1, max
;             par1step  - Step number as above for parameter 1, step
;            
;             par2min   - Start value as above for parameter 2, min
;             par2max   - End value as above for parameter 2, max
;             par2step  - Step number as above for parameter 2, step
;
; DESCRIPTION:
;
;           This command initiates a step of 1 or 2 parameters to step
;           through while fixing this parameter, perform a fit while
;           kepping this parameter fixed and compute the chi^2 value. 
;           These values are stored in a separate group (29) and could
;           be used later for a contour plot (refer plot,steppar)
;           which shows the range of a confidence level correlating
;           different parameter. 
;           If only one parameter is given the contour plot/steppar
;           plot displays the varying chi^2 values.
;
;           If a plot should be performed the command "plot" should be
;           called with the plot style "steppar" (for one parameter)
;           or "steppar2" (for 2 parameters) after performing the
;           computation of the steppar grid values.
;           It is also possible to use the "data"/"data2" plot style
;           but then no confidence ranges are shown.
;
;           For fitting following parameter rules are used:
;
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
;           
; OPTIONS:
;           plot    - plot the contour (as a sort of preview). The
;                     plot could not be printed out with the plotout
;                     command.  
;           verbose - report fit process.
;           selected- compute steppar for selected data points only
;
; REMARK:
;           Long lasting steppar processes may be interrupted with
;           "Ctrl-G". (Not possible in idlwave). 
;
;
; SIDE EFFECTS:
;           Stores the steppar values in group 9 if this group is free.
;
; EXAMPLE:
;           > model, "parabel", 1
;           > fit
;           > steppar, 1[0;1;30],2[3;4;10]
;                 -> compute steppar plot for parameter 1+2,
;                    ranging from 0..1 (30 steps) for parameter 1 and 
;                    from 3..4 (20 steps) for parameter 2.
;           > plot, steppar2
;                 -> show result
;
; HISTORY:
;           $Id: cafe_steppar.pro,v 1.10 2003/04/29 07:58:19 goehler Exp $
;-
;
; $Log: cafe_steppar.pro,v $
; Revision 1.10  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.9  2003/04/15 09:27:36  goehler
; short help pretty print
;
; Revision 1.8  2003/03/17 14:40:02  goehler
;  bug fix: error/steppar modified environment via pointer.
;  fixed by copying environment.
;
; Revision 1.7  2003/03/17 14:11:37  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2003/02/27 09:46:15  goehler
; - Check whether last group is occupied
; - No group selection available for steppar displays
;
; Revision 1.4  2003/02/26 17:56:28  goehler
; Fix: select free group for last available instead of 9
;
; Revision 1.3  2003/02/24 14:48:42  goehler
; updated documentation
;
; Revision 1.2  2003/02/24 14:46:14  goehler
; save original parameters as parameter info, not the strange ones used for steppar
;
; Revision 1.1  2003/02/18 08:02:32  goehler
; change of steppar/contour:
; use free group 9 to put contour plot at
;
; Revision 1.10  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="steppar"

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
        cafereport,env, "steppar  - compute chi^2 contour plot"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    ;; default group setting:
    group = (*env).def_grp

    ;; set selected flag
    (*env).fitresult.selected = keyword_set(selected)

    ;; define group for resulting steppar values:
    result_group=n_elements((*env).groups[*])-1

    ;; ------------------------------------------------------------
    ;; CHECK THAT LAST GROUP is FREE
    ;; ------------------------------------------------------------

    FOR result_subgroup = 0, n_elements((*env).groups[result_group].data)-1 DO BEGIN 

        ;; skip not defined data sets (subgroups)
        IF NOT PTR_VALID((*env).groups[result_group].data[result_subgroup].y) OR $
          (*env).groups[result_group].data[result_subgroup].file EQ  "*steppar*" THEN $
          BREAK 
    ENDFOR 

    ;; no free subgroup for result:
    IF result_subgroup GE n_elements((*env).groups[group].data) THEN BEGIN 
        cafereport,env, "Error: maximal subgroup number for result expired"
        return
    ENDIF

    ;; report problems for existing data:
    IF result_subgroup GT 0 THEN $
      cafereport,env, "Warning: Group "+strtrim(string(result_group),2) $
                      +" already contains data. Appending steppar result."

    ;; ------------------------------------------------------------
    ;; DEFINE TOTAL PARAMETER LIST
    ;; ------------------------------------------------------------

    ;; compute index for all valid parameters:
    param_index = cafegetvalidparam(env,selected=selected) ; index of all used parameters

    ;; check for valid parameter existence:
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: No model/valid parameter found"
        return
    ENDIF

    ;; compute free paramters:
    free_index =  cafegetvalidparam(env,/free,selected=selected)

    ;; check for sufficient free parameter existence: (must be more
    ;; than parameters to use for contour)
    IF n_elements(free_index) LT (n_elements(param1)+n_elements(param2)) THEN BEGIN 
        cafereport,env, "Error: Insufficient free parameter found"
        return
    ENDIF
    
    ;; check for number of defined datapoints by running fit function: 
    IF n_elements(cafefitfun(env=env)) EQ 1 THEN BEGIN 
        cafereport,env, "Error: Insufficient defined datapoints"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER INFO/ERROR LIST:
    ;; ------------------------------------------------------------

    ;; set parameter info -> all valid parameters
    parinfo = (*env).parameter[param_index]


    ;; error needed for first approximation:
    perror = (*env).parameter[param_index].error

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER 1
    ;; ------------------------------------------------------------

    ;; no first parameter specified -> error
    IF n_elements(param1) EQ 0  THEN BEGIN 
        cafereport,env,"Error: Parameter 1 not specified"
        return 
    ENDIF 

    ;; compute index of parameters as being requested with parameter
    ;; given 
    param1index = cafeparam(env,param1,group,options=options)

    ;; no valid parameter given -> thats it. (report already in cafeparameter)
    IF param1index[0] EQ -1 THEN return 

    ;; make shure parameter is valid and free:
    param1index = cafegetvalidparam(env,param1index,/free,selected=selected)

    ;; Parameter must be free:
    IF param1index[0] EQ -1  THEN BEGIN 
        cafereport,env, "Error: Parameter 1 not free or not valid"
        return 
    END
    
    ;; Must be single parameter:
    IF n_elements(param1index) GT 1 THEN BEGIN 
        cafereport,env, "Error: More than one parameter specified"
        return
    END

    ;; define parameter 1 block
    param1 = (*env).parameter[param1index]

    ;; convert parameter 1 index to absolute parameter number:
    param1index = cafeconvertparamtoabs(env, param1index)

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER 1 RANGES:
    ;; ------------------------------------------------------------

    ;; split option string:
    options=stregex(options,"(.*),(.*),(.*)",/extract,/subexpr)

    ;; set options according string:
    par1min = options[1]
    par1max = options[2]
    nstep1   = options[3]

    IF par1min EQ "" THEN BEGIN 
        par1min = double(cafegetplotparam(env,"par1min",               $
                                          0,param1.value-3.*param1.error))
    ENDIF ELSE par1min = double(par1min)

    IF par1max EQ "" THEN BEGIN 
        par1max = double(cafegetplotparam(env,"par1max",               $
                                          0,param1.value+3.*param1.error))
    ENDIF ELSE par1max = double(par1max)

    IF nstep1 EQ "" THEN BEGIN 
        nstep1 = double(cafegetplotparam(env,"par1step",                $
                                         0,20))
    ENDIF ELSE nstep1=double(nstep1)


    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER 2
    ;; ------------------------------------------------------------

    ;; second parameter specified -> check
    IF n_elements(param2) NE 0  THEN BEGIN 

        ;; compute index of parameters as being requested with parameter
        ;; given 
        param2index = cafeparam(env,param2,group,options=options)

        ;; no valid parameter given -> thats it. (report already in cafeparameter)
        IF param2index[0] EQ -1 THEN return 


        ;; make shure parameter is valid and free:
        param2index = cafegetvalidparam(env,param2index,/free,selected=selected)

        ;; Parameter must be free:
        IF param2index[0] EQ -1  THEN BEGIN 
            cafereport,env, "Error: Parameter 2 not free or not valid"
            return 
        ENDIF


        ;; Must be single parameter:
        IF n_elements(param2index) GT 1 THEN BEGIN 
            cafereport,env, "Error: More than one parameter specified"
            return
        ENDIF 

        ;; define parameter 1 block
        param2 = (*env).parameter[param2index]

        ;; convert parameter 2 index to absolute parameter number:
        param2index = cafeconvertparamtoabs(env, param2index)
    ENDIF 

    ;; ------------------------------------------------------------
    ;; DEFINE PARAMETER 2 RANGES:
    ;; ------------------------------------------------------------


    IF n_elements(param2) NE 0 THEN BEGIN 

        ;; split option string:
        options=stregex(options,"(.*),(.*),(.*)",/extract,/subexpr)
        
        ;; set options according string:
        par2min = options[1]
        par2max = options[2]
        nstep2   = options[3]
        
        IF par2min EQ "" THEN BEGIN 
            par2min = double(cafegetplotparam(env,"par2min",               $
                                          0,param2.value-3.*param2.error))
        ENDIF ELSE par2min = double(par2min)
        
        IF par2max EQ "" THEN BEGIN 
            par2max = double(cafegetplotparam(env,"par2max",               $
                                          0,param2.value+3.*param2.error))
        ENDIF ELSE par2max = double(par2max)
        
        IF nstep2 EQ "" THEN BEGIN 
            nstep2 = double(cafegetplotparam(env,"par2step",               $
                                            0, 20))
        ENDIF ELSE nstep2=double(nstep2)
    ENDIF 


    ;; ------------------------------------------------------------
    ;; BUILD MEASURE ARRAYS AS NEEDED FOR MPSTEPPAR
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

            ;; check error existence
            IF NOT PTR_VALID((*env).groups[group].data[subgroup].err) THEN BEGIN 
                cafereport,env, "Error: Missing error data for group"+$
                           strtrim(string(group),2)+                  $
                           ", subgroup "+strtrim(string(subgroup),2)
                return                
            ENDIF 

            ;; no index found -> next data set
            IF def_index[0] EQ -1 THEN CONTINUE 
            
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
    ;; PERFORM CONTOUR COMPUTATION
    ;; ------------------------------------------------------------


    ;; copy environment which should be kept:
    env_copy = ptr_new(*env)


    cafereport,env, "Computing contour. This may take a while"
    
    mpsteppar, "cafefitfun", x,y,err,FUNCTARGS={env:env_copy},$
               bestnorm = cafegetchisq(env,selected=selected),$
               par1ind=param1index,                          $
               par1min=par1min,                              $
               par1max=par1max,                              $
               nstep1=nstep1,                                $
               par2ind=param2index,                          $
               par2min=par2min,                              $
               par2max=par2max,                              $      
               nstep2=nstep2,                                $
               par1val=par1val, par2val=par2val,             $
               chi2val=chi2val,                              $
               status=status,                                $
               perror=perror,                                $
               parinfo=parinfo,                              $
               plot=plot,                                    $
               quiet=(keyword_set(verbose) EQ 0),            $
               /iterstop

    cafereport,env, "Finished"

    ;; ------------------------------------------------------------
    ;; STORE VALUES:
    ;; ------------------------------------------------------------


    ;; free former values
;    PTR_FREE, (*env).contour.p1
;    PTR_FREE, (*env).contour.p2
;    PTR_FREE, (*env).contour.chi2


    ;; save parameter(s) used:

    (*env).steppar.param1=(*env).parameter[param1index]
    IF n_elements(param2index) NE 0 THEN (*env).steppar.param2=(*env).parameter[param2index]

    ;; save current computed values (if given):
    IF n_elements(param2) NE 0 THEN BEGIN 

        x1axis=par1val#make_array(n_elements(par2val),value=1.D0,/double)        
        x2axis=make_array(n_elements(par1val),value=1.D0,/double)#par2val

        (*env).groups[result_group].data[result_subgroup].x = ptr_new([[x1axis[*]],[x2axis[*]]]) 
        
  ENDIF  ELSE                                                            $
    (*env).groups[result_group].data[result_subgroup].x = ptr_new(par1val) 

    (*env).groups[result_group].data[result_subgroup].y = ptr_new(chi2val[*])

    ;; allocate defined measure point array (default all defined):
    (*env).groups[result_group].data[result_subgroup].def = PTR_NEW(bytarr(n_elements(chi2val),/nozero)) 
    (*(*env).groups[result_group].data[result_subgroup].def)[*]=1

    ;; allocate selected point array (none selected):
    (*env).groups[result_group].data[result_subgroup].selected = PTR_NEW(bytarr(n_elements(chi2val),/nozero)) 
    (*(*env).groups[result_group].data[result_subgroup].selected)[*]=0
    
    (*env).groups[result_group].data[result_subgroup].file = "*steppar*"


  RETURN  
END


