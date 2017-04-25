PRO TVPROFILE, IMAGE, WSIZE=WSIZE, DISABLE=DISABLE, NOWINDOW = NOWINDOW, $
               win_id=win_id, quiet=quiet, widget=widget
;+
; Project     : SOHO - CDS
;
; Name        : 
;	TVPROFILE
; Purpose     : 
;	Interactively draw profile of an image in separate window.
; Explanation : 
;	Interactively draw row or column profiles of an image in a separate
;	window.  A new window is created and the mouse location in the original
;	window is used to plot profiles in the new window.  Pressing the left
;	mouse button toggles between row and column profiles.  The right mouse
;	button exits.
; Use         : 
;	TVPROFILE, Image
;
;	Example: Create and display an image and use the TVPROFILE routine on
;	it.  Create and display the image by entering:
;
;		A = DIST(256)
;		EXPTV, A
;
;	Run the TVPROFILE routine by entering:
;
;		TVPROFILE, A
;
;	The TVPROFILE window should appear.  Move the cursor over the original
;	image to see the profile at the cursor position.  Press the left mouse
;	button to toggle between row and column profiles.  Press the right
;	mouse button (with the cursor over the original image) to exit the
;	routine.
;
; Inputs      : 
;	IMAGE	= The variable that represents the image displayed.  This data
;		  need not be scaled into bytes.  The profile graphs are made
;		  from this array.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	None.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	WSIZE	= The size of the TVPROFILE window as a fraction or multiple 
;		  of 640 by 512.
;	DISABLE	= If set, then TVSELECT is not used.
;	NOWINDOW= If set, then the graph is made using the current graphics
;		  device or window.
;       WIN_ID  = ID of the graphic window in which the profile is
;                 shown (unless NOWINDOW is set). If neither NOWINDOW
;                 nor WIN_ID is set, the profile will be displayed in
;                 a new window
;       QUIET   = Set this keyword to suppress informative messages
;
;       WIDGET = If this keyword is not set and there are at least one
;                realized, managed widget on the screen, TVPROFILE will
;                try to find out (through FIND_DRAW_WIDGET) whether the
;                draw window is actually a widget.
;
;                If the draw window is actually a widget, WIDGET_EVENT() 
;                WILL BE USED instead of the CURSOR procedure, UNLESS this
;                keyword is set to -1.
;
;                If WIDGET is set to -1, no search for a widget ID will be
;                performed.
;
;                If the widget ID of the draw window is known by the caller,
;                this keyword may be set to that ID to avoid searching for it.
;                 
; Calls       : 
;	GET_TV_SCALE, HAVE_WINDOWS, TVPOS, SETWINDOW
; Common      : 
;	None.
; Restrictions: 
;	The image must have been displayed with EXPTV or PUT.
;
;	It is important that the user select the graphics device/window, and
;	image region before calling this routine.  For instance, if the image
;	was displayed using EXPTV,/DISABLE, then this routine should also be
;	called with the /DISABLE keyword.  If multiple images are displayed
;	within the same window, then use SETIMAGE to select the image before
;	calling this routine.
;
;	In general, the SERTS image display routines use several non-standard
;	system variables.  These system variables are defined in the procedure
;	IMAGELIB.  It is suggested that the command IMAGELIB be placed in the
;	user's IDL_STARTUP file.
;
;	Some routines also require the SERTS graphics devices software,
;	generally found in a parallel directory at the site where this software
;	was obtained.  Those routines have their own special system variables.
;
; Side effects: 
;	Unless the keyword WIN_ID is set, a new window is created and
;	used for the profiles.  When done, the new window is deleted.
;	
;	If widgets are used, both DRAW_MOTION_EVENTS and DRAW_BUTTON_EVENTS
;	are set for the widget (they should be set already anyway..).
;
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	William Thompson, March 1993, from PROFILES by DMS, Nov, 1988.
; Written     : 
;	William Thompson, GSFC, March 1993.
; Modified    : 
;	Version 1, William Thompson, GSFC, 11 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 1 September 1993.
;		Changed WSET to SETWINDOW in selected places.
;	Version 3, William Thompson, GSFC, 29 October 1993.
;		Added image value to display.
;       Version 4, November 15, 1995, Liyun Wang, GSFC/ARC
;               Added keywords WIN_ID and QUIET
;       Version 5, 22 May 1997, SVH Haugan, UiO
;               Added the use of WIDGETs.
;       Version 6, 03-Jun-2004, William Thompson
;               Allow the background color to be other than zero.
;       Version 7, 24-Sep-2010, WTT, use [] indexing
; Version     : 
;	Version 7, 24-Sep-2010
;-
;
	ON_ERROR,2			;Return to caller if an error occurs
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN MESSAGE,'Syntax:  TVPROFILE, IMAGE'
;
;  Get the relative size of the window to be created.
;
	IF N_ELEMENTS(WSIZE) EQ 0 THEN WSIZE = 0.75
;
;  Check the IMAGE array.
;
	S = SIZE(IMAGE)
	IF S[0] NE 2 THEN MESSAGE,'IMAGE must be two-dimensional'
;
;  Get the scale of the displayed image.
;
	GET_TV_SCALE,NX,NY,MX,MY,IX,IY,DISABLE=DISABLE
	IF (NX NE S[1]) OR (NY NE S[2]) THEN MESSAGE,	$
		'IMAGE size does not agree with displayed image'
;
;  Get the image extrema.  Used for scaling the plots.
;
	MAXV = MAX(IMAGE)
	MINV = MIN(IMAGE)
;
;  Decide whether or not to create a special window.
;
	USE_WINDOW = HAVE_WINDOWS() AND (NOT KEYWORD_SET(NOWINDOW))
;
;  Create a new window for the plot.
;
	IF USE_WINDOW THEN BEGIN
		SETWINDOW		;Save current parameters
                ORIG_W = !D.WINDOW
                IF N_ELEMENTS(win_id) NE 0 THEN $
                   new_w = win_id $
                ELSE BEGIN 
                   WINDOW, /FREE , XS=WSIZE*640, YS=WSIZE*512, TITLE='Profiles'
                   NEW_W = !D.WINDOW
                ENDELSE
	ENDIF
;
;  Set up some parameters used by the software.
;
	TICKL = 0.1				;Cross length
	OLD_MODE = -1				;Mode = 0 for rows, 1 for cols
	MODE = 0
	OLD_FONT = !P.FONT			;Use hardware font
	!P.FONT = 0
;
;  Keep going until the right mouse button has been pressed.
;
        IF NOT KEYWORD_SET(quiet) THEN BEGIN
           PRINT, 'Left mouse button to toggle between rows and columns.'
           PRINT, 'Right mouse button to Exit.'
        ENDIF
;
;  Is this a widget window?
;
        IF N_ELEMENTS(WIDGET) NE 1 THEN BEGIN
           IF NOT (HAVE_WINDOWS() AND WIDGET_INFO(/ACTIVE)) THEN WIDGET = -1 $
           ELSE WIDGET = FIND_DRAW_WIDGET(ORIG_W)
        END
        
        IF WIDGET NE -1L THEN BEGIN
           IF NOT WIDGET_INFO(WIDGET,/DRAW_BUTTON_EVENTS) OR $
              NOT WIDGET_INFO(WIDGET,/DRAW_MOTION_EVENTS) THEN BEGIN 
              MESSAGE,"Motion/button events turned on",/CONTINUE
              MESSAGE,"They may have to be turned off after returning from "+$
                 "TVPROFILE",/CONTINUE
              WIDGET_CONTROL,WIDGET,/DRAW_BUTTON_EVENTS,$
                 /DRAW_MOTION_EVENTS
           END
        END 
        
	WHILE 1 DO BEGIN
;
;  Set the mouse focus to the original window, and read the image position.
;
		IF USE_WINDOW THEN WSET,ORIG_W		;Image window
                TVPOS,X,Y,WAIT=2,DISABLE=DISABLE,$      ;Read position
                   WIDGET=WIDGET
;
;  If the right mouse button was pressed, then exit.
;
		IF !ERR EQ 4 THEN BEGIN			;Quit
			IF USE_WINDOW THEN BEGIN
				WSET, NEW_W
				SETWINDOW,ORIG_W	;Restore parameters
                                IF N_ELEMENTS(win_id) EQ 0 THEN WDELETE, NEW_W
			ENDIF
                        !P.FONT = OLD_FONT
			RETURN
		ENDIF
;
;  If the left mouse button was pressed, then switch plotting modes.
;
		IF !ERR EQ 1 THEN BEGIN
			MODE = 1-MODE	;Toggle mode
			REPEAT TVPOS,X,Y,WAIT=0,DISABLE=DISABLE UNTIL !ERR EQ 0
		ENDIF
;
;  Force X and Y to be integer values.
;
		X = FIX(X)  &  Y = FIX(Y)
;
;  Switch to the graphics window.
;
		IF USE_WINDOW THEN WSET,NEW_W		;Graph window
;
;  If necessary change the graphics mode.
;
		IF MODE NE OLD_MODE THEN BEGIN
			OLD_MODE = MODE
			FIRST = 1
			IF MODE THEN BEGIN	;Columns?
				PLOT,[MINV,MAXV],[0,NY-1],/NODAT,	$
					TITLE='Column Profile'
				VECY = FINDGEN(NY)
				CROSSX = [-TICKL, TICKL]*(MAXV-MINV)
				CROSSY = [-TICKL, TICKL]*NY
			END ELSE BEGIN
				PLOT,[0,NX-1],[MINV,MAXV],/NODATA,	$
					TITLE='Row Profile'
				VECX = FINDGEN(NX)
				CROSSX = [-TICKL, TICKL]*NX
				CROSSY = [-TICKL, TICKL]*(MAXV-MINV)
			ENDELSE
		ENDIF
;
;  If the cursor falls within the image, then draw the graph.
;
		IF (X LT NX) AND (Y LT NY) AND $
			(X GE 0) AND (Y GE 0) THEN BEGIN	;Draw it
		
			IF FIRST EQ 0 THEN BEGIN		;Erase?
                                BG = !P.BACKGROUND
				PLOTS, VECX, VECY, COL=BG	;Erase graph
				PLOTS, OLD_X, OLD_Y, COL=BG	;Erase cross
				PLOTS, OLD_X1, OLD_Y1, COL=BG
				XYOUTS,.1,0,/NORM,VALUE,COL=BG	;Erase text
				EMPTY
                        ENDIF ELSE FIRST = 0
			VALUE = STRTRIM(X,2) + ', '+STRTRIM(Y,2) + ', ' + $
				STRTRIM(IMAGE[X,Y],2)
			IXY = IMAGE[X,Y]			;Data value
			IF MODE THEN BEGIN			;Columns?
				VECX = IMAGE[X,*]		;Get column
				OLD_X = CROSSX + IXY
				OLD_Y = [Y,Y]
				OLD_X1 = [IXY, IXY]
				OLD_Y1 = CROSSY + Y
			ENDIF ELSE BEGIN
				VECY = IMAGE[*,Y]		;Get row
				OLD_X = [ X,X]
				OLD_Y = CROSSY + IXY
				OLD_X1 = CROSSX + X
				OLD_Y1 = [IXY,IXY]
			ENDELSE
			XYOUTS,.1,0,/NORM,VALUE			;Text of locn
			PLOTS,VECX,VECY				;Graph
			PLOTS,OLD_X, OLD_Y			;Cross
			PLOTS,OLD_X1, OLD_Y1
		ENDIF
	ENDWHILE
;
	END
