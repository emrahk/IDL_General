;+
; Name: plotman_draw_event
;
; Purpose: Handles right and left click events in plotman's draw widget.
;
; Method: Right-click show x,y of point, and for images, the image value
;	Left-click and drag allows zooming.  Single left-click unzooms.
;
; Modifications:
;	31-Jul-2001, Kim.  On right click, show image value for images, and for all types
;	  of plots, print label in IDL window as well as on plot.
;	12-Aug-2001, Kim.  Corrected error in image value display
;	11-Oct-2002, Kim.  Call new plotman method dev2data to convert coords
;	28-Mar-2003, Kim.  Made this work for multiplot plots (if they're stacked in y direction only).
;	  Figures out which plot user clicked in, then sets focus to that panel temporarily to get
;	  correct device to data conversion.  Then focuses back on original (top in multi) panel.
;	16-Jun-2005, Kim.  In point command (right click) if x is < 1.e6 don't interpret as time.
;	1-May-2007, Kim. When overlaying (stacking) plots, first overlay is now always reserved for
;	  self (only applies to images), so overlay_panel [1],[2],[3] are the three panels that can be
;	  stacked.  Also, can't assume second plot down is first overlay - overlay #1 may be blank,
;	  but overlay #2 may not be (that bug was here before).
;	3-Dec-2007, Kim.  Increased number of digits printed for x,y,image when right-click.
; 10-Aug-2008, Kim.  Removed test for ut gt 1.e6 for right-click on ut plot.  (shouldn't be needed
;   anyway, and screws up using negative times (e.g. early goes data < 1980)
; 10-Jul-2009, Kim.  Made right-click show image value for spectrograms.
; 02-Nov-2011, Kim. Added common plotman_click_common to store last click and last 20 clicks
; 15-Nov-2011, Kim. Adjusted formatting of right-click output, and use axis_get_edges for spectrograms
; 06-Sep-2012, Kim. Added using yloc to figure out which panel was clicked in (now overlay panels can have 
;   different y sizes). If y sizes weren't set, then use old way of dividing window into n plots equally.
; 18-Oct-2012, Kim. Call get_yloc with /frac, and when getting iplot, use only yloc's that have different
;   start/end (if overlay 1 is none, but overlay 2 is set, then yloc for overlay 1 will have, e.g. .5 to .5)
; 01-Apr-2014, Kim. Minor change in writing label on plot - use data, don't recalculate as d
; 27-May-2014, Kim. Increase number of digits in right-click option (was g12.4 now g14.7)
; 22-Jan-2015, Kim. Made right-click in RHESSI spectrograms work. Made the unfortunate choice a long time
;  ago in RHESSI software to pass plotman the RHESSI spectrum obj, not the generic specplot obj, so have
;  to retrieve info from it a little differently. This still compiles and works even if hessi branch isn't in ssw.
;
;-

pro plotman_draw_event, event

common plotman_click_common, lastclick, last20click

;print,'in plotman_draw_event, '
;help,event,/st

widget_control, event.top, get_uvalue=state

widget_control, state.widgets.w_message, set_value = ' '

; if user clicked in a panel that isn't current, make it current and return

if event.id ne state.widgets.w_draw then begin

	which_panel = state.plotman_obj -> which_panel (event.id, panel_number=panel_number, err=err)
	if not err then state.plotman_obj -> focus_panel, which_panel, panel_number else begin
		; if current draw id wasn't one of the saved panels, it must be hanging around from an error
		; so destroy it.
		if xalive(event.id) then widget_control, event.id, /destroy
		return
	endelse

	state.plotman_obj -> unselect
	;widget_control, event.top, get_uvalue=state
	return
endif

state.plotman_obj -> select

release=0 & left=0 & middle=0 & right=0
case event.press of
	0: release=1
	1: left=1
	2: middle=1
	4: right=1
	else: begin
		state.plotman_obj -> unselect
		return
		end
endcase

if release then begin
	state.plotman_obj -> unselect
	return ;return if release event
endif

; if multiplot, then if we're not on top plot, restore plot control and data from the panel
; clicked in.  We'll restore the original panel before we leave.
; NOTE:  If two of the panels are the same original panel, zooming or pointing on the first (higher) of the
; two, won't work because the !X,!Y, etc variables are stored for the last plot (probably it is !y.s,
; that's totally wrong for the first of the pair of plots)
; Figure out which plot was click in by: 
; get_yloc() returns the start/end for each panel in the overlay as a fraction of the window size as [2,N] array.
; If yloc is non-zero (means we used overlay_ysize and !p.region to adjust sizes of multiple plots), then use the
; fraction of click height/ plot height compared to yloc to get iplot (panel number clicked in, counting from 0 at top)
; If yloc is all 0., divide window size into nplots and compute which section was clicked in.
nplots = !p.multi[2]
if nplots ne 0 then begin
  yloc = state.plotman_obj->get_yloc(/frac)
  ; Figure out iplot, the number of the plot down the page we've clicked in (0 is top, then 1, down to bottom)
  if total(yloc) eq 0. then begin
	  plot_size = !d.y_size / nplots
	  iplot = fix ((!d.y_size - event.y) / plot_size)
	endif else begin
	  yfrac = float(event.y) / !d.y_size
	  idrawn = where(yloc[0,*] ne yloc[1,*]) ; just use ylocs that have a plot. if yloc[0,i]=yloc[1,i] means no plot
	  q = where (yfrac gt yloc[0,idrawn], count)
	  iplot = count gt 0 ? q[0] : nplots-1
	endelse
;	print,'iplot=', iplot
	
	if iplot ne 0 then begin
		; save original panel #. Figure out which panel is the one clicked in, and
		; restores its plot params, so we can convert x,y to the right coords for that panel
		; overlay_panel[0] isn't used for stacked plots. [1] is first available.
		orig_panel_num = state.plotman_obj -> get(/current_panel_number)
		ov_panels = state.plotman_obj -> get(/overlay_panel)
		; find which overlay panels are not blank, those are the ones plotted
		q = where (ov_panels ne '')
		ov_panel_num = state.plotman_obj -> desc2panel(/number,ov_panels[q[iplot-1]])
		state.plotman_obj -> focus_panel, dummy1, ov_panel_num, /minimal
;		print,'orig_panel = ', orig_panel_num, '  ov_panel_num = ', ov_panel_num
	endif
endif

if left then begin
	if event.clicks ne 2 then plotman_zoom, state, event=event, orig_panel_num=orig_panel_num
end

if right then begin
	plot_type = state.plotman_obj -> get(/plot_type)
	x = event.x
	y = event.y
	data = state.plotman_obj -> dev2data (x, y)

  image_val = ''
	text = 'X, Y: '

	if plot_type eq 'utplot' or plot_type eq 'specplot' then begin
		ut = data[0] + state.plotman_obj -> get(/utbase)
;		if ut gt 1.e6 then begin   ;removed test 10-aug-2008
			xs = anytim (ut, /ecs)
			text = 'Time, Y: '
;		endif
	endif
	if not exist(xs) then xs = strtrim(string (data[0], format='(g14.7)'), 2)

	ys = strtrim(string (data[1], format='(g14.7)'), 2)

	gdraw = widget_info(event.id, /geom)

	if x gt gdraw.xsize/2. then left = 1 else left = 0

	if plot_type eq 'image' then begin
		image_info = state.plotman_obj -> get(/image_info)
		xelem = find_ix(image_info.xvals, data[0])
		yelem = find_ix(image_info.yvals, data[1])
		image_val = strtrim(string (image_info.image[xelem,yelem], format='(g14.7)'), 2)
		text = 'X, Y, Image Value: '
	endif
	
  if plot_type eq 'specplot' then begin
    specobj = state.plotman_obj -> get(/data)
    if is_class(specobj, 'SPECPLOT') then begin
      xdata = specobj -> get(/xdata)
      ydata = specobj -> get(/ydata)
      ; dim1_vals is a 1-D array, midpoints of y vals.  When plotting specplot uses axis_get_edges to get 2xn vals.
      dim1_vals = axis_get_edges(specobj -> get(/dim1_vals)) > 0.
      xelem = find_ix(xdata, data[0])
      yelem = find_ix(dim1_vals, data[1])
      image_val = strtrim(string (ydata[xelem,yelem], format='(g14.7)'), 2)
      text = 'X, Y, Spectrogram Value: '
    endif
    if is_class(specobj, 'HSI_SPECTRUM') then begin
      xdata = specobj->getaxis(/ut, /edges_1)
      ydata = specobj->getdata()
      dim1_vals = specobj->getaxis(/energy, /edges_1)
      xelem = find_ix(xdata-xdata[0], data[0])
      yelem = find_ix(dim1_vals, data[1])
      image_val = strtrim(string (ydata[yelem,xelem], format='(g14.7)'), 2)
      text = 'X, Y, Spectrogram Value: '
    endif
  endif	

  comma = image_val eq '' ? '' : ', ' 
	label = string (xs,ys,comma,image_val, format="('(', a, ', ', a, a, a, ')' )")

;	; can't use actual data coordinates on spectrogram because of weird axes
;	d = convert_coord  (x, y, /device,/to_data, /double)
; Use data, don't have to calculate d, since already have data, which is same as d, Kim, 1-apr-2014
	label_symbol, data[0], data[1], 6, label, symsize=.4, left=left

	print, text, label
	
	lastclick = {x: xs, y: ys, z: image_val}
	last20 = append_arr(last20click, lastclick)
	last20click = n_elements(last20) gt 20 ? last20[1:*] : last20

endif

; if we're not on original panel, then set focus to it.
if exist(orig_panel_num) then begin
	if orig_panel_num ne state.plotman_obj->get(/current_panel_number) then begin
		;print,'current panel = ',state.plotman_obj->get(/current_panel_number),', setting focus back to ',orig_panel_num
		state.plotman_obj -> focus_panel, dummy2, orig_panel_num, /minimal
	endif
endif

state.plotman_obj -> unselect

end
