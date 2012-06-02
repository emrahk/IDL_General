PRO cafe_legend_result, env, group, pos,                          $
                     help=help, shorthelp=shorthelp,              $
                     _EXTRA=ex
;+
; NAME:
;           legend_result
;
; PURPOSE:
;           Writes Fit result as legend in plot window.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           legend
;
; LEGEND OUTPUT:
;           Writes out the last fit results (according show, result):
;           chi^2   - The Chi square value from last fit.
;           DOF     - Degree of freedoms, i.e. the number of
;                     defined data points reduced by the number
;                     of free parameters (which are neither
;                     fixed or tied to other parameters).
;         Chi^2_red - Reduced Chi square value; the chi^2
;                     divided by the degree of freedom. Should
;                     be near 1 for a good fit. 
;               
; SIDE EFFECTS:
;           Changes plot window.
;
;
; EXAMPLE:
;               > fit
;               > plot, data+model
;               > legend, result
;               -> creates legend with the last fit results in top
;                  left corner
;
; HISTORY:
;           $Id: cafe_legend_result.pro,v 1.2 2003/05/09 14:50:08 goehler Exp $
;             
;-
;
; $Log: cafe_legend_result.pro,v $
; Revision 1.2  2003/05/09 14:50:08  goehler
;
; updated documentation in version 4.1
;
; Revision 1.1  2003/05/05 09:26:51  goehler
; legend style to report fit results.
;
;

    ;; command name of this source (needed for automatic help)
    name="legend_result"

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
        print, "result   - legend of last fit results"
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

    pos[1]=pos[1] - 0.007

    ;; chi^2: 
    cafe_legend_string,env,group,pos,$
                       str=strtrim(string("!U!7v!X!N!U2!N  :", $
                                      chisq, format="(A,G15.4)"),2)

    ;; degree of freedom:
    cafe_legend_string,env,group,pos,$
                       str=strtrim(string("DOF:", $
                                      dof, format="(A,G15.4)"),2)

    ;; reduced chi^2:
    cafe_legend_string,env,group,pos,$
                       str=strtrim(string("!U!7v!X!N!S!U2!R!N!Dred!N :", $
                                      chired, format="(A,G15.4)"),2)

    ;; empty line as space:
    pos[1]=pos[1] - 0.003
;    cafe_legend_string,env,group,pos,str=""
END 

