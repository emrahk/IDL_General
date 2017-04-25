;---------------------------------------------------------------------------
; Document name: nl_mrqmin.pro
; Created by:    Liyun Wang, NASA/GSFC, November 10, 1994
;
; Last Modified: Thu Jul 17 17:17:48 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       NL_MRQMIN
;
; PURPOSE: 
;       Internal routine called by NL_LSQFIT
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       NL_MRQMIN, x, y, sig, a, chisq, alamda, funcs=funcs [,covar=covar]
;
; INPUTS:
;       X   -- A matrix with M x N elements containing the observation points,
;              where M is the number of independent variables, and N is the
;              number of observing points.
;       Y   -- N element vector, value of the fitted function. 
;       SIG -- Measurement error (standard deviation, N elements); If the
;              measurement errors are not know, they can all be set to 1.
;       A   -- Fit parameter, M element vector, initial guessing. Will be
;              changed upon exit.
;       ALAMDA -- Fudge factor. On the first call, set it to be a negative
;                 value, it will then be changed to a small positive value. If
;                 a step succeeds, it decreases by a factor of 10; if a step
;                 fials, it grows by a factor of 10.
;       FUNCS -- Name of the user-supplied procedure that returns values of
;                the model function and its first derivative. Its calling
;                sequence must be:
;                     FUNCS, x0, a, ymod, dyda
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       CHISQ -- Value of the merit function
;       A     -- Fit parameters.
;
; OPTIONAL OUTPUTS:
;       COVAR -- Covariance matrix with M x M elements, used for calculating
;                the uncertainties.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       MRQCOF, GAUSSJ, COVSRT, DELVARX
;
; COMMON BLOCKS:
;       nl_mrqmin -- Internal common block used for saving some variables
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       ulitities, numerical recipes
;
; PREVIOUS HISTORY:
;       Written November 10, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 2, July 17, 1997, Liyun Wang, NASA/GSFC
;          Renamed from MRQMIN, which is used as a built-in routine in
;             IDL 5.0
;       
; VERSION:
;       Version 2, July 17, 1997
;-
;
PRO nl_mrqmin, x, y, sig, a, chisq, alamda, funcs=funcs, covar=covar
   ON_ERROR, 2
   IF N_PARAMS() NE 6 THEN MESSAGE, 'Require 6 parameters.'
;----------------------------------------------------------------------
;  Check size of input parameters
;----------------------------------------------------------------------
   COMMON nl_mrqmin, alpha, zeta, ochisq
   size_x = SIZE(x)
   IF size_x(0) NE 2 THEN MESSAGE, 'Input array must be 2 dimensional.'
   ma = N_ELEMENTS(a)
   IF alamda LT 0.0 THEN BEGIN
      alamda = 0.001
      IF N_ELEMENTS(alpha) EQ 0 THEN BEGIN
         alpha = fltarr(ma,ma)
      ENDIF ELSE BEGIN
         delvarx, alpha, zeta
         alpha = fltarr(ma,ma)
      ENDELSE
      mrqcof,x,y,sig,a,alpha,zeta,chisq,funcs=funcs
      ochisq = chisq
   ENDIF
   covar = alpha
   FOR j = 1, ma DO BEGIN
      covar(j-1,j-1) = alpha(j-1,j-1)*(1.0+alamda)
   ENDFOR
   da = zeta
   gaussj, covar, da, inverted = aaa, solution = bbb
   covar = aaa & da = bbb
   IF alamda EQ 0.0 THEN BEGIN
      ia = intarr(ma)
      ia(*) = 1
      covsrt, covar, ia, ma
      RETURN
   ENDIF
   atry = a+da
   mrqcof, x, y, sig, atry, covar, da, chisq, funcs=funcs
   IF chisq LT ochisq THEN BEGIN
      alamda = 0.1*alamda
      ochisq = chisq
      alpha = covar
      a = atry
      zeta = da
   ENDIF ELSE BEGIN
      alamda = 10.*alamda
      chisq = ochisq      
   ENDELSE
END

;---------------------------------------------------------------------------
; End of 'nl_mrqmin.pro'.
;---------------------------------------------------------------------------
