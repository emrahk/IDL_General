;+
; Name: plotman::multi_profile_widget
;
; Category: HESSI
;
; Purpose: plotman method with widget to select options for computing profile for multiple images
;
; Input arguments:
;	group - widget id of parent widget
;	panels - panel numbers of panels to compute profile for
;
; Method:  After setting up options, calls multi_profile method to do the work.
;
; Written:  11-Nov-2009, Kim Tolbert
; Modifications:
; 
;-

;-----

pro plotman_multi_profile_widget_event, event

widget_control, event.top, get_uvalue=state

widget_control, event.id, get_uvalue=uvalue

if not exist(uvalue) then uvalue='none'

exit = 0

case uvalue of

  'show': begin
    if state.plotman_obj -> get(/plot_type) eq 'image' then begin
      widget_control, state.w_startxy, get_value=startxy
      widget_control, state.w_endxy, get_value=endxy
      state.plotman_obj -> select
      state.plotman_obj -> plot  ; to clear off previous lines may have drawn
      state.plotman_obj -> select  ; re-select, since plot unselects
      oplot, [startxy[0], endxy[0]], [startxy[1], endxy[1]],psym=0, thick=2
      state.plotman_obj -> unselect
    endif else message,'Current panel is not an image',/cont
    end
    
	'cancel': begin
		exit = 1
		end

	'accept': begin
		exit = 1
		; save imgflux structure and contour level and percent selection back in plotman object
		widget_control, state.w_filename, get_value=filename
		widget_control, state.w_startxy, get_value=startxy
		widget_control, state.w_endxy, get_value=endxy
  	state.plotman_obj -> multi_profile, state.panels, p1=startxy, p2=endxy, outfile=filename
		end

	else:

endcase

if exit then widget_control, event.top, /destroy

end

;------------------

pro plotman::multi_profile_widget, group, panels

common profiles2_common, xstart, ystart, xdata, ydata

if xregistered('plotman_multi_profile_widget') then begin
	xmessage,'plotman_multi_profile_widget is already running.  Only one copy allowed.'
	return
endif

filename = 'profiles.sav'
startxy = exist(xstart) ? [xstart,ystart] : [0.,0.]
endxy =   exist(xdata)  ? [xdata,ydata]   : [0.,0.]

tlb = widget_base (group=group, $
					title='Options for multiple profiles', $
					/base_align_center, $
					/column, $
					ypad=5, $
					/frame)
					;/modal )

tmp = widget_label (tlb, value='On entry, x,y positions defining line for profiles default to', /align_left)
tmp = widget_label (tlb, value='last positions used in interactive profiles (if any were made).', /align_left)
tmp = widget_label (tlb, value='  ', /align_center)
tmp = widget_label (tlb, value='Non-image panels and non-conforming image panels will be rejected.', /align_left)
tmp = widget_label (tlb, value='(Since output is an array of structures that must be the same size, ', /align_left)
tmp = widget_label (tlb, value='only images with the same x and y axis can be profiled together.)', /align_left)
tmp = widget_label (tlb, value='  ', /align_center)
tmp = widget_label (tlb, value='For conforming panels, the following will be written in output file:', /align_left)
tmp = widget_label (tlb, value='  line_start, line_end - start x,y and end x,y of line for profile', /align_left)
tmp = widget_label (tlb, value='  array of structures with the following tags:', /align_left)
tmp = widget_label (tlb, value='    dist - distance along profile line', /align_left)
tmp = widget_label (tlb, value='    profile - profile of image along line', /align_left)
tmp = widget_label (tlb, value='    xvals, yvals - x and y elements of image used for profile', /align_left)
tmp = widget_label (tlb, value='      (i.e. profile[i] is equal to image[xvals[i], yvals[i]]', /align_left)
tmp = widget_label (tlb, value='    panel - description of panel', /align_left)
tmp = widget_label (tlb, value=' ')

;
tlb2 = widget_base (tlb, /column, /frame, ypad=10, space=10)

w_use_base = widget_base (tlb2, /row, space=10)

w_startxy = cw_range (w_use_base, label1='Start x: ', label2=' y: ', format='(f10.2)', value=startxy, xsize=10, uvalue='')
w_endxy =   cw_range (w_use_base, label1='End x: ', label2=' y: ', format='(f10.2)', value=endxy, xsize=10, uvalue='')

w_file_base = widget_base ( tlb2, /row)
tmp = widget_label (w_file_base, value='Output file name: ')
w_filename = widget_text (w_file_base, value=filename, xsize=20, /edit)

w_button_base2 = widget_base (tlb2, $
					/row, $
					space=20, ypad=10, /align_center )

tmp = widget_button (w_button_base2, value='Show line', uvalue='show')
          
tmp = widget_button (w_button_base2, value='Cancel', uvalue='cancel')

tmp = widget_button (w_button_base2, value='Accept', uvalue='accept')

state = { $
	plotman_obj: self, $
	panels: panels, $
	filename: filename, $
  w_startxy: w_startxy, $
  w_endxy: w_endxy, $
	w_filename: w_filename $
  }

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=tlb
	widget_control, tlb, xoffset=xoffset, yoffset=yoffset
endif

widget_control, tlb, /realize

widget_control, tlb, set_uvalue=state

xmanager, 'plotman_multi_profile_widget', tlb

return

end





