;+
; Name: widget_offset
; Purpose: Determine position of a child widget so that it is near, but doesn't block
;	its parent.
;
; Calling sequence:  widget_offset, parent, xoffset, yoffset, newbase=newbase, $
;						newsize=newsize, vertical=vertical
;
; Input:
;	parent - widget id of parent
;	newbase - widget id of new widget that hasn't been realized yet (need this for size)
;	newsize - size of new widget.  NOTE: pass newbase OR newsize, not both
;	vertical - if set positions new widget above or below parent instead of beside
;
; Output:
;	xoffset, yoffset - offset from corner of screen of new widget.
;
; Method:
;	Call widget creation routines, but before realizing widget, call widget_offset,
;	 then call widget_control, newbase, xoffset=xoffset, yoffset=yoffset, then realize it.
;
; Written: Kim Tolbert, Mar 18, 2000
;
;-


pro widget_offset, parent, xoffset, yoffset, newbase=newbase, $
	newsize=newsize, vertical=vertical

xoffset = 0  &  yoffset = 0

if xalive (parent) then begin

	p = widget_info (parent, /geometry)

	if not (keyword_set(newbase) or keyword_set(newsize)) then begin
		xoffset = p.xoffset
		yoffset = p.yoffset
		return
	endif

	if keyword_set(newbase) then begin
		n = widget_info (newbase, /geometry)
		nxsize = n.xsize
		nysize = n.ysize
	endif else begin
		if keyword_set(newsize) then begin
			nxsize = newsize[0]
			nysize = newsize[1]
		endif
	endelse

	device, get_screen_size=scr

	if keyword_set(vertical) then begin
		ptop = p.yoffset
		pbottom = p.yoffset + p.ysize

		if (scr[1] - pbottom) gt .75 * nysize then begin
			newbottom = (pbottom + nysize ) < scr[1]
			newtop = newbottom - nysize
		endif else begin
			newtop = (ptop - nysize ) > 0.
		endelse

		xoffset = p.xoffset
		yoffset = newtop

	endif else begin

		pleft = p.xoffset
		pright = pleft + p.xsize

		if (scr[0] - pright) gt .75 * nxsize then begin
			newright = (pright + nxsize ) < scr[0]
			newleft = newright - nxsize
		endif else begin
			newleft = (pleft - nxsize ) > 0.
		endelse

		xoffset = newleft
		yoffset = p.yoffset + p.ysize / 2. - nysize / 2.

	endelse

endif

end