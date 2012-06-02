PRO  cafe_defpar, env, $
                  parameter, property, value,       $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           defpar
;
; PURPOSE:
;           define model parameter properties like its name or its boundary 
;
; CATEGORY:
;           cafe
;
; SYNTAX:
;           defpar, parameter[:group],property,value
;
; OPTIONS:
;           parameter - The parameter to change. This can be either:
;                        - The absolute parameter number in the
;                          current model.
;                        - A parameter number range, defined by the
;                          first parameter and last parameter,
;                          separated with "-". (e.g. 1-7)
;                        - A string designating the parameter
;                          name. The parameter name is usually
;                          "model:parname". If this parameter name is
;                          not unique in current model all matching
;                          parameters will be asked to change.
;                       If no parameter information is given all
;                       parameters will be asked to changed.
;                       
;               group - The group number defining the model to
;                       change. Default is 0, must be in range [0,9].
;
;            property - Which part of the parameter will be
;                       changed. Currently valid properties are (these
;                       are also mentioned in mpfitfun.pro):
;                   VALUE - the starting parameter value.
;  
;                   FIXED - a boolean value, whether the parameter is to be held
;                           fixed or not.  
;  
;                 LIMITED - a two-element boolean array.  If the first/second
;                           element is set, then the parameter is bounded on the
;                           lower/upper side.  A parameter can be bounded on both
;                           sides.  Both LIMITED and LIMITS must be given
;                           together.
;  
;                  LIMITS - a two-element float or double array.  Gives the
;                           parameter limits on the lower and upper sides,
;                           respectively.  Zero, one or two of these values can be
;                           set, depending on the values of LIMITED.  Both LIMITED
;                           and LIMITS must be given together.
;  
;                 PARNAME - name of the parameter.  
;  
;                    STEP - the step size to be used in calculating the numerical
;                           derivatives.  If set to zero, then the step size is
;                           computed automatically.  Ignored when AUTODERIVATIVE=0.
;
;                  MPSIDE - the sidedness of the finite difference when computing
;                           numerical derivatives.  This field can take four
;                           values:
;
;                            0 - one-sided derivative computed automatically
;                            1 - one-sided derivative (f(x+h) - f(x)  )/h
;                           -1 - one-sided derivative (f(x)   - f(x-h))/h
;                            2 - two-sided derivative (f(x+h) - f(x-h))/(2*h)
;                           Where H is the STEP parameter described above.  The
;                           "automatic" one-sided derivative method will chose a
;                           direction for the finite difference which does not
;                           violate any constraints.  The other methods do not
;                           perform this check.  The two-sided method is in
;                           principle more precise, but requires twice as many
;                           function evaluations.  Default: 0.
;
;               MPMINSTEP - the minimum change to be made in the parameter
;                           value.  During the fitting process, the parameter
;                           will be changed by multiples of this value.
;                           Note that this constraint should be used
;                           with care since it may cause non-converging,
;                           oscillating solutions.
;                           A value of 0 indicates no minimum (  Default).
;
;               MPMAXSTEP - the maximum change to be made in the parameter
;                           value.  During the fitting process, the parameter
;                           will never be changed by more than this value.
;                           A value of 0 indicates no maximum (Default).
;  
;                    TIED - a string expression which "ties" the parameter to other
;                           free or fixed parameters.  Any expression involving
;                           constants and the parameter array P are permitted.      
;
;               value - The value to set the parameter property at. 
;
;
; REMARK:
;           These properties are used for the fit command with the
;           calling mpfit library functions. They also apply for the
;           error command.
;
; SIDE EFFECTS:
;           Changes part of parameters. 
;
; EXAMPLE:
;
;               > defpar,sin:P:2, parname, period
;                   sin:P: 22.5, 1
;               -> changes Parameter name of sin:P of model in group 2 at "period"
;
; HISTORY:
;           $Id: cafe_defpar.pro,v 1.6 2003/05/09 14:50:07 goehler Exp $
;-
;
; $Log: cafe_defpar.pro,v $
; Revision 1.6  2003/05/09 14:50:07  goehler
;
; updated documentation in version 4.1
;
; Revision 1.5  2003/03/17 14:11:28  goehler
; review/documentation updated.
;
; Revision 1.4  2003/03/03 11:18:22  goehler
; major change: environment struct has become a pointer -> support of wplot/command line
; in common.
; Branch to be able to maintain the former line also.
;
; Revision 1.3  2002/09/09 17:36:02  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    ;; command name of this source (needed for automatic help)
    name="defpar"

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
        cafereport,env, "defpar   - define parameter property"
        return
    ENDIF


    ;; ------------------------------------------------------------
    ;; CHECK RANGE, SET DEFAULTS:
    ;; ------------------------------------------------------------


    ;; define default group
    group = (*env).def_grp


    ;; parameter array dimensions:
    param_dim = size((*env).parameter,/dimension)

    ;; ------------------------------------------------------------
    ;; GET PARAMETER INDEX
    ;; ------------------------------------------------------------

    param_index = cafeparam(env,parameter,group)

    ;; check model existence
    IF (*env).groups[group].model EQ "" THEN BEGIN
        cafereport,env, "Error: No model given in group", group
        return
    ENDIF

    ;; invalid parameter
    IF param_index[0] EQ -1 THEN BEGIN 
        cafereport,env, "Error: Invalid parameter specified"
        return
    ENDIF 

        
    ;; ------------------------------------------------------------
    ;; SET PARAMETER PROPERTY
    ;; ------------------------------------------------------------            


    ;; property not defined -> error:
    IF n_elements(property) EQ 0 THEN BEGIN 
        cafereport,env, "Error: Property not defined"
        return
    ENDIF 

    ;; value not defined -> error:
    IF n_elements(value) EQ 0 THEN BEGIN 
        cafereport,env, "Error: Property value not defined"
        return
    ENDIF 

    ;; if string -> add quotings
    IF (size(value))[0] EQ 0 AND (size(value))[1] EQ 7 THEN  $
      value = "'" + value+"'"
    

    print, "(*env).parameter[param_index]." + property $
                     +"="+string(value)                      
    IF NOT execute(  "(*env).parameter[param_index]." + property $
                     +"="+string(value)                       $
                  ) THEN BEGIN                             
        cafereport,env,"Error:"+!ERR_STRING ; plotting failed
        return
    ENDIF 

    ;; show result:
    cafe_show,env,"param+error",/transient

  RETURN  
END


