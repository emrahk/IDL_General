	PRO TVAXIS,ARRAY,MX,MY,JX,JY,XAXIS=XAXIS,YAXIS=YAXIS,XRANGE=XRANGE,  $
		YRANGE=YRANGE,XTITLE=XTITLE,YTITLE=YTITLE,TICKLEN=TICKLEN,   $
		XTICKLEN=XTICKLEN,YTICKLEN=YTICKLEN,XTICKNAME=XTICKNAME,     $
		YTICKNAME=YTICKNAME,XTICKS=XTICKS,YTICKS=YTICKS,	     $
		XTICKV=XTICKV,YTICKV=YTICKV,NOXLABEL=NOXLABEL,		     $
		NOYLABEL=NOYLABEL,XTYPE=XTYPE,YTYPE=YTYPE,COLOR=COLOR,	     $
		DISABLE=DISABLE,DATA=DATA,ORIGIN=ORIGIN,SCALE=SCALE,	     $
		_EXTRA=_EXTRA
;+
; Project     : SOHO - CDS
;
; Name        : 
;	TVAXIS
; Purpose     : 
;	Places X and/or Y axes on displayed images.
; Explanation : 
;	Places X and/or Y axes on images displayed with the EXPTV or similar
;	procedure.
; Inputs      : 
;	None required.
; Opt. Inputs : 
;	ARRAY	 = Image to draw axes on.
;	MX, MY	 = The size of the image on the display screen.
;	JX, JY	 = The position of the lower left-hand corner of the image on 
;		   the display screen.
;
;	If the optional parameters are not passed, then they are retrieved with
;	GET_TV_SCALE.  It is anticipated that these optional parameters will
;	only be used in extremely rare circumstances.
;
; Outputs     : 
;	The values of MX, MY and JX, JY are printed to the terminal screen.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	XAXIS	 = If 0 then X axis is drawn below image, if 1 then above.
;		   Default is not to draw an X axis.
;	YAXIS	 = If 0 then Y axis is drawn to the left, if 1 then right.
;		   Default is not to draw a Y axis.
;
;	ORIGIN	 = Two-element array containing the coordinate value in
;		   physical units of the center of the first pixel in the
;		   image.  Defaults to whatever was previously set, or [0,0] if
;		   none.
;	SCALE	 = Pixel scale in physical units.  Can have either one or two
;		   elements.  Defaults to whatever was previously set, or [1,1]
;		   if none.
;
;	XRANGE	 = Array containing minimum and maximum values of X.  Default
;		   is to use predefined scale, or pixel numbers if none.  It is
;		   important to realize that the range refers to the edges of
;		   the pixels, i.e. from the left edge of the leftmost pixel to
;		   the right edge of the rightmost pixel.  The width of the
;		   pixels in the data coordinates must be taken into account.
;		   This is to maintain compatibility with the behavior of AXIS
;		   when used with graphic plots.
;	YRANGE	 = Array containing minimum and maximum values of Y.  Default
;		   is to use predefined scale, or pixel numbers if none.  The
;		   same comments for XRANGE also apply to YRANGE, except that
;		   the range applies from the bottom of the bottommost pixel to
;		   the top of the topmost pixel.
;
;	Either ORIGIN,SCALE or XRANGE,YRANGE can be used, but not both.  If
;	neither are used, then whatever scale was previously defined will be
;	used.  If no scale has been defined, then pixel numbers will be used.
;
;	XTITLE	 = X axis title.  Default is value of !XTITLE.
;	YTITLE	 = Y	"	"	"	"	"
;	TICKLEN	 = Length of tick marks.  Default is !TICKLEN.
;	XTICKLEN = Length of X tick marks.  Overrides TICKLEN.
;	YTICKLEN =	"    Y	"	"
;	XTICKNAME= String array giving the annotation of each X tick.
;	YTICKNAME=	"	"	"	"	"     Y	"
;	XTICKS	 = Number of major X tick intervals to draw.
;	YTICKS	 =	"	"  Y	"	"
;	XTICKV	 = Array of values for each X tick mark.
;	YTICKV	 = 	"	"	"   Y	"
;	NOXLABEL = If set, then the X axis is not labelled.  Overridden by
;		   XTITLE and  XTICKNAME keywords.
;	NOYLABEL = If set, then the Y axis is not labelled.  Overridden by
;		   YTITLE and  YTICKNAME keywords.
;	XTYPE	 = Either 0 for linear, or 1 for logarithmic.
;	YTYPE	 = Either 0 for linear, or 1 for logarithmic.
;	COLOR	 = Color to use for drawing the axes.
;	DISABLE  = If set, then TVSELECT not used.
;	DATA	 = If set, then immediately activate the data coordinates for
;		   the displayed image.
;
;	Other standard keywords for the AXIS command are also supported.
;
; Calls       : 
;	GET_TV_SCALE, TVSELECT, TVUNSELECT
; Common      : 
;	None.
; Restrictions: 
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
;	The data coordinates associated with an image are changed by this
;	routine.
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	W.T.T., July 1991.
;	William Thompson, May 1992, modified to use GET_TV_SCALE.
;	William Thompson, Nov 1992, removed call to INIT_SC1_SC4.
; Written     : 
;	William Thompson, GSFC, July 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 11 May 1993.
;		Incorporated into CDS library.
;	Version 2, William Thompson, GSFC, 1 September 1993.
;		Modified to keep track of image data coordinates.
;	Version 3, William Thompson, GSFC, 19 October 1994
;		Added XTYPE and YTYPE keywords.
;	Version 4, William Thompson, GSFC, 20 March 1995
;		Added ORIGIN and SCALE keywords.
;	Version 5, William Thompson, GSFC, 11 November 1999
;		Added keyword _EXTRA
;	Version 6, William Thompson, GSFC, 02-Apr-2001
;		Modified to use correct system variables (for v5.4)
;	Version 7, William Thompson, GSFC, 14-May-2001
;		Further modified system variables.
; Version     : 
;	Version 7, 14-May-2001
;-
;
        ON_ERROR,2
;
;  Check the number of parameters.
;
	IF (N_PARAMS() NE 0) AND (N_PARAMS() NE 5) THEN BEGIN
		PRINT,'*** TVAXIS must be called with 0 or 5 parameters:'
		PRINT,'                             [, XAXIS=... ]  [, YAXIS=... ]'
		PRINT,'      ARRAY, MX, MY, JX, JY  [, XAXIS=... ]  [, YAXIS=... ]'
		RETURN
	ENDIF
;
;  If necessary, get the scale on the image display screen.
;
	IF N_PARAMS() EQ 0 THEN BEGIN
		GET_TV_SCALE,SX,SY,MX,MY,JX,JY,DT,DISABLE=DISABLE
	END ELSE BEGIN
		S = SIZE(ARRAY)
		IF S(0) NE 2 THEN MESSAGE,'ARRAY must be two-dimensional'
		SX = S(1)
		SY = S(2)
	ENDELSE
	IF (MX LE 0) OR (MY LE 0) THEN BEGIN
		PRINT,'*** Unable to expand array, routine TVAXIS.'
		RETURN
	ENDIF
	IX = MX / SX
	IY = MY / SY
;
;  Select the image display device or window.
;
	TVSELECT, DISABLE=DISABLE
;
;  If either the ORIGIN or the SCALE keywords are passed, then restore the TV
;  scale.
;
	IF (N_ELEMENTS(ORIGIN) NE 0) OR (N_ELEMENTS(SCALE) NE 0) THEN BEGIN
		STORE_TV_SCALE,SX,SY,MX,MY,JX,JY,ORIGIN=ORIGIN,SCALE=SCALE, $
			/DISABLE
		GET_TV_SCALE,SX,SY,MX,MY,JX,JY,DT,/DISABLE
	ENDIF
;
;  Set the system variables, and save the current values.  The borders of the
;  plot, !X.WINDOW, !Y.WINDOW, are set to the edges of the image.
;
	NOERASE = !P.NOERASE   &  !P.NOERASE = -1
	XSTYLE = !X.STYLE  &  !X.STYLE = 1
	YSTYLE = !Y.STYLE  &  !Y.STYLE = 1
	POSITION = !P.POSITION
	XWINDOW  = !X.WINDOW
	YWINDOW  = !Y.WINDOW
	!X.WINDOW = [JX-1., JX+MX] / !D.X_SIZE
	!Y.WINDOW = [JY-1., JY+MY] / !D.Y_SIZE
	!P.POSITION = [!X.WINDOW(0), !Y.WINDOW(0), !X.WINDOW(1), !Y.WINDOW(1)]
;
;  Retrieve the data coordinates associated with the image, if any.  Save the
;  old clip region.
;
	CLIP = !P.CLIP
	IF N_ELEMENTS(DT) NE 0 THEN BEGIN
		!P.CLIP = DT.CLIP
		DXS = DT.XS
		DYS = DT.YS
	ENDIF
;
;  Unless already set, the scale parameters !X.CRANGE, !X.S and !Y.CRANGE, !Y.S
;  are set by the image.
;
	IF N_ELEMENTS(XRANGE) NE 2 THEN BEGIN
		IF N_ELEMENTS(DT) EQ 0 THEN BEGIN
			XRANGE = [0, SX]
		END ELSE BEGIN
			XRANGE = (!X.WINDOW - DXS(0)) / DXS(1)
		ENDELSE
	ENDIF
	XCRANGE = !X.CRANGE  &  !X.CRANGE = XRANGE
	IF N_ELEMENTS(XTYPE) EQ 0 THEN XTYPE = 0
	IF XTYPE EQ 1 THEN !X.CRANGE = ALOG10(!X.CRANGE)
	XS = !X.S
	!X.S = [!X.WINDOW(0)*!X.CRANGE(1) - !X.WINDOW(1)*!X.CRANGE(0),	$
		!X.WINDOW(1) - !X.WINDOW(0)] / (!X.CRANGE(1) - !X.CRANGE(0))
;
	IF N_ELEMENTS(YRANGE) NE 2 THEN BEGIN
		IF N_ELEMENTS(DT) EQ 0 THEN BEGIN
			YRANGE = [0, SY]
		END ELSE BEGIN
			YRANGE = (!Y.WINDOW - DYS(0)) / DYS(1)
		ENDELSE
	ENDIF
	YCRANGE = !Y.CRANGE  &  !Y.CRANGE = YRANGE
	IF N_ELEMENTS(YTYPE) EQ 0 THEN YTYPE = 0
	IF YTYPE EQ 1 THEN !Y.CRANGE = ALOG10(!Y.CRANGE)
	YS = !Y.S
	!Y.S = [!Y.WINDOW(0)*!Y.CRANGE(1) - !Y.WINDOW(1)*!Y.CRANGE(0),	$
		!Y.WINDOW(1) - !Y.WINDOW(0)] / (!Y.CRANGE(1) - !Y.CRANGE(0))
;
;  Check if the NOXLABEL and NOYLABEL keywords were set.
;
	IF KEYWORD_SET(NOXLABEL) THEN BEGIN
		IF N_ELEMENTS(XTITLE) EQ 0 THEN XTITLE = ' '
		IF N_ELEMENTS(XTICKNAME) EQ 0 THEN XTICKNAME =	$
			REPLICATE(' ',30)
	ENDIF
	IF KEYWORD_SET(NOYLABEL) THEN BEGIN
		IF N_ELEMENTS(YTITLE) EQ 0 THEN YTITLE = ' '
		IF N_ELEMENTS(YTICKNAME) EQ 0 THEN YTICKNAME =	$
			REPLICATE(' ',30)
	ENDIF
;
;  Draw the axes.
;
	IF N_ELEMENTS(XAXIS) EQ 1 THEN BEGIN
		COMMAND = 'AXIS,XAXIS=XAXIS,XTYPE=XTYPE,_EXTRA=_EXTRA'
		IF N_ELEMENTS(COLOR) EQ 1 THEN COMMAND = COMMAND +	$
			",COLOR=COLOR"
		IF N_ELEMENTS(XTITLE) EQ 1 THEN COMMAND = COMMAND +	$
			",XTITLE=XTITLE"
		IF N_ELEMENTS(TICKLEN) EQ 1 THEN COMMAND = COMMAND +	$
			",TICKLEN=TICKLEN"
		IF N_ELEMENTS(XTICKLEN) EQ 1 THEN COMMAND = COMMAND +	$
			",XTICKLEN=XTICKLEN"
		IF N_ELEMENTS(XTICKNAME) NE 0 THEN COMMAND = COMMAND +	$
			",XTICKNAME=XTICKNAME"
		IF N_ELEMENTS(XTICKS) EQ 1 THEN COMMAND = COMMAND +	$
			",XTICKS=XTICKS"
		IF N_ELEMENTS(XTICKV) NE 0 THEN COMMAND = COMMAND +	$
			",XTICKV=XTICKV"
		TEST = EXECUTE(COMMAND)
	ENDIF
;
	IF N_ELEMENTS(YAXIS) EQ 1 THEN BEGIN
		COMMAND = 'AXIS,YAXIS=YAXIS,YTYPE=YTYPE,_EXTRA=_EXTRA'
		IF N_ELEMENTS(COLOR) EQ 1 THEN COMMAND = COMMAND +	$
			",COLOR=COLOR"
		IF N_ELEMENTS(YTITLE) EQ 1 THEN COMMAND = COMMAND +	$
			",YTITLE=YTITLE"
		IF N_ELEMENTS(TICKLEN) EQ 1 THEN COMMAND = COMMAND +	$
			",TICKLEN=TICKLEN"
		IF N_ELEMENTS(YTICKLEN) EQ 1 THEN COMMAND = COMMAND +	$
			",YTICKLEN=YTICKLEN"
		IF N_ELEMENTS(YTICKNAME) NE 0 THEN COMMAND = COMMAND +	$
			",YTICKNAME=YTICKNAME"
		IF N_ELEMENTS(YTICKS) EQ 1 THEN COMMAND = COMMAND +	$
			",YTICKS=YTICKS"
		IF N_ELEMENTS(YTICKV) NE 0 THEN COMMAND = COMMAND +	$
			",YTICKV=YTICKV"
		TEST = EXECUTE(COMMAND)
	ENDIF
;
;  If applicable, refresh the data in the database maintained by
;  STORE_TV_SCALE.
;
	IF N_ELEMENTS(DT) NE 0 THEN BEGIN
		DT.XS = !X.S
		DT.YS = !Y.S
		STORE_TV_SCALE,SX,SY,MX,MY,JX,JY,DATA=DT,/DISABLE
	ENDIF
;
;  Restore the system parameters.
;
	!P.POSITION = POSITION
	!X.WINDOW   = XWINDOW
	!Y.WINDOW   = YWINDOW
	!X.CRANGE   = XCRANGE
	!Y.CRANGE   = YCRANGE
	!X.S        = XS
	!Y.S        = YS
	!X.STYLE    = XSTYLE
	!Y.STYLE    = YSTYLE
	!P.NOERASE  = NOERASE
	!P.CLIP     = CLIP
	TVUNSELECT, DISABLE=DISABLE
;
;  If the DATA keyword was set, then activate the data coordinates.
;
	IF KEYWORD_SET(DATA) THEN SETIMAGE, /CURRENT, /DATA, DISABLE=DISABLE
;
	RETURN
	END
