;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Document name: covsrt.pro
; Created by:    Liyun Wang, GSFC/ARC, November 10, 1994
;
; Last Modified: Sun Nov 13 21:14:39 1994 (lwang@orpheus.nascom.nasa.gov)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
PRO COVSRT, covar, ia, mfit
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       COVSRT
;
; PURPOSE: 
;       Repack the covariance matrix to the true order of the parameters
;
; EXPLANATION:
;       Given the covariance matrix COVAR of a fit for MFIT of MA total
;       parameters, and their ordering IA(i), repack the covariance matrix to
;       the true order of the parameters. Elements associated with fixed
;       parameters will be zero.
;
; CALLING SEQUENCE: 
;       COVSRT, covar, ia, mfit
;
; INPUTS:
;       COVAR -- 
;       IA    --
;       MFIT  --
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       COVAR -- 
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       None.
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
; CATEGORY:
;       
; PREVIOUS HISTORY:
;       Written November 10, 1994, by Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       
; VERSION:
;       Version 1, November 10, 1994
;-
;
   ON_ERROR, 2
   IF N_PARAMS() NE 3 THEN MESSAGE, 'Require 3 parameters.'
;----------------------------------------------------------------------
;  Get size of the matrix
;----------------------------------------------------------------------
   csize = SIZE(covar)
   IF csize(0) NE 2 OR csize(1) NE csize(2) THEN MESSAGE, $
      'Input array must be 2 dimensional square matrix.'
   ma = csize(1)
   IF N_ELEMENTS(ia) NE ma THEN MESSAGE, $
      'Invalid input vector.'
;----------------------------------------------------------------------
;  Zero all elements below diagonal
;----------------------------------------------------------------------
   FOR i = mfit, ma-1 DO BEGIN
      FOR j = 0, i-1 DO BEGIN
         covar(i,j) = 0.
         covar(j,i) = 0.
      ENDFOR
   ENDFOR
   k = mfit-1
   FOR j = ma-1, 0, -1 DO BEGIN
      IF ia(j) NE 0 THEN BEGIN
         FOR i = 0, ma-1 DO BEGIN
            swap = covar(i,k)
            covar(i,k) = covar(i,j)
            covar(i,j) = swap
         ENDFOR
         FOR i = 0, ma-1 DO BEGIN
            swap = covar(k,i)
            covar(k,i) = covar(j,i)
            covar(j,i) = swap
         ENDFOR
         k = k-1
      ENDIF
   ENDFOR
END
