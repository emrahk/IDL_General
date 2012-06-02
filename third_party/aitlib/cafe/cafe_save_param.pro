PRO cafe_save_param, env, filename,                    $
                     help=help, shorthelp=shorthelp
;+
; NAME:
;           save_param
;
; PURPOSE:
;           Saves fit parameter into ascii file.
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           save
;
; DATA FORMAT:
;           This action will save last fit parameters into a text file
;           with given save file name.
;           Saved will be:
;               - the fit parameter+value
;               - the fit error, if given
;               - current x range position
;           If the file did'nt exist a descriptive header for the
;           columns will be saved also with the parameter name and its
;           error name.
;
;           Only free and non-tied parameters will be saved. 
;
;           If the file exists the new data/parameters will be appended (and
;           the file will NOT be overridden). Therefore it is
;           recomended to use the /clobber option for multiple
;           parameter saves. 
;
; SIDE EFFECTS:
;           Changes content of file.
;
; EXAMPLE:
;
;               > fit
;               > save, result.dat, param,/clobber
;               -> saves fit parameter into file "result.dat"
;
; HISTORY:
;           $Id: cafe_save_param.pro,v 1.2 2003/04/29 07:58:19 goehler Exp $
;             
;-
;
; $Log: cafe_save_param.pro,v $
; Revision 1.2  2003/04/29 07:58:19  goehler
; change/fix: ignore groups with undefined data points or non-existing models
;             The determination of valid parameters is performed in new
;             function cafegetvalidparam()
;
; Revision 1.1  2003/04/24 09:45:58  goehler
; moved parameter saving to new procedure cafe_save_param
; which allows interactive saving also.
;
;
;
;

    ;; command name of this source (needed for automatic help)
    name="save_param"

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
        print, "param    - parameter ascii save type"
        return
    ENDIF

    ;; check if file exists:
    newfile=(NOT file_exist(filename))

    ;; get write lun:
    get_lun, paramfile

    ;; open file to append new parameters:
    openw, paramfile, filename, /append
    

    ;; get index of free/untied parameters:
    param_index = cafegetvalidparam(env,free,selected=(*env).fitresult.selected)

    ;; parameter available -> print them
    IF param_index[0] NE -1 THEN BEGIN 


        ;; create header if new file:
        IF newfile THEN BEGIN            
            printf, paramfile, "#",                                        $ ;; comment
              transpose([[(*env).parameter[param_index].parname],          $ ;; name
                         ["err_"+(*env).parameter[param_index].parname]]), $ ;; xpos
              "             X-Pos",                                        $
              format="(A1,"+strtrim(string(2*n_elements(param_index)+1))   $ ;; formatize
              + "A18" + ")"            
        ENDIF 

        ;; extract parameter data for convenience:
        values = (*env).parameter[param_index].value
        errors = (*env).parameter[param_index].error

        ;; try to get better error computed with error command:
        err_index = where(((*env).parameter[param_index].errmin NE 0) OR $
                          ((*env).parameter[param_index].errmax NE 0))
        
        ;; we extract errors by taking the supremum of val-min and max-val:
        IF err_index[0] NE -1 THEN BEGIN 
            errors[err_index] = (((*env).parameter[param_index].errmax - $
                                  (*env).parameter[param_index].value)  $
                              >  ((*env).parameter[param_index].value -  $
                                  (*env).parameter[param_index].errmin))[err_index]

        ENDIF 

        ;; perform actual printout, arrange values+errors consecutively
        ;; (bit dirty):
        printf, paramfile," ",                                  $ ;; prepend space
          transpose([[values],[errors]]),                       $ ;; write parameters
          (*env).plot.xpos,                                     $ ;; write x position
          format="(A1,"+                                        $ ;; format of 
                 strtrim(string(2*n_elements(values)+1))        $ ;; n parameters+errors
          + "F18.10)"                                             ;; +xpos

        ;; thats it
        close,paramfile
        free_lun,paramfile

        cafereport,env,"Parameters saved in "+filename
    ENDIF
END 
