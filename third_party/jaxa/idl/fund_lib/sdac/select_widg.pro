PRO select_widg_evt, event

common select_widg_com,  list_index
checkvar,list_index, -1

if widget_info(/type, event.id) eq 1 then $
	WIDGET_CONTROL, GET_UVALUE = retval, event.id $
	else list_index=event.index

checkvar, retval, ''

IF(retval EQ "EXIT") THEN WIDGET_CONTROL, event.top, /DESTROY 

END


;+
; Project: 
;	SDAC                   
; NAME: 
;	select_widg
;
; PURPOSE:
;	Display an ASCII list using widgets and the widget manager.
;       Select a line of the text.
; CATEGORY:
;	Widgets.
;
; CALLING SEQUENCE:
;	line = select_widg(list)
;	or
;	index= select_widg(list, /index)
; INPUTS:
;	LIST	A string array to be displayed in the widget.
;
; KEYWORD PARAMETERS:
;	INDEX:  If set, the index of the selected line is returned.
;
;	FONT:   The name of the font to use.  If omitted use the default
;		font.
;	GROUP:	The widget ID of the group leader of the widget.  If this 
;		keyword is specified, the death of the group leader results in
;		the death of SELECT_WIDG.
;
;	HEIGHT:	The number of text lines that the widget should display at one
;		time.  If this keyword is not specified, 24 lines is the 
;		default.
;
;	TITLE:	A string to use as the widget title rather than the file name 
;		or "select_widg".
;
;	WIDTH:	The number of characters wide the widget should be.  If this
;		keyword is not specified, 80 characters is the default.
;
; OUTPUTS:
;	Returns the selected line from the display, unless the keyword index is set.
;       Returns null string if nothing selected or -1 for the index.
; KEYWORD PARAMETERS:
;	INDEX:  The index of the selected line from the string array.
; SIDE EFFECTS:
;	Triggers the XMANAGER if it is not already in use.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Create a list widget and select from its contents.
;
; MODIFICATION HISTORY:
;	modified from xdisplayfile by richard.schwartz@gsfc.nasa.gov, 5-jul-94
;       27-Sep-2010, William Thompson, use [] indexing
;-
function select_widg, list, TITLE = TITLE, GROUP = GROUP, WIDTH = WIDTH, $
		HEIGHT = HEIGHT, FONT = font, index=index

common select_widg_com, list_index

title = fcheck(TITLE,'SELECT AN ENTRY')
IF(NOT(KEYWORD_SET(HEIGHT))) THEN HEIGHT = 24		;the keywords were not
IF(NOT(KEYWORD_SET(WIDTH))) THEN WIDTH = 80		;passed in

filebase = WIDGET_BASE(TITLE = title, $			;create the base
		/COLUMN, $
		SPACE = 20, $
		XPAD = 20, $
		YPAD = 20, /modal)

filequit = WIDGET_BUTTON(filebase, $			;create a Done Button
		VALUE = "Done with " + TITLE, $
		UVALUE = "EXIT")

IF n_elements(font) gt 0 then $
 filelist = WIDGET_LIST(filebase, $			;create a list widget
		XSIZE = WIDTH, $			;to display the file's
		YSIZE = HEIGHT, $			;contents
		FONT = font, $
		VALUE = list) $
ELSE filelist = WIDGET_LIST(filebase, $			;create a list widget
		XSIZE = WIDTH, $			;to display the file's
		YSIZE = HEIGHT, $			;contents
		VALUE = list)


WIDGET_CONTROL, filebase, /REALIZE			;instantiate the widget

Xmanager, "select_widg", $				;register it with the
		filebase, $				;widget manager
		GROUP_LEADER = GROUP, $
		EVENT_HANDLER = "select_widg_evt", /modal

if keyword_set(index) then result = list_index else $
	if list_index eq -1 then result='' else result = list[list_index]
return, result
END  ;--------------------- procedure select_widg ----------------------------
