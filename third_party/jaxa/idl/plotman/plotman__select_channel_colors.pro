;+
; Name: select_channel_colors method for plotman
;
; Purpose: Widget interface to allow user to select color for
;	each channel separately.  Sets dim1_color in plotman object.
;
; Method: Called from plotman_xyoptions normally
;
; Written: Kim Tolbert 13-Jul-2003
; Modifications:
; 24-Jul-2003, Kim.  Only show the channels that are selected.
; 24-Apr-2008, Kim. Fix reset option. Also adjust dim1_use if some are outside 
;   range of current panel's channels
;
;-

;---- update widgets with current color selection

pro plotman_select_channel_colors_update, state

for i = 0,n_elements(state.w_ids)-1 do begin
	ind = state.dim1_colors[i] - state.ncolors - 1
	widget_control, state.w_ids[i], set_droplist_select=ind
endfor

end

;----- event handler for plotman::select_channel_colors

pro plotman_select_channel_colors_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

exit = 0

case uvalue of
	'color': begin
		q = where (event.id eq state.w_ids)
		state.dim1_colors[q[0]] = event.index + state.ncolors + 1
		end

	'reset': begin
		plot_defaults = state.plotman_obj -> get(/plot_defaults)
		val = *plot_defaults.dim1_colors
		; val will only have 10 colors, replicate it to be enough for all the channels
		nchan = n_elements(state.dim1_use)
		while n_elements(val) lt nchan do val = append_arr (val, val)
;		state.dim1_colors = (val[0:nchan-1])[state.dim1_use]
    state.dim1_colors = val[state.dim1_use]
		end

	'cancel': begin
		state.dim1_colors = state.orig_dim1_colors
		exit = 1
		end

	'accept': exit = 1

endcase

widget_control, event.top, set_uvalue=state
plotman_select_channel_colors_update, state

if exit then begin
	if not same_data(state.dim1_colors, state.orig_dim1_colors) then begin
		;before setting back into plotman, get all the dim_colors, and insert
		;the selected colors into the proper places.
		all_dim1_colors = state.plotman_obj -> get(/dim1_colors)
		all_dim1_colors[state.dim1_use] = state.dim1_colors
		state.plotman_obj -> set, dim1_colors=all_dim1_colors
	endif
	widget_control, event.top, /destroy
endif

end

;----- main program

pro plotman::select_channel_colors,group=group, do_def=do_def

cn = self -> get(/color_names)

if do_def then begin
	dim1_use = indgen(10)
	dim1_ids = 'Line ' + trim(indgen(10))
endif else begin
	dim1_use = self -> get(/dim1_use)
	dim1_ids = self -> get(/dim1_ids)
	;limit dim1_use to # of dim1_ids there really are (dim1_use may have been set for
	;a different panel and may include channels not available for this panel), kim 24-apr-08 
	q = where (dim1_use lt n_elements(dim1_ids),c)
	dim1_use = c gt 0 ? dim1_use[q] : 0
endelse

; dim1_use is the array of selected channels.  We'll only show those.
dim1_colors =  (self -> get(/dim1_colors))[dim1_use]
ncolors = self -> get(/ncolors)

dim1_ids = dim1_ids[dim1_use]
nchan = n_elements(dim1_ids)
nchan_use = nchan < 18

if not keyword_set(group) then group=self->get(/plot_base)

tlb = widget_base (group_leader=group, $
					title='Select Colors for each Channel', $
					/column, $
					space=5, $
					/modal )

w_box = widget_base (tlb, /column, /frame, space=0)

w_ids = lonarr(nchan_use)
for i=0,nchan_use - 1 do begin
	w_row = widget_base(w_box, /row, space=20)
	w_ids[i] = widget_droplist (w_row, title=dim1_ids[i]+':    ', value=tag_names(cn), uvalue='color')
endfor

if nchan_use lt nchan then tmp = widget_label (w_box, value='NOTE: Showing only first 18 selected channels')

w_buttons = widget_base(tlb, /row, space=15)

w_reset = widget_button (w_buttons, value='Reset to Defaults', uvalue='reset')
w_cancel = widget_button (w_buttons, value='Cancel', uvalue='cancel')
w_accept = widget_button (w_buttons, value='Accept and Close', uvalue='accept')

widget_offset, parent, newbase=tlb, xoffset, yoffset

widget_control, tlb, xoffset=xoffset, yoffset=yoffset

widget_control, tlb,  /realize

state = {w_ids:w_ids, $
	dim1_use: dim1_use, $
	dim1_ids: dim1_ids, $
	dim1_colors: dim1_colors, $
	orig_dim1_colors: dim1_colors, $
	ncolors: ncolors, $
	plotman_obj: self }

plotman_select_channel_colors_update, state

widget_control, tlb, set_uvalue=state

xmanager, 'plotman_select_channel_colors', tlb

end