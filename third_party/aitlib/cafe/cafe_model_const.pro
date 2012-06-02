FUNCTION  cafe_model_const, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model_const
;
; PURPOSE:
;           Define constant fit model y = const
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - Input x value array. Should be double precision.
;           parameter - Parameter to compute model. Must contain 2
;                       values.  
; 
; PARAMETERS:
;           const:c   - Constant value
; 
;
; OUTPUT:
;           y = c
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_const.pro,v 1.6 2002/09/10 13:24:31 goehler Exp $
;-
;
; $Log: cafe_model_const.pro,v $
; Revision 1.6  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:05  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    name="model_const"

    ;; ------------------------------------------------------------
    ;; HELP
    ;; ------------------------------------------------------------
    ;; if help given -> print the specification above (from this file)
    IF keyword_set(help) THEN BEGIN
        cafe_help,env, name,/model
        return,0
    ENDIF 


  ;; ------------------------------------------------------------
  ;; short HELP
  ;; ------------------------------------------------------------
  IF KEYWORD_SET(SHORTHELP) THEN BEGIN  
      PRINT, "const - constant fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param = {cafeparam}
      param.parname =  "const:c"
      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE 
  ;; ------------------------------------------------------------



  ;; actual computation - return constant value:
  return,  replicate( parameter[0], n_elements(x)) 

END  
