;+
;$Id: cw_bselector2.pro,v 1.1 2006/08/28 18:17:53 nathan Exp $
;
; Copyright (c) 1993, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	CW_BSELECTOR
;
; PURPOSE:
;	CW_BSELECTOR is a compound widget that appears as a pull-down
;	menu whose label shows the widget's current value. When the button
;	is pressed, the menu appears and the newly selected value becomes
;	the new title of the pull-down menu.
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;		widget = CW_BSELECTOR(Parent, Names)
;
;	To get or set the value of a CW_BSELECTOR, use the GET_VALUE and
;	SET_VALUE keywords to WIDGET_CONTROL. The value of a CW_BSELECTOR
;	is the index of the selected item.
;
; INPUTS:
;       Parent:		The ID of the parent widget.
;	Names:		A string array, containing one string per button,
;			giving the name of each button.
;
; KEYWORD PARAMETERS:
;	EVENT_FUNCT:	The name of an optional user-supplied event function 
;			for buttons. This function is called with the return
;			value structure whenever a button is pressed, and 
;			follows the conventions for user-written event
;			functions.
;	FONT:		The name of the font to be used for the button
;			titles. If this keyword is not specified, the default
;			font is used.
;	FRAME:		Specifies the width of the frame to be drawn around
;			the base.
;	IDS:		A named variable into which the button IDs will be
;			stored, as a longword vector.
;	LABEL_LEFT:	Creates a text label to the left of the buttons.
;	LABEL_TOP:	Creates a text label above the buttons.
;	MAP:		If set, the base will be mapped when the widget
;			is realized (the default).
;	RETURN_ID:	If set, the VALUE field of returned events will be
;			the widget ID of the button.
;	RETURN_INDEX:	If set, the VALUE field of returned events will be
;			the zero-based index of the button within the base.
;			THIS IS THE DEFAULT.
;	RETURN_NAME:	If set, the VALUE field of returned events will be
;			the name of the button within the base.
;	RETURN_UVALUE:	An array of user values to be associated with
;			each button. Selecting the button sets the uvalue
;			of the CW_BSELECTOR to the button's uvalue and
;			returns the uvalue in the value field of the event
;			structure.  If this keyword isn't specified, the
;			CW_BSELECTOR's uvalue remains unchanged.
;	SET_VALUE:	The initial value of the buttons. This keyword is 
;			set to the index of the Names array element desired.
;			So if it is desired that the initial value be the 
;			second element of the Names array, SET_VALUE would
;			be set equal to 1. This is equivalent to the later 
;			statement:
;
;			WIDGET_CONTROL, widget, set_value=value
;
;	UVALUE:		The user value to be associated with the widget.
;	XOFFSET:	The X offset of the widget relative to its parent.
;	YOFFSET:	The Y offset of the widget relative to its parent.
;
; OUTPUTS:
;       The ID of the created widget is returned.
;
; SIDE EFFECTS:
;	This widget generates event structures with the following definition:
;
;		event = { ID:0L, TOP:0L, HANDLER:0L, INDEX:0, VALUE:0 }
;
;	The INDEX field is the index (0 based) of the menu choice. VALUE is
;	either the INDEX, ID, NAME, or BUTTON_UVALUE of the button,
;	depending on how the widget was created.
;
; RESTRICTIONS:
;	Only buttons with textual names are handled by this widget.
;	Bitmaps are not understood.
;
; MODIFICATION HISTORY:
;	1 April 1993, DMS,  Adapted from CW_BGROUP.
;	22 Dec. 1993, KDB,  Corrected documentation for keyword SET_VALUE.
;	11 Aug. 1994, Scott Paswaters (NRL)
;          1) Added MENU=2 to differentiate a pd menu from a button under Motif.
;          2) Modified the CW_BSELECTOR_SETV procedure to allow changing the labels
;             of the buttons.  Example if you had a pd menu with two buttons 'b1' & 'b2':
;               WIDGET_CONTROL, cw_bselector_base, SET_VALUE=['b3','b4']	;** change labels
;               WIDGET_CONTROL, cw_bselector_base, SET_VALUE=0
;               ;** to select 'b3'
;       4 February, 2008, Zarro (ADNET) 
;            - Added _EXTRA to pass keywords to WIDGET_BUTTON. 
;              This feature was somehow lost.
;-
; $Log: cw_bselector2.pro,v $
; Revision 1.1  2006/08/28 18:17:53  nathan
; Copied from PT/PRO; duplicates (with mod from current)
; $SSW/gen/idl/widgets/cw_bselector2.pro.
;
; Revision 1.2  2004/09/01 15:40:42  esfand
; commit new version for Nathan.
;
; Revision 1.1.1.2  2004/07/01 21:18:59  esfand
; first checkin
;
; Revision 1.1.1.1  2004/06/02 19:42:35  esfand
; first checkin
;
; 
;-


pro CW_BSELECTOR2_SETV, id, value
  ON_ERROR, 2				;return to caller
  stash = WIDGET_INFO(id, /CHILD)	;Get state from 1st child
  WIDGET_CONTROL, stash, GET_UVALUE=s, /NO_COPY
  sz = SIZE(value)
  IF (sz(N_ELEMENTS(sz)-2) EQ 7) THEN BEGIN	;** value is a string, create new buttons
    IF (N_ELEMENTS(value) NE N_ELEMENTS(s.ids)) THEN $
	MESSAGE, 'New button name array must have same elements as original.', /INFO $
    ELSE FOR i=0, N_ELEMENTS(s.ids)-1 DO BEGIN 
           IF (i LT N_ELEMENTS(value)) THEN $
             WIDGET_CONTROL, s.ids(i), SET_VALUE=value(i) $	;Set menu label
           ELSE $
             WIDGET_CONTROL, s.ids(i), SET_VALUE=''
         END
  ENDIF ELSE BEGIN				;** value not a string, select a current button
    if value lt 0 or value ge n_elements(s.ids) then $
	MESSAGE, 'Button value must be from 0 to n_buttons -1.', /INFO $
    ELSE BEGIN  
      WIDGET_CONTROL, s.ids(value), GET_VALUE=v	;Get button label
      WIDGET_CONTROL, s.menu, SET_VALUE=v	;Set menu label
      if s.uvret then WIDGET_CONTROL, id, SET_UVALUE=s.ret_arr(value)
      s.select = value			;save button that's selected
    ENDELSE
  ENDELSE
  WIDGET_CONTROL, stash, SET_UVALUE=s, /NO_COPY  
end



function CW_BSELECTOR2_GETV, id
  ON_ERROR, 2						;return to caller
  stash = WIDGET_INFO(id, /CHILD)	;Get state from 1st child
  WIDGET_CONTROL, stash, GET_UVALUE=s, /NO_COPY
  ret = s.select
  WIDGET_CONTROL, stash, SET_UVALUE=s, /NO_COPY  
  return, ret
end



function CW_BSELECTOR2_EVENT, ev
  base = ev.handler
  stash = WIDGET_INFO(base, /CHILD)	;Get state from 1st child
  WIDGET_CONTROL, stash, GET_UVALUE=s, /NO_COPY
  WIDGET_CONTROL, ev.id, get_uvalue=uvalue  ;The button index
  s.select = uvalue			;Save the selected index
  rvalue = s.ret_arr(uvalue)
  WIDGET_CONTROL, ev.id, GET_VALUE = v	;Copy button's label to menu
  WIDGET_CONTROL, s.menu, SET_VALUE = v
  if s.uvret then WIDGET_CONTROL, base, SET_UVALUE=rvalue
  efun = s.efun
  WIDGET_CONTROL, stash, SET_UVALUE = s, /NO_COPY

  st = { ID:base, TOP:ev.top, HANDLER:0L, INDEX: uvalue, $  ;Return value
	    VALUE: rvalue }
  if efun ne '' then return, CALL_FUNCTION(efun, st) $
  else return, st
end







function CW_BSELECTOR2, parent, names, EVENT_FUNCT = efun, $
	RETURN_UVALUE = return_uvalue, $
	FONT=font, FRAME=frame, IDS=ids, LABEL_TOP=label_top, $
	LABEL_LEFT=label_left, MAP=map, RETURN_ID=return_id, $
	RETURN_INDEX=return_index, RETURN_NAME=return_name, $
	SET_VALUE=sval, UVALUE=uvalue, $ 
        XOFFSET=xoffset, XSIZE=xsize, $
	YOFFSET=yoffset, YSIZE=ysize, _EXTRA=extra


;  ON_ERROR, 2						;return to caller

  ; Set default values for the keywords
  version = WIDGET_INFO(/version)
  if (version.toolkit eq 'OLIT') then def_space_pad = 4 else def_space_pad = 3
  IF (N_ELEMENTS(frame) eq 0)		then framet = 0 else framet = frame
  IF (N_ELEMENTS(map) eq 0)		then map=1
  IF (N_ELEMENTS(uvalue) eq 0)		then uvalue = 0
  IF (N_ELEMENTS(xoffset) eq 0)		then xoffset=0
  IF (N_ELEMENTS(xsize) eq 0)		then xsize = 0
  IF (N_ELEMENTS(yoffset) eq 0)		then yoffset=0
  IF (N_ELEMENTS(ysize) eq 0)		then ysize = 0

  top_base = 0L
  next_base = parent
  if (n_elements(label_top) ne 0) then begin
    next_base = WIDGET_BASE(next_base, XOFFSET=xoffset, YOFFSET=yoffset, $
		FRAME=framet, /COLUMN)
    top_base = next_base
    framet = 0				;Only one frame
    junk = WIDGET_LABEL(next_base, value=label_top)
  endif else next_base = parent

  if (n_elements(label_left) ne 0) then begin
    next_base = WIDGET_BASE(next_base, XOFFSET=xoffset, YOFFSET=yoffset, $
		  FRAME=framet, /ROW)
    junk = WIDGET_LABEL(next_base, value=label_left)
    framet = 0				;Only one frame
    if (top_base eq 0L) then top_base = next_base
  endif

  ; We need some kind of outer base to hold the users UVALUE
  if (top_base eq 0L) then begin
    top_base = WIDGET_BASE(next_base, XOFFSET=xoffset, YOFFSET=yoffset, $
			FRAME = framet)
    next_base = top_base
  endif

  ; Set top level base attributes
  WIDGET_CONTROL, top_base, MAP=map, EVENT_FUNC='CW_BSELECTOR2_EVENT', $
     FUNC_GET_VALUE='CW_BSELECTOR2_GETV', PRO_SET_VALUE='CW_BSELECTOR2_SETV', $
     SET_UVALUE=uvalue
  if n_elements(sval) le 0 then sval = 0	;Default selection index

  len = max(strlen(names), i)			;Longest string = 1st value
  len1 = strlen(names(sval))			;Initial string length
  if len gt len1 then $
	i = names(sval) + string(replicate(32B, len-len1+2)) $  ;+ slop
  else i = names(sval)
  menu = WIDGET_BUTTON(next_base, MENU=2, value = i,_extra=extra)

  n = n_elements(names)
  ids = lonarr(n)
  for i = 0, n-1 do begin
    if (n_elements(font) eq 0) then begin
      ids(i) = WIDGET_BUTTON(menu, value=names(i), UVALUE=i,_extra=extra)
    endif else begin
      ids(i) = WIDGET_BUTTON(menu, value=names(i), FONT=font, UVALUE=i,_extra=extra)
    endelse
  endfor

  
	;Make returned value array
  return_uvals = 0
  if KEYWORD_SET(RETURN_ID) then ret_arr = ids $
  else if KEYWORD_SET(RETURN_NAME) then ret_arr = names $
  else if KEYWORD_SET(RETURN_UVALUE) then begin
	ret_arr = return_uvalue
	return_uvals = 1
  endif else ret_arr = indgen(n)

  stash = WIDGET_INFO(top_base, /CHILD)	;Affix state to 1st child
  if n_elements(efun) le 0 then efun = ''

  WIDGET_CONTROL, stash, SET_UVALUE= { $
	menu: menu, $
	efun : efun, $			; Name of event fcn
        ret_arr: ret_arr, $		; Vector of event values
	select : sval, $
	uvret : return_uvals, $
	ids:ids }			; Ids of buttons
  return, top_base
END
