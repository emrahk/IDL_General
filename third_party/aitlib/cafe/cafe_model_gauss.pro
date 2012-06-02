FUNCTION  cafe_model_gauss, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model_gauss
;
; PURPOSE:
;           Define Gaussian fit model y =  1/sqrt(2*pi*sigma) * exp(- 1/2*((x-x0)/sigma)^2)
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
;           gauss:x0    - Center of the Gaussian curve (mean value)
;           gauss:sigma - Width of the Gaussian curve. 
;
; OUTPUT:
;           y = 1/sqrt(2*pi*sigma)*exp(-(1/2*(x-x0)/sigma)^2)
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_gauss.pro,v 1.9 2003/03/17 14:11:31 goehler Exp $
;-
;
; $Log: cafe_model_gauss.pro,v $
; Revision 1.9  2003/03/17 14:11:31  goehler
; review/documentation updated.
;
; Revision 1.8  2002/09/10 13:31:10  goehler
; bug fix: gauss normalisation invalid
;
; Revision 1.7  2002/09/10 13:24:31  goehler
; updated name convention:
; - the command name for all commands
; - the command name + "_" + subcommand name for all subcommands
;
; Revision 1.6  2002/09/09 17:36:06  goehler
; public version: updated help matching aitlib html structure.
; common version: 3.0
;
;
;



    name="model_gauss"

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
      PRINT, "gauss - gaussian fit model"
      RETURN, 0
  ENDIF




  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},2) ;; empty parameter
      param.parname = ["gauss:x0",   $
                       "gauss:sigma" $
                      ]

      ;; set default sigma -> avoid division by zero:
      param[1].value = 1.D0

      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE:
  ;; ------------------------------------------------------------

  ;; check exponent. more than 500 is treated as zero for power. 
  exponent = 0.5D0*((x-parameter[0])/parameter[1])^2

  exponent = exponent < 500.D0

  ;; actual computation:
  return,  1.D0/sqrt(2.D0*!DPI)/parameter[1]*exp(-exponent) 

END  
