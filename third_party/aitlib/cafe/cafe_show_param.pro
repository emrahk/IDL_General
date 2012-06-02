PRO  cafe_show_param, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_param
;
; PURPOSE:
;           displays complete parameter information
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, param
;
; OUTPUT:
;           Displays model parameter for all groups. Displayed are all
;           used parameters with:
;            - parameter number in given group
;            - model number to which the parameter belongs to (in
;              brackets) 
;            - name of the parameter
;            - current value
;            - error value of the parameter. This is usually the error
;              estimated from the diagonal elements of the Hessian
;              retrieved from last fit. This error value has to be
;              used with care! If the "error" command was called
;              before its error values are shown. 
;            - fixed flag (may be reseted with chpar/thaw)
;            - parameter link information. This is a parameter
;              expression usually containing "->P(num)" set with the
;              tie command. In this case <num> is the absolute
;              parameter number, i.e. counting the parameters
;              regardless of the current group. 
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_param.pro,v 1.7 2003/03/17 14:11:36 goehler Exp $
;-
;
; $Log: cafe_show_param.pro,v $
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
; Revision 1.4  2002/09/09 17:36:12  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_param"

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
        cafereport,env, "result     - show parameter values"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; LIST MODEL PARAMETER 
    ;; ------------------------------------------------------------

    ;; define default format
    format=(*env).format.paramvalformat+","+(*env).format.paramerrformat

    cafereport,env, "------------------------------"
    cafereport,env, "Parameters:"    
    FOR group = 0, n_elements((*env).parameter[0,0,*])-1 DO BEGIN

        IF (*env).groups[group].model EQ "" THEN CONTINUE 

        cafereport,env, "=== GROUP "+strtrim(string(group),2)+" ==="

        ;; absolute number of parameter:
        absparnum = 0

        FOR modnum = 0, n_elements((*env).parameter[0,*,0])-1 DO BEGIN               

            FOR parnum = 0, n_elements((*env).parameter[*,0,0])-1 DO BEGIN 

                ;; skip empty parameter
                IF (*env).parameter[parnum,modnum,group].parname EQ "" THEN CONTINUE 

                ;; extract tied information
                IF (*env).parameter[parnum,modnum,group].tied NE "" THEN BEGIN 
                    tied = " ->"+(*env).parameter[parnum,modnum,group].tied
                ENDIF ELSE tied = ""

                ;; create string with parameter info, constant length
                parinfo = "                   "
                strput,parinfo,strtrim(string(absparnum,format="(I2)"),2)+")  "    $
                  + "["+strtrim(string(modnum),2)+"]"+"->"                    $
                  + (*env).parameter[parnum,modnum,group].parname


                ;; print parameter
                cafereport,env,string(parinfo,                              $
                  (*env).parameter[parnum,modnum,group].value,                   $
                  (*env).parameter[parnum,modnum,group].error,                   $
                  (*env).parameter[parnum,modnum,group].fixed,                   $
                  tied,                                                       $
                  format="(A20,"+format+",  I5,A)")

                ;; next parameter:
                absparnum = absparnum + 1
              ENDFOR
        ENDFOR                
    ENDFOR

END 


