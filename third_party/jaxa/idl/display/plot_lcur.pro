function plot_lcur, struct, array, ref_time, noplot=noplot, qblowup=qblowup, $
		plotr=plotr, nohard=nohard, qhard=qhard, $
		nomultiset=nomultiset, multiset=multiset, qreset=qreset, $
		extra1=extra1, qextra1=qextra1, $
		xsel=xsel, ysel=ysel, $
		nowhere=nowhere, _extra=_extra;
;+
;NAME:
;	plot_lcur
;PURPOSE:
;	Plot a light curve and allow the user to blowup
;	on certain areas.  It returns the subscripts of
;	the last selected region.
;CALLING SEQUENCE:
;	ss = plot_lcur(roadmap, roadmap.sxs1)
;	ss = plot_lcur(roadmap, /nodata, qblowup=qblowup)
;	ss = plot_lcur(index, gt_sum_l(index), plotr=a, title=title)
;	ss = plot_lcur(index, gt_sum_l(index), /nohard)
;INPUTS:
;	struct	- the structure that holds the .time and .day fields
;		  If struct is a floating point array, and ref_time is
;		  not passed in, then PLOT will be used instead of UTPLOT
;	array	- the array to be plotted
;OPTIONAL INPUT PARAMETERS:
;	ref_time- The reference time to use with UTPLOT.  If it is
;		  undefined, then struct(0) is used.  Must be in form of
;		  a structure (.time, .day fields) (?)
;
;	noplot	- If set, do not plot any data, but allow the user
;		  to select a starting and ending time to be blown
;		  up (used for cases where the data to be plotted is
;		  more complex)
;	psym	- the plotting symbol used.  Default is 1 (a + sign)
;	title	- A title string for the plot
;	nohard	- If set, do not allow or display the hardcopy capabiltiy
;	nomultiset - If set, do not allow multiple selection
;	extra1	- A string with a description to be used for the lower left
;		  box/right button key option
;	nowhere	- If set, then do not do a "where" to find the subscripts
;		  of the selected times.  It is used in conjunction with
;		  the /NOPLOT option and the XSEL value is passed back
;		  to be used by the calling routine
;OPTIONAL OUTPUT PARAMETERS:
;	qblowup	- used with the /noplot option.  Tells the calling
;		  procedure that the user wants a blowup of the
;		  selected area.
;	plotr	- Returns the min and max subscripts of the input
;		  vector that were used for the last plot (refresh of
;		  the screen).  This allows a programmer to plot light
;		  curves for the extracted datasets AND for a larger
;		  region that goes beyond the extracted datasets.
;		  Bob Bentley requested this capability
;	multiset- If the user wants to select multiple start and end times,
;		  using the middle button on the left box, the resulting
;		  matrix of 2xN subscripts will be returned, where the
;		  (0,*) is the starting subscript and (1,*) is the end.
;		  Using the reset option will clear the accumulated
;		  marks.
;	qhard	- used with the /noplot option.  Tells the calling
;		  procedure that the user wants a hardcopy of the
;		  selected area.
;	qhard	- used with the /noplot option.  Tells the calling
;		  procedure that the user wants to reset to the full
;		  range.
;	qextra1	- if bottom left box/right button was select, return
;		  true
;	xsel	- the x data coordinates selected.
;	ysel	- the y data coordinates selected.
; CALLS:
;	data_type, int2secarr, utplot, box_cursor
; RESTRICTIONS:
;	Only works on workstations that have a puck to allow the
;	CURSOR function to work.
; HISTORY:
;	Written 4-Mar-92 by M.Morrison
;	20-Mar-92 (MDM) - Added "plotr" and "title" options
;			- Also added hard copy capability
;	20-Mar-92 (MDM) - Added the "multiset" option
;	29-Apr-92 (MDM) - Removed the /DELETE command from hardcopy
;			  option
;	29-Apr-92 (MDM) - Added "qhard" and "qreset" option
;	 2-May-92 (MDM) - Added "extra1" and "qextra1" options as
;			  well as "xsel" and "ysel" option
;	 5-May-92 (MDM) - Changed "extra" option to use box_cursor
;			  to mark the box to select
;			- Added "nomultiset" option
;	26-May-92 (MDM) - Expanded to work with TEK plotting device
;	29-May-92 (MDM) - Added "ynozero"
;	 9-Jun-92 (MDM) - Adjusted so that an floating array can be passed in
;			  as the X parameter (previously it had to be a structure)
;	14-Jul-93 (MDM) - Added SYMSIZE
;	25-Jul-94 (MDM) - Moved the print statement for the instructions outside
;			  of the loop
;	10-Mar-95 (MDM) - Modified to accept a floating point array as "x" input
;			  and to simply plot "x" versus "y" if REF_TIME is not
;			  passed in (ie: not to call UTPLOT)
;	15-Jan-95 (LWA) - Replaced indgen with lindgen to handle larger arrays.
;	 3-Apr-00 (LWA) - Added YRANGE and YSTYLE.
;	Jun-01, Paul Hick
;			Added check for !d.name = 'WIN' to make it work on windows
;			Added _extra keyword and removed all generic plot keywords passed
;				to utplot and plot.
;			Replaced calls to 'plot_vline' by call to 'oplot'
;			Added erase of vertical line of previous selection of left/right boundary
;-

noplot = keyword_set(noplot)
nohard = keyword_set(nohard)
extra1 = keyword_set(extra1)
nowhere= keyword_set(nowhere)
nomultiset = keyword_set(nomultiset)

qsimple_plot = data_type(struct) eq 4 and n_elements(ref_time) eq 0

qdebug = 0
if n_elements(ref_time) eq 0 then ref_time = struct[0]

wsystem = !d.name eq 'X' or !d.name eq 'WIN'

if wsystem then begin
    if !d.window eq -1 then window else wshow
    factor = 1
end else	$		;assumes TEK
    factor = 6

qextra1 = 0

siz = size(struct)
typ = siz[siz[0]+1]
x = struct
if typ eq 8 then x = int2secarr(x, ref_time)


xmin = min(x)
xmax = max(x)
ss = lindgen(n_elements(x))
ss0 = ss

ymin0 = min(array)
ymax0 = max(array)
if n_elements(xsel) ne 0 then xsel0 = xsel else xsel0 = [xmin, xmax]		;needed because of /noplot option
										;in order to remember what was done last
										;if don't want to require they always give
										;a start and a stop
if n_elements(ysel) ne 0 then ysel0 = ysel else ysel0 = [min(array), max(array)]
xsel = 0
ysel = 0

plotr = [0, n_elements(x)-1]
multiset = 0

;----- MDM moved print statement outside of the loop 25-Jul-94

print, 'Use Middle key on plot to exit
print, '    On plot, use left key to mark starting time, right key to mark ending time
print, '    On lower right box, use left key to blowup, right key to reset to full view
print, '    On lower left box, use left key to hardcopy, middle key for multiple set marking'
if !d.name eq 'TEK' then	$
	print, '    For TEK device, use key L, M, and R to signify left/middle/right buttons

nx  = !d.x_size
box = 30*factor
xx1 = [nx, nx-box, nx-box,  nx, nx]
yy1 = [ 0,      0,    box, box,  0]
xx2 = [ 0,   box,  box,   0, 0]
yy2 = [ 0,      0, box, box, 0]
qdone = 0
qplot = 1
qreset = 0

while not qdone do begin
	print, '************ Currently there are ', strtrim(n_elements(ss), 2), ' points selected

	if not noplot and qplot then begin

		case qsimple_plot of
		0: utplot, struct(ss), array(ss), _extra=_extra, ref_time
		1:   plot, struct(ss), array(ss), _extra=_extra
		endcase

		plotr = [min(ss), max(ss)]
    endif
    ;
    str = '!18'
    if nohard	  then str = str + ' /' else str = str + 'Hardcopy/'
    if nomultiset then str = str + ' /' else str = str + 'Multi/'
    if extra1	  then str = str + extra1 + '!3' else str = str + '!3'

    polyfill, xx1, yy1, /device
    xyouts, nx-box-130*factor, 0, '!18Blowup/ /Reset!3', size=1.4, /device, font=-1

    polyfill, xx2, yy2, /device
    xyouts, box+10*factor, 0, str, size=1.4, /device, font=-1

    cursor, x0, y0, /data, /down

	if wsystem then		$
		button = !err	$
	else if !d.name eq 'TEK' then begin
		button = -1
		if strupcase(string(byte(!err))) eq 'L' then button = 1
		if strupcase(string(byte(!err))) eq 'M' then button = 2
		if strupcase(string(byte(!err))) eq 'R' then button = 4
		if button eq -1 then print, 'Key not recognized.  Use L,M,R please', string(7b)
	endif else	$
		button = -1		;trap on this case?

	temp  = convert_coord(x0,y0,/data,/to_device)
	x0dev = temp[0]
	y0dev = temp[1]			;y position in device coordinates
	if qdebug then print, button, y0

	if button eq 1 then begin & xmin0 = x0 & xmax0 = xmax & end	;temporary working min/max variables
	if button eq 4 then begin & xmax0 = x0 & xmin0 = xmin & end

	qbox1 = y0dev lt box and x0dev gt nx-box
	qbox2 = y0dev lt box and x0dev lt box
	qplot = 0
	qblowup = 0
	qhard = 0

    case 1 of
	qbox1: begin
		if button eq 1 then begin	;blow up option
		    qblowup = 1
		    qplot = 1
		endif
		if button eq 4 then begin	;reset
		    qreset = 1
		    qplot = 1
		    ss = lindgen(n_elements(struct))
		    xmin = min(x)	;reset min/max to the full range
		    xmax = max(x)
		    multiset = 0
		    xsel = 0
		    ysel = 0
		    xsel0 = [xmin, xmax]
		    ysel0 = [min(array), max(array)]
		endif
	end
	qbox2: begin
		if button eq 1 and not nohard then begin	;hard copy
			if not noplot then begin
				dsave = !d.name
				set_plot, 'ps'

				n1 = n_elements(ss)
				n2 = plotr[1] - plotr[0] + 1
				sss = lindgen(n2) + plotr[0]

				case qsimple_plot of
				0: utplot, struct(sss), array(sss), _extra=_extra, ref_time
				1:   plot, struct(sss), array(sss), _extra=_extra
				endcase

				if sss[0] ne ss[0] then begin
					xmark = struct(ss[0])
					if typ eq 8 then xmark = int2secarr(xmark, ref_time)
;					plot_vline, xmark
					oplot, [1,1]*xmark, !y.crange
				endif

				if sss[n2-1] ne ss[n1-1] then begin
					xmark = struct(ss[n1-1])
					if typ eq 8 then xmark = int2secarr(xmark, ref_time)
;					plot_vline, xmark
					oplot, [1,1]*xmark, !y.crange
				endif

				;pprint, /delete
				pprint
				set_plot, dsave
		    endif else	$
				qhard = 1

		endif
		if button eq 2 then begin	;multiple set selection
		    temp = [min(ss), max(ss)]
		    if n_elements(multiset) le 1 then multiset = temp else multiset = [[multiset], [temp]]
		    if n_elements(xsel) le 1 then begin
				xsel = xsel0
				ysel = ysel0
		    endif else begin
				xsel = [[xsel], [xsel0]]
				ysel = [[ysel], [ysel0]]
		    endelse
		endif
		if button eq 4 then begin	;extra option 1
		    box_cursor, xx0, yy0, nx0, ny0, /message
		    temp0 = convert_coord(xx0,yy0,/device,/to_data)
		    temp1 = convert_coord(xx0+nx0,yy0+ny0,/device,/to_data)
		    xsel0 = [temp0[0], temp1[0]]
		    ysel0 = [temp0[1], temp1[1]]
		    if n_elements(xsel) le 1 then begin
				xsel = xsel0
				ysel = ysel0
		    endif else begin
				xsel = [[xsel], [xsel0]]
				ysel = [[ysel], [ysel0]]
		    endelse
		    qextra1 = 1
;;		    qdone = 1
		endif
	end
	else: begin
		if button eq 1 or button eq 4 then begin
			if button eq 1 then ymin0 = y0
			if button eq 4 then ymax0 = y0
			if ymax0 lt ymin0 then begin		;reverse to have ymin0 be the lower value
				tmp = ymin0
				ymin0 = ymax0
				ymax0 = tmp
		    endif
		    ysel0 = [ymin0, ymax0]

		    ss0 = 0
		    if not nowhere then ss0 = where(xmin0 le x and x le xmax0)
		    if ss0[0] eq -1 then begin
				print, 'No datasets selected with current selection of times', string(7b)
				print, 'Not updating "SS" vector
		    endif else begin
				ss = ss0

; The next three lines removes the previous vertical line by drawing at
; the background color before drawing the new one.

				if button eq 1 then xerase = xmin
				if button eq 4 then xerase = xmax
				if !x.crange[0] lt xerase and xerase lt !x.crange[1] then oplot, [1,1]*xerase, !y.crange, color=!p.background

; Draw the new vertical line

;				plot_vline, x0
				oplot, [1,1]*x0, !y.crange

				xmin = xmin0					; only update min/max if it is a good value
				xmax = xmax0
				xsel0[0] = xmin
				xsel0[1] = xmax
		    endelse

		endif else	$
		    qdone = 1

	end
	endcase

    if !d.name eq 'TEK' and button eq -1 then qdone = 0		;reset - not done if they made a mistake
    if noplot and qblowup then qdone = 1
    if noplot and qhard   then qdone = 1
    if noplot and qreset  then qdone = 1
end
;
if n_elements(xsel) le 1 then begin
    xsel = xsel0
    ysel = ysel0
endif

return, ss  &  end
