;+
; Name: PLOTMAN::COLORS
; Purpose: Called when button is clicked to change image or spectrogram colors.  Called
;  from plotman__widget and image and spectrogram options widgets.  Pops up modified version
;  of xloadct, and allows user to select a color.
; Keywords:
;	replot - if set, replot current panel with new colors
;	modal - if set, run hsi_xcolors in modal (blocked form) (needed when running from
;	  image or spectrogram options widget, since they're blocking)
; Modifications:
;   21-Apr-2001, Kim.  Changed plot control tags from r,g,b to rcolors,...
;   2-Aug-2002, Kim.  Call hsi_xcolors instead of xcolors
;   30-Oct-2007, Kim.  Changed to method. Also instead of notifyid keyword, use notifyobj
;    keyword in call to hsi_xcolors so it will call plotman method (getcolors) with arguments.
;   7-Jul-2008, Kim. call plotman_xcolors instead of hsi_xcolors (for move of plotman to ssw gen)

pro plotman::colors, event, replot=replot, modal=modal

pc = self -> get(/plot_control)
tvlct, pc.rcolors, pc.gcolors, pc.bcolors, pc.bottom


widget_offset, event.top, newsize=[250,300], xoffset, yoffset, /vertical

if pc.color_file ne '' then file = pc.color_file

plotman_xcolors, group=event.top, ncolors=pc.ncolors+1, bottom=pc.bottom, $
	xoffset=xoffset, yoffset=yoffset, $
	title='Plotman colors', file=file, $
	notifyobj={XCOLORS_NOTIFYOBJ, object:self, method:'getcolors'}, replot=replot, modal=modal

end