PRO  cafe_plot_steppar, env, group, position=position,     $
                        color=color, range=range,quiet=quiet, $ 
                        deviation=deviation,               $
                        nofancy=nofancy,                   $
                        _EXTRA=ex,                         $
                        help=help,shorthelp=shorthelp
;+
; NAME:
;           plot_steppar
;
; PURPOSE:
;           plot 2-dim parameter confidence computed with steppar command
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           plot type
;
; INPUTS:
;          There group is always the last available one. Subgroup is
;          always the first one.
;
; PLOT OUTPUT:
;
;           steppar  - Plot a 2-dim parameters/chi^2 dependency of
;                      last computed values  created with the command
;                      "steppar". For this the first parameter of the
;                      steppar command is taken.
;                      
; SETPLOT KEYWORDS:
;           Apart from IDL oplot keywords following special
;                      are defined:
;                      
;          deviation - Flag. If true (=1) the parameter values are
;                      measured in deviation from the best-fit
;                      parameter value.
;
;          nofancy   - Flag which disables plotting of significance
;                      levels etc. 
;
; SIDE EFFECTS:
;           Plots in current window. 
;
; EXAMPLE:
;
;               > model,parabel
;               > fit
;               steppar, 1,2
;               plot, steppar -> displays chi^2 of parameter 1
;
; HISTORY:
;           $Id: cafe_plot_steppar.pro,v 1.13 2003/03/03 11:18:24 goehler Exp $
;-
;
; $Log: cafe_plot_steppar.pro,v $
; Revision 1.13  2003/03/03 11:18:24  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.12  2003/02/27 09:46:15  goehler
; - Check whether last group is occupied
; - No group selection available for steppar displays
;
; Revision 1.11  2003/02/26 17:56:27  goehler
; Fix: select free group for last available instead of 9
;
; Revision 1.10  2003/02/18 08:02:31  goehler
; change of steppar/contour:
; use free group 9 to put contour plot at
;
; Revision 1.9  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.8  2002/09/09 17:36:09  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; command name of this source (needed for automatic help)
    name="plot_steppar"

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
        cafereport,env, "steppar    - plot parameter/chi^2 parameters"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP 
    ;; ------------------------------------------------------------

    ;; define default group for resulting steppar values:
    result_group=n_elements((*env).groups[*])-1 


    ;; ------------------------------------------------------------
    ;; CHECK EXISTENCE OF STEPPAR COMPUTATION
    ;; ------------------------------------------------------------
    IF NOT ptr_valid((*env).groups[result_group].data[0].x) THEN BEGIN  
        cafereport,env, 'Error: missing steppar values. Must call command "steppar" before'
        range=[0,0,0,0]         ; dummy range
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP FOR CONVENIENCE
    ;; ------------------------------------------------------------


    ;; the parameter values:
    param = (*env).steppar.param1

    ;; the pointer to the values:
    p1 = *(*env).groups[result_group].data[0].x
    chi2 = *(*env).groups[result_group].data[0].y

    ;; best norm is chi^2 value
    bestnorm = cafegetchisq(env,selected=(*env).fitresult.selected)



    ;; ------------------------------------------------------------
    ;; DEFINE RANGE
    ;; ------------------------------------------------------------

    ;; offset -> parameter value when deviation required
    IF keyword_set(deviation) THEN offset=param.value ELSE offset=0.

    
    ;; simple: use already determined parameter/chi2 values:
    IF n_elements(range) NE 0 THEN BEGIN 

        range[0] = range[0] < (min(p1)-offset)
        range[1] = range[1] > (max(p1)-offset)
        range[2] = range[2] < min(chi2)
        range[3] = range[3] > max(chi2)
    ENDIF 

    ;; do not plot if quiet:
    ;; (needed for range determination)
    IF keyword_set(quiet) THEN RETURN 

    ;; ------------------------------------------------------------
    ;; PLOTTING STUFF
    ;; TAKEN FROM MPSTEPPAR (J.Wilms)
    ;; ------------------------------------------------------------
    
    ;; plot parameter/chi^2
    oplot,p1-offset, chi2, _extra=ex


    ;; plot additional stuff if not excluded
    IF NOT keyword_set(nofancy) THEN BEGIN 

        ;; min/max values of parameter (extens range)
        par1min =  2.*range[0] - range[2]
        par1max = 2.*range[2] - range[0]

        ;; plot dotted center line at best fit:
        oplot,[param.value,param.value]-offset,[min(chi2),max(chi2)], $
          linestyle=1

        ;; plot errors
        oplot,[par1min,par1max],[bestnorm,bestnorm],linestyle=1
        
        deltay=(max(chi2)-min(chi2))*0.01
        deltax=(max(p1)-min(p1))*0.01

        ;; 1 sigma confidence with and without hesse uncertainty
        ;; uncertainty from Hessian matrix
        oplot,param.value+[-param.error,+param.error]-offset, $
          [bestnorm,bestnorm]+1.,linestyle=2
        
        ;; plot dotted lines min..best-error, best+error..max:
        oplot,[par1min,param.value-param.error-offset], $
          [bestnorm,bestnorm]+1.,linestyle=1
        oplot,[param.value+param.error-offset,par1max], $
          [bestnorm,bestnorm]+1.,linestyle=1
        
        ;; label it:
        xyouts,range[0]+deltax, bestnorm+1.+deltay,'1 sigma'
        
        ;; 90% confidence
        oplot,[par1min,par1max], $
          [bestnorm,bestnorm]+2.706,linestyle=1
        xyouts,range[0]+deltax,bestnorm+2.706+deltay,'90%'
        
        ;; 99% confidence
        oplot,[par1min,par1max], $
          [bestnorm,bestnorm]+6.635,linestyle=1
        xyouts,range[0]+deltax,bestnorm+6.635+deltay,'99%'
    ENDIF 

END
