PRO VIS_FWDFIT_PARMRANGE, srcstr, xyrange, prange, stepsize, _EXTRA=_extra
;+
; Given an array of source structures, calculates parameter range and initial stepsize arrays for use by amoeba_c
;
; 6-Nov-05 gh	Initial version, equivalent to previously embedded code
; 13-Nov-05 gh	Adapt to revised interpretation of srcomp.srcx and .srcy
;  9-Dec-05 gh	Adapt to revised source structure and srcparm format.
; 26-Aug-09 ejs Implemented inheritance with _EXTRA to eneable prange control from outside
; 30-Oct-13 A.M.Massone   Removed hsi dependencies
; 24-nov-13 ras changing range of eccentricity for ellipse
;-

nsrc 	= N_ELEMENTS(srcstr)
temp 	= FLTARR(nsrc*10,3)
;
FOR n=0, nsrc-1 DO BEGIN
	n10 = n*10
	temp[n10+1,*] 	= [  .01,  10.,  0.1] * srcstr[n].srcflux
	temp[n10+2,*] 	= [ -0.5,  0.5, 0.01] * xyrange     ; .01 is prev value
	temp[n10+3,*] 	= [ -0.5,  0.5, 0.01] * xyrange
	temp[n10+4,*] 	= [  0.5, 200.,   1.]
	temp[n10+5,*] 	= srcstr[n].srctype eq 'ellipse' ? [  0,  1.,   .05] :  [  -5.,  +5.,   1.] ;eccentricity
	temp[n10+6,*] 	= [  -5.,  +5.,   1.]
	temp[n10+7,*] 	= [-180., 180.,  20.]		; loop angle
	temp[n10+8,*]	= [   0.,  0.8,  0.1]		; albedo_ratio
	temp[n10+9,*]	= [   0.,  60.,   5.]		; source height
ENDFOR
prange 		= temp[*,0:1]
stepsize 	= temp[*,2]
RETURN
END


