PRO ploterr, x, y, xerr, yerr, NOHAT=hat, HATLENGTH=hln, ERRTHICK=eth, $
      ERRSTYLE=est, TYPE=itype, XRANGE = xrange, XLOG=xlog, YLOG=ylog, $
      NSKIP = nskip, NOCLIP = noclip, ERRCOLOR = ecol, YRANGE = yrange, $
      _EXTRA = pkey, ANONYMOUS_ = DUMMY_

;+
; NAME:
;	PLOTERR
; PURPOSE:
;	Plot data points with accompanying X or Y error bars.
;	This is a greatly enhanced version of a standard IDL Library routine.
;
; CALLING SEQUENCE:
;	ploterr, [ x,]  y, [xerr], yerr [, TYPE =, /NOHAT, HATLENGTH= ,
;		 ERRTHICK=, ERRSTYLE=, ERRCOLOR = ]
;
; INPUTS:
;	X = array of abcissae.
;	Y = array of Y values.
;	XERR = array of error bar values (along X)
;	YERR = array of error bar values (along Y)
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;	TYPE = type of plot produced.  The possible types are:
;		TYPE = 0 :	X Linear - Y Linear  (default)
;		TYPE = 1 :	X Linear - Y Log
;		TYPE = 2 :	X Log    - Y Linear
;		TYPE = 3 :	X Log    - Y Log
;	       Actually, if 0 is specified, the XLOG and YLOG keywords
;	       are used.  If these aren't specified, then a linear-linear
;	       plot is produced.  This keyword is available to maintain
;	       compatibility with the previous version of PLOTERR.
;	NOHAT     = if specified and non-zero, the error bars are drawn
;	            without hats.
;	HATLENGTH = the length of the hat lines used to cap the error bars.
;	            Defaults to !D.X_VSIZE / 100).
;	ERRTHICK  = the thickness of the error bar lines.  Defaults to the
;	            THICK plotting keyword.
;	ERRSTYLE  = the line style to use when drawing the error bars.  Uses
;	            the same codes as LINESTYLE.
;	ERRCOLOR =  scalar integer (0 - !D.N_TABLE) specifying the color to
;			use for the error bars
;	NSKIP = Integer specifying the error bars to be plotted.   For example,
;		if NSKIP = 2 then every other error bar is plotted; if NSKIP=3
;		then every third error bar is plotted.   Default is to plot
;		every error bar (NSKIP = 1)
;
;
; RESTRICTIONS:
;	Arrays must not be of type string.  There must be enough points to plot.
;	If only three parameters are input, they will be taken as X, Y and
;	YERR respectively.
;
; EXAMPLE:
;       Suppose one has X and Y vectors with associated errors XERR and YERR
;
;       (1) Plot Y vs. X with both X and Y errors and no lines connecting
;           the points
;                  IDL> ploterr, x, y, xerr, yerr, psym=3
;
;       (2) Like (1) but plot only the Y errors bars and omits "hats"
;                  IDL> ploterr, x, y, yerr, psym=3, /NOHAT
;
; WARNING:
;	This an enhanced version of a procedure that already exists in the
;	standard IDL V4.0 distribution.   Any call to the standard IDL version
;	should also work with this version, but the reverse is not true.
;	
; PROCEDURE:
;	A plot of X versus Y with error bars drawn from Y - YERR to Y + YERR
;	and optionally from X - XERR to X + XERR is written to the output device
;
; MODIFICATION HISTORY:
;	William Thompson	Applied Research Corporation  July, 1986
;	DMS, April, 1989	Modified for Unix
;	Michael R. Greason	ST Systems
;	May, 1991		Added most of the plotting keywords, put hats
;				on the error bars.
;	K. Venkatakrishna       Added option to plot xerr, May, 1992
;	Michael R. Greason	Corrected handling of reversed axes.  Aug. 1992.
;	W. Landsman             Removed CHAN keyword for V4.0 compat. June 1995
;	W. Landsman             Use _EXTRA keyword                    July 1995
;	W. Landsman             Plot more than 32767 points           Feb 1996
;	W. Landsman	Fix Y scaling when only XRANGE supplied       Nov 1996
;	W. Landsman     Added NSKIP keyword                           Dec 1996
;	W. Landsman     Use XLOG, YLOG instead of XTYPE, YTYPE        Jan 1998
;-
;			Check the parameters.
 On_error, 2
 np = N_params()
 IF (np LT 2) THEN BEGIN
	print, "PLOTERR must be called with at least two parameters."
	print, "Syntax: ploterr, [x,] y, [xerr], yerr"
	RETURN
 ENDIF

;				Error bar keywords (except for HATLENGTH; this
;				one will be taken care of later, when it is
;				time to deal with the error bar hats).

 IF (keyword_set(hat)) THEN hat = 0 ELSE hat = 1
 if not keyword_set( THICK ) then thick = !P.THICK
 if (n_elements(eth) EQ 0) THEN eth = thick
 IF (n_elements(est) EQ 0) THEN est = 0
 IF (n_elements(ecol) EQ 0) THEN ecol = !P.COLOR
 if N_elements( NOCLIP ) EQ 0 then noclip = 0
 if not keyword_set(NSKIP) then nskip = 1

;				Other keywords.

 IF (keyword_set(itype)) THEN BEGIN
	CASE (itype) OF
		   1 :  ylog = 1	; X linear, Y log
		   2 :  xlog = 1	; X log, Y linear
		   3 :  BEGIN		; X log, Y log
			xlog = 1
			ylog = 1
			END
		ELSE : 
	ENDCASE
 ENDIF
 if not keyword_set(XLOG) then xlog = 0
 if not keyword_set(YLOG) then ylog = 0
;			If no x array has been supplied, create one.  Make
;			sure the rest of the procedure can know which parameter
;			is which.

 IF np EQ 2 THEN BEGIN			; Only Y and YERR passed.
	yerr = abs(y)
	yy = x
	xx = indgen(n_elements(yy))
        xerr = make_array(size=size(xx))

 ENDIF ELSE IF np EQ 3 THEN BEGIN 	; X, Y, and YERR passed.
        yerr = abs(xerr)
        yy = y
        xx = x

 ENDIF ELSE BEGIN                        ; X, Y, XERR and YERR passed.
	yerr = abs(yerr)
	yy = y
        xerr = abs(xerr)
	xx = x
 ENDELSE

;			Determine the number of points being plotted.  This
;			is the size of the smallest of the three arrays
;			passed to the procedure.  Truncate any overlong arrays.

 n = N_elements(xx) < N_elements(yy)

 IF np GT 2 then n = n < N_elements(yerr)   
 IF np EQ 4 then n = n < N_elements(xerr)

 IF n LT 2 THEN $
	message,'Not enough points to plot.'

 xx = xx(0:n-1)
 yy = yy(0:n-1)
 yerr = yerr(0:n-1)
 IF np EQ 4 then xerr = xerr(0:n-1)

;	 If no y-range was passed via keyword or system variable, force one 
;	 large enough to display all the data and the entire error bars.
;	 If a reversed y-range was passed, switch ylo and yhi.

 ylo = yy - yerr
 yhi = yy + yerr
 if not keyword_set( YRANGE ) then yrange = !Y.RANGE
 IF yrange(0) EQ yrange(1) THEN BEGIN
	if keyword_set( XRANGE ) then  begin
		good = where( (xx GT min(xrange)) and (xx LT max(xrange)) )
		yrange = [min(ylo(good)),max(yhi(good))]
	endif else yrange = [min(ylo), max(yhi)]
 ENDIF ELSE IF yrange(0) GT yrange(1) THEN BEGIN
	ylo = yy + yerr
	yhi = yy - yerr
 ENDIF

;        Similarly for x-range

 if not keyword_set( XRANGE ) then xrange = !X.RANGE
 if NP EQ 4 then begin
   xlo = xx - xerr
   xhi = xx + xerr
   IF xrange(0) EQ xrange(1) THEN xrange = [min(xlo), max(xhi)]
   IF xrange(0) GT xrange(1) THEN BEGIN
      xlo = xx + xerr
      xhi = xx - xerr
   ENDIF
 endif

;			Plot the positions.

 plot, xx, yy, XRANGE = xrange, YRANGE = yrange, XLOG = xlog, YLOG = ylog, $
         _EXTRA = pkey, NOCLIP = noclip

;	Plot the error bars.   Compute the hat length in device coordinates
;       so that it remains fixed even when doing logarithmic plots.

    data_low = convert_coord(xx,ylo,/TO_DEVICE)
    data_hi = convert_coord(xx,yhi,/TO_DEVICE)
    if NP EQ 4 then begin
       x_low = convert_coord(xlo,yy,/TO_DEVICE)
       x_hi = convert_coord(xhi,yy,/TO_DEVICE)
    endif
    ycrange = !Y.CRANGE   &  xcrange = !X.CRANGE
    if ylog EQ 1 then ylo = ylo > 10^ycrange(0)
    if xlog EQ 1 then xlo = xlo > 10^xcrange(0)
    
 FOR i = 0L, (n-1), Nskip DO BEGIN     

    plots, [xx(i),xx(i)], [ylo(i),yhi(i)], LINESTYLE=est,THICK=eth,  $
		NOCLIP = noclip, COLOR = ecol

;                                                         Plot X-error bars 
    if np EQ 4 then plots, [xlo(i),xhi(i)],[yy(i),yy(i)],LINESTYLE=est, $
		THICK=eth, COLOR = ecol, NOCLIP = noclip
	IF (hat NE 0) THEN BEGIN
		IF (N_elements(hln) EQ 0) THEN hln = !D.X_VSIZE/100. 
		exx1 = data_low(0,i) - hln/2.
		exx2 = exx1 + hln
		plots, [exx1,exx2], [data_low(1,i),data_low(1,i)],COLOR=ecol, $
                      LINESTYLE=est,THICK=eth,/DEVICE, noclip = noclip
		plots, [exx1,exx2], [data_hi(1,i),data_hi(1,i)], COLOR = ecol,$
                       LINESTYLE=est,THICK=eth,/DEVICE, noclip = noclip

;                                                        Plot Y-error bars

                IF np EQ 4 THEN BEGIN
                   IF (N_elements(hln) EQ 0) THEN hln = !D.Y_VSIZE/100.
                   eyy1 = x_low(1,i) - hln/2.
                   eyy2 = eyy1 + hln
                   plots, [x_low(0,i),x_low(0,i)], [eyy1,eyy2],COLOR = ecol, $
                         LINESTYLE=est,THICK=eth,/DEVICE, NOCLIP = noclip
                   plots, [x_hi(0,i),x_hi(0,i)], [eyy1,eyy2],COLOR = ecol, $
                         LINESTYLE=est,THICK=eth,/DEVICE, NOCLIP = noclip
                ENDIF
	ENDIF
    NOPLOT:
 ENDFOR
;
 RETURN
 END
