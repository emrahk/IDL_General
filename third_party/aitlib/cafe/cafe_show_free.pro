PRO  cafe_show_free, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_free
;
; PURPOSE:
;           displays fit results of free parameters
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, free
;
; OUTPUT:
;           Displays fit results for all groups. These are
;               parameter - All used parameters with
;                            - parameter number in given group
;                            - model number to which the parameter
;                              belongs to (in brackets)
;                            - name of the parameter
;                            - current value
;                            - error value of the parameter. This is
;                              usually the error estimated from the
;                              diagonal elements of the Hessian
;                              retrieved from last fit.
;                              This error value has to be used with
;                              care! If the "error" command was
;                              executed before the error is the result
;                              of the error command.
;                           Tied/fixed parameters are not shown.
;                            
;                 chi^2   - The Chi square value from last fit.
;                 DOF     - Degree of freedoms, i.e. the number of
;                           defined data points reduced by the number
;                           of free parameters (which are neither
;                           fixed or tied to other parameters).
;               Chi^2_red - Reduced Chi square value; the chi^2
;                           divided by the degree of freedom. Should
;                           be near 1 for a good fit. 
;                            
;         Goodness_of_fit - The probability that the fit may
;                           contain larger values of chi^2. Should
;                           be close to  1 for a good fit. 
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_free.pro,v 1.9 2003/05/09 14:50:09 goehler Exp $
;-
;
; $Log: cafe_show_free.pro,v $
; Revision 1.9  2003/05/09 14:50:09  goehler
;
; updated documentation in version 4.1
;
; Revision 1.8  2003/03/17 14:11:36  goehler
; review/documentation updated.
;
; Revision 1.7  2003/03/03 11:18:26  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.6  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:12  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_free"

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
    ;; LIST FREE MODEL PARAMETER 
    ;; ------------------------------------------------------------

    ;; define default format
    format=(*env).format.paramvalformat+","+(*env).format.paramerrformat

    cafereport,env, "------------------------------"
    cafereport,env, "Free Parameters:"    
    FOR group = 0, n_elements((*env).parameter[0,0,*])-1 DO BEGIN

        IF (*env).groups[group].model EQ "" THEN CONTINUE 

        cafereport,env, "=== GROUP "+strtrim(string(group),2)+" ==="

        ;; absolute number of parameter:
        absparnum = 0

        FOR modnum = 0, n_elements((*env).parameter[0,*,0])-1 DO BEGIN               

            FOR parnum = 0, n_elements((*env).parameter[*,0,0])-1 DO BEGIN 

                ;; skip empty parameter
                IF (*env).parameter[parnum,modnum,group].parname EQ "" THEN CONTINUE 

                ;; skip fixed parameter 
                IF (*env).parameter[parnum,modnum,group].fixed THEN BEGIN 
                    ;; count it
                    absparnum = absparnum + 1
                    CONTINUE 
                ENDIF 

                ;; skip tied parameter 
                IF (*env).parameter[parnum,modnum,group].tied NE "" THEN BEGIN 
                    ;; count it
                    absparnum = absparnum + 1
                    CONTINUE 
                ENDIF 

                ;; create string with parameter info, constant length
                parinfo = "                   "
                strput,parinfo,strtrim(string(absparnum,format="(I2)"),2)+")  "    $
                  + "["+strtrim(string(modnum),2)+"]"+"->"                    $
                  + (*env).parameter[parnum,modnum,group].parname


                ;; print parameter
                cafereport,env,string(parinfo,                                 $
                  (*env).parameter[parnum,modnum,group].value,                   $
                  (*env).parameter[parnum,modnum,group].error,                   $
                  format="(A20,"+format+")")

                ;; next parameter:
                absparnum = absparnum + 1
              ENDFOR
        ENDFOR                
    ENDFOR

    ;; ------------------------------------------------------------
    ;; LIST FIT RESULT (?) 
    ;; ------------------------------------------------------------

    cafe_show_result,env

END 

