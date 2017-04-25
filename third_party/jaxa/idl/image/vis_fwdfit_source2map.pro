PRO VIS_FWDFIT_SOURCE2MAP, srcstrin, xyoffset, data, $
	pixel=pixel, mapsize=mapsize, _EXTRA=extra
;+
; Uses PLOTMAN to display the image corresponding to the input vis_fwdfit source structure.
;
;  9-Dec-05		First working version displays circles only (ghurford@ssl.berkeley.edu)
; 12-Dec-05 gh	Add provision for loops.
; 13-Dec-05 gh	Add provision for ellipses.
; 15-Dec-05 gh	Improve strategy for avoiding exponential underflows.
; 07-mar-06 ejs Added _EXTRA keyword to facilitate inheritance of subroutine keywords
; 28-Mar-06 gh  Reimplemented fix for normalization bug which enhanced sources that extended beyond map boundaries
; 23-Nov-13 ras hsi_ stripped and base routine added to SSW
;
;-


checkvar, pixel, 0.5
checkvar, mapsize, 128

toofar		= 2.		; points more than toofar*FWHM will be set to zero
;
; Define the map and its axes.
data 		= FLTARR(mapsize,mapsize)
x 			= (FINDGEN(mapsize)-mapsize/2.+0.5)*pixel+ xyoffset[0]
y 			= (FINDGEN(mapsize)-mapsize/2.+0.5)*pixel+ xyoffset[1]
;
; Expand loops, if any, in input source structure
ok = WHERE(srcstrin.srctype NE 'loop', nok)
IF nok GT 0 THEN srcstr = srcstrin[ok]
iloop = WHERE(srcstrin.srctype EQ 'loop', nloop)
IF nloop GT 0 THEN BEGIN
	FOR i = 0, nloop-1 DO BEGIN
		strtemp = hsi_vis_fwdfit_makealoop(srcstrin[iloop[i]])
		IF N_ELEMENTS(srcstr) GT 0 THEN srcstr = [[srcstr, strtemp]] ELSE srcstr = strtemp
	ENDFOR
ENDIF
;
; Begin loop over source structure.
nsrc 		= N_ELEMENTS(srcstr)
FOR n = 0, nsrc-1 DO BEGIN
	fwhm 		= srcstr[n].srcfwhm
	fwhmeff2	= fwhm^2
    normfactor  = 4 * ALOG(2.) / !PI * srcstr[n].srcflux / fwhmeff2
	eccen		= srcstr[n].eccen
	srcpa		= srcstr[n].srcpa * !DTOR				; radians E of N
	b 			= fwhm * (1.-eccen^2)^0.25				; Useful if source is elliptical
; Loop over y coordinates
	FOR ny = 0, mapsize-1 DO BEGIN
		dy 		= srcstr[n].srcy- y[ny]
		dx 		= srcstr[n].srcx - x
		dr2 	= dx^2 + dy^2
		IF srcstr[n].srctype EQ 'ellipse' THEN BEGIN
			pa			= ATAN(dy,dx)								; radians W of N
			relpa		= pa - srcpa - !PI/2.						; angle 'pixel to source' and ellipse axis
			fwhmeff2	= b^2 / (1 - (eccen*COS(relpa))^2)	; nvis-element vector
		ENDIF
		term = 2.77259*dr2/fwhmeff2 < 20
		ok	= WHERE (term LT 20, nok)						; avoid exponential underflows.
		IF nok EQ 0 THEN CONTINUE
		dflux = EXP(-term[ok])
		data[ok,ny] = data[ok,ny] + dflux * normfactor		; add to one row for one source component
	ENDFOR
ENDFOR
;
; Map has been constructed, now display it.
IF MAX(data) EQ 0 THEN BEGIN
	MESSAGE, 'MAP IS ZERO-FILLED', /CONTINUE

    END

END


