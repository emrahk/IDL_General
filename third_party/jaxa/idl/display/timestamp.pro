;+
;
; NAME: TIMESTAMP
;
;
; PURPOSE: Place the current time outside the upper right-hand corner
;	of the plot window or at very bottom of entire window
;
;
; CATEGORY: Util,Gen, Graphics
;
;
; CALLING SEQUENCE: TIMESTAMP
;
;
; CALLED BY:
;
;
; CALLS:
;	FCOLOR
;
; INPUTS:
;       none
;
; OPTIONAL INPUTS:
;  bottom - place timestamp in bottom right corner
;	XYOUTS KEYWORDS-
;	CHARSIZE
;	CHARTHICK
;	COLOR
;
; OUTPUTS:
;       none
;
; OPTIONAL OUTPUTS:
;	none
;
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	ras, 24-jan-96
;	ras, version 2, 13-dec-1996, added keywords charsize, charthick, and color
;	ras, version 3, 24-dec-1996, fixed bug in charsize
;   kim, 27-sep-2000, added bottom option
;   kim, 18-may-2010, color wasn't being passed on bottom option
;
;-


pro TIMESTAMP, dummy, charsize=charsize, charthick=charthick, color=color, bottom=bottom

time = strmid(anytim(!stime, /vms),0,17)

if keyword_set(bottom) then begin
	xyouts, 1., .01, time+' ', charsize=fcheck(charsize,1), /norm, align=1., color=fcolor(color)
endif else begin
	xw = !x.window
	xyouts,/norm, xw(1)+.01*(xw(1)-xw(0)), $
		!y.window(1), time, orientation=-90,$
		charsize=fcheck(charsize,1), charthick=fcheck(charthick,1), color=fcolor(color)
endelse

end
