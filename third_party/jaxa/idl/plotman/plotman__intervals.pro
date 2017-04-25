; Modifications:
;   9-Mar-2001 - Kim, If right click and previous click is none, then return
;   29-Jun-2001 - Kim, Use w_draw's parent as group in call to popup_menu.  This should
;     fix the probelm on Solaris where it crashes all the way out of IDL with multiple
;     messages: 'X windows protocol error: BadWindow (invalid Window parameter)'
;   31-Aug-2001 - Kim.  Set intervals passed in through calling arguments into the
;	  plotman object, so if user cancels interval widget, plotman has the initial
;	  intervals stored.
;   18-Nov-2001, Kim.  Added send_widget keyword.  On exit, send an event to this widget
;     to indicate the interval selection is completed.  Intervals are stored in plotman object.
;	6-Dec-2001, Kim.  On cancel store -1 in intervals in plotman, not original intervals.
;	13-Mar-2003, Kim.  Use edges_2 keyword on getaxis call
;	19-Mar-2003, Kim.  Changed handling of force to data bound. option so that it works even when
;	  making sub-intervals with popup options (previously only worked on right and left click).
;	  Also added 'Adjust to data boundaries' button to make it effect all existing intervals.
;	  Added a text help window.
;	  Added option in popup options to divide an interval into sub-intervals by grouping data bins.
;	16-Mar-2004, Kim.  Return -99 when users presses 'cancel'
;	25-Mar-2005, Kim.  Changed max_intervals default to 10000 (from 2000)
;	10-Jan-2006, Kim.  In plotman_intervals_event, check xalive(w_draw), to prevent crash if new
;	  plot was drawn in the plotman window
;	20-Jul-2006, Kim.  Fix bug where using relist variable even if already exited.
;	30-Nov-2007, Kim.  Segmentation fault in linux corrected.  Failed at end of the cleanup called
;	  automatically when widget destroyed.  Leave cleanup setting on xmanager - if widget is killed
;	  via x button, need to reset the draw window.  But now if exit normally, undo auto cleanup
;	  and call cleanup directly before destroying widget.
;	14-Feb-2008, Kim.  Added no_replot keyword so plot doesn't get redrawn when show_start is set.
; 6-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont to remove hessi dependencies.
;     and use file_search instead of hsi_loc_file to find help file (for move to ssw gen)
; 18-Aug-2008, Kim. Added option to merge intervals. User double-clicks in start interval and
;     selectes merge in popup widget.  Next right-click identifies end interval to merge.  Can
;     be before or after start interval.  If don't right-click next, merge is cancelled.  Both
;     clicks must be on existing intervals.
; 25-Aug-2008, Kim.  Look for help files in $SSW/gen/idl/plotman/doc after move to gen
; 28-Oct-2013, Kim. Added widget_control/show in several places to make selection widget come to front
;
;-----

function which_interval, x, int_info, desc=desc, previous=previous, next=next

se = *int_info.se
nint = int_info.nint

if keyword_set(previous) then begin
	if nint le 0 then count = 0 else $
	q = reverse(where (x ge se[1,0:nint-1], count))
endif else begin
	if keyword_set(next) then begin
		if nint le 0 then count = 0 else $
		q = where (x le se[0,0:nint-1], count)
	endif else begin
		if nint le 0 then count = 0 else $
			q = where (x ge se[0,0:nint-1] and x le se[1,0:nint-1], count)
	endelse
endelse

if count eq 0 then begin
	int = -1
	desc = 'None'
endif else begin
	int = q(0)
	desc = plotman_format_int (int_index=int, int_info)
endelse

;print,'interval = ', int
return, int

end

;----------------------------------------------------------------------------------------------------------------------------------------

pro cleanup_intervals, widget_id

;print,'In cleanup_intervals'
widget_control, widget_id, get_uvalue=w_info
if xalive(w_info.w_draw) then begin
	widget_control, w_info.w_draw, get_uvalue=int_info

	int_info.plotman_obj -> select
	device,set_graphics = int_info.sav_graphics
	int_info.plotman_obj -> unselect

	;print, 'resetting to event_pro = ', int_info.sav_event_pro
	widget_control, w_info.w_draw, event_pro=int_info.sav_event_pro, $
		event_func=int_info.sav_event_func, $
		draw_button_events=int_info.sav_draw_button_events, $
		draw_motion_events=int_info.sav_draw_motion_events

	widget_control, int_info.w_message, set_value=''
endif

end

;----------------------------------------------------------------------------------------------------------------------------------------

function move_interval_event, event
;print,'in move_interval_event function'
;help,event,/st
return,event

end

pro plotman_intervals_move_event, event

;print,'in plotman_intervals_move_event'
;help,event,/st
this_event = tag_names (event, /structure)
if (this_event eq 'WIDGET_TIMER')  then return   ; event might be leftover timer from double-click detector

w_draw = event.id

widget_control, w_draw, get_uvalue=int_info
if int_info.nint eq 0 then return  ; no intervals defined yet.

d = convert_coord  (event.x, event.y, /device,/to_data)	; get point clicked in data coordinates
xrange = crange('x')
if d[0] lt xrange[0] or d[0] gt xrange[1] then return

int = which_interval ( d[0], int_info, desc=desc)	; determine which interval was clicked on
if int eq -1 then return

device, get_graphics = sav_graphics
sav_draw_motion_events = widget_info(w_draw, /draw_motion_events)
sav_draw_button_events = widget_info(w_draw, /draw_button_events)
widget_control, w_draw, /draw_motion_events, /draw_button_events, $
	event_pro='', event_func='move_interval_event'

se = *int_info.se
nint = int_info.nint

int_info.new_se = se(*,int)
sav_se = int_info.new_se

loop = 1
dfirst = -1
while loop do begin

	wait, .1

	ev = widget_event (w_draw)
	;print,'just after call to widget_event'
	;help,ev,/st

	if ev.release eq 0 then begin

		; plotman_draw_int selects plotman window, and then unselects it every time.
		plotman_draw_int, 'interval', int_index=int, int_info, /erase

		int_info.plotman_obj -> select

		d = convert_coord  (ev.x, ev.y, /device,/to_data)
		if dfirst eq -1 then dfirst = d[0]

		case int_info.popup_choice of
			'moves': int_info.new_se[0] = d[0] < int_info.new_se[1]
			'movee': int_info.new_se[1] = d[0] > int_info.new_se[0]
			'movei': int_info.new_se = sav_se + (d[0]-dfirst)
		endcase
		(*int_info.se)[*,int] = int_info.new_se
		plotman_draw_int, 'interval', int_info
	endif else begin

		loop = 0

	endelse

endwhile

plotman_modify_int, 'nothing', int_info, data_bound=int_info.data_bound  ; call again with no action just to clean up and sort
plotman_list_int, int_info
int_info.plotman_obj -> select
int_info.plotman_obj -> plot
plotman_draw_int, 'all', int_info

int_info.plotman_obj -> select
device,set_graphics = sav_graphics
int_info.plotman_obj -> unselect

widget_control, w_draw, draw_button_events=sav_draw_button_events, $
		draw_motion_events=sav_draw_motion_events, $
		event_func='',  event_pro='plotman_intervals_draw_event'

widget_control, w_draw, set_uvalue=int_info
widget_control, int_info.interval_tlb, /show


end


;----------------------------------------------------------------------------------------------------------------------------------------

pro edit_int, int_index=int_index, int_info

plotman_edit_int, int_index=int_index, int_info, err_msg=err_msg

if err_msg eq '' then begin
	int_info.plotman_obj -> select
	int_info.plotman_obj -> plot
	plotman_draw_int, 'all', int_info
endif

return

end


;----------------------------------------------------------------------------------------------------------------------------------------

pro plotman_intervals_event, event

;print,'in plotman_intervals_event'
;help,event,/st


widget_control, event.top, get_uvalue=w_info
w_draw = w_info.w_draw
if not xalive(w_draw) then begin
	print,'Warning - Plot window has been changed.  Exiting interval selection widget.'
	widget_control, event.top, /destroy
	return
endif

widget_control, w_draw, get_uvalue= int_info

if tag_names(event,/struc) eq 'WIDGET_KILL_REQUEST' then begin
	exit = 1
	goto, getout
endif

;print, ' nint = ', int_info.nint
;print, anytim(*int_info.se, /vms)

widget_control, event.id, get_uvalue=uvalue

exit = 0
relist = 0
case uvalue of

	'deletesel': begin
		index = widget_info (int_info.w_list, /droplist_select)
		plotman_modify_int, 'delete', int_info, int_index=index
		relist = 1
		int_info.plotman_obj -> select
		int_info.plotman_obj -> plot
		plotman_draw_int, 'all', int_info
		widget_control, w_draw, set_uvalue=int_info
		end

	'editsel': begin
		index = widget_info (int_info.w_list, /droplist_select)
		edit_int, int_index=index, int_info
		relist = 1
		widget_control, w_draw, set_uvalue=int_info
		end

	'editlist': begin
		edit_int, int_info
		relist = 1
		widget_control, w_draw, set_uvalue=int_info
		end

	'contiguous': begin
		int_info.contiguous = event.select
		widget_control, w_draw, set_uvalue= int_info
		end

	'force': begin
		int_info.data_bound = event.select
		if int_info.data_bound and int_info.xaxis[0] eq -1 then begin
				a=dialog_message("Can't get x axis information for this type of data.")
				int_info.data_bound = 0
		endif
		widget_control, w_draw, set_uvalue=int_info
		end

	'move_data': begin
		if int_info.xaxis[0] eq -1 then begin
			a=dialog_message("Can't get x axis information for this type of data.")
		endif else begin
			plotman_modify_int, 'Nothing', int_info, /data_bound
			int_info.plotman_obj -> select
			int_info.plotman_obj -> plot
			plotman_draw_int, 'all', int_info
			plotman_list_int, int_info
		endelse
		end

	'help': begin
		;gui_help, 'gui_intervals_help.htm'

;		file = hsi_loc_file('plotman_intervals_help.txt', path='$HSI_DOC', count=count,/no_dialog)
    check = concat_dir(local_name('$SSW/gen/idl/plotman/doc'), 'plotman_intervals_help.txt')
    file = file_search (check, count=count)

		if count gt 0 then begin
		 text = rd_ascii(file[0], error=error)
		 if not error then dummy = dialog_message(text,title='HELP for plotman intervals',/info)
		endif else error = 1

		if error then dummy=dialog_message('Error opening or reading help file ' + check)

		end

	'display': begin
		int_info.plotman_obj -> select
		int_info.plotman_obj -> plot
		plotman_draw_int, 'all', int_info
		end

	'deleteall': begin
		int_info.plotman_obj -> select
		int_info.plotman_obj -> plot
		plotman_modify_int, 'delete', int_info
		relist = 1
		widget_control, w_draw, set_uvalue= int_info
		end

	'exit': begin
		exit=1
		if ptr_exist(int_info.se) then begin
			if  (*int_info.se)[0] eq 0. and (*int_info.se)[1] eq 0. then begin
				int_info.plotman_obj -> set, intervals=-1
			endif else begin
				int_info.plotman_obj -> set, intervals=*int_info.se +  int_info.utbase
			endelse
		endif

		end

	'cancel': begin
		exit=1
		int_info.plotman_obj -> set, intervals=-99
		end

	else:

endcase

getout:
if exit then begin
	; on linux using the cleanup routine autmatically when widget is destroyed sometimes
	; causes segmentation fault.  If we got here, we're exiting normally, so undo the cleanup
	; set in xmanager, and call the cleanup routine directly.  This seems to be OK.
	widget_control, event.top, kill_notify=''
	cleanup_intervals, event.top
	widget_control, event.top, /destroy

	; send an event to caller indicating ready to get intervals out of plotman obj
	if xalive(int_info.send_widget) then begin
		event = {id: int_info.send_widget, $
			top: event.top, $
			handler: 0L, $
			value: 1}
		widget_control, int_info.send_widget, send_event=event
	endif

	free_var, int_info, exclude='plotman_obj'

endif else begin
  if relist then plotman_list_int, int_info
  widget_control, int_info.interval_tlb, /show
endelse

end

;----------------------------------------------------------------------------------------------------------------------------------------

pro plotman_intervals_draw_event, event

;print,'in plotman_intervals_draw_event'
;help,event,/st

double_click_detect, event, continue, delay=.4
if not continue then return

w_draw = event.id
widget_control, w_draw, get_uvalue=int_info

int_info.plotman_obj -> select

press=0 & left=0 & middle=0 & right=0

case event.release of
	0: press=1
	1: left=1
	2: middle=1
	4: right=1
	else: goto, getout
endcase

double_click = event.clicks eq 2

if press then goto, getout ;return if press event

;print,'left=',left, ' middle=',middle,' right=',right,' double_click=',double_click
d = convert_coord  (event.x, event.y,  /device, /to_data)
xrange = crange('x')
if d[0] lt xrange[0] or d[0] gt xrange[1] then goto, getout  ; clicked outside x range of plot
;print, 'device x,y, data x = ', event.x, event.y, d[0]

if int_info.data_bound and not double_click then begin		; force to nearest data boundary
	xaxis = int_info.xaxis
	if xaxis[0] ne -1 then begin
		q = min (abs(d[0] - xaxis), index)
		d[0] = xaxis[index]
	endif
endif

case 1 of
	left: begin
		if double_click then begin
			plotman_popup_menu, event, int_info, d
			int_info.previous_button = 'double_click
		endif else begin
			if int_info.previous_button eq 'left' then $
				plotman_draw_int, 'start', int_info, /erase
			if int_info.nint+1 gt int_info.max_intervals then begin
				msg = 'Maximum intervals allowed ( ' + strtrim(int_info.max_intervals,2) + ') already defined.'
				message, msg, /cont
				widget_control, int_info.w_message, set_value=msg
			endif  else begin
				int_info.new_se[0] = d[0]
				plotman_draw_int, 'start', int_info
				int_info.previous_button = 'left'
			endelse
			int_info.popup_choice = ''  ; clear in case merge was last choice
		endelse
		end

	right: begin
	
	  ;If merging intervals, we've already stored first interval to merge in into_info.new_se[0]
	  if int_info.popup_choice eq 'merge' then begin
	    int_first = which_interval(int_info.new_se[0], int_info, /next)
	    int_last = which_interval(d[0], int_info)
	    ; If first and last are same interval, nothing to merge
	    if int_first eq int_last then goto, end_of_right
	    if int_first eq -1 or int_last eq -1 then begin
	      message,'Invalid choice.  Start and end interval to merge must already exist.',/cont
	      goto, end_of_right
	    endif
	    ;If rightclick is to left of first interval, then switch first and last
	    if int_first gt int_last then begin
	      temp = int_first
	      int_first = int_last
	      int_last = temp
	      int_info.new_se[0] = (*int_info.se)[0,int_first]
	    endif
	    ;don't save exact time clicked, save end of last interval in merge intervals
	    d[0] = (*int_info.se)[1,int_last]
	    ; Delete all intervals in between and including first and last.  Can't just use 
	    ; intervals numbers, because they change after each delete. Have to find interval
	    ; corresponding to times we want to delete for each interval, then delete.
	    ; for each, since interval number changes after
	    save_times = average(*int_info.se, 1)
	    for ii=int_first,int_last do begin
	      int = which_interval(save_times[ii], int_info)
	      plotman_modify_int, 'delete', int_info, int_index=int
	    endfor	    
	  endif else begin
	    
      ; if rightclicked, and previous click wasn't a left and we're in contiguous mode,
      ; then use end of previous interval as start of this interval
  		if int_info.contiguous then begin
  			if int_info.previous_button ne 'left' then begin
  			  ; exit if right-clicked in an existing interval
  				int = which_interval(d[0], int_info)
  				if int ne -1 then goto, getout
  				int = which_interval (d[0], int_info, /previous)
  				if int eq -1 then goto, getout
  				int_info.new_se[0] = (*int_info.se)[1,int]
  				plotman_draw_int, 'start', int_info
  			endif
  		endif else begin
  			if int_info.previous_button eq 'None' then goto, getout
  			if int_info.previous_button eq 'double_click' then goto, getout
  			if d[0] le int_info.new_se[0] then goto, getout
  			if int_info.previous_button eq 'right' then begin
  				plotman_draw_int, 'end', int_info, /erase
  				int = which_interval ( int_info.new_se[1], int_info, desc=desc)
  				plotman_modify_int, 'delete', int_info, int_index=int
  			endif
  		endelse
  	endelse
    ; now store new interval that's in int_info.new_se
		int_info.new_se[1] = d[0]
		plotman_modify_int, 'add', int_info, error=error
		plotman_list_int, int_info
		if not error then begin
		  ; if we merged, redraw plot and intervals, otherwise just new end line
		  if int_info.popup_choice eq 'merge' then begin
		    int_info.plotman_obj -> select
        int_info.plotman_obj -> plot
        plotman_draw_int, 'all', int_info        
      endif else plotman_draw_int, 'end', int_info
			int_info.previous_button = 'right'
			if int_info.no_widget then begin
				exit_event = {id: int_info.w_exit, $
				top: int_info.interval_tlb, $
				handler: 0L }
				widget_control, int_info.w_exit, send_event=exit_event
			endif
		endif
		end_of_right:
		int_info.popup_choice = ''  ; clear in case merge was last choice
		end

	else:
endcase

widget_control, event.id, set_uvalue=int_info

getout:
int_info.plotman_obj -> select
widget_control, int_info.interval_tlb, /show

end

;----------------------------------------------------------------------------------------------------------------------------------------

pro plotman_popup_menu, event,  int_info, d

w_draw = event.id

if int_info.previous_button eq 'left' then $
	plotman_draw_int, 'start', int_info, /erase

int = which_interval ( d[0], int_info, desc=desc)

if int ne -1 then begin

	list = [desc, $
			'(click an option below)', $
			' ', $
			'Move start (click and drag)', $
			'Move end (click and drag)', $
			'Move interval (click and drag)', $
			'Delete interval', $
			'Break into N Sub-intervals (set N in widget)', $
			'Break into Sub-intervals of Equal Length (set in widget)', $
			'Break into Sub-intervals of M data bins each (set M in widget)', $
			'Merge intervals from here to interval you right-click next', $
			'Cancel']

	list_short = ['cancel', 'cancel', 'cancel', 'moves', 'movee', 'movei', 'deletei', 'nbreak', 'lbreak', 'ndata', 'merge','cancel']
	geomid = widget_info( event.id, /geometry)
	geomtop = widget_info( event.top, /geometry)
	position=[geomtop.xoffset + geomid.xoffset + event.x, $
		geomtop.yoffset + geomid.yoffset + (geomid.ysize - event.y)]

	choice = 0
	if not xregistered ('popup_menu') then begin
		group = widget_info(w_draw,/parent)	; on Solaris, bombs if group is w_draw, so use parent
		choice = popup_menu ( list, title='Edit intervals...', $
			group=group, position=position, popup_base=popup_base, /index )
	endif

	choice = choice > 0 < (n_elements(list_short)-1)
	int_info.popup_choice = list_short[choice]

	relist = 0

	case int_info.popup_choice of
		'cancel':
		'deletei': begin
			plotman_draw_int, 'interval', int_index=int, int_info, /erase
			plotman_modify_int, 'delete', int_info, int_index=int
			relist = 1
			end
		'nbreak': begin
			if int_info.nint+1 gt int_info.max_intervals then begin
				msg = 'Maximum intervals allowed ( ' + strtrim(int_info.max_intervals,2) + ') already defined.'
				message, msg, /cont
				widget_control, int_info.w_message, set_value=msg
			endif  else begin
				widget_control, int_info.w_nbreak, get_value=value
				plotman_modify_int, 'nbreak', int_info, int_index=int, nbreak=value[0], data_bound=int_info.data_bound
				relist = 1
				int_info.plotman_obj -> select
				int_info.plotman_obj -> plot
				plotman_draw_int, 'all', int_info
			endelse
			end
		'lbreak': begin
			if int_info.nint+1 gt int_info.max_intervals then begin
				msg = 'Maximum intervals allowed ( ' + strtrim(int_info.max_intervals,2) + ') already defined.'
				message, msg, /cont
				widget_control, int_info.w_message, set_value=msg
			endif  else begin
				widget_control, int_info.w_lbreak, get_value=value
				plotman_modify_int, 'lbreak', int_info, int_index=int, lbreak=float(value[0]), data_bound=int_info.data_bound
				relist = 1
				int_info.plotman_obj -> select
				int_info.plotman_obj -> plot
				plotman_draw_int, 'all', int_info
			endelse
			end
		'ndata': begin
			if int_info.nint+1 gt int_info.max_intervals then begin
				msg = 'Maximum intervals allowed ( ' + strtrim(int_info.max_intervals,2) + ') already defined.'
				message, msg, /cont
				widget_control, int_info.w_message, set_value=msg
			endif  else begin
				widget_control, int_info.w_ndata, get_value=value
				plotman_modify_int, 'ndata', int_info, int_index=int, ndata=fix(value[0]), data_bound=int_info.data_bound
				relist = 1
				int_info.plotman_obj -> select
				int_info.plotman_obj -> plot
				plotman_draw_int, 'all', int_info
			endelse
			end
		'merge': int_info.new_se[0] = (*int_info.se)[0,int]
		  
		else: widget_control, event.id, event_pro = 'plotman_intervals_move_event'

	endcase

	if relist then plotman_list_int, int_info

endif

end

;----------------------------------------------------------------------------------------------------------------------------------------

pro plotman::intervals, $
	intervals=intervals, $		; first index is start/end, second index is interval number
	max_intervals=max_intervals, $
	type=type, $
	title=title, force=force, $
	show_start=show_start, $
	no_replot=no_replot, $
	send_widget=send_widget, $
	no_widget=no_widget, $
	err_msg=err_msg

err_msg = ''

if xregistered ('plotman_intervals') ne 0 then begin
  message, /cont, 'An instance of plotman_intervals widget is already running.'
  return
endif

get_font, font, big_font=big_font

widget_control, default_font = font

checkvar, show_start, 1
checkvar, max_intervals, 10000
checkvar, no_widget, 0
checkvar, send_widget, 0L

checkvar, type, ''
self -> select
plot_type = self -> get(/plot_type)
utbase = self -> get(/utbase)

plotman_tlb = self -> get(/plot_base)
widget_control, plotman_tlb, get_uvalue=state

w_draw = state.widgets.w_draw
window_id = state.widgets.window_id
w_message = state.widgets.w_message

device, get_graphics = sav_graphics
sav_draw_motion_events = widget_info(w_draw, /draw_motion_events)
sav_draw_button_events = widget_info(w_draw, /draw_button_events)
sav_event_pro = widget_info(w_draw, /event_pro)
sav_event_func = widget_info(w_draw, /event_func)

widget_control, w_draw, event_pro='plotman_intervals_draw_event'

checkvar, title, 'Define ' + type + ' Intervals'

err_int = 1
if keyword_set(intervals) then begin
	intervals = anytim(intervals)
	dim1 = n_elements(intervals[*,0])
	dim2 = n_elements(intervals[0,*])
	if dim1 eq 2 then begin
		nint = dim2
		if not (nint eq 1 and intervals[0] eq intervals[1]) then begin
			self -> set, intervals=intervals
			se = ptr_new(intervals - utbase)
			err_int = 0
		endif
	endif
endif

if err_int then begin
	nint = 0
	se = ptr_new([0.d0, 0.d0])
endif

nbreak = 2
lbreak = 4.
ndata = 2
contiguous = 0
data_bound = keyword_set(force) ? 1 : 0
xaxis = self -> getaxis(/xaxis, /edges_2)
if xaxis[0] gt 1.e6 then xaxis = xaxis - utbase

interval_tlb = widget_base ( group_leader=plotman_tlb, $
					title=title[0], $
					/column, $
					xpad=15, $
					ypad=15, $
					space=10, $
					/tlb_kill )

w_temp = widget_label (interval_tlb, value=title[0],  /align_center, font=big_font)
if n_elements(title) gt 1 then w_temp = widget_label (interval_tlb, value=title[1],  font=big_font, /align_center)

w_temp = widget_label (interval_tlb, value='Left/right click to define start/end of intervals.',  /align_center)
w_temp = widget_label (interval_tlb, value='Left double click on a plotted interval for editing options.',   /align_center)

w_listbase = widget_base (interval_tlb, $
					/column, $
					/frame, $
					space=5)

w_current = widget_base (w_listbase, /row, space=10)

w_list = widget_droplist (w_current, $
					title='Current intervals: ', $
					;value=string(bytarr(60)+32B), $
					value=' ', $
					uvalue='list', $
					/dynamic_resize)

w_total = widget_label (w_current, value = '# intervals =    ', /dynamic_resize)

w_listbuttons = widget_base (w_listbase, $
					/align_center, $
					/row, $
					space=5 )

w_editsel = widget_button (w_listbuttons, $
					value='Delete selected interval', $
					uvalue='deletesel' )

w_editsel = widget_button (w_listbuttons, $
					value='Edit selected interval...', $
					uvalue='editsel' )

w_editlist = widget_button (w_listbuttons, $
					value='Edit intervals...', $
					uvalue='editlist', $
					/align_center)

w_optbase = widget_base (interval_tlb, $
					/row, $
					/frame, $
					space=10, $
					xpad=10)

w_opt1 = widget_base (w_optbase, /column)

temp = widget_label (w_opt1, value='Options for cursor selection:')

w_opts = widget_base (w_opt1, $
					/nonexclusive, $
					/column )

w_contiguous = widget_button (w_opts, $
					value='Contiguous intervals', $
					uvalue='contiguous' )

w_force = widget_button (w_opts, $
					value='Force to data boundaries', $
					uvalue='force' )
if keyword_set(force) then widget_control, w_force, /set_button, sensitive=0
if xaxis[0] eq -1 then widget_control, w_force, set_button=0, sensitive=0

w_breakbase = widget_base (w_optbase, $
					/column )

temp = widget_label (w_breakbase, $
					value='Editing Option Parameters:' , $
					/align_left)

w_nbreak = cw_field (w_breakbase, $
					/row, $
					title='# Sub-intervals (N): ', $
					value= strtrim(string (nbreak, format='(i4)'), 2), $
					uvalue='nbreak', $
					xsize=7)

if plot_type eq 'utplot' or plot_type eq 'specplot' then length_unit = ' (sec)' else length_unit = ''
w_lbreak = cw_field (w_breakbase, $
					/row, $
					title='Length of Sub-intervals' + length_unit + ':', $
					value=strtrim(string (lbreak, format='(f12.3)'), 2), $
					uvalue='lbreak', $
					xsize=7 )

w_ndata = cw_field (w_breakbase, $
					/row, $
					title='# Data Bins per Sub-interval (M):', $
					value=strtrim(string(ndata, format='(i4)'), 2), $
					uvalue='ndata', $
					xsize=7)

w_buttons1 = widget_base (interval_tlb, /row, space=15, /align_center )

temp = widget_button (w_buttons1, value='Adjust to data boundaries', uvalue='move_data')
if xaxis[0] eq -1 then widget_control, temp, sensitive=0

temp = widget_button (w_buttons1, value='Display current', uvalue='display' )

temp = widget_button (w_buttons1, value='Delete all', uvalue='deleteall' )

w_buttons2 = widget_base (interval_tlb, /row, space=15, /align_center )

temp = widget_button (w_buttons2, value='Help', uvalue='help' )

temp = widget_button (w_buttons2, value='Cancel', uvalue='cancel' )

w_exit = widget_button (w_buttons2, value='Accept and Close', uvalue='exit' )

w_info= {w_draw: w_draw} ; store in interval widget base uvalue so we can get at int_info

int_info = {new_se: [0.d0, 0.d0], $
	nint: nint, $
	se: se, $
	type: type, $
	utbase: utbase, $
	max_intervals: max_intervals, $
	popup_choice: '', $
	contiguous: contiguous, $
	data_bound: data_bound, $
	xaxis: xaxis, $
	nbreak: nbreak, $
	lbreak: lbreak, $
	previous_button: 'None', $
	first_click: 0, $
	save_event: {widget_draw}, $
;	widget_event: widget_event, $

	send_widget: send_widget, $
	plotman_obj: self, $
	plot_type: plot_type, $
	window_id: window_id, $
	w_draw: w_draw, $
	w_message: w_message, $

	interval_tlb: interval_tlb, $
	plotman_tlb: plotman_tlb, $
	w_list: w_list, $
	w_total: w_total, $
	w_nbreak: w_nbreak, $
	w_lbreak: w_lbreak, $
	w_ndata: w_ndata, $
	w_exit: w_exit, $
	no_widget: no_widget, $

	sav_graphics: sav_graphics, $
	sav_draw_motion_events: sav_draw_motion_events, $
	sav_draw_button_events: sav_draw_button_events, $
	sav_event_pro: sav_event_pro, $
	sav_event_func: sav_event_func }

list = plotman_format_int (int_info)
widget_control, w_list, set_value=list
widget_control, w_total, set_value='# intervals = ' + strtrim(int_info.nint,2)

xshow, plotman_tlb
if show_start then begin
	int_info.plotman_obj -> select
	if not keyword_set(no_replot) then int_info.plotman_obj -> plot
	plotman_draw_int, 'all', int_info
endif

widget_offset, plotman_tlb, newbase=interval_tlb , xoffset, yoffset
widget_control, interval_tlb, xoffset=xoffset, yoffset=yoffset
widget_control, interval_tlb, /realize, map=no_widget eq 0

widget_control, interval_tlb, set_uvalue = w_info

widget_control, w_draw, set_uvalue=int_info

widget_control, w_message, $
	set_value='Left/right click to define start/end of intervals.  Left doubleclick on an interval for editing options.'

widget_control, interval_tlb, /show

xmanager, 'plotman_intervals', interval_tlb, cleanup='cleanup_intervals'

end
