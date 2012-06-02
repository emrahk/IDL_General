FUNCTION  cafe_model_ceil, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_ceil
;
; PURPOSE:
;           Returns closest integer value above x value
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - Input x value array. Should be double precision.
;           parameter - Parameter to compute model. None.
; 
; PARAMETERS:
;           none.
;
; OUTPUT:
;           Y = Ceil(x)
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_ceil.pro,v 1.6 2002/09/10 13:24:31 goehler Exp $
;-
;
; $Log: cafe_model_ceil.pro,v $
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

    name="model_ceil"

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
      PRINT, "ceil  - closest integer number above value"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  ;; no parameter
  IF keyword_set(getparam)  THEN BEGIN 
      return, {cafeparam} ;; empty parameter
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE
  ;; ------------------------------------------------------------



  ;; actual computation 
  return,  double(ceil(x,/L64))

END  
