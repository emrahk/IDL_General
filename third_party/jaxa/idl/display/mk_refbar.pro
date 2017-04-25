pro mk_refbar, x0, y0, imin, imax, hist=hist, xsiz=xsiz, ysiz=ysiz, $
		nlab=nlab, fmt=fmt, delta=delta, average=average, deviation=deviation, $
		ynozero=ynozero, size=size, log_scale=log_scale, log_offset=log_offset, $
		horizontal=horizontal, qdebug=qdebug
;+
;NAME:
;	mk_refbar
;PURPOSE:
;	To display a reference color bar (to go along side an image)
;SAMPLE CALLING SEQUENCE:
;	mk_refbar, x0, y0, imin, imax
;	mk_refbar, x0, y0, imin, imax, /horiz, fmt=fmt, nlab=lab, /log
;	mk_refbar, x0, y0, imin, imax, xsiz=xsiz, ysiz=ysiz
;INPUT:
;	x0	- The lower left X corner for the color bar
;	y0	- The lower left Y corner for the color bar
;	imin	- The minimum data value displayed (color=0)
;	imax	- The maximum data value displayed (color=!d.table_size-1)
;OPTIONAL KEYWORD INPUT:
;	horiz	- If set, make the color bar horizontal
;	nlab	- The number of labels (default=16)
;	fmt	- The format statement for the label values
;	xsiz	- The X size of the color bar (def = 24)
;	ysiz	- The Y size of the color bar (def = 256)
;	size	- The font size for the labels
;	hist	- If set, then the image was displayed with histogram
;		  equalization
;	average - If set, then display a message about the average
;	deviation-If set, then display a message about the deviation
;	delta	- If set, then display a message about the range
;	log_scale-If set, then the data was log scaled before display
;HISTORY:
;	Written Feb-94 by M.Morrison
;	 5-Apr-94 (MDM) - Added "log_scale" and "log_offset" options
;	 3-May-94 (MDM) - Slight changes (make bar go to a value of 255, 
;			  not !d.n_colors)
;	 2-Apr-96 (MDM) - Added /horizontal option
;			- Added /qdebug 
;	22-Apr-96 (MDM) - Replaced to scale to !d.n_colors (this time N-1)
;	11-Nov-96 (MDM) - Changed !d.n_colors to !d.table_size
;			- Added some header info
;-
;
;
if (n_elements(xsiz) eq 0) then xsiz = 24
if (n_elements(ysiz) eq 0) then ysiz = 256
if (n_elements(nlab) eq 0) then nlab = 16
if (n_elements(fmt) eq 0) then fmt = ''
if (n_elements(size) eq 0) then size = 1.0
if (n_elements(log_offset) eq 0) then log_offset = 0
;
;colors = findgen(1,ysiz) * !d.n_colors/float(ysiz-1)
cmax = !d.table_size -1		;cmax = 255 before 22-Apr-96
bar = intarr(xsiz, ysiz)
if (keyword_set(horizontal)) then begin
    colors = findgen(1,xsiz) * cmax/float(xsiz-1)
    for i=0,ysiz-1 do bar(*,i) = colors
end else begin
    colors = findgen(1,ysiz) * cmax/float(ysiz-1)
    for i=0,xsiz-1 do bar(i,*) = colors
end
bar([0,xsiz-1],*) = 128
bar(*,[0,ysiz-1]) = 128
tv2, bar, x0, y0
;
if (keyword_set(hist)) then bimg = hist_equal(hist)
;
if (nlab gt 0) then labels = strarr(nlab)
for i=0L,nlab-1 do begin
    if (not keyword_set(hist)) then begin
	val = imin + (imax-imin)*i/float(nlab-1)
	delta_val = imax-imin
	if (keyword_set(log_scale)) then begin
	    val = 10.^val + log_offset
	    delta_val = 10.^imax - 10.^imin
	end
    end else begin
	cval = i/float(nlab-1)*255
	ss = where((bimg ge cval-2) and (bimg le cval+2))
	if (ss(0) ne -1) then 	val = total(hist(ss))/n_elements(ss) else val = 1/0.
	if (keyword_set(ynozero)) then delta_val = max(hist(where(hist ne 0))) - min(hist(where(hist ne 0))) $
				else delta_val = max(hist) - min(hist)
    end
    labels(i) = string(val, format=fmt)
end
;
for i=0,nlab-1 do begin
    if (keyword_set(horizontal)) then begin
	y00 = y0 - 10
	x00 = x0 + i/float(nlab-1)*xsiz
	xyouts2, x00, y00, labels(i), /device, size=size, align=0.5
	if (keyword_set(qdebug)) then print, x00, y00, labels(i)
    end else begin
	x00 = x0 + xsiz + 4
	y00 = y0 + i/float(nlab-1)*ysiz
	xyouts2, x00, y00, labels(i), /device, size=size
    end
end
;
str = ''
if (keyword_set(average)) then str = 'Avg =' + strtrim(string(average,format=fmt),2)
if (keyword_set(deviation)) then str = str + '  Dev = ' + strtrim(string(deviation,format=fmt),2)
if (keyword_set(average) or keyword_set(deviation)) then xyouts2, x0-20, y0+ysiz/2, str, align=0.5, /dev, orient=90, siz=size
;
if (keyword_set(delta)) then str = 'Range = ' + strtrim(string(delta_val,format=fmt),2)
if (keyword_set(delta)) then xyouts2, x0-2, y0+ysiz/2, str, align=0.5, /dev, orient=90, siz=size
;
end
