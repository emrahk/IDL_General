PRO VIS_FWDFIT_SHOWMAP, srcstrin, mapcenter, TIME=time, ID=id, PLOTMAP=plotmap,$
	pixel=pixel, mapsize = mapsize,_EXTRA=extra
;+
;
; Uses PLOTMAN to display the image corresponding to the input vis_fwdfit source structure.
;
;  9-Dec-05		First working version displays circles only (ghurford@ssl.berkeley.edu)
; 12-Dec-05 gh	Add provision for loops.
; 13-Dec-05 gh	Add provision for ellipses.
; 15-Dec-05 gh	Improve strategy for avoiding exponential underflows.
; 01-mar-06 ejs Added time, id (string) keywords to add flare time to map (default uses
;                   current time) The time & id is now entered into plotman's title.
; 07-mar-06 ejs Added PLOT_MAP keyword to use plot_map instead of the default plotman for the display.
; 07-mar-06 ejs Added _EXTRA keyword to facilitate inheritance of subroutine keywords
; 28-Mar-06 gh  Reimplemented fix for normalization bug which enhanced sources that extended beyond map boundaries
;               Changed PLOT_MAP keyword to PLOTMAP to avoid ssw conflict.
; 23-May-06 ras Broke routine into source2map and mapping functions
; 30-Oct-13 A.M.Massone   Removed hsi dependencies 
;-
default,TIME,systime(0)
default,ID,''
default,plot_map,0

checkvar, pixel, 0.5
checkvar, mapsize, 128

VIS_SOURCE2MAP, srcstrin, mapcenter, data,pixel=pixel, mapsize = mapsize,_EXTRA=extra

; Map has been constructed, now display it.
IF MAX(data) EQ 0 THEN BEGIN
	MESSAGE, 'MAP IS ZERO-FILLED', /CONTINUE
	RETURN
    END
map     = MAKE_MAP(data, xc=mapcenter[0], yc=mapcenter[1], dx=pixel, dy=pixel, TIME=time,ID=id)
time1   = ANYTIM(time,/ECS) + ' ' + id
IF KEYWORD_SET(plotmap) THEN BEGIN
    plot_map,map,/limb,title=time1,_EXTRA=extra
ENDIF ELSE p = obj_new('plotman', input=map, plot_type='image', COLORTABLE=39, TITLE=time1)
RETURN
END


