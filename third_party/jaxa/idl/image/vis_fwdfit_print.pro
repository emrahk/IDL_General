PRO VIS_FWDFIT_PRINT, srcstr, COMPACT=compact, _EXTRA=_extra
;
; Generates a printed display of source parameters in source structure, srcstr.
;  visin is the input visibility structure with map center offsets
;
; /COMPACT uses a compact format, with no titles or spaces
;
;  7-Nov-05		First version (ghurford@ssl.berkeley.edu)
;  8-Nov-05 gh	Minor correction to output
; 13-Nov-05 gh	Adapt to srctype tag in source component structure
;				Adapt to revised origin of srcstr.xyoffset
; 14-Nov-05 gh	Add COMPACT keyword
; 20-Nov-05 gh	Minor change to output format.
;  9-Dec-05 gh	Add loop angle to display.
; 14-Dec-05 gh	Change labelling to Loop_FWHM to reflect revised interpretation.
; 16-Jan-06 gh  Add provision for albedo.
; 30-Oct-13 A.M.Massone   Removed hsi dependencies
;
IF KEYWORD_SET(compact) EQ 0 THEN BEGIN
	PRINT
	PRINT, 'COMPONENT  PROFILE      FLUX     X(+ve W)  Y(+ve N)   <FWHM>  Eccentricity  PosnAngle   Loop_FWHM AlbedoRatio   SrcHeight'
	PRINT, '                      ph/cm2/s    arcsec    arcsec    arcsec                deg EofN     degrees                    Mm'
	PRINT
ENDIF
nsrc = N_ELEMENTS(srcstr)
FOR n = 0, nsrc-1 DO BEGIN
	temp      	= [	srcstr[n].srcflux, 	srcstr[n].srcx,  srcstr[n].srcy, 	$
					srcstr[n].srcfwhm, 	srcstr[n].eccen, srcstr[n].srcpa, srcstr[n].loop_angle, $
					srcstr[n].albedo_ratio, srcstr[n].srcheight]
	PRINT, n+1, srcstr[n].srctype, temp, FORMAT="(I5, A13, F12.2, 4F10.2, 2F12.1, F12.3, F12.1)"
ENDFOR
IF KEYWORD_SET(compact) EQ 0 THEN PRINT
RETURN
END
