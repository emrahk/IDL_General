PRO  cafe_show_limit, env,                        $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           show_limit
;
; PURPOSE:
;           displays parameter limit
;
; CATEGORY:
;           cafe
;
; SUBCATEGORY:
;           show topic
;
; SYNTAX:
;           show, limit
;
; OUTPUT:
;           Displays limit information of model parameter for all groups.
;           Displayed is:
;           parameter - All used parameters with
;                            - parameter number in given group
;                            - model number to which the parameter
;                              belongs to (in brackets)
;                            - name of the parameter
;                            - current value
;                            - min limit. If not limit given "-inf" is
;                              shown.
;                            - max limit. If not limit given "inf" is shown.
;
; SIDE EFFECTS:
;           None
;
; HISTORY:
;           $Id: cafe_show_limit.pro,v 1.5 2003/03/03 11:18:26 goehler Exp $
;-
;
; $Log: cafe_show_limit.pro,v $
; Revision 1.5  2003/03/03 11:18:26  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.4  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.3  2002/09/09 17:36:12  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="show_limit"

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
        cafereport,env, "limi       - show parameter limits"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; LIST MODEL PARAMETER 
    ;; ------------------------------------------------------------

    ;; define default format
    format=(*env).format.paramvalformat


    cafereport,env, "------------------------------"
    cafereport,env, "Parameter limits:"    
    FOR group = 0, n_elements((*env).parameter[0,0,*])-1 DO BEGIN

        IF (*env).groups[group].model EQ "" THEN CONTINUE 

        cafereport,env, "=== GROUP "+strtrim(string(group),2)+" ==="

        ;; absolute number of parameter:
        absparnum = 0

        FOR modnum = 0, n_elements((*env).parameter[0,*,0])-1 DO BEGIN               

            FOR parnum = 0, n_elements((*env).parameter[*,0,0])-1 DO BEGIN 

                ;; skip empty parameter
                IF (*env).parameter[parnum,modnum,group].parname EQ "" THEN CONTINUE 

                
                ;; define output for min limit
                IF (*env).parameter[parnum,modnum,group].limited[0] THEN BEGIN
                    limitstr = string((*env).parameter[parnum,modnum,group].limits[0],format="(G15.5)")
                ENDIF ELSE limitstr = "           -inf"

                ;; define output for max limit
                limitstr =limitstr+ "   "
                IF (*env).parameter[parnum,modnum,group].limited[1] THEN BEGIN
                    limitstr = limitstr+string((*env).parameter[parnum,modnum,group].limits[1],format="(G15.5)")
                ENDIF ELSE limitstr = limitstr+"            inf"
                
                ;; create string with parameter info, constant length
                parinfo = "                   "
                strput,parinfo,strtrim(string(absparnum,format="(I2)"),2)+")  "    $
                  + "["+strtrim(string(modnum),2)+"]"+"->"                    $
                  + (*env).parameter[parnum,modnum,group].parname

                cafereport,env,string(parinfo,                              $
                  (*env).parameter[parnum,modnum,group].value,                   $
                  limitstr,                                                      $
                  format="(A20,"+format+",A)")

                ;; next parameter:
                absparnum = absparnum + 1
              ENDFOR
        ENDFOR                
    ENDFOR
END 


