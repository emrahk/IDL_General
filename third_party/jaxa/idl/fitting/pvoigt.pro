;+
; Project     : YOHKOH-BCS
;    
; Name        : PVOIGT
;
; Purpose     : Compute voigt function with partial derivatives
;
; Explanation : Calculates the Voigt function after  Humlicek (1982) 
;               JQSRT 27,437. Derivatives are from Humlicek (1979) 
;               JQSRT 21, 309. This method is fast and VERY accurate.
;
; Category    : fitting
;
; Syntax      : pvoigt,a,v,h,f
;
; Inputs      : a = damping parameter
;               v = frequency vector
;
; Outputs     : h=H(a,v)
;               f=2F(a,v)
;
;               dH(a,v)/dv = 2.0(af-vh) 
;               dH(a,v)/da = 2.0(ah+vf-.56418958)
;
;               d2 H(a,v)/d2v = 4[(v^2-a^2)h - 2avf - h/2 + a*0.56418958]
;
;
;               d(2F)/dv = -2.0(ah+vf-.5641896) (Cauchy-Riemann equation)
;
;               d2 (2F(a,v))/d2v = -4[(a^2-v^2)f - 2avh + f/2 +v*0.56418958]
;
;               where .5641896 is 1/sqrt(pi)
;
; Opt Outputs : None
;
; Keywords    : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  17-July-1993,  D M Zarro.  Written
;               Modified from T.R Metcalf (IAH)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
 
  pro pvoigt, a, v, h, f

  check = check_math(1,1)   ; turn off math errors to avoid underflow reports

  sizev = size(v)

  if sizev(0) GT 1 then begin
     print,'ERROR: voigt: v has too many dimensions: scalar or vector only'
     return
  endif

  t = complex(float(a),float(-v))
  w1 = complexarr(sizev(n_elements(sizev)-1))
  u = t*t
  absv = abs(v)
  s = absv+abs(a)
  s2 = 0.195*absv-0.176

  region1 = where(s GE 15)
  region2 = where(s GE 5.5 and s LT 15)
  region3 = where(s LT 5.5 and abs(a) GE s2) 
  region4 = where(s LT 5.5 and abs(a) LT s2)
 
  ;if region1(0) GE 0 then print,'region1: ',n_elements(region1)
  ;if region2(0) GE 0 then print,'region2: ',n_elements(region2)
  ;if region3(0) GE 0 then print,'region3: ',n_elements(region3)
  ;if region4(0) GE 0 then print,'region4: ',n_elements(region4)

; Region 1

  if region1(0) GE 0 then $
     w1(region1) = t(region1)*(1.4104739589+u(region1)* $
                   0.56418958355)/(0.74999999999+u(region1)*(3.0+u(region1)))

; Region 2

  if region2(0) GE 0 then $
     w1(region2) = t(region2)*(4.6545640642+u(region2)*(3.9493270848+u(region2)*0.56418958355)) / $
                   (1.8750000000+u(region2)*(11.250000000+u(region2)*(7.5000000000+u(region2))))

; Region 3

  if region3(0) GE 0 then $
     w1(region3) = (179.0714766+t(region3)*(289.4827444+t(region3)*(231.1440618+t(region3)*(111.5306766+t(region3)*(34.03818681+t(region3)*(6.269921295+t(region3)*0.5641900381)))))) / $
     (179.0714766+t(region3)*(491.5434301+t(region3)*(606.7189137+t(region3)*(439.3066119+t(region3)*(203.2455046+t(region3)*(60.83060715+t(region3)*(11.11317476+t(region3))))))))

; Region 4

  if region4(0) GE 0 then $
     w1(region4) =  (exp(u(region4))-t(region4)*(36183.30536-u(region4)*(3321.990492-u(region4)*(1540.786893-u(region4)*(219.0312964-u(region4)*(35.76682780-u(region4)*(1.320521697-u(region4)*0.5641900381)))))) / $
       (32066.59372-u(region4)*(24322.84021-u(region4)*(9022.227659-u(region4)*(2186.181081-u(region4)*(364.2190727-u(region4)*(61.57036588-u(region4)*(1.841438936-u(region4)))))))))

  check = check_math(0,0)   ; turn on math errors and check if any occurred
  if (check NE 0) and (check NE 32) then begin
    if (check and 1) GT 0 then $
       print,'WARNING: math error in voigt.pro: Integer divide by zero'
    if (check and 2) GT 0 then $
       print,'WARNING: math error in voigt.pro: Integer overflow'
    if (check and 16) GT 0 then $
       print,'WARNING: math error in voigt.pro: Floating point divide by zero'
    ; skip 32 since that is the underflow we are trying to avoid
    if (check and 64) GT 0 then $
       print,'WARNING: math error in voigt.pro: Floating point overflow'
    if (check and 128) GT 0 then $
       print,'WARNING: math error in voigt.pro: Floating point operand error'
  endif

  h = float(w1)      ; The real part
  f = imaginary(w1)

  if (sizev(0) EQ 0) then begin    ; v is a scalar in this case - not an array
    h=h(0)  ; Return a scalar not an array in this case
    f=f(0)
  endif

end
