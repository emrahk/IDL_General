	PRO UTPLOT_IMAGE,IMAGE,XX,YY,NOERASE=NOERASE,	$
		SMOOTH=SMOOTH,NOSCALE=NOSCALE,	$
		MISSING=MISSING,COLOR=COLOR,MAX=MAX,MIN=MIN,TOP=TOP,	$
		BOTTOM=BOTTOM, VELOCITY=VELOCITY,COMBINED=COMBINED,LOWER=LOWER,$
		CHARSIZE=CHARSIZE,XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
		_EXTRA=_EXTRA,CUBIC=CUBIC,CONTOUR=CONTOUR,LCOLOR=LCOLOR, $
                LEVELS=LEVELS,THICK=THICK,TIMERANGE=TIMERANGE,YRANGE=YRANGE, $
                BSCALED=BSCALED
;+
; Name:
; 
;	UTPLOT_IMAGE
;
; Purpose:
; 
;	Display time series data as images with plot axes around it.
;       For example a time series of spectra.
;
; Explanation:
; 
;	Display images with plot axes around it.  Subsequent graphics commands,
;	such as OPLOT and CURSOR, can then be called in the ordinary way.
;
;       If the time series or the second dimension (e.g. wavelength) is not 
;       linear the data is remapped onto a regular grid using INTERPOLATE.
;
;	Axes are plotted with utplot, and EXPAND_TV/CONTV is called to display
;       the image/contours. 
;
; Use:
; 
;	UTPLOT_IMAGE, IMAGE, TIME, YY
;
; Inputs:
; 
;	IMAGE	 = Two dimensional time series data to be displayed. With time
;                  in the x direction.
;       TIME	 = The time array of the data, must be increasing.
;       YY       = The second dimension, for example wavelength. Must be 
;                  increasing.
;
; Opt. Inputs:
; 
;	None.
;
; Outputs     : 
;
;	None.
;
; Opt. Outputs: 
;
;	None.
;
; Keywords    : 
;
;       CONTOUR  = Display the image as contours
;	CUBIC    = Set for initial interpolation to regular grid
;	NOERASE	 = If set, then the screen is not erased before putting up the
;		   plot. When !p.multi is set this will make the plot appear 
;                  over the last one. 
;	SMOOTH	 = If set, then the image is expanded with bilinear
;		   interpolation.
;	NOSCALE  = If set, then the command TV is used instead of TVSCL to
;		   display the image.
;	MISSING	 = Value flagging missing pixels.  These points are scaled to
;		   zero.  Ignored if NOSCALE is set.
;	COLOR	 = Color used for drawing the axes.
;       LCOLOR   = Color for drawing the contours
;       LEVELS   = Levels for the contours
;	MAX	 = The maximum value of ARRAY to be considered in scaling the
;		   image, as used by BYTSCL.  The default is the maximum value
;		   of ARRAY.
;	MIN	 = The minimum value of ARRAY to be considered in scaling the
;		   image, as used by BYTSCL.  The default is the minimum value
;		   of ARRAY.
;	TOP	 = The maximum value of the scaled image array, as used by
;		   BYTSCL.  The default is !D.N_COLORS-1.
;	BOTTOM	 = The minimum value of the scaled image array, as used by
;		   BYTSCL.  The default is 0.
;	VELOCITY = If set, then the image is scaled using FORM_VEL as a
;		   velocity image.  Can be used in conjunction with COMBINED
;		   keyword.  Ignored if NOSCALE is set.
;	COMBINED = Signals that the image is to be displayed in one of two
;		   combined color tables.  Can be used by itself, or in
;		   conjunction with the VELOCITY or LOWER keywords.
;	LOWER	 = If set, then the image is placed in the lower part of the
;		   color table, rather than the upper.  Used in conjunction
;		   with COMBINED keyword.
;       BSCALED  = Returns the bytescaled image passed to the TV command.
;	TITLE	 = Main plot title, default is !P.TITLE.
;	XTITLE	 = X axis title, default is !X.TITLE.
;	YTITLE	 = Y axis title, default is !Y.TITLE.
;	XTICK_GET= Same as for PLOT
;	YTICK_GET= Same as for PLOT
;	CHARSIZE = Character size to use in making plot.
;
;	Also, any other keyword used by UTPLOT is supported.
;
; Calls       : 
;	EXPAND_TV, CONTV, INTERPOLATE
; Common      : 
;	None.
; Restrictions: 
;	The graphics device must be capable of displaying images.
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
;
;	System variables may be changed even if the routine exits with an error
;	message.
;
; Category    : 
;	Utilities, Image_display.
; Prev. Hist. : 
;	Derived from PLOT_IMAGE of William Thompson
;	Version 6, 29 March 2000
; Written    
;       Neale Ranns, MSSL, November 2000
; Version     : 
;       Version 1, Neale Ranns, MSSL, 21-Nov-00 
;	Version 2, 13-Sep-2002, William Thompson, GSFC
;		Fixed bug when interpolation not used.
;	Version 3, 18-Dec-2002, William Thompson, GSFC
;		Changed !COLOR to !P.COLOR
;	Version 4, 30-Jan-2003, William Thompson, GSFC
;		Changed bug with titles, best handled through _EXTRA
;	Version 5, 3-Jan-2006, William Thompson, GSFC
;		Added keyword BOTTOM
;       Version 6, William Thompson, GSFC, 26-Sep-2006
;               Added keyword BSCALED
; Version     : 
;	Version 6, 26-Sep-2006
;-
;
	ON_ERROR,0
;
;  Check the number of parameters.
;
	IF N_PARAMS() LT 3 THEN MESSAGE,'Syntax:  PLOT_IMAGE, IMAGE'
;
;  Check the image size.
;
	SZ = SIZE(IMAGE)
	IF SZ(0) NE 2 THEN MESSAGE,'IMAGE must be two-dimensional'
;
;  If !p.multi ne 0 then we need to change it if /noerase is set. Then
;  the new plot will go over the last
;

   	IF KEYWORD_SET(NOERASE) AND ((!P.MULTI[1] GT 0) OR (!P.MULTI[2] GT 0))$
           THEN BEGIN
 
           NWIN=!P.MULTI[1]*!P.MULTI[2]
	   IF !P.MULTI[0] EQ 0 THEN !P.MULTI[0] = 1 ELSE $
            !P.MULTI[0]=!P.MULTI[0]+1
        ENDIF

;
;  Check to see if the input arrays are regular
;  If not then interpolate onto a regular grid
;  We have to do this!!
;

        X = ANYTIM(XX,/TAI)
        X = X - X[0]
        Y = YY
	NX = N_ELEMENTS(X)
        NY = N_ELEMENTS(Y)

        IF (NX NE SZ[1]) OR (NY NE SZ[2]) THEN MESSAGE, $
           'DATA ARRAY AND X/Y ARRAY ARE NOT THE SAME SIZE',/INFO  

       
        DX = X[1:*]-X
        DY = Y[1:*]-Y

        ; are the arrays linear
        ; does y increase or decrease

        X_LINEAR = N_ELEMENTS(UNIQ(DX,SORT(DX)))
        Y_LINEAR = N_ELEMENTS(UNIQ(DY,SORT(DY)))

        SCALE=[0.0,0.0]

        IF (X_LINEAR GT 1) OR (Y_LINEAR GT 1) THEN BEGIN  ;we must interpolate

           SCALE[0] = MIN(ABS(DX))
           SCALE[1] = MIN(ABS(DY))

           N_X_INT = (X[NX-1]-X[0])/SCALE[0]
           N_Y_INT = (Y[NY-1]-Y[0])/SCALE[1]
  
;;         XARR = FINDGEN(N_X_INT+1)/(N_X_INT+1)*NX
;;	   YARR = FINDGEN(N_Y_INT+1)/(N_Y_INT+1)*NY

           XPOS=FINDGEN(N_X_INT+1)*SCALE[0]+X[0]
           YPOS=FINDGEN(N_Y_INT+1)*SCALE[1]+Y[0]

           XARR=DSPLINE(X,FINDGEN(NX),XPOS)
	   YARR=DSPLINE(Y,FINDGEN(NY),YPOS)

           DATA=INTERPOLATE(IMAGE,XARR,YARR,/GRID,CUBIC=CUBIC)
           SZ = SIZE(DATA)

        ENDIF ELSE BEGIN

           DATA=IMAGE
           SCALE[0] = DX[0]
           SCALE[1] = DY[0]
           XPOS = X
           YPOS = Y

        ENDELSE
	
;
; if yrange of timerange is set we must take a subset of the image
; do that now, it's easier
;

        IF N_ELEMENTS(YRANGE) EQ 2 THEN BEGIN

           TMP = MIN(ABS(YPOS-YRANGE[0]),YLOWCUT)
           TMP = MIN(ABS(YPOS-YRANGE[1]),YHIGHCUT)

           DATA = DATA[*,YLOWCUT:YHIGHCUT]
           YPOS = YPOS[YLOWCUT:YHIGHCUT]
           SZ = SIZE(DATA)

        ENDIF

        IF N_ELEMENTS(TIMERANGE) EQ 2 THEN BEGIN

           XR=ANYTIM(TIMERANGE,/TAI)
           XRANGE=XR-ANYTIM(XX[0],/TAI)

           TMP = MIN(ABS(XPOS-XRANGE[0]),XLOWCUT)
           TMP = MIN(ABS(XPOS-XRANGE[1]),XHIGHCUT)

           DATA = DATA[XLOWCUT:XHIGHCUT,*]
           XPOS = XPOS[XLOWCUT:XHIGHCUT]
           SZ = SIZE(DATA)

        ENDIF

;
;  Get the image origin.
;
	ORIGIN=[XPOS[0],YPOS[0]]

;
;  Get the image scale.
;
	XSCALE = SCALE(0)
	YSCALE = SCALE(1)

;
;  Set the scale, and plot the axes.
;


	X1 = ORIGIN(0) - XSCALE/2.  &  X2 = X1 + SZ(1)*XSCALE
	Y1 = ORIGIN(1) - YSCALE/2.  &  Y2 = Y1 + SZ(2)*YSCALE

	XSTYLE = !X.STYLE  &  !X.STYLE = !X.STYLE OR 1
	YSTYLE = !Y.STYLE  &  !Y.STYLE = !Y.STYLE OR 1
	
	IF N_ELEMENTS(COLOR)  EQ 0 THEN COLOR  = !P.COLOR
	IF N_ELEMENTS(CHARSIZE) EQ 0 THEN CHARSIZE = !P.CHARSIZE
	PMULTI = !P.MULTI

        BASE_TIME = ANYTIM(XX[0],/YOH) ;used as base time for utplot.

	UTPLOT,[X1,X2],[Y1,Y2],BASE_TIME,/NODATA,NOERASE=NOERASE, $
		COLOR=COLOR,CHARSIZE=CHARSIZE, $
		XRANGE=[X1,X2],YRANGE=[Y1,Y2],_EXTRA=_EXTRA,/XS

;
;  Set the image display parameters, and display the image.
;
	XS = !X.S * !D.X_SIZE
	YS = !Y.S * !D.Y_SIZE
	MX = XS(1)*SZ(1)*XSCALE
	MY = YS(1)*SZ(2)*YSCALE
	IX = XS(0) + (ORIGIN(0) - XSCALE/2.)*XS(1)
	IY = YS(0) + (ORIGIN(1) - YSCALE/2.)*YS(1)

        IF KEYWORD_SET(CONTOUR) THEN $
		
		CONTV,DATA,MX,MY,IX,IY,COLOR=LCOLOR,LEVELS=LEVELS, $
                MAX=MAX,THICK=THICK $
		
        ELSE $
         	EXPAND_TV,DATA,MX,MY,IX,IY,SMOOTH=SMOOTH,/NOBOX, $
		NOSCALE=NOSCALE, $
		MISSING=MISSING,/DISABLE,COLOR=COLOR,MAX=MAX,MIN=MIN,	$
		TOP=TOP,BOTTOM=BOTTOM,VELOCITY=VELOCITY,COMBINED=COMBINED, $
                LOWER=LOWER,BSCALED=BSCALED
                

;
;  Replot the axes to refresh them, and reset the scaling behavior for future
;  plots.
;
	!P.MULTI = PMULTI
	UTPLOT,[X1,X2],[Y1,Y2],BASE_TIME,/NODATA,/NOERASE,COLOR=COLOR, $
        	CHARSIZE=CHARSIZE, XRANGE=[X1,X2],YRANGE=[Y1,Y2], $
        	XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,$
		_EXTRA=_EXTRA

	!X.STYLE = XSTYLE
	!Y.STYLE = YSTYLE

;
;  Modify !P.MULTI.  Normally, this would happen automatically, but this has
;  been disabled for this routine.
;
	K = !P.MULTI(0)
	NX = !P.MULTI(1) > 1
	NY = !P.MULTI(2) > 1
	IF (K LE 0) OR (K GT NX*NY) THEN K = NX*NY
	!P.MULTI(0) = (K - 1) MOD (NX*NY)
;
	RETURN
	END
