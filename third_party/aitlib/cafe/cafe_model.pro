PRO  cafe_model, env,                           $
                  model, quiet=quiet,add=add,   $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model
;
; PURPOSE:
;           define model of fit
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           model, modelstring[:group] [,/add][,/quiet]
;
; INPUTS:
;           modelstring - Defines the models to apply. The string may
;                         consist of several models to apply which
;                         could be combined via algebraic operators as
;                         there are:
;                          "+" - adds two models
;                          "-" - subtracts two models
;                          "*" - multiplies two models
;                          "/" - divides two models
;                         Parentheses are allowed to group the
;                         operations. Chaining of models is possible
;                         by enclosing the inner model within parentheses:
;                         sin(lin) -> y = sin(lin(x)).
;
;                         Model components must be lower case. If a
;                         component is upper case or starts with a
;                         number it is interpreted as a usual IDL
;                         function/expression. This can be used to
;                         exploit simple/built in functions.
;                         Example:
;                         > model, const*SIN(x*2*!DPI)
;                         -> use two model components (const and x) and a
;                         fix function (SIN) with a built in constant
;                         (!DPI). 
;                         
;                         
;           group    - (optional) The data group for which the model
;                      should be applied.
;                      Default is the current group which can be
;                      changed with "chgrp". Must be in range [0..29].
;
; OPTIONS:
;           /quiet   - Do not ask for parameter values (useful for
;                      command file processing)
;           /add     - Do not erase former model (and their
;                      parameter) but append the model string with a
;                      leading "+".
;                      All new parameters will be asked for. 
;
; MODELS:
;          The models are defined in separate modules which could be
;          added and maintained separately.
;
;          Available models could be list with
;          
;                      help,model,all
;
;          while a specific model can be shown with
;
;                      help,model, <model>
;
;          Models can be add by defining a function in a separate
;          file. Refer maintenance. 
;
;
; SIDE EFFECTS:
;           Stores model information in environment for given group
;
; EXAMPLE:
;           > model, "sin+lin", 2
;
; HISTORY:
;           $Id: cafe_model.pro,v 1.13 2003/04/30 14:42:51 goehler Exp $
;-
;
; $Log: cafe_model.pro,v $
; Revision 1.13  2003/04/30 14:42:51  goehler
; changed model behavior: all built in model components must be lower case.
; This allows simple use of built in IDL functions/constants which must be
; upper case.
;
; Revision 1.12  2003/04/07 13:12:31  goehler
; allow parameter expressions also
;
; Revision 1.11  2003/03/17 14:11:30  goehler
; review/documentation updated.
;
; Revision 1.10  2003/03/03 11:18:23  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.9  2003/02/11 15:01:36  goehler
; bug fix: numbers in models were not allowed. now they are
;
; Revision 1.8  2002/11/05 17:43:44  goehler
; bug fix: model identifier must start with a letter
;
; Revision 1.7  2002/09/09 17:36:04  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;


    ;; file name prefix for all models:
    MODEL_PREFIX="cafe_model_"




    ;; command name of this source (needed for automatic help)
    name="model"

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
        cafereport,env, "model    - define fit model"
        return
    ENDIF



    ;; ------------------------------------------------------------
    ;; GENERAL SETUP
    ;; ------------------------------------------------------------

    ;; check model
    IF n_elements(model) EQ 0 THEN BEGIN
        cafereport,env, "Error: No model given"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; GROUP SETUP
    ;; ------------------------------------------------------------

    ;; define default group
    group = (*env).def_grp

    ;; extract model/group:
    modcomp = stregex(model, "^([^:]*)(:([0-9]+))?$",$ ; model string+group
                      /extract,/subexpr) 

    ;; model string is first part
    model = modcomp[1]

    ;; set group if given
    IF modcomp[2] NE "" THEN group = fix(modcomp[3])

    ;; check boundary:
    IF (group GE n_elements((*env).groups)) OR (group LT 0)  THEN BEGIN 
        cafereport,env, "Error: invalid group number"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CLEAR FORMER MODEL PARAMETER (IF NOT ADDED)
    ;; ------------------------------------------------------------

    IF NOT keyword_set(add) THEN BEGIN 

        ;; create new parameter (defined in cafeenv__define)
        empty_param = {cafeparam}

        ;; assign it:
        (*env).parameter[*,*,group] = empty_param
    ENDIF 


    ;; ------------------------------------------------------------
    ;; APPEND MODEL IF ADDED
    ;; ------------------------------------------------------------
    
    IF keyword_set(add) THEN BEGIN 

        ;; former models:
        oldmodels = STRSPLIT(model,"[^a-zA-Z][^a-zA-Z0-9]*",/EXTRACT,/REGEX)

        ;; set number of former models to skip:
        IF model EQ "" THEN modelstart = 0 ELSE $
          modelstart = n_elements(oldmodels)
        
        model=(*env).groups[group].model+"+"+model

    ENDIF ELSE BEGIN 

        ;; starting with first model (default)
        modelstart = 0
    ENDELSE 
     

    ;; ------------------------------------------------------------
    ;; EXTRACT MODEL COMPONENTS FROM STRING: 
    ;; (to define parameter)
    ;; ------------------------------------------------------------

    ;; copy model string which will change during scan:
    aux = model

    ;; list of models:
    models=[""]

    ;; get models by scan:
    WHILE aux NE "" DO BEGIN 
        token = cafemodelscan(aux)
        ;; model found -> store
        IF stregex(token, "^[a-z][a-z0-9_]*$",/boolean) THEN $
          models = [models,token]
    ENDWHILE   

    ;; ------------------------------------------------------------
    ;; NO MODEL -> NO PARAMETER
    ;; ------------------------------------------------------------

    IF n_elements(models) LT 2 THEN BEGIN 
        modelnum = 0
        models = ""
    ENDIF ELSE BEGIN 
        models = models[1:*]
        modelnum = n_elements(models)
    ENDELSE 



    ;; ------------------------------------------------------------
    ;; READ MODEL PARAMETER 
    ;; ------------------------------------------------------------
    
    FOR modnum = modelstart, modelnum-1 DO BEGIN
        
        ;; get parameter list from model function for given model group/number
        paramlist = CALL_FUNCTION(MODEL_PREFIX+models[modnum], 0,0, /getparam)

        ;; skip non-existing parameter lists:
        IF paramlist[0].parname EQ "" THEN CONTINUE 

        ;; read in parameter, store its values:
        CAFEREPORT,ENV, "Model ["+strtrim(string(modnum),2)+"] - "+models[modnum]+": "
        FOR parnum = 0, n_elements(paramlist)-1 DO BEGIN 


            ;; store current parameter:
            (*env).parameter[parnum,modnum,group] = paramlist[parnum]

            ;; read string for value/fixed flag:
            input = ""

            ;; read if no hush up requested
            IF NOT keyword_set(quiet) THEN BEGIN 

                ;; print current parameter:
                  cafereport,env,                                       $
                  (*env).parameter[parnum,modnum,group].parname          $
                  +string((*env).parameter[parnum,modnum,group].value)   $
                  +string((*env).parameter[parnum,modnum,group].fixed)

                ;; read new value:
                caferead,env,  input, prompt=(paramlist[parnum].parname+": ")
            ENDIF 

            input = strsplit(input,",",/extract,/preserve_null)            

            print, input
            ;; set value parameter (if any):
            IF NOT stregex(input[0], "^ *$",/boolean) THEN BEGIN 
                IF NOT execute('val = ' + input[0]) THEN                      $
                  cafereport,env, "Error: Invalid expression value"           $
                ELSE                                                          $
                  (*env).parameter[parnum,modnum,group].value = double(val)
            ENDIF  

            ;; set fixed flag (if any):
            IF (n_elements(input) EQ 2) THEN $
              IF stregex(input[1], "^[01]$",/boolean) THEN $
              (*env).parameter[parnum,modnum,group].fixed = fix(input[1])
                       
        ENDFOR

    ENDFOR



  ;; ------------------------------------------------------------
  ;; STORE MODEL:
  ;; ------------------------------------------------------------

  (*env).groups[group].model=model



  ;; ------------------------------------------------------------
  ;; REPORT NEW SETTINGS
  ;; ------------------------------------------------------------


  ;; show result:
  cafe_show,env,"model+param+result",/transient


  ;; ------------------------------------------------------------
  ;; WARNING FOR SHIFTED PARAMETERS:
  ;; ------------------------------------------------------------

  ;; compute number of groups following this one:
  nextgroupnum = n_elements((*env).groups)-group-1

  ;; create array refering following groups:
  nextgroups = indgen(nextgroupnum)+group+1

  ;; if one contains non-empty tied information ->
  ;; parameter number may have changed
  IF (where((*env).parameter[*,*,nextgroups].tied NE ""))[0] NE -1 THEN $
    cafereport,env, "Warning: Parameter tie reference may have shifted"
  
  
  RETURN  
END


