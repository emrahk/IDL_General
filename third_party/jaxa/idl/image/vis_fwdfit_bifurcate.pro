FUNCTION VIS_FWDFIT_BIFURCATE, srcstr0
;
; Returns a modified fwdfit source structure based on bifurcation of input source structure.
;
;  8-Nov-05 	Original version (ghurford@ssl.berkeley.edu)
; 20-Nov-05 gh	Fix bug which reflected source positions about NS axis.
;  0-Dec-05 gh	Adapt to revised source structure array format
;  30-Oct-13 A.M.Massone   Removed hsi dependencies 
;
IF N_ELEMENTS(srcstr0) NE 1 THEN MESSAGE, 'Multielement source input is not yet permitted.'
IF srcstr0.srctype NE 'ellipse' THEN MESSAGE, ' Input should be an ellipse'
;
; Determine the size and separation of the separated components.
fwhmminor		= srcstr0.srcfwhm * (1-srcstr0.eccen^2)^0.25
fwhmmajor		= srcstr0.srcfwhm / (1-srcstr0.eccen^2)^0.25
halfsep 		= SQRT((fwhmmajor)^2 - fwhmminor^2) / 2.345
pasep 			= srcstr0.srcpa * !DTOR							; +ve E of N !!
;
; Modified source structure has 2 equal, circular sources which reproducing 0th, 1st and 2nd moments.
pm				= [-1,1]
srcstr 			= REPLICATE(srcstr0,2)						; Create a 2-element structure array
srcstr.srctype	= 'circle'
srcstr.srcflux 	= srcstr0.srcflux / 2.						; Split the flux between components.
srcstr.srcx		= srcstr.srcx - pm * halfsep*SIN(pasep)		; place new components symmetrically about the original
srcstr.srcy		= srcstr.srcy + pm * halfsep*COS(pasep)
srcstr.srcfwhm 	= fwhmminor									; Reproduces moment orthogonal to separation
srcstr.eccen	= 0											; Circular sources
srcstr.srcpa	= 0
RETURN, srcstr
END