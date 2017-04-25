;+
; Project: 
;	SDAC
;
; NAME: 
;	RESET_XY
;
; PURPOSE:
;	This procedure resets saved !x, !y, and !p values to enable active switching
;	and overplotting between graphics windows.
;
; CATEGORY:
;	GRAPHICS
;
; CALLING SEQUENCE:
;	RESET_XY, Winsav
;	
;	or
;
;	RESET_XY, Bang_x, Bang_y, P_clip
;
; CALLS:
;	DATATYPE
;
; INPUTS:
;	Winsav: a structure with tags {winsav, x:!x, y:!y, clip:!p.clip}
;
;	or
;
;       Bang_x: Saved !x 
;	Bang_y: Saved !y
;	P_clip: Saved !p.clip
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	The system variables controlling plotting are changed.
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	The values are used to construct a plot with /nodata to reset 
;	all the needed system variable elements.
;
; MODIFICATION HISTORY:
;	RAS, 12-april-1996
;	Version 2, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;-
Pro Reset_xy, Bang_x, Bang_y, P_clip


if datatype(bang_x) eq 'STC' then begin
	win = bang_x
	tags=tag_names(win)
	wx = where(tags eq 'X', nx)
	wy = where(tags eq 'Y', ny)
	wp = where(tags eq 'CLIP', nc)
	if nx eq 1 and ny eq 1 and nc eq 1 then $
	if datatype(win.x) eq 'STC' and datatype(win.y) eq 'STC' then $
	if tag_names(win.x,/str) eq '!AXIS' and tag_names(win.y,/str) eq '!AXIS' then $
	good = 1 else good = 0
	if not good then begin
		message,/cont, 'Invalid structure used, need {x:!x, y:!y, clip:!p.clip}'
		return
	endif	
	x = win.x
	y = win.y
	clip = win.clip
endif else begin
	x = bang_x
	y = bang_y
	clip = p_clip
endelse

position = [x.window(0),y.window(0), x.window(1),y.window(1)]
if y.type eq 1 then ycrange=10^y.crange else ycrange=y.crange
if x.type eq 1 then xcrange=10^x.crange else xcrange=x.crange
plot,xcrange,ycrange,/nodata,xstyle=5,ystyle=21,/noerase, $ 
    position=position,ytype=y.type,xtype=x.type
!p.clip=clip

end
