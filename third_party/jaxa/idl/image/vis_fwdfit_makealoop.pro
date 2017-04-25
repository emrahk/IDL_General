FUNCTION VIS_FWDFIT_MAKEALOOP, ellstr, LOOPPARM=loopparm
; Returns a modified fwdfit source structure that approximates a loop by a set of equispaced
;    circular gaussians.
;
; Input is a single structure for an elliptical source.
; The output array of source structures has ncirc circular sources equally-spaced along an arc
;     with a binomial flux distribtion.
; The set of circular sources reproduce the 0th, 1st and 2nd moments of the input elliptical gaussian.
;
; Note that ellstr.loop_angle (degrees) is interpreted as FWHM along arc which is externally constrained to 180 deg.
; Internally, loopangle (radians) is the total length of the arc.
;
; 8-Dec-05      First working version (ghurford@ssl.berkeley.edu)
; 12-Dec-05 gh  Fix position angle bug
; 14-Dec-05 gh  Change interpretation of loopangle from end-to-end to FWHM
;               Ignore calculation of curvature-induced centroid shift.
; 15-Dec-05 gh  Set minimum value of circfwhm=1arcsec to avoid display problems.
; 21-Dec-05 gh  Changes to enable -ve loop_angle values to correspond to opposite loop curvature
;               Modification to handle case of inconsistent sigmajor, sigminor and loopangle without generating a math error.
; 05-Jan-06 gh  Add LOOPPARM keyword
; 16-Jan-06 gh
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
IF (N_ELEMENTS(ellstr) NE 1 OR (ellstr.srctype NE 'ellipse' AND ellstr.srctype NE 'loop')) THEN $
                        MESSAGE, 'Source structure input must be a single ellipse or loop.'
ncirc0      = 21     ; Upper limit to number of ~equispaced circles that will be used to approximate loop.
PLUSMINUS   = [-1,1]
SIG2FWHM    = SQRT(8 * ALOG(2.))     ; = 2.35482,,,
;
; Calculate the relative strengths of the sources to reproduce a gaussian and their collective stddev.
iseq0       = INDGEN(ncirc0)
relflux0    = FLTARR(ncirc0)
relflux0    = FACTORIAL(ncirc0-1) / (FLOAT(FACTORIAL(iseq0)*FACTORIAL(ncirc0-1-iseq0))) / 2.^(ncirc0-1) ; TOTAL(relflux)=1
ok          = WHERE(relflux0 GT 0.01, ncirc)      ; Just keep circles that contain at least 1% of flux
relflux     = relflux0[ok] / TOTAL(relflux0[ok])
iseq        = INDGEN(ncirc)
reltheta    = (iseq/(ncirc-1.) - 0.5)          ; locations of circles for arclength=1
factor      = SQRT(TOTAL(reltheta^2 *relflux)) * SIG2FWHM   ; FWHM of binomial distribution for arclength=1
loopangle   = ellstr.loop_angle * !DTOR / factor ; length of loop (radians) that gives fwhm = ellstr.loop_angle
IF ABS(loopangle) GT 1.99*!PI THEN MESSAGE, 'Internal parameterization error - Loop arc exceeds 2pi.'
IF loopangle EQ 0 THEN loopangle = 0.01          ; radians. Avoids problems if loopangle = 0
theta       = ABS(loopangle) * (iseq/(ncirc-1.) - 0.5)      ; equispaced between +- loopangle/2
xloop       = SIN(theta)                  ; for unit radius of curvature, R
yloop       = COS(theta)                  ; relaive to center of curvature
IF loopangle LT 0 THEN yloop = -yloop          ; Sign of loopangle determines sense of loop curvature
;
; Determine the size and location of the equivalent separated components in a coord system where...
; x is an axis parallel to the line joining the footpoints
; Note that there are combinations of loop angle, sigminor and sigmajor that cannot occur with radius>1arcsec.
;   In such a case circle radius is set to 1.  Such cases will lead to bad solutions and be flagged as such at the end.
sigminor    = ellstr.srcfwhm * (1-ellstr.eccen^2)^0.25 / SIG2FWHM
sigmajor    = ellstr.srcfwhm / (1-ellstr.eccen^2)^0.25 / SIG2FWHM
fsumx2   = TOTAL(xloop^2*relflux)         ; scale-free factors describing loop moments for endpoint separation=1
fsumy     = TOTAL(yloop*relflux)
fsumy2   = TOTAL(yloop^2*relflux)
loopradius  = SQRT((sigmajor^2 - sigminor^2) / (fsumx2 - fsumy2 + fsumy^2))
term      = (sigmajor^2 - loopradius^2 *fsumx2) > 0    ; >0 condition avoids problems in next step.
circfwhm    = SIG2FWHM * SQRT(term) > 1              ; Set minimum to avoid display problems

sep        = 2.*loopradius * ABS(SIN(theta[0]))
cgshift     = loopradius * fsumy               ; will enable emission centroid location to be unchanged
relx      = xloop * loopradius               ; x is axis joining 'footpoints'
rely      = yloop * loopradius - cgshift
;
; Calculate source structures for each circle.
pasep          = ellstr.srcpa*!DTOR             ; position angle of line joining arc endpoints
srcstrout        = REPLICATE(ellstr,ncirc)                 ; Create an ncirc-element structure array
srcstrout.srctype   = 'circle'
srcstrout.srcflux   = ellstr.srcflux * relflux                ; Split the flux between components.
srcstrout.srcx   = ellstr.srcx - relx* SIN(pasep) + rely* COS(pasep)
srcstrout.srcy   = ellstr.srcy + relx* COS(pasep) + rely* SIN(pasep)
srcstrout.srcfwhm   = circfwhm                          ; Reproduces moment orthogonal to separation
srcstrout.eccen     = 0                                  ; Circular sources
srcstrout.srcpa     = 0
xav = TOTAL(srcstrout.srcx*srcstrout.srcflux) / TOTAL(srcstrout.srcflux)
yav = TOTAL(srcstrout.srcy*srcstrout.srcflux) / TOTAL(srcstrout.srcflux)
;IF (ABS(xav - ellstr.srcx) > ABS(yav - ellstr.srcy)) GT 0.2 THEN STOP
loopparm=[LOOPRADIUS*ELLSTR.LOOP_angle*!DTOR, circfwhm]
RETURN, srcstrout
END