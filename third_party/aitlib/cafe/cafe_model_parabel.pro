FUNCTION  cafe_model_parabel, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model_parabel
;
; PURPOSE:
;           Define parabolic fit model y = a*x^2 + b*x + c. 
;
; CATEGORY:
;           CAFE
;
; SUBCATEGORY:
;           fitmodel
;
; INPUTS:
;           x        - Input x value array. Should be double
;                      precision. 
;           parameter- Parameter to compute model. Must contain 3
;                       values.
;
; PARAMETERS:
;           parabel:a - quadratic coefficient
;           parabel:b - linear coefficient
;           parabel:c - constant coefficient
;
; OUTPUT:
;           y = a*x^2 + b*x + c

;
; SIDE EFFECTS:
;           None.
;
;
; HISTORY:
;             $Id: cafe_model_parabel.pro,v 1.8 2003/03/17 14:11:31 goehler Exp $
;-
;
; $Log: cafe_model_parabel.pro,v $
; Revision 1.8  2003/03/17 14:11:31  goehler
; review/documentation updated.
;
; Revision 1.7  2002/09/19 14:02:38  goehler
; documentized
;
; Revision 1.6  2002/09/10 13:24:31  goehler
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



    name="model_parabel"

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
      PRINT, "parabel - parabolic fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},3) ;; empty parameter
      param.parname = ["parabel:a",   $
                       "parabel:b",   $
                       "parabel:c"   $
                      ]
      return, param
  ENDIF


  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE:
  ;; ------------------------------------------------------------

  ;; actual computation (horner schema):
  return,  (x * parameter[0] + parameter[1]) * x + parameter[2]
  

END  





















