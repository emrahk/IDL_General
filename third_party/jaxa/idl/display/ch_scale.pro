;+
; Project     : SDAC
;
; Name        : CH_SCALE
;
; Purpose     : This procedure computes a scale factor for charsize that is appropriate for
;		the size of the current graphics.  Works for X, PS, and TEKTRONIX
;
; Category    : GRAPHICS
;
; Explanation :
; 	scale text in graphics output for X, PS, and TEKTRONIX graphics
; 	also scale to multiplot environment
; 	SCALE TO Y DISTANCE, XSCALING MUST BE DONE IN SETTING UP DISPLAY.
; 	XSCALING ALLOWED USING KEYWORD
; 	Scaling for plot axes is different than for xyouts because of
; 	the scaling factor of 0.5 applied to plot text when any dimension of
; 	!p.multi exceeds 2.  This factor is not applied to text labels in
; 	xyouts!
;
; Use         :
;	scale = Ch_scale( Scale [,/xyouts] [,/xcorr])
;
; Examples    :
;    xyouts, nx1lab, ylab, 'N', /normal, chars = ch_scale(.8,/xy), col=fcolor(9)
;      utplot, xsc4(*,0), yplotted, yminor=-1, $
;        ymargin=[10,2],xmargin=[13,5], title=desc(0), ytitle='Counts S!u-1!n', $
;        xtitle=' ', xrange=[xmin,xmax], yrange=[ymin,ymax], $
;        ytype=logplot, psym=psym, chars = ch_scale(0.8), color=9
;
; Inputs      :
;	Scale - Normal scaling factor used in TEKTRONIX graphics.
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    :
;	XYOUTS  -Keyword indicating scale used in XYOUTS call.   (input)
;	XCORR   -Keyword indicating to use scaling along x axis. (input)
;
; Calls       :
;	FCHECK
; Common      :
;	SCALECOM
;
; Restrictions:
;
; Side effects: None.
;
; Prev. Hist  :
; 		RAS 4/92
;
; Modified    :
;        Modified 8/29/94 by Amy Skowronek to check for global variable.
;        If variable is set, result multiplied by global.  To scale up
;        text in multiple plot.
;	Version 3, richard.schwartz@gsfc.nasa.gov, 7-sep-1997, more documentation
;	8/9/00, Kim Tolbert, generalize to work for X and PS as well as Tektronix
;   11/3/00, Kim Tolbert, changed normalized character size for PS
; 9-May-2008, Kim.  changed x, y scaling factors. old way is there but commented out, since I wasn't
;   really sure how it worked. But only worked correctly for old standard screen size.  And wasn't 
;   sure where PS numbers came from.\
; 16-May-2008, Kim.  commented out multiscale calculation that depends on number of plots.  We
;	want to do what IDL does for multi plots - if > 2 plots, scale by .5
;
;-
;  ----------------------------------------------------------------------

function ch_scale, scale, xyouts=xyouts, xcorr = xcorr

on_error,2

common scalecom,global

;; Set normalized character size for the default size window for each type of device
;; in x and y direction
;case !d.name of
;  'TEK': begin
;    ynorm = 88./3129.
;    xnorm = 51./4096.
;    end
;  'PS': begin
;    ynorm = 352. / 20000.
;    xnorm = 222. / 15000.
;    end
;  else: begin
;    ynorm = 10. / 512.
;    xnorm = 6. / 640.
;    end
;endcase
;
;;normalized character size for the current graphics device in use
;ydev = 1.* !d.y_ch_size / !d.y_vsize
;xdev = 1.* !d.x_ch_size / !d.x_vsize



; Set scaling factor for character size based on type of device
; in x and y direction
case !d.name of
	'TEK': begin
		yscale = (88./3129.) / (1.* !d.y_ch_size / !d.y_vsize)
		xscale = (51./4096.) / (1.* !d.x_ch_size / !d.x_vsize)
		end
	'PS': begin
    yscale = 1. * !d.y_vsize / !d.y_size
    xscale = 1. * !d.x_vsize / !d.x_size
		end
	else: begin
		yscale = 1.
		xscale = 1.
		end
endcase

;if in multiplots check max !p.multi(1:2) for global plot axis scaling
if (max(!p.multi(1:2)) gt 2) and (not keyword_set(xyouts)) then $
	gscale = 2 else gscale = 1.

;if keyword_set(xcorr) then multiscale = 1. / (!p.multi(1) > 1) else $
;			   multiscale = 1. / (!p.multi(2) > 1)

if (max(!p.multi(1:2)) gt 2) then multiscale=.5 else multiscale=1.

if keyword_set(xcorr) then $
	result = scale * multiscale * gscale * xscale else $
	result = scale * multiscale * gscale * yscale

return, result*fcheck(global,1)
end
