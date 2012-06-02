FUNCTION  cafe_model_dip, x, parameter, env=env,$
                  getparam=getparam, $
                  help=help,shorthelp=shorthelp

;+
; NAME:
;           model_dip
;
; PURPOSE:
;           Define dip model 
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
;           dip:E   - Ephemerides of dip.
;           dip:P   - Period of dip. Should not be zero.
;           dip:Pdot- Period change of dip. Default 0.
;           dip:width- Width of dip feature. Should be less than
;                      dip:P/2. Default 0.1.

;
; OUTPUT:
;           y = 1 - when exist N with k1 = E + P*N + 1/2*P*Pdot*N^2 - width/2
;                                     k2 = E + P*N + 1/2*P*Pdot*N^2 + width/2
;                   and x in [k1..k2]
;               0 - else
;           
;
; SIDE EFFECTS:
;           None
;
;
; HISTORY:
;           $Id: cafe_model_dip.pro,v 1.2 2003/04/25 16:36:08 goehler Exp $
;-
;
; $Log: cafe_model_dip.pro,v $
; Revision 1.2  2003/04/25 16:36:08  goehler
; fix: do quadratic dip times used invalid cycle computation
;
; Revision 1.1  2003/04/14 15:23:38  goehler
; dip model; for display use only
;
;
;
;

    name="model_dip"

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
      PRINT, "dip - dip fit model"
      RETURN, 0
  ENDIF

  ;; ------------------------------------------------------------
  ;; PARAMETER SETTING
  ;; ------------------------------------------------------------

  IF keyword_set(getparam)  THEN BEGIN 
      param=replicate({cafeparam},4) ;; 4 parameters as follow
      param.parname = ["dip:E",   $
                       "dip:P",   $
                       "dip:Pdot",$
                       "dip:Width"$
                      ]

      ;; set default period -> avoid division by zero:
      param[1].value = 1.D0
      param[3].value = 0.1D0

      return, param
  ENDIF

  ;; ------------------------------------------------------------
  ;; COMPUTE VALUE
  ;; ------------------------------------------------------------


  ;; 1.) get N = cycle number (simple/complex case)
  IF parameter[2] eq 0.D0 THEN N = round((x-parameter[0])/parameter[1]) $
  ELSE BEGIN
      N = round((- 1.D0  + sqrt(1.D0 - $
                                2.D0*parameter[2]/parameter[1]* $
                                (parameter[0]-x)))              $
                /parameter[2])
  ENDELSE 

  K = parameter[0] + parameter[1]*N + 0.5D0*parameter[1]*parameter[2]*N^2.D0

  ;; actual computation 
  return,  double(x GE K-parameter[3]/2.D0  AND x LE K+parameter[3]/2.D0)

END  

