FUNCTION  cafe_model_tan, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_tan
;
; PURPOSE:
;           Define tangent fit model y
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
;           tan:P   - Period of tangent. Must not be zero.
;           tan:phi - Phase of tangent.
;
; OUTPUT:
;           y = tan(2*pi* (X / P + phi))
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_tan.pro,v 1.7 2003/03/17 14:11:31 goehler Exp $
;-
;
; $Log: cafe_model_tan.pro,v $
; Revision 1.7  2003/03/17 14:11:31  goehler
; review/documentation updated.
;
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

    name="model_tan"

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
      PRINT, "tan - tangens fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},2) ;; empty parameter
      param.parname = ["tan:P",   $
                       "tan:phi"  $
                      ]

      ;; set default period -> avoid division by zero:
      param[0].value = 1.D0

      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE
  ;; ------------------------------------------------------------



  ;; actual computation 
  return,  tan ( 2.D0 *!DPI * (x / parameter[0] + parameter[1]))

END  
