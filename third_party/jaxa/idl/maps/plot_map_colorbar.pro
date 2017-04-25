; +
; Name:  plot_map_colorbar
; Purpose: plot colorbar on images drawn by plot_map
; Kim Tolbert, 9-Jan-2001
; Modifications:
;   3-Feb-2001, Kim.  Ensure that y title is blank for colorbar, and if range of data
;     for color bar is 0. make it min - min + .001 so don't get draw error from
;     colorbar object.
; 19-Mar-2001, Kim.  fix bug related to 3-Feb fix.  Check for range < 1.e-6, not eq 0. duh.
; 12-Jul-2001, Kim.  don't set charsize in colorbar object.  If !p.charsize is set, then
;   colorbar will use charsize as a scaling factor, and labels will be too big.  Instead
;   set !p.charsize to charsize.
; 3-Aug-2001, Kim.  Added cb_title keyword
; 26-Oct-2001, Kim.  Changed check on datarange range to use absolute value.
; 19-Jun-2002, Kim.  If range < 1. use g9.2 format
; 2-May-2003, Kim.  Made datarange float, so in case of [0,0], will change to [0.,.001]
;	so that colorbar::draw doesn't generate error
; 22-May-2003, Kim.  Added log keyword
; 13-Jul-2009, Kim.  Added color keyword to pass into colorbar obj - control color of annotation and outline.
;    And take charsize out of extra.
; 20-Sep-2011, Kim.  Use colorbar2 obj instead of colorbar (renamed to avoid conflict in IDL V8)
;-
 $
pro plot_map_colorbar, prange, bottom, ncolors, cb_title=cb_title, log=log, $
  charsize=charsize, position=position, color=color, _extra=extra

 	colorbar = obj_new('colorbar2', title=cb_title)
 	default, charsize, 1.
 	format = '(f8.1)'
 	if max(abs(prange)) gt 9999. then format='(i6)'
 	if max(abs(prange)) gt 99999. then format='(g9.2)'
 	if max(abs(prange)) lt 100. then format='(f8.2)'
 	if max(abs(prange)) lt 1. then format='(g9.2)'
 	datarange = float(prange)
 	if abs(datarange[1]-datarange[0]) lt 1.e-6  then datarange[1] = datarange[0] + .001
 	colorbar -> setproperty, range=datarange,position=[.15,.96, .88,.99], $
 		bottom=bottom, ncolors=ncolors, ticklen=-.2, format=format, log=log, color=color
 	ytitle_sav = !y.title
 	; colorbar draw uses xcharsize which is a scaling factor on !p.charsize, so don't
 	; pass charsize in through set - if !p.charsize is already set, characters will be huge
 	pcharsize_sav = !p.charsize
 	!y.title = ''
 	!p.charsize = .8 * charsize
 	colorbar -> draw
 	!y.title = ytitle_sav
 	!p.charsize = pcharsize_sav
 	obj_destroy, colorbar

end
