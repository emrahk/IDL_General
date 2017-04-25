
;+
; NAME
;
;    GAUSS_SG
;
; EXPLANATION
;
;    Defines a Gaussian to be used when performing
;    Gaussian fits with the SPEC_GAUSS suite of IDL routines.
;
;    The format is that required by the MPFIT routines.
;
; INPUTS
;
;    X   The points at which the function is evaluated. Typically these
;        will be wavelength values.
;
;    P   A three element array that describes the Gaussian. P[0] is the
;        peak of the Gaussian, P[1] is the centroid, and P[2] is the
;        Gaussian width.
;
; OPTIONAL INPUTS
;
;    PEAK_FACTOR  If set, then the line peak parameter will be
;                 multiplied by PEAK_FACTOR.
;
;    CEN_OFFSET   If set, then the line centroid will be offset by
;                 CEN_OFFSET. 
;
; OUTPUT
;
;    The values of the Gaussian defined by P at the input values X.
;
; HISTORY
;
;    Ver.1, Peter Young, 5-Aug-2005
;    Ver.2, Peter Young, 29-Jul-2010
;      added cen_offset and peak_factor keywords
;-

FUNCTION gauss_sg, x, p, _EXTRA=extra, cen_offset=cen_offset, peak_factor=peak_factor
;
; this is needed by mpfitexpr
;
IF n_elements(peak_factor) EQ 0 THEN peak_factor=1.0
IF n_elements(cen_offset) EQ 0 THEN cen_offset=0.0

z=( (x-(p[1]+cen_offset) )/abs(p[2]) )^2
f=p[0] * peak_factor * exp(-0.5*temporary(z))
return,f

END
