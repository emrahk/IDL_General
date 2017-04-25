; $Id: xmenu.pro,v 1.1 1993/04/02 19:54:08 idl Exp $

; Copyright (c) 1991-1993, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	XMENU
;
; PURPOSE:
;	This procedure simplifies setting up widget menus. XMENU accepts a 
;	string array of menu labels, creates a widget base, and populates
;	the base with buttons containing the specified labels.
;
; CALLING SEQUENCE:
;	XMENU, Values [, Parent]
;
; INPUTS:
;	Values:	An array of labels for the butons (menu items).  
;		If VALUES is a string array, then it is a 1-D array of labels.
;		If it a byte array, it is a 3-D array of bitmaps, where
;		the 1st 2 dimensions are the width and height of each
;		bitmap.
;
;	Parent:	The widget ID of parent base widget.  If this argument is
;		omitted, the menu base is a top-level base.
;
; KEYWORDS:
;	BASE:	A named variable to recieve the widget ID of the created base.
;
;      BUTTONS:	A named variable to recieve the widget ID of the created
;		buttons. This return value is a longword array, with each
;		element matching the corresponding element in Values.
;
;	COLUMN: This keyword specifies that the buttons should be layed out 
;		in columns. The value specified gives the number of columns
;		desired.
;
;    EXCLUSIVE:	Set this keyword to make each menu selection an exclusive
;		button.  Exclusive buttons have both selected and unselected 
;		states and only one button at a time can be selected.
;
;	FONT:	A string containing the name of the font for the button labels.
;
;	FRAME:	If this keyword is specified, it represents the thickness (in
;		pixels) of the frame drawn around the base.  The default is
;		no frame.
;
; NONEXCLUSIVE:	Set this keyword to make each menu selection a non-exclusive
;		button.  Non-exclusive buttons have both selected and 
;		un-selected states.  More that one button can be selected at
;		one time.
;
;   NO_RELEASE:	Set this keyword to prevent the buttons from returning release
;		events.  Normally, buttons return both selection and release
;		events.
;
;	ROW:	This keyword specifies that the buttons should be layed out 
;		in rows.  The value specified gives the number of rows desired.
;
;	SCROLL:	Set this keyword to give the base scrollbars to allow a large 
;		number of buttons to be viewed in a small region.
;
;	SPACE:	The space, in pixels, to be left around the edges of the base.
;
;	TITLE:	If PARENT is not specified, TITLE specifies the MENU title.
;		If PARENT is specified, a framed base is created and a
;		label with the value TITLE is added before the menu. 
;
;	XPAD:	The horizontal space, in pixels, to be left between the 
;		buttons.
;
;	YPAD:	The vertical space, in pixels, to be left between the buttons.
;
;	UVALUE:	An array of user values to be set into the UVALUE of the
;		buttons. This array must have the same number of elements
;		as VALUES.
;
;X_SCROLL_SIZE:	The width of the scrolling viewport.  This keyword implies 
;		SCROLL.
;
;Y_SCROLL_SIZE:	The height of the scrolling viewport.  This keyword
;		implies SCROLL.
;	
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	A widget base containing buttons is created, but not realized.
;
; EXAMPLE:
;	For an example of using XMENU to create menus see the "Non-Exclusive
;	Menu" and "Exclusive Menu" examples in the "Simple Widget Examples".
;	The simple widget examples menu can be seen by entering WEXMASTER at
;	the IDL prompt.
;
; MODIFICATION HISTORY:
;	16 January 1991, AB, RSI
;
;	5 September 1991, SMR, RSI   Fixed bug where titles were ignored when
;				     no base specified.
;
;	21 January 1992, ACY, RSI    Added FONT keyword.
;	7  July 1997, Zarro, GSFC    Passed FONT to TITLE and made FRAME optional
;                                    (renamed to XMENU2)
;       7 May 2000, Zarro (SM&A/GSFC) - added LFONT
;-

PRO XMENU2, VALUES, PARENT, BASE=BASE, BUTTONS=BUTTONS, COLUMN=COLUMN, $
	EXCLUSIVE=EXCLUSIVE, FONT=FONT, FRAME=FRAME, LFONT=LFONT,$
	NONEXCLUSIVE=NONEXCLUSIVE, ROW=ROW, SCROLL=SCROLL, SPACE=SPACE, $
	XPAD=XPAD, YPAD=YPAD, UVALUE=UVALUE, X_SCROLL_SIZE=X_SCROLL_SIZE, $
	Y_SCROLL_SIZE=Y_SCROLL_SIZE, TITLE = TITLE, NO_RELEASE = NO_RELEASE

  ; Error check the plain arguments
  s = size(parent)
  if (s(s(0) + 1) eq 0) then begin
    ; No parent is specified.
    parent = 0
    if (not keyword_set(TITLE)) then TITLE = 'Menu'
  endif else begin
    if (s(0) ne 0) then message, 'PARENT must be a scalar value."
    if (s(1) ne 3) then message, 'PARENT must be a long integer."
  endelse
  s = size(VALUES)
  value_type = s(s(0) + 1)
  if ((value_type ne 1) and (value_type ne 7)) then $
    message, 'VALUES must be a string vector or 3-D byte array.`
  if (value_type eq 1) then begin
    if (s(0) ne 3) then message, 'Type Byte VALUES must be 3-D'
    n_buttons = s(3)
  endif else begin
    n_buttons = n_elements(VALUES)
  endelse

  ; Sort out the keywords
  if ((not keyword_set(row)) and (not keyword_set(column))) then column=1
  if (not keyword_set(COLUMN)) then COLUMN=0
  if (not keyword_set(FONT)) then FONT = ''
  if (not keyword_set(LFONT)) then LFONT=''
  if (not keyword_set(ROW)) then ROW=0
  if (not keyword_set(EXCLUSIVE)) then EXCLUSIVE=0
  if (not keyword_set(NONEXCLUSIVE)) then NONEXCLUSIVE=0
  if (keyword_set(scroll) or keyword_set(x_scroll_size) or $
      keyword_set(y_scroll_size)) then begin
    scroll = 1;
    if (not keyword_set(x_scroll_size)) then x_scroll_size=0
    if (not keyword_set(y_scroll_size)) then y_scroll_size=0
  endif else begin
    scroll=0
  endelse
  if (not keyword_set(frame)) then frame = 0
  if (not keyword_set(space)) then space = 0
  if (not keyword_set(xpad)) then xpad = 0
  if (not keyword_set(ypad)) then ypad = 0
  if (not keyword_set(uvalue)) then begin
    uvalue=lindgen(n_buttons)
  endif else begin
    s = size(uvalue)
    if (s(s(0) + 2) ne n_buttons) then $
      message, 'UVALUE must have the same number of elements as VALUES'
  endelse

  ; Create the base
  if (parent eq 0) then begin
    if (scroll) then $
      base = widget_base(COLUMN=COLUMN, EXCLUSIVE=EXCLUSIVE, $
	  FRAME=FRAME, NONEXCLUSIVE=NONEXCLUSIVE, ROW=ROW, SCROLL=SCROLL, $
	  SPACE=SPACE, XPAD=XPAD, YPAD=YPAD, X_SCROLL_SIZE=X_SCROLL_SIZE, $
	  Y_SCROLL_SIZE=Y_SCROLL_SIZE, TITLE = TITLE, $
	  X_SCROLL_INCR = 20, Y_SCROLL_INCR = 20) $
    else $
      base = widget_base(COLUMN=COLUMN, EXCLUSIVE=EXCLUSIVE, $
	  FRAME=FRAME, NONEXCLUSIVE=NONEXCLUSIVE, ROW=ROW, $
	  SPACE=SPACE, XPAD=XPAD, YPAD=YPAD, TITLE = TITLE)
  endif else begin
    if (KEYWORD_SET(TITLE)) THEN BEGIN
      theparent = widget_base(parent, COLUMN=COLUMN, ROW=ROW,FRAME=FRAME)
      thelabel = widget_label(theparent, value = title,FONT=LFONT)
    ENDIF ELSE theparent = parent
    if (scroll) then $
      base = widget_base(theparent, COLUMN=COLUMN, EXCLUSIVE=EXCLUSIVE, $
	  FRAME=FRAME, NONEXCLUSIVE=NONEXCLUSIVE, ROW=ROW, SCROLL=SCROLL, $
	  SPACE=SPACE, XPAD=XPAD, YPAD=YPAD, X_SCROLL_SIZE=X_SCROLL_SIZE, $
	  Y_SCROLL_SIZE=Y_SCROLL_SIZE) $
    else $
      base = widget_base(theparent, COLUMN=COLUMN, EXCLUSIVE=EXCLUSIVE, $
	  FRAME=FRAME, NONEXCLUSIVE=NONEXCLUSIVE, ROW=ROW, $
	  SPACE=SPACE, XPAD=XPAD, YPAD=YPAD)
  endelse

  ; Create the buttons
  buttons = lindgen(n_buttons)
  if (value_type eq 1) then begin
    for i = 0, n_buttons-1 do $
      buttons(i) = WIDGET_BUTTON(base, $
		value=values(*, *, i), $
		no_release = no_release, $
		uvalue=uvalue(i), $
		FONT = FONT)
  endif else begin
    for i = 0, n_buttons-1 do $
      buttons(i) = WIDGET_BUTTON(base, $
		value=values(i), $
		no_release = no_release, $
		uvalue=uvalue(i), $
		FONT = FONT)
  endelse

end
