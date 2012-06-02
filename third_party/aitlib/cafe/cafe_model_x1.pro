FUNCTION  cafe_model_x1, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_x1
;
; PURPOSE:
;           Projektion model of identity - returns X-values column 1
;           (first) of multidimensional data.
;
; CATEGORY:
;           CAFE
; 
; SUBCATEGORY:
;           fitmodel
;  
; INPUTS:
;           x         - Input x value array. May be multidimensional,
;                       so first column will be selected. Should be
;                       double precision. 
;           parameter - Parameter to compute model. None.
; 
; PARAMETERS:
;           none.
;
; OUTPUT:
;           For X=[X1,X2,...Xn] return:
;           Y = X1
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_x1.pro,v 1.1 2003/02/11 15:00:09 goehler Exp $
;-
;
; $Log: cafe_model_x1.pro,v $
; Revision 1.1  2003/02/11 15:00:09  goehler
; initial version of 2-dim projectors
;
;
;
;

    name="model_x1"

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
      PRINT, "x1 - projection to first x component"
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
  return,  x[*,0]

END  
