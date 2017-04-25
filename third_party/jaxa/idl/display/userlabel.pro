;+
;
; NAME: USERLABEL
;
;
; PURPOSE: Place a user-specified string to the right
;	of the plot window or at very bottom of entire window
;
;
; CATEGORY: Util,Gen, Graphics
;
;
; CALLING SEQUENCE: userlabel, text
;
;
; CALLED BY:
;
;
; CALLS:
;	FCOLOR
;
; INPUTS:
;       text - string to use for label
;
; OPTIONAL INPUTS:
;  bottom - If set, place timestamp in bottom right corner.  Otherwise
;    text is placed on right side of plot oriented
;  maxlen - If text is longer than maxlen, it will be cut off (if that
;    was necessary, last two chars will be .. to show it was cut off)
;    Default is 70 chars.
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
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;   kim, 20-Feb-2002, copied from timelabel
;   5-Apr-2004, changed -90 to +90 orientation
;   9-May-2007, Kim.  added maxlen keyword
;   9-May-2008, Kim.  If doing a multi plot (!p.multi), figure out which we're on, and
;     put label next to that plot.  Otherwise, yval=.5
;   8-Mar-2015, Kim. For bottom-0, make xval depend on size of chars, Change () to [].
;
;-


pro userlabel, text, maxlen=maxlen, charsize=charsize, charthick=charthick, color=color, bottom=bottom

if text eq '' then return

checkvar, maxlen, 70
checkvar, charsize, 1.

if strlen(text) gt maxlen then text = strmid(text, 0, maxlen-2) + '..'

if keyword_set(bottom) then begin
	xyouts, 0., .01, text, charsize=charsize, /norm, align=0.
endif else begin
	xw = !x.window
	if total(!p.multi) le 0 then yval = .5 else begin
	  n = !p.multi[2]
	  i = n - !p.multi[0] -1
	  yval = 1. - (i+.5)/n
	endelse
	xval = xw[1]+.025*(xw[1]-xw[0]) + (charsize-1.)/50.
	xyouts,/norm, xval, yval, text, orientation=90, align=.5, $
		charsize=ch_scale(/xyouts,charsize), charthick=fcheck(charthick,1), color=fcolor(color)
endelse

end
