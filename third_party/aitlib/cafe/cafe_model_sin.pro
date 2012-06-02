FUNCTION  cafe_model_sin, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_sin
;
; PURPOSE:
;           Define sinus fit model y
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
;           sin:P   - Period of sinus. Should not be zero.
;           sin:phi - Phase of sinus
;
; OUTPUT:
;           y = sin(2*pi* (X / P + phi))
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_sin.pro,v 1.7 2003/03/17 14:11:31 goehler Exp $
;-
;
; $Log: cafe_model_sin.pro,v $
; Revision 1.7  2003/03/17 14:11:31  goehler
; review/documentation updated.
;
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

    name="model_sin"

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
      PRINT, "sin - sinus fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},2) ;; empty parameter
      param.parname = ["sin:P",   $
                       "sin:phi"  $
                      ]

      ;; set default period -> avoid division by zero:
      param[0].value = 1.D0

      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE
  ;; ------------------------------------------------------------



  ;; actual computation 
  return,  sin ( 2.D0 *!DPI * (x / parameter[0] + parameter[1]))

END  
