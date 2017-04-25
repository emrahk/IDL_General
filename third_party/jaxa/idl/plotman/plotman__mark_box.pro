;+
; Name: plotman_mark_box
;
; Purpose: plotman method with widget to select boxes on an image
;
; Calling sequence:  boxes = plotman_obj -> mark_box ()
;
; Input arguments:
;	list - (2,n) array of x,y vertices for boxes
;	nop - 1-d array of number of items in list per box
;	type - string, type of boxes to draw, e.g. 'Clean', 'Flux'  Used for labels, and if type is 'Flux'
;		then file writing options are displayed in widget
;
;
; Output: structure containing tags list and nop.
;      For each if none defined, they are = 0.
;      If boxes are defined, then list is a fltarr(2,n) where the first
;      dimension is x,y, and nop is the number of points used for each box.
;      (example: a triangle and a rectangle would result in list(2,9), and
;          nop = [4,5]
;
; Method:  User can draw rectangles,
;    circles, or polygons to define clean boxes.
;
; Written:  22-Feb-2001, Kim Tolbert
; Modifications:
;  22-Apr-2001, Kim.  Added polygons and circles.  Use cw_list and cw_nop instead of clean_box
;  6-May-2001, Kim.  Changed from a routine to a plotman method.
;  4-Jun-2001, Kim.  Added initial circle radius box for user.  On call to stretch_circle,
;	 added keywords radius and message_id.
;  5-Jun-2001, Kim.  Added common plotman_mark_box_common and "restore" button.  Saves boxes
;    from previous time routine was called and restores them.
;  13-Jul-2002, Kim.  Added contour option and color choice for boxes
;  18-Jul-2002, Kim.  Use xsel_list_multi to allow multiple selection of boxes to delete
;  21-Jul-2002, Kim.  Added file writing options when type = 'Flux'
;  28-Jul-2002, Kim.  Allowed for larger values of contour level in widget text box
;  02-Aug-2002, Kim.  Added More Info button when type = 'Flux'
;  11-Apr-2003, Kim.  Added inverse option
;  5-Apr-2004,  Kim.  Added option to draw fixed circle at specified center, radius.
;  31-Aug-2004, Kim.  Added Keep button for contours (choose how many contours to keep)
;  9-Jul-2005, Kim.  On Linux, mark box widget wasn't being re-sensitized sometimes (very rarely)
;    after drawing boxes.  I think it's another of those weird timing problems on Linux, so
;    I added a second command to sensitize widget - see if that fixes it.
;  31-Mar-2006, Kim.  Added option to define % contour levels based on currently defined ROIs instead
;    of entire image.  Also changed defaults for radius and center of circle to be 1/5 size of image and
;    position of max element, respectively.
;	3-Apr-2006, Kim.  Add option to delete existing ROIs before adding new contours
;	18-May-2006, Kim.  Added Delete, Restrict buttons, popup widget to choose which ROIs to
;	  use for contours and added Help button.
; 8-Jul-2008, Kim. Use file_search instead of hsi_loc_file to find help file, and call 
;   plotman_oplot_boxes instead of hsi_oplot_clean_boxes (for move to ssw gen)
; 25-Aug-2008, Kim. Added save and restore boxes from sav file capability
; 25-Aug-2008, Kim.  Look for help files in $SSW/gen/idl/plotman/doc after move to gen
; 29-Jul-2014, Kim.  Added fixed rectangle option, and option to click for center for both the
;   fixed rectangle and the fixed circle options.
; 05-Aug-2014, Kim.  Added 'Add adjustable rectangle' option - can specify initial size of rectangle, but
;   then resize and move it with cursor. Changed wording and positioning of widgets. Changed help content.
; 23-Apr-2015, Kim.  Use free_lun instead of close in 'clearfile' block
;-

;-----


pro plotman_mark_box_drawbox, state_box
		state_box.plotman_obj -> select
		state_box.plotman_obj -> plot
		state_box.plotman_obj -> select
		psym=!p.psym
		!p.psym=0
;		hsi_oplot_clean_boxes, 0, 2, 2,state_box.box_color, $
;			cw_pixels=*state_box.vals.cw_list, cw_nop=*state_box.vals.cw_nop, $
;			/labelwindow, thick=2., cw_inverse=*state_box.vals.cw_inverse
    plotman_oplot_boxes, color=state_box.box_color, $
      cw_pixels=*state_box.vals.cw_list, cw_nop=*state_box.vals.cw_nop, $
      /labelwindow, thick=2., cw_inverse=*state_box.vals.cw_inverse
		!p.psym=psym
		wait,.2
		state_box.plotman_obj -> unselect
end

;-----

pro plotman_mark_box_addbox, newbox, state_box

cw_nop = *state_box.vals.cw_nop
cw_list = *state_box.vals.cw_list

if cw_nop[0] le 0 then begin
	cw_list = newbox
	cw_nop = n_elements(newbox[0,*])
endif else begin
	cw_list = [[cw_list], [newbox]]
	cw_nop = [cw_nop, n_elements(newbox[0,*])]
endelse

*state_box.vals.cw_list = cw_list
*state_box.vals.cw_nop = cw_nop
end


;-----

pro plotman_mark_box_delbox, delnum, state_box

cw_nop = *state_box.vals.cw_nop
cw_list = *state_box.vals.cw_list

if (n_elements(cw_nop) eq 1) or (n_elements(delnum) eq n_elements(cw_nop)) then begin
	cw_nop = 0
	cw_list = 0
endif else begin
	cum = [0., cum_sum(cw_nop)]
	for i=0,n_elements(delnum)-1 do rem_ind = append_arr(rem_ind, $
		indgen(cw_nop(delnum[i])*2) + 2*cum(delnum[i]) )
	remove, rem_ind, cw_list
	remove, delnum, cw_nop
	cw_list = reform(cw_list, 2, n_elements(cw_list)/2)
endelse
*state_box.vals.cw_nop = cw_nop
*state_box.vals.cw_list = cw_list

end


;-----

; plotman_mark_box_update updates the widgets with the current values of parameters

pro plotman_mark_box_update, state_box

if (*state_box.vals.cw_nop)[0] eq 0 then ncw = 0 else ncw = n_elements(*state_box.vals.cw_nop)

;nbox = n_elements(*state_box.vals.clean_box)/4 + ncw
nbox = ncw
label = '   Number of boxes defined:  ' + strtrim(nbox,2) + '   '
widget_control, state_box.w_nbox, set_value=label

widget_control, state_box.w_delbox, sensitive=(ncw gt 0)

widget_control, state_box.w_center_rect, sensitive=(state_box.rect_cent_click eq 0)
widget_control, state_box.w_center_rect_click, set_button=state_box.rect_cent_click

widget_control, state_box.w_center_circ, sensitive=(state_box.circ_cent_click eq 0)
widget_control, state_box.w_center_circ_click, set_button=state_box.circ_cent_click

widget_control, state_box.w_contpercenttype, sensitive=(state_box.contpercent eq 1)
widget_control, state_box.w_contpercenttype, get_value=contpercenttype
widget_control, state_box.w_delroi, sensitive=(state_box.contpercent eq 1) and (contpercenttype eq 1)
widget_control, state_box.w_restrictcont, sensitive=(state_box.contpercent eq 1) and (contpercenttype eq 1)

if xalive(state_box.w_filename) then widget_control, state_box.w_filename, sensitive=state_box.imgflux.writefile
if xalive(state_box.w_append) then widget_control, state_box.w_append, sensitive=state_box.imgflux.writefile
if xalive(state_box.w_clear_file) then widget_control, state_box.w_clear_file, sensitive=state_box.imgflux.writefile



end

;-----

; plotman_mark_box_event handles events from the widget

pro plotman_mark_box_event, event

common plotman_mark_box_common, boxes_save

;help,event,/st

widget_control, event.top, get_uvalue=state_box

widget_control, event.id, get_uvalue=uvalue

if not exist(uvalue) then uvalue='none'

cancel = 0
exit = 0

case uvalue of

	'delbox': begin
		cw_nop = *state_box.vals.cw_nop
		ncw = n_elements(cw_nop)
		delnum = xsel_list_multi (strtrim(indgen(ncw),2), /index, title='Select Box to Delete', $
			label='Select Box #(s) to Delete:  ', group=event.top, cancel=cancel_del)
		if not cancel_del then begin
			plotman_mark_box_delbox, delnum, state_box
			plotman_mark_box_drawbox, state_box
		endif
		end

	'newrect': begin
		state_box.plotman_obj -> select
		widget_control, event.top, sensitive=0
    widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
		b = stretch_box (state.widgets.w_draw, /data, color=state_box.box_color)
		; do twice for linux
		widget_control, event.top, sensitive=1
		widget_control, event.top, sensitive=1
		newbox = [ [b[*,0]], [b[0,1],b[1,0]], [b[*,1]], [b[0,0],b[1,1]], [b[*,0]] ]
		plotman_mark_box_addbox, newbox, state_box
		end

  'adjrect': begin
    state_box.plotman_obj -> select
    widget_control, event.top, sensitive=0
    widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
    widget_control, state_box.w_size_rect, get_value=rsize    
    newbox = stretch_box2 (state.widgets.w_draw, /data, color=state_box.box_color, $
      message_id=state.widgets.w_message, xsize=rsize[0], ysize=rsize[1])
    plotman_mark_box_addbox, newbox, state_box
    ; do twice for linux
    widget_control, event.top, sensitive=1
    widget_control, event.top, sensitive=1
  end
    
  'fixedrect': begin
    if state_box.rect_cent_click then begin
      state_box.plotman_obj -> select
      widget_control, event.top, sensitive=0
      widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
      bcent = get_xy_pos(state.widgets.w_draw, count=count)
      ; do twice for linux
      widget_control, event.top, sensitive=1
      widget_control, event.top, sensitive=1
    endif else begin
      widget_control, state_box.w_center_rect, get_value=bcent
      count = 1
    endelse
    if count gt 0 then begin
      widget_control, state_box.w_size_rect, get_value=rsize
      xs = rsize[0] / 2.
      ys = rsize[1] / 2.
      for ii=0,count-1 do begin
        bx = bcent[0,ii] + xs * [-1.,1.]
        by = bcent[1,ii] + ys * [-1.,1.]
        newbox = [[bx[0],by[0]], [bx[1],by[0]], [bx[1],by[1]], [bx[0],by[1]], [bx[0],by[0]]]
        plotman_mark_box_addbox, newbox, state_box
      endfor
    endif
    end
    
  'rectclick': state_box.rect_cent_click = event.select
    
	'adjcirc': begin
		state_box.plotman_obj -> select
		widget_control, event.top, sensitive=0
        widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
        widget_control, state_box.w_circradius, get_value=radius
        if valid_num(radius[0],value) then radius = value else begin
        	radius = 10.
        	message, 'Invalid initial radius specified.  Using 10.', /cont
        endelse
		newbox = stretch_circle (state.widgets.w_draw, /data, color=state_box.box_color, $
			message_id=state.widgets.w_message, radius=radius)
		plotman_mark_box_addbox, newbox, state_box
		; do twice for linux
		widget_control, event.top, sensitive=1
		widget_control, event.top, sensitive=1
		end

	'fixedcirc': begin		
		widget_control, state_box.w_circradius, get_value=radius
		rad = 0.
		if valid_num(radius[0],value) then rad = value
		if rad eq 0. then begin
        	message, 'Invalid radius specified.', /cont
        	return
    endif
    if state_box.circ_cent_click then begin
      state_box.plotman_obj -> select
      widget_control, event.top, sensitive=0
      widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
      bcent = get_xy_pos(state.widgets.w_draw, count=count)
      ; do twice for linux
      widget_control, event.top, sensitive=1
      widget_control, event.top, sensitive=1
    endif else begin
      widget_control, state_box.w_center_circ, get_value=bcent
      count = 1
    endelse
    if count gt 0 then begin
      theta = indgen(20)*2*!pi / (19-1)
      for ii=0,count-1 do begin
		    xarr = rad * sin(theta) + bcent[0,ii]
		    yarr = rad * cos(theta) + bcent[1,ii]
		    plotman_mark_box_addbox, transpose([[xarr],[yarr]]), state_box
		  endfor
		endif
		plotman_mark_box_drawbox, state_box
		end

  'circclick': state_box.circ_cent_click = event.select
  
	'newpoly': begin
		state_box.plotman_obj -> select
		widget_control, event.top, sensitive=0
                widget_control, state_box.plotman_obj -> get(/plot_base), get_uvalue=state
		newbox = mark_poly (state.widgets.w_draw, /data, color=state_box.box_color)
		plotman_mark_box_addbox, newbox, state_box
		; do twice for linux
		widget_control, event.top, sensitive=1
		widget_control, event.top, sensitive=1
		end

	'drawcont': begin
		widget_control, state_box.w_contlevel, get_value=level
		delroi = widget_info(state_box.w_delroi,/button_set)
		restrict = widget_info(state_box.w_restrictcont, /button_set)
		image_info = state_box.plotman_obj -> get(/image_info)
		if state_box.contpercent then begin

			widget_control, state_box.w_contpercenttype, get_value=contpercenttype

			case contpercenttype of	; 0 is use max of full image, 1 is use max of ROIs

				0: begin
					maxval = max(image_info.image)
					restrict = 0
					delroi = 0
				end

				1: begin
					i1=0
					boxes = state_box.vals
					cw_nop = *boxes.cw_nop
					if cw_nop[0] eq 0 then begin
						message, 'No ROIs defined yet.  No contours drawn.', /cont
						return
					endif

					ncw = n_elements(cw_nop)
					if ncw eq 1 then begin
						selnum = 0
					endif else begin
						selnum = xsel_list_multi (strtrim(indgen(ncw),2), /index, title='Select Box to Use', $
							label='Select Box #(s) to Use:  ', initial=indgen(ncw), group=event.top, cancel=cancel_sel)
						if cancel_sel then return
					endelse

					image = image_info.image

					; find max in all of selected ROIs
					maxval = -999.
					dim = size(image,/dim)
					masked_image = restrict ? image * 0. + min(image) : image
					for i=0,ncw-1 do begin
						i2 = i1 + cw_nop[i] -1 > 0
						if is_member (i, selnum) then begin
							index = (*boxes.cw_list)[*,i1:i2]
							xpix = value_locate(image_info.xvals, index[0,*] ) > 0
							ypix = value_locate(image_info.yvals, index[1,*] ) > 0
							roi = polyfillv(xpix, ypix, dim[0], dim[1])
							; if roi=-1, just use xpix ypix elements, no inner area found
							thismax = roi[0] eq -1 ? max(image[xpix,ypix]) : max(image[roi])
							maxval = maxval > thismax

							if restrict and (roi[0] ne -1) then masked_image[roi] = image[roi]
						endif
						i1 = i2+1
					endfor
				end
			endcase
			level = level * maxval / 100.
			;print,'max = ', maxval, '  level = ', level
		endif
		; if requested, delete existing ROIs before saving contours.
		if delroi then plotman_mark_box_delbox, selnum, state_box
;			*(state_box.vals.clean_box) = 0
;			*(state_box.vals.cw_list) = 0
;			*(state_box.vals.cw_nop) = 0
;		endif

		mid = image_info.pixel_size / 2.
		contour, (restrict ? masked_image : image_info.image), image_info.xvals+mid[0], image_info.yvals+mid[1], $
			level=level, path_xy=path_xy, /path_data, path_info=path_info
		if n_elements(path_info) ge 1 then begin
			; only save number of contours requested
			contkeep = widget_info (state_box.w_contkeep, /droplist_select)
			nkeep = (contkeep eq 0) ? 999 : fix(contkeep)	; 0 means all
			for i=0,(n_elements(path_info) < nkeep)-1 do begin
				i1 = path_info[i].offset & i2 = i1 + path_info[i].n - 1
				newbox = path_xy[*,i1:i2]
				plotman_mark_box_addbox, newbox, state_box
			endfor
		endif else message,'No contours defined.', /info
		end

	'contpercent': state_box.contpercent = event.select

	'box_color': begin
		cn = state_box.plotman_obj -> get(/color_names)
		state_box.box_color = cn.(event.index)
		end

	'inverse': begin
		newbox = 1  ; set to something just to get it to redraw boxes
		*state_box.vals.cw_inverse = event.select
		end

	'writefile': state_box.imgflux.writefile = event.select

	;'filename': state_box.imgflux.filename = event.value

	'append': state_box.imgflux.append = event.select

	'clearfile': begin
		; to erase the contents of the file, just open for writing, and close
		widget_control, state_box.w_filename, get_value=filename
		openw, lun, filename, /get_lun
		free_lun, lun
		end
		
	'save_in_file': begin

		file = ssw_pickfile(file='save_boxes.sav', $
			title='Select file to save boxes in', filter='*.sav', get_path=path )
		if file ne '' and test_dir(path) then begin
		  boxes_savefile = {clean_box: ptr_new(0), $
        cw_list: ptr_new(*(state_box.vals.cw_list)), $
        cw_nop: ptr_new(*(state_box.vals.cw_nop)), $
        cw_inverse: ptr_new(*(state_box.vals.cw_inverse)) }
		  save, file=file, boxes_savefile 
		endif else message, 'No file selected, or can not write in selected directory.  Aborting.', /cont
		end
		
	'restore_from_file': begin
		file = ssw_pickfile(file='save_boxes.sav', $
			title='Select file to restore boxes from', filter='*.sav', exists=exists)
		if exists then begin
			restore, file=file
			if exist(boxes_savefile) then begin
				*(state_box.vals.clean_box)  = *boxes_savefile.clean_box
				*(state_box.vals.cw_list)  = *boxes_savefile.cw_list
				*(state_box.vals.cw_nop)  = *boxes_savefile.cw_nop
				*(state_box.vals.cw_inverse) = *boxes_savefile.cw_inverse
				plotman_mark_box_drawbox, state_box
			endif else message, 'Selected file does not contain boxes. Aborting.', /cont
		endif else message, 'No file selected or selected file does not exist. Aborting.', /cont
		end
		
	'restore': begin
		if (*boxes_save.cw_nop)[0] le 0 then begin
			msg = 'There are no previous boxes to restore.'
			message, msg, /cont
			a = dialog_message(msg)
		endif else begin
			*(state_box.vals.clean_box)  = *boxes_save.clean_box
			*(state_box.vals.cw_list)  = *boxes_save.cw_list
			*(state_box.vals.cw_nop)  = *boxes_save.cw_nop
			*(state_box.vals.cw_inverse) = *boxes_save.cw_inverse
			plotman_mark_box_drawbox, state_box
		endelse
		end

	'drawboxes': begin
		plotman_mark_box_drawbox, state_box
		end

	'delall': begin
		*(state_box.vals.clean_box) = 0
		*(state_box.vals.cw_list) = 0
		*(state_box.vals.cw_nop) = 0
		plotman_mark_box_drawbox, state_box
		end

	'help': begin
	  check = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'mark_box_widget_help.txt')
    file = file_search (check, count=count)
		if count gt 0 then begin
			msg = rd_ascii(file[0], error=error)
			if not error then a = dialog_message(wrap_txt(msg, length=130, delim=' ', /no_dollar), /info)
		endif else error=1

		if error then a = dialog_message('Error finding or reading info file ' + check)
		end

	'table_info': begin
	  check = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'image_flux_info.txt')
    file = file_search (check, count=count)
		if count gt 0 then begin
			msg = rd_ascii(file[0], error=error)
			if not error then a = dialog_message(msg, /info)
		endif else error=1

		if error then a = dialog_message('Error finding or reading info file ' + check)
		end

	'cancel': begin
		*(state_box.vals.clean_box)  = state_box.orig_vals.clean_box
		*(state_box.vals.cw_list)  = state_box.orig_vals.cw_list
		*(state_box.vals.cw_nop)  = state_box.orig_vals.cw_nop
		*(state_box.vals.cw_inverse) = state_box.orig_vals.cw_inverse
		cancel = 1
		exit = 1
		end

	'accept': begin
		exit = 1

		; save imgflux structure and contour level and percent selection back in plotman object
		if size(state_box.imgflux, /tname) eq 'STRUCT' then begin
			widget_control, state_box.w_filename, get_value=filename
			state_box.imgflux.filename = filename
			state_box.plotman_obj -> set, imgflux = state_box.imgflux
		endif
		widget_control, state_box.w_contlevel, get_value=level
		state_box.plotman_obj -> set, mark_box_contour_level=level, mark_box_contour_percent=state_box.contpercent

		; save in common
		free_var, boxes_save
		boxes_save = {clean_box: ptr_new(0), $
					cw_list: ptr_new(*(state_box.vals.cw_list)), $
					cw_nop: ptr_new(*(state_box.vals.cw_nop)), $
					cw_inverse: ptr_new(*(state_box.vals.cw_inverse)) }
		end

	else:

endcase

if not cancel then begin

	if exist(newbox) then begin

		plotman_mark_box_drawbox, state_box
	endif

	plotman_mark_box_update, state_box
endif

*(state_box.cancel) = cancel

if exit then widget_control, event.top, /destroy else $
	widget_control, event.top, set_uvalue=state_box


end

;------------------

; plotman method mark_box - main routine that presents the clean options widget

function plotman::mark_box, list=list, nop=nop, inverse=inverse, cancel=cancel, type=type

common plotman_mark_box_common, boxes_save

if xregistered('plotman_mark_box') then begin
	cancel = 1
	xmessage,'plotman_mark_box is already running.  Only one copy allowed.'
	return,-1
endif

cancel = 0

checkvar, type, ''

group = self.plot_base

box_color = self -> get (/cyan)

; Set default center for fixed circles and rectangles to pixel with max value
image_info = self->get(/image_info)
radius = ( max(image_info.xvals) - min(image_info.xvals) ) / 5.
dim = size(image_info.image, /dim)
im_max = max(image_info.image, index_1d)
index_2d = get_ij(index_1d, dim[0])
mid = image_info.pixel_size / 2.
center_xy = [ image_info.xvals[index_2d[0]] + mid[0], image_info.yvals[index_2d[1]] + mid[1] ]

rect_cent_click = 1
circ_cent_click = 1

if keyword_set(list) then begin
	checkvar, nop, n_elements(list)
	checkvar, inverse, 0
	vals = {clean_box: ptr_new(0), $
			cw_list: ptr_new(list), $
			cw_nop: ptr_new(nop), $
			cw_inverse: ptr_new(inverse) }

	orig_vals = {clean_box: 0, $
			cw_list: list, $
			cw_nop: nop, $
			cw_inverse: inverse }
endif else begin
	vals = {clean_box: ptr_new(0), $
			cw_list: ptr_new(0), $
			cw_nop: ptr_new(0), $
			cw_inverse: ptr_new(0) }

	orig_vals = {clean_box: 0, $
			cw_list: 0, $
			cw_nop: 0, $
			cw_inverse: 0 }
endelse

if not exist(boxes_save) then boxes_save = {clean_box: ptr_new(0), $
			cw_list: ptr_new(0), $
			cw_nop: ptr_new(0), $
			cw_inverse: ptr_new(0) }

tlb = widget_base (group=group, $
					title='Mark ' + type + ' Boxes', $
					/base_align_center, $
					/column, $
					ypad=1, $
					space=5, $
					/frame)
					;/modal )

tmp = widget_label (tlb, value = 'Define / Modify ' + type + ' Boxes' )

tlb2 = widget_base (tlb, /column, /frame)
tlb3 = widget_base (tlb2, /column, /frame, ypad=5)

w_nbox = widget_label (tlb3, value='', /dynamic_resize, /frame)

w_button_base1 = widget_base (tlb3, $
					/column, $
					space=1 )

w_rectbase = widget_base (w_button_base1, /column, ypad=5)

w_rectbase0 = widget_base(w_rectbase, /row, space=10)
tmp = widget_button (w_rectbase0, $
					value='Draw Rectangle', uvalue='newrect' )
tmp = widget_label (w_rectbase0, value='Left-click and drag to draw box.')


w_rectbase1 = widget_base(w_rectbase, /row)
w_size_rect = cw_range(w_rectbase1, $
  uvalue='rect_xy', $
  label1='Rectangle Size X: ', $
  label2=' Y: ', $
  value=radius*2. + [0.,0.], $
  format='(f9.3)', $
  xsize=9, $
  xpad=0, $
  ypad=0, $
  space=0 )
w_center_rect = cw_range(w_rectbase1, $
  uvalue='rect_center', $
  label1='Center X: ', $
  label2=' Y: ', $
  value=center_xy, $
  format='(f9.3)', $
  xsize=9, $
  xpad=0, $
  ypad=0, $
  space=0 )

w_adjrectbase = widget_base (w_rectbase, /row, space=10)
tmp = widget_button (w_adjrectbase, value='Add Adjustable Rectangle', uvalue='adjrect' )
tmp = widget_label (w_adjrectbase, value='Drag, left-click and drag to resize, right-click to finish.')
    
w_rectbase2 = widget_base(w_rectbase, /row, space=10)
tmp = widget_button (w_rectbase2, value='Add Fixed Rectangle', uvalue='fixedrect')
w_center_rect_click_base = widget_base (w_rectbase2, /nonexclusive, /row, space=0)
w_center_rect_click = widget_button (w_center_rect_click_base, $
  value='Click for Center (Left-click one or more centers, right-click to finish)', uvalue='rectclick')
;tmp = widget_label(w_rectbase2, value='(Left-click one or more centers, right-click to finish.')


w_circbase = widget_base (w_button_base1, /column, ypad=5)

w_fixedcirc_base0 = widget_base(w_circbase, /row)
w_circradius = cw_field (w_fixedcirc_base0, $
  title='Circle Radius: ', $
  value=radius, $
  xsize=6, $
  /return_events, $
  uvalue='circradius')
w_center_circ = cw_range (w_fixedcirc_base0, $
  uvalue='circ_center', $
  label1='Center X: ', $
  label2=' Y: ', $
  value=center_xy, $
  format='(f9.3)', $
  xsize=9, $
  xpad=0, $
  ypad=0, $
  space=0 )

w_adjcircbase = widget_base (w_circbase, /row, space=10)
tmp = widget_button (w_adjcircbase, value='Add Adjustable Circle', uvalue='adjcirc' )
tmp = widget_label (w_adjcircbase, value='Drag, left-click and drag to resize, right-click to finish.')

w_fixedcirc_base1 = widget_base(w_circbase, /row, space=10)
tmp = widget_button (w_fixedcirc_base1, value='Add Fixed Circle', uvalue='fixedcirc')
w_center_circ_click_base = widget_base (w_fixedcirc_base1, /nonexclusive, /row, space=0)
w_center_circ_click = widget_button (w_center_circ_click_base, $
  value='Click for Center (Left-click one or more centers, right-click to finish)', uvalue='circclick')
;tmp = widget_label(w_fixedcirc_base1, value='Left-click one or more centers, right-click to finish.')

w_polybase = widget_base (w_button_base1, /row, space=10, ypad=5)

tmp = widget_button (w_polybase, $
					value='Add Polygon', uvalue='newpoly' )

tmp = widget_label (w_polybase, value='Left-click on vertices, right-click to finish.')

w_contbase = widget_base (w_button_base1, /row, space=10, /frame)

w_cont = widget_button (w_contbase, value='Draw Contour', uvalue='drawcont', /align_center)

w_contopt = widget_base (w_contbase, /column)
w_contopt1 = widget_base (w_contopt, /row)

level = self.mark_box_contour_level
alevel = level lt 10000. ? trim(level, '(f8.2)') : trim(level, '(g12.5)')
w_contlevel = cw_field (w_contopt1, $
					title='Contour Level: ', $
					value=alevel, $
					xsize=12, $
					/return_events, $
					uvalue='contlevel')

keep_str = [' All new contours', 'First ' + trim(indgen(9)+1,'(i3)') + ' contours']

w_contkeep = widget_droplist (w_contopt1, title='Keep: ', value=keep_str, uvalue='contkeep')

w_contopt2 = widget_base (w_contopt, /row)

contpercent = self.mark_box_contour_percent
w_cont_perc_base = widget_base (w_contopt2, /nonexclusive, /row)
w_contpercent = widget_button (w_cont_perc_base, value='% max in ', uvalue='contpercent')
widget_control, w_contpercent, set_button = contpercent
w_contpercenttype = cw_bgroup (w_contopt2, ['full image', 'ROIs'], button_uvalue=['full','roi'], $
	/row, /exclusive, /no_release, uvalue='contpercenttype')
widget_control, w_contpercenttype, set_value=0
w_delroi_base = widget_base (w_contopt2, /nonexclusive, /row)
w_delroi = widget_button (w_delroi_base, value='Delete', uvalue='deloldroi')
w_restrict_base = widget_base (w_contopt2, /nonexclusive, /row)
w_restrictcont = widget_button (w_restrict_base, value='Restrict', uvalue='restrictcont')


w_delbase = widget_base (w_button_base1, /row, space=10)

w_delbox = widget_button (w_delbase, value='Delete Boxes', uvalue='delbox')
tmp = widget_label (w_delbase, value='Popup window will let you choose boxes.')

colors = tag_names(self -> get(/color_names))
q = where (colors eq 'CYAN')
w_box_color = widget_droplist (w_delbase, $
					title='Outline Color: ', $
					value=colors, $
					uvalue='box_color')
widget_control, w_box_color, set_droplist_select=q[0]


if type eq 'Flux' then begin

	w_inversebase = widget_base(w_button_base1, /row, /nonexclusive)
	w_inverse = widget_button (w_inversebase, value='Inverse Boxes (use area outside box)', uvalue='inverse')
	widget_control, w_inverse, set_button = *vals.cw_inverse

	imgflux = self->get(/imgflux)
	w_file_base = widget_base ( w_button_base1, /row)
	w_writefile_base = widget_base(w_file_base, /nonexclusive, /row)
	w_writefile = widget_button (w_writefile_base, value='Write to File: ', uvalue='writefile')
	widget_control, w_writefile, set_button=imgflux.writefile
	w_filename = widget_text (w_file_base, value=imgflux.filename, /edit)
	w_append_base = widget_base (w_file_base, /nonexclusive, /row)
	w_append = widget_button (w_append_base, value='Append', uvalue='append')
	widget_control, w_append, set_button=imgflux.append
	w_clear_file = widget_button (w_file_base, value='Clear file', uvalue='clearfile')
endif else begin
	w_writefile = 0L
	w_filename = 0L
	w_append = 0L
	w_clear_file = 0L
	imgflux = -1
endelse

w_button_base2 = widget_base (tlb2, $
					/row, $
					space=5, ypad=1, /align_center )

tmp = widget_button (w_button_base2, $
					value='Save boxes in file', uvalue='save_in_file')
w_restore = widget_button (w_button_base2, $
					value='Restore boxes from file', uvalue='restore_from_file')
w_restore = widget_button (w_button_base2, $
					value='Restore previous boxes', uvalue='restore')

;w_button_base2a = widget_base (tlb2, $
;					/row, $
;					space=20, ypad=1, /align_center )
					
w_drawbox = widget_button (w_button_base2, $
					value='Draw boxes', uvalue='drawboxes' )

w_delall = widget_button (w_button_base2, $
					value='Delete all boxes', uvalue='delall' )

w_button_base3 = widget_base (tlb2, $
					/row, $
					space=20, ypad=1, /align_center )


tmp = widget_button (w_button_base3, value='Help', uvalue='help')

if type eq 'Flux' then tmp = widget_button (w_button_base3, value='Flux Table Info', uvalue='table_info')

tmp = widget_button (w_button_base3, $
					value='Cancel', uvalue='cancel')

tmp = widget_button (w_button_base3, $
					value='Accept', uvalue='accept')

state_box = { $
	plotman_obj: self, $
	box_color: box_color, $
	w_nbox: w_nbox, $
	w_center_rect_click: w_center_rect_click, $
	w_center_rect: w_center_rect, $
	w_size_rect: w_size_rect, $
	w_center_circ_click: w_center_circ_click, $	
	w_center_circ: w_center_circ, $
	w_circradius: w_circradius, $
	w_contlevel: w_contlevel, $
	w_contpercent: w_contpercent, $
	w_contpercenttype: w_contpercenttype, $
	w_contkeep: w_contkeep, $
	w_delroi: w_delroi, $
	w_restrictcont: w_restrictcont, $
	w_delbox: w_delbox, $
	w_writefile: w_writefile, $
	w_filename: w_filename, $
	w_append: w_append, $
	w_clear_file: w_clear_file, $
	rect_cent_click: rect_cent_click, $
	circ_cent_click: circ_cent_click, $
	contpercent: contpercent, $
	imgflux: imgflux, $
	vals: vals, $
	orig_vals: orig_vals, $
	cancel: ptr_new(0) }

plotman_mark_box_update, state_box

plotman_mark_box_drawbox, state_box

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=tlb
	widget_control, tlb, xoffset=xoffset, yoffset=yoffset
endif

widget_control, tlb, /realize

widget_control, tlb, set_uvalue=state_box

xmanager, 'plotman_mark_box', tlb

clean_box = *vals.clean_box
list = *vals.cw_list
nop = *vals.cw_nop
inverse = *vals.cw_inverse
ret = { $
		list: list, $
		nop: nop, $
		inverse: inverse }

cancel = *state_box.cancel

ptr_free, vals.clean_box, vals.cw_list, vals.cw_nop, vals.cw_inverse, state_box.cancel

return, ret

end





