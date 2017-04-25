pro xyouts2, x00, y00, str, size=size0, orientation=orientation0, $
			alignment=alignment0, device=device, color=color0, $
			charsize=charsize0, charthick=charthick0, font=font0
;+
;NAME:
;  xyouts2
;PURPOSE:
;  Wrapper for xyouts -- use pseudo pixel coordinates when writing to PostScript file.
;  Must "set up" the coordinates with a previous call to tv2,/init,xsize,ysize first.
;
;  If !d.name is not set to 'PS', the xyouts2 simply calls xyouts,/device
;
;CALLING SEQUENCE:
;  xyouts2, x0, y0, str
;
;INPUTS:
;  x0		- In PostScript mode, this the xvalue in pseudo pixel space
;  y0   	- In PostScript mode, this the yvalue in pseudo pixel space
;  str		- The string to write;
;OPTIONAL INPUT KEYWORDS:
;  size		- The size of the text  (default = 1.0)
;  charsize 	- Same as size.  If both size and charsize are present, size orrides.
;  charthick	- Thickness of the text (default = 1.0)
;  orientation	- Desired angle in degress counter-clockwise.
;  alignment	- 0 for left-justified, 0.5 for centered, 1.0 for right-justified.
;  font		- 0 for hardware fonts or -1 for vector drawn fonts.
;  color	- Color of the text.
;  device	- /device does not mean anything 
;			- xyouts2 units are always in window pixel device units
;
;  /norm and /data switches are not allowed.  In that case, simply call xyouts.
;METHOD:
; xyouts2 requires the PostScript plotting size to be set by a previous call
; to tv2.  The necessary information is stored in the named common block: tv2_blk.
;
; See also the following routines:    tv2, ocontour, draw_grid (sxt_grid), plots2
;
;HISTORY:
;  25-apr-1995, M. D. Morrison (LPARL), Written
;  19-jan-1996, J. R. Lemen (LPARL), Added document header and various keywords.
;  18-Dec-2002, William Thompson, GSFC, Changed !COLOR to !P.COLOR
;-

common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch
;
if (n_elements(x00) eq 0) then x0 = 0 else x0 = x00
if (n_elements(y00) eq 0) then y0 = 0 else y0 = y00
if (n_elements(str) eq 0) then str = ' '
if (n_elements(charsize0) eq 0) then size=!p.charsize else size=charsize0
if (n_elements(size0) ne 0) then size = size0
if (n_elements(orientation0) eq 0) then orientation = 0 else orientation = orientation0
if (n_elements(alignment0) eq 0) then alignment = 0 else alignment = alignment0
if (n_elements(color0) eq 0) then color=!p.color else color=color0
if (n_elements(charthick0) eq 0) then charthick=!p.charthick else charthick=charthick0
if (n_elements(font0) eq 0) then font=!p.font else font=font0
;
if (!d.name ne 'PS') then begin
    xyouts, x0, y0, str, size=size, orientation=orientation, alignment=alignment, /device, $
		color=color, charthick=charthick, font=font			
end else begin
    xi0 = x0 / float(xsiz_pix) * !d.x_size
    yi0 = y0 / float(ysiz_pix) * !d.y_size
    xyouts, xi0, yi0, str, /device, size=size, orientation=orientation, alignment=alignment, $
		color=color, charthick=charthick, font=font			
endelse
;
end
