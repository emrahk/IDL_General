;+
; NAME:
;	XTV
; PURPOSE:
;	This application is designed to display IDL arrays as images. XTV
;	allows the user to view the image at any resolution and read off
;	x and y coordinates. It is hoped that this will be very useful for
;	studying morphology and enabling precise coalignment of astronomical
;	images. Special effort has been made to accommodate large images
;	efficiently and without relying on the server or IDL for backing store.
;	A region of interest can be selected and passed to another program
;	by pressing the ROI button (coordinates are passed through the 
;	XTV_ENVIRONMENT common block).
; CATEGORY:
;	Widgets
; CALLING SEQUENCE:
;	XTV, image_raw [, /D]
; INPUTS:
;	image_raw = an IDL 2d array of almost any size. May be of type byte,
;		integer, longword, floating, or double.
; OPTIONAL INPUT PARAMETERS:
;	none.
; KEYWORD PARAMETERS:
;	GROUP = The widget ID of the widget that calls XTV.  When this
;		ID is specified, a death of the caller results in a death of
;		XTV.
;	D = 	Deallocate. If D is defined, then the image_raw 
;		array will be destroyed in order to conserve memory. When XTV
;		exits, image_raw will be replaced by a copy from the 
;		XTV_ENVIRONMENT common block.
;	screenwidth = width of display widget, in pixels.
;	screenheight = height of display widget, in pixels.
; OUTPUTS:
;	none
; OPTIONAL OUTPUT PARAMETERS:
;	none
; COMMON BLOCKS:
;   COMMON XTV_ENVIRONMENT, image, $	;a copy of the image
;	i_width, i_height,	$	;size of image
;	d_width, d_height,	$	;size of draw widget
;	xsp, ysp, 		$	;position of scoll bars
;	draw_index,		$	;window index of draw widget
;	x_scroll, y_scroll,	$	;scroll bars
;	xylabel,		$	;cursor position label
;	new_d_width,		$	;magnification = d_width/new_d_width
;	roi				;region of interest coord's [x1,x2,y1,y2]
;	This common block allows me to handle redraws.
; SIDE EFFECTS:
;	Initiates the XManager if it is not already running.
; RESTRICTIONS:
;	Only one copy of XTV is allowed to run at a time, because otherwise the
;	common blocks would intersect. In a future version, I plan to cleverly
;	get around this problem.
; PROCEDURE:
;	Create and register the widget, draw the image, and manually hook up
;	sliders to act as scroll bars, with redraws provided by the event
;	handler. Neither the server nor IDL is capable of providing backing
;	store, so redraws are handled explicitly. Woof.
; MODIFICATION HISTORY:
;	Created by Charles Kankelborg, October 1993.
;	Modified to keep full image depth and tvscl with each display, so
;	  that the pixel value can be displayed with the coordinates. cck 5/97
;	Added region of interest selection. cck 6/9/97
;       Use [] indexing, William Thompson, 24 Sep 2010
;-



;------------------------------------------------------------------------------
;	procedure XTV_cursor
;------------------------------------------------------------------------------
;This procedure displays the x and y coordinates of the mouse
;pointer within the XTV draw window.
;------------------------------------------------------------------------------
PRO XTV_cursor, mouse

COMMON XTV_ENVIRONMENT, image,	$	;a copy of the image
	i_width, i_height,	$	;size of image
	d_width, d_height,	$	;size of draw widget
	xsp, ysp, 		$	;position of scoll bars
	draw_index,		$	;window index of draw widget
	x_scroll, y_scroll,	$	;scroll bars
	xylabel,		$	;cursor position label
	new_d_width,		$	;magnification = d_width/new_d_width
	roi				;region of interest coord's [x1,x2,y1,y2]


new_d_height=FIX(FLOAT(new_d_width)*d_height/d_width+.5)

xleft=xsp-(new_d_width/2)	;xleft and ylower must match the first-cut def-
ylower=ysp-(new_d_height/2)	;initions of x1 and y1 in procedure XTV_redraw.

reduction = FLOAT(new_d_width)/FLOAT(d_width)	;gotta be sure to count pixels
x = FIX(reduction*FLOAT(mouse.x)+xleft)		;exactly the way CONGRID does.
y = FIX(reduction*FLOAT(mouse.y)+ylower)	;

coordinates = STRING(x) + ', ' + STRING(y) + STRING(10B) + STRING(13B) $
	+ STRING(FLOAT(image[x > 0 < (i_width-1),y > 0 < (i_height-1)]))

WIDGET_CONTROL, xylabel, SET_VALUE=coordinates

END



;------------------------------------------------------------------------------
;	procedure XTV_redraw
;------------------------------------------------------------------------------
;This is the procedure for handling routine redraws of the XTV draw screen.
;The XTV_ENVIRONMENT common block is used, so there are no calling parameters.
;------------------------------------------------------------------------------
PRO XTV_redraw, smooth=smooth

COMMON XTV_ENVIRONMENT, image,	$	;a copy of the image
	i_width, i_height,	$	;size of image
	d_width, d_height,	$	;size of draw widget
	xsp, ysp, 		$	;position of scoll bars
	draw_index,		$	;window index of draw widget
	x_scroll, y_scroll,	$	;scroll bars
	xylabel,		$	;cursor position label
	new_d_width,		$	;magnification = d_width/new_d_width
	roi				;region of interest coord's [x1,x2,y1,y2]



new_d_height=FIX(FLOAT(new_d_width)*d_height/d_width+.5)

x1=xsp-(new_d_width/2)		;(x1:x2, y1:y2) is the subscript range of image
y1=ysp-(new_d_height/2)		;which belongs in the draw widget; but these
x2=x1+new_d_width-1		;subscripts might be out of range, in which
y2=y1+new_d_height-1		;case the next block of code fixes the problem.

width = d_width			;width of region to be drawn in draw widget
height = d_height		;height of region to be drawn in draw widget

x_margin = 0		;offset of region from left edge of draw widget
y_margin = 0		;offset of region from bottom edge of draw widget

;* --------------------------------------------------------- *
;*   What to do if the subscripts xi, yi are out of range    *
;* --------------------------------------------------------- *
if x1 lt 0 then begin
   off_edge=FIX(FLOAT(-x1)*FLOAT(d_width)/FLOAT(new_d_width)+0.5)
   x_margin=off_edge
   width=width-x_margin
   x1=0
endif

if y1 lt 0 then begin
   off_edge=FIX(FLOAT(-y1)*FLOAT(d_height)/FLOAT(new_d_height)+0.5)
   y_margin=off_edge
   height=height-y_margin
   y1=0
endif

if x2 gt i_width-1 then begin
   off_edge=FIX(FLOAT(x2-(i_width-1))*FLOAT(d_width)/FLOAT(new_d_width)+0.5)
   width=width-off_edge
   x2=i_width-1
endif

if y2 gt i_height-1 then begin
   off_edge=FIX(FLOAT(y2-(i_height-1))*FLOAT(d_height)/FLOAT(new_d_height)+0.5)
   height=height-off_edge
   y2=i_height-1
endif
;* --------------------------------------------------------- *


WSET, draw_index

ERASE

if N_ELEMENTS(smooth) eq 0 then smooth = 0 $
	else smooth=1

if d_width eq new_d_width then begin		;Magnification of 1 is about
   TVSCL, image[x1:x2,y1:y2], x_margin, y_margin	;four times faster this way.
endif else begin
   TVSCL, congrid(image[x1:x2,y1:y2], width, height, interp=smooth), $
       x_margin, y_margin
						;rescale and plot in one step 
endelse


END	;================= end of XTV_redraw procedure================



;------------------------------------------------------------------------------
;	procedure XTV_ev
;------------------------------------------------------------------------------
;This is the event handler for the XTV widget. It doesn't look like it, but
;it's a loop that is always looking for the next event. Of course, the real
;workings are obscured in the Xmanager thing, which was quite fortunately 
;written by somebody else.
;------------------------------------------------------------------------------
PRO XTV_ev, event

COMMON XTV_ENVIRONMENT, image,	$	;a copy of the image
	i_width, i_height,	$	;size of image
	d_width, d_height,	$	;size of draw widget
	xsp, ysp, 		$	;position of scoll bars
	draw_index,		$	;window index of draw widget
	x_scroll, y_scroll,	$	;scroll bars
	xylabel,		$	;cursor position label
	new_d_width,		$	;magnification = d_width/new_d_width
	roi				;region of interest coord's [x1,x2,y1,y2]
	;This common block allows me to handle redraws.

WIDGET_CONTROL, event.id, GET_UVALUE = eventval		;find the user value
							;of the widget where
							;the event occured

CASE eventval OF		;What am I supposed to do about this event?

  "ONE2ONE": begin					;Display the image at a
        new_d_width = d_width				;Magnification of 1,
        XTV_redraw					;that is, pixel for
     end						;pixel.

  "FULLWIDTH": begin					;Squeeze the whole width
        new_d_width = i_width				;of the image into the
        XTV_redraw					;draw widget.
     end						;

  "FULLHEIGHT": begin					 ;Squeeze entire height
        new_d_width=FIX(LONG(d_width)*i_height/d_height) ;of the image into the
        XTV_redraw					 ;draw widget.
      end						 ;

  "ENLARGE": begin
        new_d_width = new_d_width/2
        XTV_redraw
     end

  "REDUCE": begin
        new_d_width = new_d_width*2
        XTV_redraw
     end

  "EN_TEN": begin
        new_d_width = new_d_width/1.1
        XTV_redraw
     end

  "RE_TEN": begin
        new_d_width = new_d_width*1.1
        XTV_redraw
     end

  "XLOADCT": XLoadct, GROUP = event.top			;XLoadct is the library
							;routine that lets you
							;select and adjust the
							;color palette being
							;used.

  "XPALETTE": XPalette, GROUP = event.top		;XPalette is the
							;library routine that
							;lets you adjust 
							;individual color
							;values in the palette.

  "XMANTOOL": XManagerTool, GROUP = event.top		;XManTool is a library
							;routine that shows 
							;which widget
							;applications are 
							;currently registered
							;with the XManager as
							;well as which
							;background tasks.


  "EXIT": begin						;EXIT routine:
        WIDGET_CONTROL, event.top, /DESTROY		;No need to unregister,
     end						;Xmanager will clean up.


  "x_scroll": begin					;x-axis scroll bar
        WIDGET_CONTROL, event.id, GET_VALUE=scroll_position
        xsp=scroll_position
        XTV_redraw
     end


  "y_scroll": begin					;y-axis scroll bar
        WIDGET_CONTROL, event.id, GET_VALUE=scroll_position
        ysp=scroll_position
        XTV_redraw
     end

  "image_draw": begin
        XTV_cursor, event
     end

  "smooth": XTV_redraw, /smooth				;Tell CONGRID to use
							;bilinear interpolation.
							;Makes highly magnified
							;images look prettier.

  "region": begin
	;Based on procedure XTV_cursor; allows selection of region of interest.
        ;tvboxcrs, roix1, roix2, roiy1, roiy2
	select_box, roimx, roimy, roix1, roiy1
	roix2 = roix1 + roimx
	roiy2 = roiy1 + roimy
        new_d_height=fix(float(new_d_width)*d_height/d_width+.5)
	xleft = xsp-(new_d_width/2)
	ylower = ysp-(new_d_height/2)
	reduction = float(new_d_width)/float(d_width)
	roix1 = fix(reduction*float(roix1)+xleft)
	roix2 = fix(reduction*float(roix2)+xleft)
	roiy1 = fix(reduction*float(roiy1)+ylower)
	roiy2 = fix(reduction*float(roiy2)+ylower)
	roi = [roix1,roix2,roiy1,roiy2]
     end

  "print": tvlaser

  ELSE: MESSAGE, "Event not implemented in handler", $	;When an event occurs
				/INFORMATIONAL		;in a widget that has
							;a user value not in
							;this case statement, a
							;message is shown

  ENDCASE

END ;============= end of XTV event handling routine task =============



;------------------------------------------------------------------------------
;	procedure XTV
;------------------------------------------------------------------------------
; This routine creates the widget and registers it with the XManager.
;------------------------------------------------------------------------------
PRO XTV, image_raw, D = D, GROUP = GROUP, $
		screenwidth = screenwidth, $
		screenheight = screenheight, $
		magnification = magnification

IF(XRegistered("XTV") NE 0) THEN RETURN		;only one instance of the XTV
						;widget is allowed, because it
						;uses a common block. If XTV
						;is already managed, do
						;nothing and return

COMMON XTV_ENVIRONMENT, image,	$	;a copy of the image
	i_width, i_height,	$	;size of image
	d_width, d_height,	$	;size of draw widget
	xsp, ysp, 		$	;position of scoll bars
	draw_index,		$	;window index of draw widget
	x_scroll, y_scroll,	$	;scroll bars
	xylabel,		$	;cursor position label
	new_d_width,		$	;magnification = d_width/new_d_width
	roi				;region of interest coord's [x1,x2,y1,y2]
	;This common block allows me to handle redraws. Neither IDL nor the
	;server are capable of providing backing store for such a large image.

if N_ELEMENTS(screenwidth) eq 0 then screenwidth = 512
if N_ELEMENTS(screenheight) eq 0 then screenheight = 512

i_size = SIZE(image_raw)

if N_ELEMENTS(i_size) ne 5 then begin
	message,"Image parameter is not a 2D array. Exiting...", $
           /INFORMATIONAL
	RETURN
endif

i_width = i_size[1]
i_height = i_size[2]

image = image_raw ;used to bytescale, but not anymore!

;IMAGE IS NO LONGER BYTESCALED!
;if i_size(3) ne 1 then begin	;if image_raw is not a byte array yet...
;   case i_size(3) of
;      2: i_type="INTEGER"
;      3: i_type="LONGWORD INTEGER"
;      4: i_type="FLOATING POINT"
;      5: i_type="DOUBLE PRECISION FLOATING"
;      else: begin
;         message, "Image parameter is of inappropriate type. Exiting...", $
;            /INFORMATIONAL
;         RETURN
;      endelse
;   endcase
;   print,"Rescaling ",i_type," image to 8 bits..."
;   image = bytscl(image_raw)	;then make a byte array of the image.
;endif else begin		;Otherwise,
;   image = image_raw		;let it stay as it is.
;endelse

if N_ELEMENTS(D) ne 0 then begin
   image_raw=0
   message,'/D: Deallocated original image array to save memory.', $
      /INFORMATIONAL
endif

d_width = screenwidth
d_height = screenheight

new_d_width = d_width		;default

xsp = i_width/2		;default
ysp = i_height/2	;default

XTVbase = WIDGET_BASE(TITLE = "XTV", /COLUMN)
	;Create the main base of the XTV widget.

menu_base = WIDGET_BASE(XTVbase, /ROW)

XPdMenu, [	'"Done"					EXIT',		$
		'"Print"				print',		$
		'"ROI"					region',	$
		'"Zoom" {',					$
				'"1 : 1"		ONE2ONE',	$
				'"Full Width"		FULLWIDTH',	$
				'"Full Height"		FULLHEIGHT',	$
				'"^ Enlarge x 2"	ENLARGE',	$
				'"| Enlarge 10%"	EN_TEN',	$
				'"| Reduce 10%"		RE_TEN',	$
				'"v Reduce x 1/2"	REDUCE',	$
				'}',					$
		'"Interp"				smooth',	$
		'"Tools"	{',					$
				'"XLoadct"		XLOADCT',	$
				'"XPalette"		XPALETTE',	$
				'"XManagerTool"		XMANTOOL',	$
				'}'],					$
	 menu_base		; Create menus for XTV widget

ybase = WIDGET_BASE(XTVbase,/ROW)

image_draw = WIDGET_DRAW(ybase, xsize=d_width, ysize=d_height, RETAIN=1, $
	/MOTION_EVENTS, UVALUE='image_draw')
	;the keyword RETAIN is here explicitly set to 1 (default value)
	;even though the finished application xtv does not rely on con-
	;ventional backing store. It turns out that RETAIN=0 causes
	;goofy things to happen. Usually, small ( < 168x168) arrays will not
	;draw on the image_draw widget if RETAIN=0.

y_scroll = WIDGET_SLIDER(ybase, maximum = i_height, $
	UVALUE='y_scroll', /VERTICAL)

x_scroll = WIDGET_SLIDER(xsize = d_width, XTVbase, maximum = i_width, $
	UVALUE='x_scroll')
	;Apparently, the X toolkit won't take the hint from the xsize keyword.

xylabel = WIDGET_TEXT(menu_base, FRAME=0, YSIZE=2, $
	VALUE='Coordinates' + string(10B)+string(13B) + 'Pixel value')
	;                                   ^LF         ^CR

WIDGET_CONTROL, XTVbase, /REALIZE			;create the widgets
							;that are defined
WIDGET_CONTROL, GET_VALUE=draw_index, image_draw

WIDGET_CONTROL, x_scroll, set_value=xsp
WIDGET_CONTROL, y_scroll, set_value=ysp

XTV_redraw

XManager, "XTV", XTVbase, $			;register the widgets
		EVENT_HANDLER = "XTV_ev", $	;with the XManager
		GROUP_LEADER = GROUP		;and pass through the
						;group leader if this
						;routine is to be 
						;called from some group
						;leader.
;The call to XManager will return after the done button is pushed, and
;execution will resume from here...

if N_ELEMENTS(image_raw) eq 1 then begin	;If image_raw has been
   image_raw=image				;deallocated, then
   print, "The deallocated image variable"+ $	;restore from the
      " has been restored."			;copy used for viewing.
endif					

RETURN
END ;==================== end of XTV main routine =======================















