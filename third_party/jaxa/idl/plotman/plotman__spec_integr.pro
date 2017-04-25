;+
; Name: plotman__spec_integr
;
; Purpose: spec_integr method for plotman.  Integrates spectrogram over y values.
;   Makes a new panel with the integrated spectrum, and makes the spectrogram plot
;   the first overlay, so the integrated spectrum appears over the spectrogram and
;   they can be zoomed together.
;
; Method: User draws box to select y values.  (x values on zoom have no effect)
;
; Written: Kim Tolbert, March, 2003
;
; Modifications:
;	24-May-2005, Kim.  Use y integration limits as yrange for spectrogram plot
;	27-Jun-2005, Kim.  Added full keyword.
;	5-Jul-2008,  Kim.  Put spectrogram overlay in overlay[1], not overlay[0] (overlay[0] is
;		reserved for self as of May 9, 2007)
; 20-Jan-2009, Kim
;-

pro plotman::spec_integr, full=full

full = keyword_set(full)

if not full then begin
	xack, /suppress, space=5, $
		'Click and drag left mouse button to define y range to integrate.'

	self->select

	w = self->get(/widgets)
	color_names = self -> get(/color_names)
	xydev = stretch_box (w.w_draw, /dev, color=color_names.red)
	xy = fltarr(2,2)
	xy[*,0] = self -> dev2data (xydev[0,0], xydev[1,0])
	xy[*,1] = self -> dev2data (xydev[0,1], xydev[1,1])

	ydiff = abs(xy[1,0] - xy[1,1])
	yratio = f_div (ydiff, abs(!y.crange[1] - !y.crange[0]) )

	if yratio lt .01 then return  ; too small - didn't move mouse much, so cancel
	yrange = reform(xy[1,*])
endif else yrange = [0.,0.]

self.plot_control.yy.range = yrange
self.plot_control.xx.style=1
self -> update_panel

desc = self->get(/current_panel_desc)
desc_notime = self->get(/current_panel_desc, /desc_without_time)

status = self -> setdefaults (plot_type='specplot')

panel = self -> get(/current_panel_struct)

if panel.saved_data.save_mode eq 'obj_extract' then begin
	self -> set, saved_data=stc_clone(panel.saved_data), /use_extracted
endif else begin
	self -> set, input=*panel.saved_data.data, class_name=panel.saved_data.class_name
endelse

self->set, yintegrate=yrange, /pl_spec
self->new_panel, desc_notime+'Integrated', /using_saved, /noplot
;self -> set, overlay_panel=['',desc,'','']
self -> set, c1_overlay_panel=desc

self->update_panel
panel_number = self -> get(/current_panel_number)
self -> show_panel, panel_number=panel_number, /maximize

end
