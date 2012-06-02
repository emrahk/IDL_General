FUNCTION  cafe_model_pow, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_pow
;
; PURPOSE:
;           Define power fit model
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - Input x value array. Should be double precision.
;           parameter - Parameter to compute model. Must contain 1
;                       value.  
; 
; PARAMETERS:
;           pow:exp - Exponent of power
;
; OUTPUT:
;           y = X^exp
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_pow.pro,v 1.6 2002/09/10 13:24:32 goehler Exp $
;-
;
; $Log: cafe_model_pow.pro,v $
; Revision 1.6  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:06  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    name="model_pow"

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
      PRINT, "pow - power fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param = {cafeparam}
      param.parname =  "pow:exp"
      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE
  ;; ------------------------------------------------------------



  ;; actual computation 
  return,  x^parameter[0]

END  
