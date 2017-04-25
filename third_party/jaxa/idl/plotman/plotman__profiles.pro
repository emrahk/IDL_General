;
; Modifications:
;	18-Apr-2001, Kim. Before options for obj_type were HSI_IMAGE, MAP_LIST or else.  Now some of
;		Dominic's map_list image objects are a different class that inherit map_list.
;		Changed options to HSI_IMAGE and else, so assume if not a hessi image, it's one of Dominic's
; 		and will have the methods he provides.  Added catch to catch errors if an object doesn't have
;		the right methods.
;	18-Mar-2002, Kim.  Added angled option
;	6-Jun-2004, Kim.  Fixed bug with synoptic images.  They now inherit map, so don't do extra getdata to
;		get map object.
;	21-Mar-2005, Kim.  Added average keyword
;	29-Mar-2005, Kim.  Modifications to handle spectrograms as well as images - added 'SPECPLOT''
;		object type.  Pass xaxis, yaxis instead of pixel size, origin and all the other parameters
;		needed in old version of profile2.
;	25-Apr-2005, Kim.  Check if specplot is a parent of obj, and if so make class='specplot'.  Also
;		call axis_get_edges instead of mean2edge (doesn't work on reversed axes)
;	25-May-2006, Kim.  added catch,/cancel.
;	18-Mar-2008, Kim.  If *self.data is a struct, get values from struct to construct xaxis,yaxis.
; 24-Jan-2010, Kim.  Print warning that profile is based on original image.

pro plotman::profiles, angled=angled, average=average

catch, error
if error ne 0 then begin
	msg = 'Error in Profiles: ' + !err_string
	print, msg
	a = dialog_message(msg)
	catch,/cancel
	return
endif

msg = ['       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', $
  ' NOTE:  The image used for the profiles is the original image.', $
  '  No translation, smoothing, or roll has been applied.', $
  ' ']
box_message, msg

self -> select

widget_control, self.plot_base, get_uvalue=state

; check if using a saved data set or the original object
if self.use_extracted then begin

	image = *self.saved_data.data
	center = (*self.saved_data.control).xyoffset
	pixel_size = (*self.saved_data.control).pixel_size
	pixel_scale = (*self.saved_data.control).pixel_scale
	xaxis = get_edges(*self.saved_data.xaxis, /edges_1)
	yaxis = get_edges(*self.saved_data.yaxis, /edges_1)

endif else begin

	if not (obj_valid(*self.data))[0] then begin
		image = *self.data
		if is_struct(image) then begin
			center = [image.xc,image.yc]
			pixel_size = [image.dx,image.dy]
			pixel_scale = 1.
			image = image.data
			image_dim = size(image,/dim)
		endif else begin
			image_dim = size(image,/dim)
			center = [image_dim[0]/2., image_dim[1]/2.]
			pixel_size = [1,1]
			pixel_scale = 1.
		endelse
	endif else begin
		image = *self.data -> getdata()
		obj_type = obj_class (*self.data)
		if (where(obj_parents(*self.data) eq 'SPECPLOT'))[0] ne -1 then obj_type = 'SPECPLOT'

		case obj_type of

			'HSI_IMAGE' : begin
			 	image = *self.data -> getdata()
			 	xaxis = *self.data -> getaxis(/xaxis, /edges_1)
			 	yaxis = *self.data -> getaxis(/yaxis, /edges_1)
				end

			'SPECPLOT': begin
				image = *self.data->getdata(frequency=freq)
				utbase = *self.data->get(/utbase)
				xaxis = axis_get_edges(*self.data->get(/xdata))
				yaxis = axis_get_edges(freq)
				end

			else: begin
				;map_obj = *self.data -> getdata()
				image = *self.data -> getdata()
				image_dim = size(image,/dim)
				if n_elements(image_dim) ne 2 then begin
					a=dialog_message('Not a valid image type. Aborting', /error)
					goto, getout
				endif
				center = [ *self.data -> get(/xc), *self.data -> get(/yc) ]
				pixel_size = [ *self.data -> get(/dx), *self.data -> get(/dy) ]

				end

		endcase

	endelse

endelse

if n_elements(xaxis) eq 0 then begin
	xaxis = pixel_size[0] * (FINDGEN( image_dim[0]+1 ) - image_dim[0]/2.) + center[0]
	yaxis = pixel_size[1] * (FINDGEN( image_dim[1]+1 ) - image_dim[1]/2.) + center[1]
endif

save_psym = !p.psym
!p.psym = 0

value = keyword_set(angled) ? ['Left mouse button to change starting point.', $
		'Right mouse button to Exit.'] : $
	['Left mouse button to toggle between rows and columns.', $
		'Right mouse button to Exit.']

widget_control, state.widgets.w_message, $
	set_value=value

profiles2, image, window_id=state.widgets.w_draw, $
	xaxis=xaxis, yaxis=yaxis, utbase=utbase, angled=angled, average=average

!p.psym = save_psym

getout:
self -> unselect

widget_control, state.widgets.w_message, set_value=''

end