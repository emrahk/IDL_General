;+
; Purpose: plotman method to check if we already have the right type of plot showing
;   (xyplot or utplot), and if not, draw a blank plot (this is to allow graphical
;   selection of intervals).
;
; Written: 16-Mar-2003, Kim.  Replaces hsi_get_plot.
; 6-Jun-2003, Kim.  Added blank_plot keyword - returns 0/1
;-

function plotman::any_plot, range=range, what=what, blank_plot=blank_plot

blank_plot = 0
doplot = 0

utplot = what eq 'Time' ? 1 : 0
xyplot = what eq 'Energy' ? 1 : 0

plot_type = utplot ? 'utplot' : 'xyplot'

if not self->valid_window(utplot=utplot, xyplot=xyplot) then doplot=1

xlog = utplot ? 0 : 1

if doplot then begin
	if utplot then $
		success = self -> setdefaults (input=[ [range-range[0]], [0,0] ], utbase=range[0], plot_type=plot_type, yrange=[0,1], xlog=xlog) $
	else $
		success = self -> setdefaults (input=[ [range], [0,0] ], plot_type=plot_type, yrange=[0,1], xlog=xlog)

	if success then begin
		blank_plot = 1
		self -> new_panel, 'Blank plot'
		message,' No ' + plot_type + ' plot showing.  Drawing blank plot...', /cont
	endif
endif

if self->valid_window(/message, utplot=utplot, xyplot=xyplot) then return, 1 else return, 0

end
