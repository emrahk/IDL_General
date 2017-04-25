;============================================================================
;+
; PROJECT:  HESSI
;
; NAME: popup_menu
;
; PURPOSE:  pop up a menu with a list of options to choose from
;
; CATEGORY: widgets
;
; CALLING SEQUENCE:
;	choice = popup_menu (list, title=title, group=group, position=position, $
;		width=width, height=height, index=index, popup_base=base)
;
; INPUTS:
;	list - string array of options
;
; OPTIONAL INPUTS (KEYWORDS):
;	title - title to put at top of list (default = 'Options:')
;	group - widget id of group leader
;	position - fltarr(2) - x,y position of top left corner of popup widget
;		relative to top left corner of screen
;	width - width of widget will be "width' characters
;	height - number of lines in widget
;	index - if set, return index into list of selection.  Otherwise return string.
;
;
; OUTPUTS:
;	Results of function is string selected from list, or index of selection if INDEX
;	keyword is set.
;
; OPTIONAL OUTPUTS:
;	popup_base - widget id of popup widget
;
; Calls:
;
; COMMON BLOCKS: Uses an internal common called popup_menu_common
;
; PROCEDURE:
;
; RESTRICTIONS: None
;
; SIDE EFFECTS: None.
;
; EXAMPLES:
;
; HISTORY:
;	Written, Kim, Nov 99
;	Mod, Kim, 7-Sep-2000. Made widget base modal.
;       27-Sep-2010, William Thompson, use [] indexing
;
;-
;============================================================================

pro popup_menu_event, event

common popup_menu_common, list_index

list_index = event.index

widget_control, event.top, /destroy

end

function popup_menu, list, title=title, group=group, position=position, $
	width=width, height=height, index=index, popup_base=base

common popup_menu_common, list_index

list_index = -1

title = fcheck (title, 'Options:')

width = fcheck (width, max(strlen(list))+3) > 20 < 85
height = fcheck (height, n_elements(list)) < 40
position = fcheck (position, [0.,0.])

base = widget_base (title=title, $
	group=group, $
	/column, $
	xoffset=position[0], $
	yoffset=position[1], $
	/modal)

tmp = widget_list (base, $
	xsize=width, $
	ysize=height, $
	value=list)

widget_control, base, /realize

xmanager, 'popup_menu', base


if keyword_set(index) then result = list_index else $
	if list_index eq -1 then result='' else result = list[list_index]

return, result
end
