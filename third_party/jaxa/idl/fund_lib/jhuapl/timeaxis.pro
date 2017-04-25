;-------------------------------------------------------------
;+
; NAME:
;       XPRINT
; PURPOSE:
;       Print text on graphics device.  After initializing use just like print.
; CATEGORY:
; CALLING SEQUENCE:
;       xprint, item1, [item2, ..., item10]
; INPUTS:
;       txt = text string to print.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set text color.
;         ALIGNMENT=a set text alignment.
;         /INIT to initialize xprint.
;           xprint,/INIT,x,y
;             x,y = coord. of upper-left corner of first line of text.    in
;         /DATA use data coordinates (def). Only needed on /INIT.
;         /DEVICE use device coordinates. Only needed on /INIT.
;         /NORM use normalized coordinates. Only needed on /INIT.
;         /NWIN use normalized window coordinates. Only needed
;           on /INIT.  NWIN coordinates are linear 0 to 1
;           inside plot window (inside axes box).
;         CHARSIZE=sz  Text size to use. On /INIT only.
;         CHARTHICK=thk  Text thickness to use. On /INIT only.
;           Text is thickened by shifting and overplotting.
;           Thk is total number of overplots wanted. To shift by
;           > 1 pixel per plot do CHARTHICK=[thk,step]
;           where step is in pixels (def=1).
;         DY=factor.  Adjust auto line space by this factor. On /INIT only
;           Try DY=1.5 for PS plots with the printer fonts (not PSINIT,/VECT).
;         YSPACE=out return line spacing in Y.
;         x0=x0 return graphics x-position of text in normalized coordinates.
;         y0=y0 return graphics y-position of text in normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
;       xprint_com
; NOTES:
;       Notes: Initialization sets text starting location and text size.
;         All following xprint calls work just like print normally does except
;         text is output on the graphics device.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Oct, 1989.
;       H. Cohl, 19 Jun, 1991.  (x0, y0)
;       R. Sterner, 25 Sep, 1991 --- fixed a bug that made line spacing
;       wrong when the window Y size varied from the normal value. The
;       bug showed up for psinit,/full with !p.multi=[0,1,2,0,0] where
;       the line spacing appeared to be 2 times too much.  Was using
;       xyouts to print a dummy letter to get its size.  Now just use
;       the value !d.y_ch_size (dev coord) as a good guess.
;       R. Sterner, 10 Mar, 1992 --- added CHARTHICK.
;       R. Sterner, 18 Mar, 1992 --- Modified CHARTHICK to do shifted
;       overplots and added shift size in pixels.
;       R. Sterner, 27 Mar, 1992 --- fixed a bug added with the modified
;       CHARTHICK.
;       R. Sterner, 20 May, 1993 --- Allowed CHARSIZE.
;       R. Sterner, 30 Jul, 1993 --- coordinate system used only to set
;       initial point, not needed for each print.
;       Handle log axes.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xprint, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, $
	  help=hlp, init=nit, dy=dy2, size=size, color=color, debug=debug, $
	  alignment=alignment, data=data,device=device,norm=norm,nwin=nwin,$
	  yspace=yspace,x0=x0,y0=y0, charthick=charthick, charsize=charsize
 
	common xprint_com, xc, yc, szc, clo, chi, cst, px, py, dy
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Print text on graphics device.  After initializing '+$
	    'use just like print.'
	  print,' xprint, item1, [item2, ..., item10]'
	  print,'   txt = text string to print.     in'
	  print,' Keywords:'
	  print,'   COLOR=c set text color.'
	  print,'   ALIGNMENT=a set text alignment.'
	  print,'   /INIT to initialize xprint.'
	  print,'     xprint,/INIT,x,y'
	  print,'       x,y = coord. of upper-left corner of first '+$
	    'line of text.    in'
	  print,'   /DATA use data coordinates (def). Only needed on /INIT.'
	  print,'   /DEVICE use device coordinates. Only needed on /INIT.'
	  print,'   /NORM use normalized coordinates. Only needed on /INIT.'
	  print,'   /NWIN use normalized window coordinates. Only needed'
	  print,'     on /INIT.  NWIN coordinates are linear 0 to 1'
	  print,'     inside plot window (inside axes box).'
	  print,'   CHARSIZE=sz  Text size to use. On /INIT only.'
	  print,'   CHARTHICK=thk  Text thickness to use. On /INIT only.'
	  print,'     Text is thickened by shifting and overplotting.'
	  print,'     Thk is total number of overplots wanted. To shift by'
	  print,'     > 1 pixel per plot do CHARTHICK=[thk,step]'
	  print,'     where step is in pixels (def=1).'
	  print,'   DY=factor.  Adjust auto line space by this factor. '+$
	    'On /INIT only.
	  print,'     Try DY=1.5 for PS plots with the printer fonts '+$
	    '(not PSINIT,/VECT).'
	  print,'   YSPACE=out return line spacing in Y.'
          print,'   x0=x0 return graphics x-position of text in normalized'+$
	    ' coordinates.'
          print,'   y0=y0 return graphics y-position of text in normalized'+$
	    ' coordinates.'
	  print,' Notes: Initialization sets text starting location and '+$
	    'text size.'
	  print,'   All following xprint calls work just like print '+$
	    'normally does except'
	  print,'   text is output on the graphics device.'
	  return
	endif
 
	;------  Set defaults  -------
	;-----  Other defaults  -----
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(alignment) eq 0 then alignment = 0.
 
	;--------  /INIT  ----------------
	if keyword_set(nit) then begin
	  if n_params(0) lt 2 then begin
	    print,' Must give both x and y in normalized coordinates.'
	    return
	  endif
	  ;------  Char size and thickness  --------
	  szc = 1.	; Use size=1 to figure spacing.
	  if n_elements(charsize) ne 0 then size=charsize
	  if n_elements(size) ne 0 then szc = size
	  cthk = 1	; Default text thickness (pixels).
	  if n_elements(charthick) gt 0 then cthk = charthick(0)
	  cst = 1L	; Default thickness step size (pixels).
	  if n_elements(charthick) gt 1 then cst = long(charthick(1))
	  clo = -long((cthk-1)/2) ; Thick text: step from clo to chi by cst.
	  chi = long(cthk/2)
	  ;------  Get pixel and line spacing in normalized coordinates  ---
	  aa = convert_coord([0,1],[0,1], /dev, /to_norm)
	  px = aa(0,1) - aa(0,0)
	  py = aa(1,1) - aa(1,0)
	  dy = py*!d.y_ch_size*szc
	  if n_elements(dy2) gt 0 then dy = dy*dy2  ; Line spacing over-ride.
	  yspace = dy				    ; Output line spacing.
 
	  ;-- Get text starting point in normalized coord. 
	  case 1 of
keyword_set(device): begin			; Device.
	      aa = convert_coord([p1],[p2], /dev, /to_norm)
	      xc = aa(0)  & yc = aa(1)
	    end
keyword_set(norm): begin			; Normalized.
	      xc = p1  & yc = p2
	    end
keyword_set(nwin): begin			; Normalized window.
	      nwin, p1, p2, xc, yc, /to_norm
	    end
else:       begin				; Data (def).
	      aa = convert_coord([p1],[p2], /data, /to_norm)
	      xc = aa(0)  & yc = aa(1)
	    end
	  endcase
	  return
	endif
	;-----------  End /INIT  ---------
 
	;----------  Process output  ---------
	;---  Build up output string from procedure parameters ---- 
	txt = ''
	for i = 1, n_params(0) do begin
	  j = execute('t = p'+strtrim(i,2))
	  txt = txt + string(t)
	endfor
 
 	for iy = clo, chi do begin
	  yy = yc+iy*cst*py
	  for ix = clo, chi do begin
	    xx = xc+ix*cst*px
	    xyouts, xx, yy, txt, size=szc, color=color, $
	      alignment=alignment, /norm
	  endfor
	endfor
 
        x0=xc & y0=yc		; Returned text position.
	yc = yc - dy		; Next line position.
 
if keyword_set(debug) then stop
 
	return
	end
;-------------------------------------------------------------
;+
; NAME:
;       TIMEAXIS
; PURPOSE:
;       Plot a time axis.
; CATEGORY:
; CALLING SEQUENCE:
;       timeaxis, [t]
; INPUTS:
;       t = optional array of seconds after midnight.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         JD=jd   Set Julian Day number of reference date.
;         FORM=f  Set axis label format string, over-rides default.
;           do help,dt_tm_mak(/help) to get formats.
;           For multi-line labels use @ as line delimiter.
;         NTICKS=n  Set approximate number of desired ticks (def=6).
;         TITLE=txt Time axis title (def=none).
;         TRANGE=[tmin,tmax] Set specified time range.
;         YVALUE=Y  Y coordinate of time axis (def=bottom).
;         TICKLEN=t Set tick length as % of yrange (def=5).
;         /NOLABELS means suppress tick labels.
;         /NOYEAR drops year from automatically formatted labels.
;           Doesn't apply to user specified formats.
;         LABELOFFSET=off Set label Y offset as % yrange (def=0).
;           Allows label vertical position adjustment.
;         DY=d  Set line spacing factor for multiline labels (def=1).
;         COLOR=c   Axis color.
;         CHARSIZE=s    Axis text size.
;         CHARTHICK=cth thickness of label text (def=1).
;         THICK=thk thickness of axes and ticks (def=1).
;         MAJOR=g   Linestyle for an optional major tick grid.
;         MINOR=g2  Linestyle for an optional minor tick grid.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: To use do the following:
;         plot, t, y, xstyle=4
;         timeaxis
;         If no arguments are given to TIMEAXIS then an
;         axis will be drawn based on the last plot, if any.
;         Try DY=1.5 for PS fonts.
; MODIFICATION HISTORY:
;       R. Sterner, 25 Feb, 1991
;       R. Sterner, 26 Jun, 1991 --- made nticks=0 give default ticks.
;       R. Sterner, 18 Nov, 1991 --- allowed Log Y axes.
;       R. Sterner, 11 Dec, 1992 --- added /NOLABELS.
;       R. Sterner, 20 May, 1993 --- Made date labeling (jd2mdays).
;       Allowed CHARSIZE for SIZE.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro timeaxis, t, jd=jd, form=form, nticks=nticks, $
	  yvalue=yvalue, trange=trange, color=color, size=size, $
	  help=hlp, ticklen=ticklen, labeloffset=laboff, dy=dy, $
	  title=title, major=grid, minor=grid2, charthick=charthick,$
	  thick=thick, nolabels=nolabels, noyear=noyear, charsize=charsize
 
	if keyword_set(hlp) then begin
help:	  print,' Plot a time axis.'
	  print,' timeaxis, [t]'
	  print,'   t = optional array of seconds after midnight.  in'
	  print,' Keywords:'
	  print,'   JD=jd   Set Julian Day number of reference date.'
	  print,'   FORM=f  Set axis label format string, over-rides default.'
	  print,'     do help,dt_tm_mak(/help) to get formats.'
	  print,'     For multi-line labels use @ as line delimiter.'
	  print,'   NTICKS=n  Set approximate number of desired ticks (def=6).'
	  print,'   TITLE=txt Time axis title (def=none).'
	  print,'   TRANGE=[tmin,tmax] Set specified time range.'
	  print,'   YVALUE=Y  Y coordinate of time axis (def=bottom).'
	  print,'   TICKLEN=t Set tick length as % of yrange (def=5).'
	  print,'   /NOLABELS means suppress tick labels.'
	  print,'   /NOYEAR drops year from automatically formatted labels.'
	  print,"     Doesn't apply to user specified formats."
	  print,'   LABELOFFSET=off Set label Y offset as % yrange (def=0).'
	  print,'     Allows label vertical position adjustment.'
	  print,'   DY=d  Set line spacing factor for multiline labels (def=1).'
	  print,'   COLOR=c   Axis color.'
	  print,'   CHARSIZE=s    Axis text size.'
	  print,'   CHARTHICK=cth thickness of label text (def=1).'
	  print,'   THICK=thk thickness of axes and ticks (def=1).'
	  print,'   MAJOR=g   Linestyle for an optional major tick grid.'
	  print,'   MINOR=g2  Linestyle for an optional minor tick grid.'
	  print,' Notes: To use do the following:'
	  print,'   plot, t, y, xstyle=4'
	  print,'   timeaxis'
	  print,'   If no arguments are given to TIMEAXIS then an'
	  print,'   axis will be drawn based on the last plot, if any.'
	  print,'   Try DY=1.5 for PS fonts.'
	  return
	endif
 
	cr = string(13b)			; Carriage Return.
	if n_elements(charsize) ne 0 then size = charsize
 
	;=================  Find Axis Endpoints  =============================
	;-----  Values are in seconds after midnight of a reference date.
	;-----  At this point in the routine the reference is not yet
	;-----  determined.
	;---------------------------------------------------------------------
 
	if n_params(0) ge 1 then begin		; First try from given array.
	  xmn = min(t)
	  xmx = max(t)
	endif
 
	if n_elements(trange) ne 0 then begin	; Over-ride with range.
	  xmn = trange(0)
	  xmx = trange(1)
	endif
 
	if n_elements(xmn) eq 0 then begin	; Neither time array, t, or
	  xmn = !x.crange(0)			; time range, trange, given,
	  xmx = !x.crange(1)			; so use last plot range.
 	endif
	if (xmn + xmx) eq 0 then goto, help
 
 
	;====================  Find Axis Numbers  ============================
	;-----  If the keyword JD=jd is given it is used as the reference
	;-----  date, otherwise the days start counting up from 1.
	;---------------------------------------------------------------------
 
	;------------  Number of labeled tic marks. -----------------------
	if n_elements(nticks) eq 0 then nticks=0	; Number of ticks.
	if nticks eq 0 then nticks = 6
 
	;-----  First find ticks for the case where JD is not given  ----------
	;-----  or the time span is not more than 10 days.  -------------------
	;-- Find axis labeled (major) and unlabeled (minor) tick positions. --- 
	tnaxes, xmn, xmx, nticks, tt1, tt2, dtt, $	; Axis numbers.
	  t1, t2, dt, form=frm
	v = makex( tt1, tt2, dtt)	; Major ticks sec after midnight.
	v2 = makex(t1, t2, dt)		; Minor ticks sec after midnight.
 
	;------  If JD given AND range > 10 days use month labels  --------
	if (n_elements(jd) ne 0) and ((xmx-xmn) gt 864000.) then begin
	  jd1 = jd + xmn/86400.d0	; JD of xmn.
	  jd2 = jd + xmx/86400.d0	; JD of xmx.
	  jd2mdays, jd1, jd2, approx=dtt/86400.d0, maj=mjr, min=mnr, form=frm
	  if keyword_set(noyear) then frm = getwrd(frm,-99,-1,/last)
	  v = (mjr-jd)*86400.d0		; Major ticks sec after midnight on JD.
	  v2 = (mnr-jd)*86400.d0	; Minor ticks sec after midnight on JD.
	endif
 
	;=========  Find labels, tick lengths, axis position.  ==============
 
	;--------  Make axis labels  ------------
	if n_elements(form) eq 0 then form = ''		; Label format.
	if form eq '' then form = frm
	lab = time_label(v, form, jd=jd)
 
	;--------  Tick length  ---------------
	ycr = !y.crange					; Y data range.
	if !y.type eq 1 then ycr = 10^ycr		; Was log Y axis.
	tmp = convert_coord([0,0],ycr,/data,/to_dev)	; Find in device coord.
	yrange = tmp(4) - tmp(1)			; Full y range (pixels).
	if n_elements(ticklen) eq 0 then ticklen = 3.	; Labeled tick length.
	oneperc = yrange/100.				; 1% (pixels)
	tickl = ticklen*oneperc				; Tick in pixels.
	
	;-------  Axis y position  ------------
	yv = !y.crange(0)				; Lower x axis y value.
	if !y.type eq 1 then yv = 10^yv			; Allow log y axis.
	if n_elements(yvalue) ne 0 then begin
	  yv = yvalue
	endif
 
 
	;==================  Plot axis  =====================
;	mxlines = 1
	;-------  Plot axis  ------------------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(size) eq 0 then size = 1.
	if (!p.multi(1)>!p.multi(2)) gt 2 then size=size/2.
	if n_elements(charthick) eq 0 then charthick = 1.
	if n_elements(thick) eq 0 then thick = 1.
	if n_elements(laboff) eq 0 then laboff = 0.
	if n_elements(dy) eq 0 then dy = 1.
	plots, !x.crange, [yv, yv], color=color, thick=thick
	tmp = convert_coord(v,v*0.+yv,/data,/to_dev)
	ix = round(tmp(0,*))
	iy = round(tmp(1,*))
	iymin = (iy+tickl)<iy			; Want min dev Y used.
	iyt = iymin				; Axis or bottom of tick.
	for i = 0, n_elements(v)-1 do begin	; Major (Labeled) ticks.
	  plots, [ix(i),ix(i)], [iy,iy+tickl], color=color, /dev, thick=thick
	  if keyword_set(nolabels) then goto, skip
;	  xprint, /init, ix(i) ,iy-laboff*oneperc, /dev, $
	  xprint, /init, ix(i) ,iyt-laboff*oneperc, /dev, $
	    size=size, dy=dy, yspace=ysp, charthick=charthick
	  xprint,' '
	  labtxt = lab(i)
	  for j = 0, 5 do begin
	    txt = getwrd(labtxt, j, delim=cr)
	    if txt eq '' then goto, skip
;	    mxlines = mxlines > (j+1)
	    xprint, txt, align=.5, color=color,y0=y0, /dev
	    iymin = iymin<(y0*!d.y_size)	; Update min dev y used.
	  endfor
skip:
	endfor
	tmp = convert_coord(v2,v2*0.+yv,/data,/to_dev)
	ix = round(tmp(0,*))
	iy = round(tmp(1,*))
	for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
	  plots, [ix(i),ix(i)], [iy,iy+tickl/2.], color=color,/dev,thick=thick
	endfor
 
	;-------  Top axis  -------------
	if n_elements(yvalue) eq 0 then begin
	  yv1 = !y.crange(1)
	  if !y.type eq 1 then yv1 = 10^yv1
	  plots, !x.crange, [0,0]+yv1, color=color,thick=thick
	  tmp = convert_coord(v,v*0.+yv1,/data,/to_dev)
	  ix = round(tmp(0,*))
	  iy = round(tmp(1,*))
	  for i = 0, n_elements(v)-1 do begin
	    plots, [ix(i),ix(i)], [0,-tickl]+iy, color=color, /dev,thick=thick
	  endfor
	  tmp = convert_coord(v2,v2*0.+yv1,/data,/to_dev)
	  ix = round(tmp(0,*))
	  iy = round(tmp(1,*))
	  for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
	    plots,[ix(i),ix(i)],[0,-tickl/2.]+iy,color=color,/dev,thick=thick
	  endfor
	endif
 
	;------------  Title  ---------------
	if n_elements(title) ne 0 then begin
	  tx = total(!x.crange)/2.
	  tmp = convert_coord([tx],[yv],/data,/to_dev)
	  ix = tmp(0)
	  iy = min(iymin)
	  xprint,/init,ix,iy,/dev,size=size,dy=dy,charthick=charthick
	  xprint,' ',/dev
	  xprint,' ',/dev
;	  if laboff ge 0 then for i = 1, mxlines do xprint,' '
	  xprint, title, align=.5, color=color, /dev
	endif
 
	;-------------  Grids  ----------------
	if n_elements(grid) ne 0 then begin	; Major grid.
	  for i = 0, n_elements(v)-1 do begin
	    ver, v(i), color=color, linestyle=grid
	  endfor
	endif
	if n_elements(grid2) ne 0 then begin	; Minor grid.
	  dtt = v(1)-v(0)			; Actual major tic spacing.
	  for i = 0, n_elements(v2)-1 do begin
	    if (v2(i) mod dtt) ne 0 then begin
	      ver, v2(i), color=color, linestyle=grid2
	    endif
	  endfor
	endif
 
 	return
	end
