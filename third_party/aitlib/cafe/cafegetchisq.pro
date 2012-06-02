FUNCTION  cafegetchisq, env,selected=selected
;+
; NAME:
;           cafegetchisq
;
; PURPOSE:
;           compute chi^2 value for current parameters/data
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show/fit
;
; SYNTAX:
;           param=cafegetchisq( env)
;
; INPUTS:
;           env      - Environment containing parameters.
;           selected - Compute Chi^2 for selected data points only
;
; OUTPUT:
;           Returns Chi^2, i.e. squared normalized deviation sum
;           between data y values and model.
;           chi^2 = sum((y_i - f(x_i))/err_i)
;           
; SIDE EFFECTS:
;           none. 
;
;
; HISTORY:
;           $Id: cafegetchisq.pro,v 1.7 2003/04/25 18:38:36 goehler Exp $
;
;
; $Log: cafegetchisq.pro,v $
; Revision 1.7  2003/04/25 18:38:36  goehler
; safer estimation of chi^2 when error is zero
;
; Revision 1.6  2003/03/03 11:18:33  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/10 13:24:35  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/10 13:06:47  goehler
; removed ";-" to make auxilliary routines invisible
;
; Revision 1.3  2002/09/09 17:36:19  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


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


    ;; check for datapoints, remove first dummy one:
    IF n_elements(y) GT 1 THEN BEGIN 
        err =err[1:*]
        y =y[1:*]        
    ENDIF ELSE BEGIN

        ;; no data -> no chi^2
        return, 0.D0
    ENDELSE

    ;; return chi^2 
    return, total(((y-cafefitfun(0,env=env))/(err > 1D-10))^2)

END 
