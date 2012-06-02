FUNCTION  cafe_model_x, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_x
;
; PURPOSE:
;           Identity model - returns x value as is
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
;           Y = X
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_x.pro,v 1.6 2002/09/10 13:24:32 goehler Exp $
;-
;
; $Log: cafe_model_x.pro,v $
; Revision 1.6  2002/09/10 13:24:32  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.5  2002/09/09 17:36:07  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;

    name="model_x"

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
      PRINT, "x - identical model"
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
  return,  x

END  
