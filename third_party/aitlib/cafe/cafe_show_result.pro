PRO  cafe_show_result, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_result
;
; PURPOSE:
;           displays fit results/general status of environment
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, result
;
; OUTPUT:
;           Displays fit results. These are
;                 chi^2   - The Chi square value from last fit.
;                 DOF     - Degree of freedoms, i.e. the number of
;                           defined data points reduced by the number
;                           of free parameters (which are neither
;                           fixed or tied to other parameters).
;               Chi^2_red - Reduced Chi square value; the chi^2
;                           divided by the degree of freedom. Should
;                           be near 1 for a good fit. 
;                            
;         Goodness of fit - The probability that the fit may
;                           contain larger values of chi^2. Should
;                           be close to  1 for a good fit.
;
; REMARK:
;           Sometimes the goodnes of fit computation fails. Nothing
;           seriously to worry about.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_result.pro,v 1.9 2003/05/09 14:50:09 goehler Exp $
;-
;
; $Log: cafe_show_result.pro,v $
; Revision 1.9  2003/05/09 14:50:09  goehler
;
; updated documentation in version 4.1
;
; Revision 1.8  2003/04/25 14:04:25  goehler
; trap float underflow for goodness of fit computation by applying a
; semi-empirical critera.
;
; Revision 1.7  2003/03/17 14:11:36  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:27  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/10 13:24:33  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/09 17:36:13  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_result"

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
        cafereport,env, "result     - show fit result"
        return
    ENDIF

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    chisq = cafegetchisq(env,selected=(*env).fitresult.selected)     ; chi^2
    dof   = cafegetdof(env,selected=(*env).fitresult.selected)       ; degree of freedom
    chired = chisq/(dof > 1.D-30)                          ; reduced chi^2, check case of zero


    ;; ------------------------------------------------------------
    ;; SHOW RESULT
    ;; ------------------------------------------------------------

    cafereport,env, "------------------------------"
    cafereport,env, "Fit results:"    
    cafereport,env, "Chi^2:      ", chisq, format="(A,G15.4)"
    cafereport,env, "DOF:        ", dof,   format="(A,I15)"
    cafereport,env, "Chi^2_red:  ", chired, $
      format="(A,G15.5)"
    IF dof GT 0 THEN BEGIN 
        ;; estimate goodness of fit: if reasonable, compute it:
        IF dof lt 200.D0 OR chired LT 1.5D0 THEN BEGIN 
            gof = 1.D0 - chisqr_pdf(chisq, dof)
        ENDIF ELSE BEGIN 
            gof = 0.D0
        ENDELSE 
        cafereport,env, "Goodness of fit: ", gof, $
          format="(A,G10.5)"
    ENDIF 






END 
