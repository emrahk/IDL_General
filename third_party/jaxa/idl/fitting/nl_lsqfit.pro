;----------------------------------------------------------------------
; Document name: nl_lsqfit.pro
; Created by:    Liyun Wang, NASA/GSFC, November 10, 1994
;
; Last Modified: Thu Jul 17 17:23:52 1997 (lwang@achilles.nascom.nasa.gov)
;----------------------------------------------------------------------
;
PRO NL_LSQFIT, x, y, sig, a, chisq, acc, funcs=funcs, std_err=std_err
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       NL_LSQFIT
;
; PURPOSE: 
;       Fit a user-supplied nonlinear function to two-dimensional data
;
; CALLING SEQUENCE: 
;       NL_LSQFIT, x, y, sig, a, chisq, funcs=funcs
;
; INPUTS:
;       X
;       SIG
;       A
;       IA
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       CHISQ
;       COVAR
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       FUNC
;       STD_ERR 
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; PREVIOUS HISTORY:
;       Written November 10, 1994, by Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 2, July 17, 1997, Liyun Wang, NASA/GSFC
;          Changed call from MRQMIN (which becomes a built-in function
;             in IDL 5.0) to NL_MRQMIN
;       
; VERSION:
;       Version 2, July 17, 1997
;-
;
   ON_ERROR, 2

;----------------------------------------------------------------------
;  Check to see if input parameters are valid
;----------------------------------------------------------------------
   size_x = SIZE(x)
   IF size_x(0) NE 2 THEN MESSAGE, 'Input matrix must be 2 dimensional.'
   mx = size_x(1)
   npt = size_x(2)
   IF size_x(2) NE N_ELEMENTS(y) THEN MESSAGE, $
      'NL_LSQFIT -- Incompatiable size of input parameters.'
   ma =  N_ELEMENTS(a) 
   alamda = -1.0
;----------------------------------------------------------------------
;  Now call NL_MRQMIN
;----------------------------------------------------------------------
   nl_mrqmin, x, y, sig, a, chisq, alamda, funcs=funcs
   itst = 0
   k = 1
   WHILE (itst LT 4) DO BEGIN
      ochisq=chisq
      nl_mrqmin, x, y, sig, a, chisq, alamda, funcs=funcs
      IF abs((ochisq-chisq) LT acc) THEN $
         itst = itst+1 $
      ELSE $
         itst = 0
   ENDWHILE
   alamda = 0.0
   nl_mrqmin, x, y, sig, a, chisq, alamda, funcs=funcs, covar = covar
   cor = npt-ma   
   cor = chisq/cor
   ii = INDGEN(3)
   std_err = STRING(SQRT(covar(ii,ii)*cor))
   RETURN
END

;----------------------------------------------------------------------
;    Testing part....
;----------------------------------------------------------------------
;    filename = '~/circle_yk.dat'
;    xx = fltarr(50) &  yy = xx
;    a = 0 &  b = 0
;    OPENR, unit, filename, /GET_LUN, error=rr
;    i = 0
;    WHILE (NOT EOF(unit)) DO BEGIN
;       READF, unit, a, b
;       xx(i) = FLOAT(a) & yy(i) = FLOAT(b) 
;       i =  i+1
;    ENDWHILE
;    PRINT, 'Total of ',num2str(i),' records read.'
;    CLOSE, unit &  FREE_LUN, unit
;    acc =  1.e-6
;    a = [271.0, 264.0, 200.0]
;    dtx = TRANSPOSE([[xx(0:i-1)],[yy(0:i-1)]])
;    sig = fltarr(i) & dty = sig
;    sig(*) = 1.0
;    dty(*) = 0.0
;    nl_lsqfit,dtx,dty,sig,a,chisq,acc,funcs = 'funcir'
; END

;----------------------------------------------------------------------
; End of 'nl_lsqfit.pro'.
;----------------------------------------------------------------------
