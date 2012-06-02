PRO  cafe_show_error, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_error
;
; PURPOSE:
;           displays last computed parameter errors
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, error
;
; OUTPUT:
;           Displays error information of model parameter for all groups.
;           Shown are only free parameter (for fixed parameters the
;           error range is 0..0).
;           Displayed is:
;                parameter - All used parameters with
;                            - parameter number in given group
;                            - model number to which the parameter
;                              belongs to (in brackets)
;                            - name of the parameter
;                            - current value
;                            - error value of the parameter. This
;                              error is estimated as the max
;                              difference of error ranges from the
;                              fitted value. If this difference is
;                              zero the hessian error value is displayed. 
;                            - min error value as being determined
;                              with the error command.
;                            - max error value as being determined
;                              with the error command.
;                            - parameter link information as a
;                              "*". This marks that the parameter is
;                              linked to other parameter(s).
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_error.pro,v 1.7 2003/03/17 14:11:36 goehler Exp $
;-
;
; $Log: cafe_show_error.pro,v $
; Revision 1.7  2003/03/17 14:11:36  goehler
; review/documentation updated.
;
; Revision 1.6  2003/03/03 11:18:26  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.5  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.4  2002/09/09 17:36:11  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_error"

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
    ;; LIST MODEL PARAMETER 
    ;; ------------------------------------------------------------

    ;; define default format
    format=(*env).format.paramvalformat+"," $ ; value
          +(*env).format.paramerrformat+"," $ ; error
          +(*env).format.paramerrformat+"," $ ; min
          +(*env).format.paramerrformat       ; max

    cafereport,env, "------------------------------"
    cafereport,env, "Parameter errors:"    
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

                ;; extract tied information
                IF (*env).parameter[parnum,modnum,group].tied NE "" THEN $
                  tied = "*"                                          $
                ELSE tied = ""

                ;; create string with parameter info, constant length
                parinfo = "                   "
                strput,parinfo,strtrim(string(absparnum,format="(I2)"),2)+")  "    $
                  + "["+strtrim(string(modnum),2)+"]"+"->"                    $
                  + (*env).parameter[parnum,modnum,group].parname

                ;; compute error as maximal deviation from the fitted
                ;; value using error command:
                IF (*env).parameter[parnum,modnum,group].errmax NE $
                  (*env).parameter[parnum,modnum,group].errmin THEN BEGIN 
                    error = max([(*env).parameter[parnum,modnum,group].errmax - $
                                 (*env).parameter[parnum,modnum,group].value,   $
                                 (*env).parameter[parnum,modnum,group].value -  $
                                 (*env).parameter[parnum,modnum,group].errmin])
                    ;; look for hessian if invalid ranges given:
                ENDIF ELSE BEGIN 
                    error = (*env).parameter[parnum,modnum,group].error
                ENDELSE 
                             

                cafereport,env,string(parinfo,                              $
                  (*env).parameter[parnum,modnum,group].value,                   $
                  error,                                                      $
                  (*env).parameter[parnum,modnum,group].errmin,                  $
                  (*env).parameter[parnum,modnum,group].errmax,                  $
                  tied,                                                       $
                  format="(A20,"+format+",A)")

                ;; next parameter:
                absparnum = absparnum + 1
              ENDFOR
        ENDFOR                
    ENDFOR
END 


