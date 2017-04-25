;+
; Project     : HESSI
;
; Name        : xedit_table
;
; Purpose     : Allows you to edit an array of values using a table widget.
;
; Category    : widgets
;
; Explanation : Builds a base for a widget_table, and adds accept and cancel buttons.
;
; Syntax      : vals = xedit_table (array [, group=group, title=title, _extra=_extra])
;
; Inputs      : array = 1 or 2-D array of values (strings or numbers) to edit
;
; Outputs     : vals - modified array
;
; Keywords    : group   = widget id of parent widget (if any)
;               title   = string to put in title of widget
;               _extra  = any keywords to pass into IDL widget_table routine, e.g. 
;                 column_labels - string array of column labels, 
;                 row_labels - string array of column labels,
;                 scr_xsize, scr_ysize - 'screen' width/height of widget in pixels 
;                 x_scroll_size, y_scroll_size - number of columns, rows to show (scroll bar will appear)
;                 background_color - RGB triplet for cell background color.  Single color or array of colors
;                 see other keywords in widget_table description
;
; Restrictions:
;              Changes to values only take effect when user presses return or clicks
;              in another cell of table.  I gave up trying to make it work without that
;              requirement.  There are lots of way to generate events when
;              the user does stuff, but doing a widget_control,id,get_value=v doesn't
;              get the changed values until one of those two things happen.
;
; Example     :
;               vals = xedit_table (findgen(8,3), $
;                      column_labels=['a','b','c','d','e','f','g','h'], $
;                      row_labels=['A','B','C'], $
;                      title='XEDIT_TABLE Example')
;
; Written     : 4-May-2005, Kim Tolbert
;
; Modifications:
;   17-Sep-2012, Kim.  Made /disjoint_selection and /all_events the defaults so now user can edit
;     multiple cells.  User highlights cells (don't have to be contiguous, and clicking a row or column label
;     selects the entire row) and types new value and HITS RETURN, then all selected cells change value.
;     Widget_table doesn't work as well as it should, so had to add extra manipulations to make it right - see
;     comments in code.
;   05-Oct-2012, Kim. On unix, when user hits Enter, get LF (10B), not CR (13B), so look for either
;-

pro xedit_table_event, event

widget_control, event.top, get_uvalue=state
widget_control, event.id, get_uvalue=uvalue
exit=0
;help,event,/st

ev_name = tag_names(event,/structure_name)

; Will get event of type 'WIDGET_TABLE_INVALID_ENTRY' when, e.g. user types string when should be numbers
if ev_name eq 'WIDGET_TABLE_INVALID_ENTRY' then begin
  message,/info,'Invalid value entered: ' + event.str
  *state.badval = 1
  return
endif

; Shouldn't have to do this, but if we don't then if user clicks cell X,Y and then selects column Z by clicking the
; column header, enters a new value, cell X,Y is changed as well as the column cells.  Could be dangerous.
; So this block ensures that the cell being edited is one of the cells in the selection.
; Note: most of the table operations use column, row indices, but edit_cell stuff uses row, column!
; On button down for a selection or de-selection, location (.sel_left, etc.) is -1, so ignore those events.  
if ev_name eq 'WIDGET_TABLE_CELL_SEL' or ev_name eq 'WIDGET_TABLE_CELL_DESEL' && event.sel_left ne -1 then begin

  ; get current edit_cell and current selection of cells
  edit_cell=reverse(widget_info(event.id, /table_edit_cell))  ; reverse because returns row, column!   
  cells = widget_info(event.id, /table_select)
;  print,'table_edit_cell = ', edit_cell
;  print,'cells = ', cells
;  
  ; check if edit_cell is one of current selection of cells 
  q = where (edit_cell[0] eq cells[0,*] and edit_cell[1] eq cells[1,*], nq)
;  print,'nq = ', nq,'  q = ', q
;  
  ;if not, then set edit_cell to first cell in selection. Unfortunately this resets the full selection, so reset the
  ; cells selected.  When reset cells selected, it moves the part of the tables that's visible to make the selected
  ; cells show in the upper left.  So get top_cell in view before set selection, and then set top cell after setting
  ; selection.  (NOTE: when user edits cells in the rightmost visible column, they are shifted to left by one automatically
  ; so get top_cell after setting edit_cell - otherwise the edit cell is shifted by one column, but the rest of the cell
  ; selection is where it was originally.  So it looks wrong, but after user changes value, it has changed correct cells.
  ; This took forever to figure out - but that's why it's important that to get top_cell after setting the edit_cell.) 
  if nq eq 0 then begin
    widget_control, event.id, edit_cell=reverse(cells[*,0]) ; reverse because wants row, column!
    top_cell = widget_info(event.id, /table_view)
    widget_control, event.id, set_table_select=cells
    widget_control, event.id, set_table_view=top_cell
  endif
endif

; Ignore events that are caused when user types characters until they hit a carriage return (13B) (or
; on unix apparently it's just a LF (10B)).
; Then get the value of the edited cell and change all values in the selection to that value.
if ev_name eq 'WIDGET_TABLE_CH' && (event.ch eq 13B or event.ch eq 10B) then begin

  ;first check if the next event is an 'invalid value' event. If so, reset flag and return
  r=widget_event(event.top,/nowait)
  if *state.badval then begin
    *state.badval = 0
    return
  endif
  
  ; if not an invalid value, get new value and set all selected cells
  cells = widget_info(event.id, /table_select) ; get selected cells
  widget_control, event.id, get_value=vals  ; get all values in table
  newval = vals[event.x,event.y]
  for i=0,n_elements(cells[0,*])-1 do vals[cells[0,i],cells[1,i]]=newval ; change selected cells to newval
  *state.vals = vals
  widget_control, state.w_table, set_value=vals   ; set new values back in table widget
endif

case uvalue of
	'accept': begin
		exit=1
		widget_control, state.w_table, get_value=vals
		*state.vals = vals
		*state.status = 1
		end
	'cancel': begin
		exit=1
		*state.vals = state.orig
		*state.status = 0
		end
	else:
	endcase
	
if exit then widget_control,event.top, /destroy else $
	widget_control, event.top, set_uvalue=state

end

;-----

function xedit_table, array, group=group, title=title, status=status, _extra=_extra

w_base = widget_base (group=group, title=title, /column, modal=exist(group))
w_table = widget_table (w_base, value=array, uvalue='table',  /edit, $
  /disjoint_selection, /all_events, /resizeable_columns, _extra=_extra)

tmp = widget_label(w_base, $
  value='Select multiple cells by left-clicking and dragging, or clicking while holding Ctrl or Shift')
tmp = widget_label(w_base, $
  value='Select entire row or column by clicking row or column label.')
tmp = widget_label(w_base, $
  value='After selecting cells, type new value and PRESS ENTER.')
tmp = widget_label(w_base, $
  value='Change column width by dragging boundary of column label.')    

w_buttons = widget_base (w_base, /row, space=10, /align_center)
tmp = widget_button (w_buttons, value='Accept', uvalue='accept')
tmp = widget_button (w_buttons, value='Cancel', uvalue='cancel')

state = {w_table: w_table, vals: ptr_new(array), orig: array, badval: ptr_new(0), status: ptr_new(0)}
widget_control, w_base, set_uvalue = state

if xalive(group) then begin
	widget_offset, group, xoffset, yoffset, newbase=w_base
	widget_control, w_base, xoffset=xoffset, yoffset=yoffset
endif
widget_control, w_base, /realize
xmanager, 'xedit_table', w_base

status = *state.status
return, *state.vals
end