FUNCTION  BIWEIGHT_MEAN,Y,SIGMA, WEIGHTs
;
;+
; NAME:
;	BIWEIGHT_MEAN 
;
; PURPOSE:
;	Calculate the center and dispersion (like mean and sigma) of a 
;	distribution using bisquare weighting.
;
; CALLING SEQUENCE:
;	Mean = BIWEIGHT_MEAN( Vector, [ Sigma, Weights ] ) 
;
; INPUTS:
;	Vector = Distribution in vector form
;
; OUTPUT:
;	Mean - The location of the center.
;
; OPTIONAL OUTPUT ARGUMENTS:
;
;	Sigma = An outlier-resistant measure of the dispersion about the 
;	      center, analogous to the standard deviation. The half-width of the 
;             95% confidence interval = |T_CVF( .95, .7*(N-1) )*SIGMA/SQRT(N)|,
;	      where N = number of points.  
;
;	Weights = The weights applied to the data in the last iteration, 
;                 floating point vector
;
; PROCEDURES USED:
;       ROBUST_SIGMA()
; REVISION HISTORY
;	Written,  H. Freudenreich, STX, 12/89
;	Modified 2/94, H.T.F.: use a biweighted standard deviation rather than
;		median absolute deviation.
;	Modified 2/94, H.T.F.: use the fractional change in SIGMA as the 
;		convergence criterion rather than the change in center/SIGMA.
;       Modified May 2002  Use MEDIAN(/EVEN)
;       Modified October 2002, Faster computation of weights 
;-

  ON_ERROR,2
  maxit = 20 ; Allow 20 iterations, this should nearly always be sufficient
  eps = 1.0e-24

  n = n_elements(y)
  close_enough =.03*sqrt(.5/(n-1)) ; compare to fractional change in width

  diff = 1.0e30
  itnum = 0

; As an initial estimate of the center, use the median:
  y0=median(y,/even)

; Calculate the weights:
  dev = y-y0
  sigma = robust_sigma( dev ) 

  if sigma lt EPS then begin
;    The median is IT. Do we need the weights?
     if arg_present(weights)  then begin
;       Flag any value away from the median:
        limit=3.*sigma
        weights = float(abs(dev) LE limit)
     endif
     diff = 0. ; (skip rest of routine)
  endif

; Repeat:
  while( (diff gt close_enough) and (itnum lt maxit) )do begin
    itnum = itnum + 1
    uu = ( (y-y0)/(6.*sigma) )^2
    uu = uu < 1.
    weights=(1.-uu)^2       & weights=weights/total(weights)
    y0 = total( weights*y ) 
    dev = y-y0
    prev_sigma = sigma      & sigma = robust_sigma( dev,/zero )
    if sigma gt eps then diff=abs(prev_sigma-sigma)/prev_sigma else diff=0.
  endwhile

return,y0
end
