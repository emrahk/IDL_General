pro plots2, x, y, dev=dev, color=color, thick=thick, continue=continue, psym=psym, symsize=symsize,_extra=extra
;
;
;	plots2, x, y, /dev
;
;	/device does not mean anything - xyouts2 units are always in window pixel device units
;
common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch
;
if (n_elements(color) eq 0) then color = 255
if (n_elements(continue) eq 0) then continue = 0
if (n_elements(thick) eq 0) then thick = 1
if (n_elements(psym) eq 0) then psym = !psym
if (n_elements(symsize) eq 0) then symsize = 1
;
if (!d.name ne 'PS') then begin
    plots, x, y, dev=dev, color=color, thick=thick, continue=continue, psym=psym, symsize=symsize,_extra=extra
end else begin
    xx = x / float(xsiz_pix) * !d.x_size
    yy = y / float(ysiz_pix) * !d.y_size
    plots, xx, yy, /dev, color=color, thick=thick, continue=continue, psym=psym, symsize=symsize,_extra=extra
end
;
end
