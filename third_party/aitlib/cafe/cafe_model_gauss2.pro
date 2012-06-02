FUNCTION  cafe_model_gauss2, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp
;+
; NAME:
;           model_gauss2
;
; PURPOSE:
;           Define 2-Dim Gaussian fit model y =  1/sqrt(sigma*2*pi)
;                                                * exp(
;                                                - 0.5*((x_1-x0)/sigma)^2
;                                                - 0.5*((x_2-y0)/sigma)^2)
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - 2-Dim Input x value array. Should be double precision.
;           parameter - Parameter to compute model. Must contain 2
;                       values.  
; 
; PARAMETERS:
;           gauss:x0    - X1-Component of the center of the Gaussian
;                         curve (mean value)
;           gauss:y0    - X2-Component of the center of the Gaussian
;                         curve (mean value) 
;           gauss:sigma - Width of the Gaussian curve. 
;
; OUTPUT:
;           y = 2-Dim gauss
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_gauss2.pro,v 1.2 2003/03/17 14:11:31 goehler Exp $
;-
;
; $Log: cafe_model_gauss2.pro,v $
; Revision 1.2  2003/03/17 14:11:31  goehler
; review/documentation updated.
;
; Revision 1.1  2003/02/11 15:03:35  goehler
; added gauss model, and method to plot models.
;



    name="model_gauss2"

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
      PRINT, "gauss2- 2-dim gaussian fit model"
      RETURN, 0
  ENDIF




  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},3) ;; empty parameter
      param.parname = ["gauss2:x0",   $
                       "gauss2:y0",   $
                       "gauss2:sigma" $
                      ]

      ;; set default sigma -> avoid division by zero:
      param[0].value = 0.D0
      param[1].value = 0.D0
      param[2].value = 1.D0

      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE:
  ;; ------------------------------------------------------------

  ;; check exponent. more than 500 is treated as zero for power. 
  exponent = 0.5D0*(((x[*,0]-parameter[0])/parameter[2])^2 $
                  + ((x[*,1]-parameter[1])/parameter[2])^2)

  exponent = exponent < 500.D0

  ;; actual computation:
  return,  1.D0/sqrt(2.D0*!DPI)/parameter[2]*exp(-exponent) 

END  
