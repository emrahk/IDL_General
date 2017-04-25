;+
; Project     :	STEREO - COR1
;
; Name        :	SYNDYNE
;
; Purpose     :	Calculate comet syndyne (or synchrone) curves.
;
; Category    :	Analysis, orbit
;
; Explanation : Applies the equations of Finson and Probstein (1968),
;               Ap.J. 154, 327-352 to calculate the syndyne (or synchrone)
;               curves for a comet tail based on the ratio of radiation
;               pressure to gravity.
;
; Syntax      :	SYNDYNE, QC, TC, TAU, BETA, RD, THETAD
;
; Examples    :	TAU = 3600 * findgen(100)       ;Up to 100 hours earlier
;               QC = 1.5 * 6.955508d5           ;Perihelion 1.5 solar radii
;               TC = -3600                      ;One hour before perihelion
;               SYNDYNE, QC, TC, TAU, 0.5, RD, THETAD
;
; Inputs      :	QC      = The perihelion distance, in kilometers
;
;               TC      = The observation time in seconds past perihelion.  Use
;                         negative values before perihelion.
;
;               TAU     = An array of release times prior to TC.  Must be
;                         positive.
;
;               BETA    = Ratio of radiation pressure to gravity.  Must be
;                         greater than 0 and less than 1.
;
;               Alternatively, this routine can be used to calculate synchrone
;               curves by passing in a single value of TAU, and an array of
;               BETA values.
;
;               It's also possible to pass in both TAU and BETA as arrays, so
;               long as both arrays have the same number of values.  This way,
;               one can pass in a grid of TAU,BETA points to test.
;
; Opt. Inputs :	None.
;
; Outputs     :	RD      = Radial distance of comet tail in kilometers from Sun
;                         center.
;
;               THETAD  = Angular position of comet tail in radians, relative
;                         to perihelion position of comet.
;
; Opt. Outputs:	None.
;
; Keywords    :	ACCURACY = The accuracy used for the reiterative solution of
;                          the F function.  The default is 1e-6.
;
;               MAX_ITER = The maximum number of iterations used when solving
;                          for the F function.  The default is 10000.
;
;               GMSUN    = The product of the universal gravitational constant
;                          with the solar mass, G * Msun.  The default value is
;                          1.32712440018D11 in units of km^3/sec^2.
;
; Calls       :	SIGN
;
; Common      :	None.
;
; Restrictions:	Distance units are forced to be in kilometers, and time units
;               in seconds, by the embedded quantity G*Msun.  However, this can
;               be overridden with the GMSUN keyword.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 25-Jun-2008, William Thompson, GSFC
;               Version 2, 13-Sep-2011, WTT, better GMSUN value
;
; Contact     :	WTHOMPSON
;-
;
pro syndyne, qc, tc, tau, beta, rd, thetad, accuracy=accuracy, $
             max_iter=max_iter, gmsun=k_gmsun
;
gmsun = 1.32712440018D11        ;G * Msun, km^3/sec^2
if n_elements(k_gmsun) eq 1 then gmsun = k_gmsun
mu = 1 - beta
;
;  Calculate the R,Theta coordinate of the comet at the times TC-TAU.
;
t = tc - tau
g1 = 1.5d0 * sqrt(gmsun/(2*qc^3)) * t
g2 = sqrt(g1^2 + 1)
z = (g1+g2)^(1/3.) - (g2-g1)^(1/3.)
rc = qc*(1+z^2)
thetac = 2*atan(z)
;
;  Calculate the hyperbolic parameters ED, AD for the dust particles.
;
ed = sqrt(1 + 4*beta*qc / (mu^2*rc))
ad = - mu*rc / (2*beta)
;
;  Calculate the parameter ALPHAD, taking into account the correct quadrant.
;  The instructions on which quadrant to use in Finson and Probstein appear to
;  be reversed.
;
val = asin(sin(thetac)/(mu*ed))
w = where((mu*rc / (2*qc)) gt 1, count)
if count gt 0 then val[w] = sign(replicate(!dpi,count),val[w]) - val[w]
alphad = thetac - val
;
;  Calculate the perihelion time for the dust particles.
;
xx = sqrt((ed-1)/(ed+1)) * tan((thetac-alphad)/2)
f0 = alog((1+xx) / (1-xx))
t0d = t - sqrt(-ad^3/(mu*gmsun)) * (ed*sinh(f0) - f0)
;
;  Reiteratively solve the transcendental equation for F(t).
;
deltat = sqrt(-mu*gmsun/ad^3) * (tc-t0d)
f = deltat
error = ed * sinh(f) - f - deltat
max_error = max(abs(error))
lambda = replicate(10.d0, n_elements(f))
n_iter = 1L
if n_elements(accuracy) eq 1 then acc = accuracy else acc = 1e-6
if n_elements(max_iter) eq 1 then n_iter_max = max_iter else n_iter_max = 10000
while (max_error gt acc) and (n_iter lt n_iter_max) do begin
    n_iter = n_iter + 1
    fnew = f - error / (1 + lambda)
    error_new = ed * sinh(fnew) - fnew - deltat
    test_sign = error * error_new
    w = where(abs(error_new) le abs(error), count, complement=wbad, $
              ncomplement=nbad)
    if count gt 0 then begin
        f[w] = fnew[w]
        error[w] = error_new[w]
        lambda[w] = (lambda[w] / 10) > 0.1
    endif
    if nbad gt 0 then lambda[wbad] = lambda[wbad] * 10
;
;  Reset lambda for any points where the error has changed sign.
;
    w = where(test_sign lt 0, count)
    if count gt 0 then lambda[w] = (lambda[w] > 1) * 100
    max_error = max(abs(error))
endwhile
;
;  Calculate the R,Theta parameters for the dust particles.
;
rd = -ad * (ed * cosh(f) - 1)
thetad = 2*atan(sqrt((ed+1)/(ed-1)) * tanh(f/2)) + alphad
;
end
