;+
; NAME:
;	STV
;
; PURPOSE:
;	Create a scrolling graphics window for examining large images.
;	By default, 1 draw widgets are used.  It displays the actual image with 
;	scrollbars that allow sliding
;	the visible window.
;
; CALLING SEQUENCE:
;	STV , Image
;
; INPUTS:
;	Image:	The 2-dimensional image array to be displayed.  If this 
;		argument is not specified, no image is displayed. The 
;		WID keyword can be used to obtain 
;		the window number of the draw widget so it can be drawn
;		into at a later time.
;
; KEYWORDS:
;
;
;	GROUP:	The widget ID of the widget that calls SLIDE_IMAGE.  If this
;		keyword is specified, the death of the caller results in the
;		death of STV.
;
;	ORDER:	This keyword is passed directly to the TV procedure
;		to control the order in which the images are drawn. Usually,
;		images are drawn from the bottom up.  Set this keyword to a
;		non-zero value to draw images from the top down.
;
;     REGISTER:	Set this keyword to create a "Done" button for SLIDE_IMAGE
;		and register the widgets with the XMANAGER procedure.
;
;		The basic widgets used in this procedure do not generate
;		widget events, so it is not necessary to process events
;		in an event loop.  The default is therefore to simply create
;		the widgets and return.  Hence, when register is not set, 
;		SLIDE_IMAGE can be displayed and the user can still type 
;		commands at the "IDL>" prompt that use the widgets.
;
;	RETAIN:	This keyword is passed directly to the WIDGET_DRAW
;		function, and controls the type of backing store
;		used for the draw windows.  If not present, a value of
;		2 is used to make IDL handle backing store.
;
; WID:	A named variable in which to store the IDL window number of 
;		the sliding window.  This window number can be used with the 
;		WSET procedure to draw to the scrolling window at a later 
;		time.
;
;	TITLE:	The title to be used for the SLIDE_IMAGE widget.  If this
;		keyword is not specified, "STV Image" is used.
;
;	TOP_ID:	A named variable in which to store the top widget ID of the 
;		STV hierarchy.  This ID can be used to kill the 
;		hierarchy as shown below:
;
;			STV, TOP_ID=base, ...
;			.
;			.
;			.
;			WIDGET_CONTROL, /DESTROY, base
;
;     XVISIBLE:	The width of the viewport on the scrolling window.  If this 
;		keyword is not specified, 1/2 of display size is used.
;
;     YVISIBLE:	The height of the viewport on the scrolling window. If
;		this keyword is not present, 1/2 of display size is used.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Widgets for displaying a very large image are created.
;	The user typically uses the window manager to destroy
;	the window, although the TOP_ID keyword can also be used to
;	obtain the widget ID to use in destroying it via WIDGET_CONTROL.
;
; RESTRICTIONS:
;	Scrolling windows don't work correctly if backing store is not 
;	provided.  They work best with window-system-provided backing store
;	(RETAIN=1), but are also usable with IDL provided backing store 
;	(RETAIN=2).
;
;	Various machines place different restrictions on the size of the
;	actual image that can be handled.
;
; MODIFICATION HISTORY:
;	04.01.02, nbr - Written, based on SLIDE_IMAGE.pro
;
;	01/02/04 @(#)stv.pro	1.1
;-


pro SLIDE_IMG_EVENT, ev
  WIDGET_CONTROL, ev.top, /DESTROY
end







pro stv, image, ORDER=ORDER, REGISTER=REGISTER, $
	RETAIN=RETAIN, WID=SLIDE_WINDOW, $
	XVISIBLE=XVISIBLE, YVISIBLE=YVISIBLE, $
	TITLE=TITLE, TOP_ID=BASE, GROUP = GROUP

  SWIN = !D.WINDOW
  device, GET_SCREEN_SIZE=ss
  if (n_params() ne 0) then begin
    image_size = SIZE(image)
    if (image_size[0] ne 2) then message,'Image must be a 2-D array'
    if (n_elements(XSIZE) eq 0) then XSIZE = image_size[1]
    if (n_elements(YSIZE) eq 0) then YSIZE = image_size[2]
  endif else begin
    image_size=bytarr(1)
    if (n_elements(XSIZE) eq 0) then XSIZE = 256
    if (n_elements(YSIZE) eq 0) then YSIZE = 256
  endelse
  if (n_elements(xvisible) eq 0) then XVISIBLE=ss[0]/2
  if (n_elements(Yvisible) eq 0) then YVISIBLE=ss[1]/2
  ;if(n_elements(SHOW_FULL) eq 0) THEN SHOW_FULL = 1
  if(not KEYWORD_SET(ORDER)) THEN ORDER = 0
  ;if(not KEYWORD_SET(USE_CONGRID)) THEN USE_CONGRID = 1
  if(n_elements(RETAIN) eq 0) THEN RETAIN = 2
  if(n_elements(TITLE) eq 0) THEN TITLE='STV Image'
  if(not KEYWORD_SET(REGISTER)) THEN REGISTER = 0

  if (REGISTER) then begin
    base = WIDGET_BASE(title=title, /COLUMN)
    junk = WIDGET_BUTTON(WIDGET_BASE(base), value='Done')
    ibase = WIDGET_BASE(base, /ROW)
  endif else begin
    base = WIDGET_BASE(title=title, /ROW)
    ibase = base
  endelse
  ; Setting the managed attribute indicates our intention to put this app
  ; under the control of XMANAGER, and prevents our draw widgets from
  ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
  ; sets this, but doing it here prevents our own WSETs at startup from
  ; having that problem.
  WIDGET_CONTROL, /MANAGED, base

;  if (SHOW_FULL) then begin
;      fbase = WIDGET_BASE(ibase, /COLUMN, /FRAME)
;        junk = WIDGET_LABEL(fbase, value='Full Image')
;        all = widget_draw(fbase,retain=retain,xsize=256,ysize=256)
;      sbase = WIDGET_BASE(ibase, /COLUMN, /FRAME)
;        junk = WIDGET_LABEL(sbase, value='Full Resolution')
;        scroll = widget_draw(sbase, retain=retain,xsize=xsize,ysize=ysize, $
;		/scroll, x_scroll_size=xvisible, y_scroll_size=yvisible)
;    WIDGET_CONTROL, /REAL, base
;    WIDGET_CONTROL, get_value=FULL_WINDOW, all
;  endif else begin
    scroll = widget_draw(ibase, retain=retain, xsize=xsize, ysize=ysize, $
	/frame, /scroll, x_scroll_size=xvisible, y_scroll_size=yvisible)
    WIDGET_CONTROL, /REAL, base
    FULL_WINDOW=-1
;  endelse

  WIDGET_CONTROL, get_value=SLIDE_WINDOW, scroll

  ; Show the image(s) if one is present
  if (image_size[0] ne 0) then begin
    ;if (SHOW_FULL) then begin
    ;  WSET, FULL_WINDOW
    ;  if (use_congrid) then begin
	;TV, congrid(image, 256,256,/interp), ORDER=ORDER
    ;  endif else begin
	;TV, image, ORDER=ORDER
    ;  endelse
    ;endif
    WSET, SLIDE_WINDOW
    TV, image, ORDER=ORDER
  endif
  if (n_elements(group) eq 0) then group=base
  ;WSET, SWIN

  if (REGISTER) then XMANAGER, 'STV', base, event='SLIDE_IMG_EVENT', $
	GROUP_LEADER = GROUP, /NO_BLOCK

end
