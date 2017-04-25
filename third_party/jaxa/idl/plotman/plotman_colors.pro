;
; Modifications:
;   21-Apr-2001, Kim.  Changed plot control tags from r,g,b to rcolors,...
;   2-Aug-2002, Kim.  Call hsi_xcolors instead of xcolors

pro plotman_colors, event


widget_control, event.top, get_uvalue=state
if not tag_exist(state,'widgets') then widget_control, state.parent, get_uvalue=state

if  not state.plotman_obj->valid_window(/message) then return

widget_control, state.widgets.w_message, set_value=' '

widget_control, event.id, get_uvalue=colors

pc = state.plotman_obj -> get(/plot_control)
tvlct, pc.rcolors, pc.gcolors, pc.bcolors, colors[1]

geom = widget_info(event.top, /geom)

widget_offset, event.top, newsize=[250,300], xoffset, yoffset

if pc.color_file ne '' then file = pc.color_file

hsi_xcolors, group=event.top, ncolors=colors[0], bottom=colors[1], $
	xoffset=xoffset, yoffset=yoffset, $
	title='Plotman colors', notifyid=[state.widgets.w_refresh, event.top], $
	file=file

end