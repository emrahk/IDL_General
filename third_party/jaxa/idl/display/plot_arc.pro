pro plot_arc, index, image, width0, bin=bin, use_spline=use_spline, $
	use_poly=use_poly, ndeg=ndeg, xlcur=xlcur, lcur=lcur, $
	qdebug=qdebug, qstop=qstop, $
	sample=sample, enhance=enhance
;
;+
;NAME:
;	plot_arc
;PURPOSE:
;	To allow a user to mark an arc on an image and the intensity
;	along that arc will be plotted
;SAMPLE CALLING SEQUENCE:
;	plot_arc, index, image
;	plot_arc, 0, gbo_image, /sample
;	plot_arc, index, image, width, bin=bin
;	plot_arc, index(1), data(*,*,1), 10, bin=4, /use_poly
;	plot_arc, index(1), data(*,*,1), /enhance
;RESTRICTIONS:
;	The image must be re-displayed to insure that the user is marking
;	the image in the proper location and proper scaling.
;INPUT:
;	image	- The image for which the curve wants to be plotted
;OPTIONAL INPUT:
;	width	- The width in original pixels of the curve.
;		  (ie: the number of lines to add together)
;		  This is the width of the channel for which to get
;		  the light curve.
;OPTIONAL KEYWORD INPUT:
;	bin	- The rebinning factor.
;		  If not passed, it will be set to whatever it takes
;		  to make the image be 512 in the x direction.
;	use_spline - If set, then use the SPLINE method for smoothing
;		  the curve (Default is to use SPLINE)
;	use_poly - If set, then use the POLYNOMIAL FIT method for smoothing
;		  the curve (Default is to use SPLINE)
;	ndeg	- The polynomial degree to be used for the fits.  If
;		  not passed, it will use 4th degree polynomial.
;	enhance - If you wish to use the function ENHANCE for displaying
;		  the image, then pass the index in for the image being
;		  displayed.
;	sample	- If set, then use /SAMPLE option within REBIN instead
;		  of interpolate (which is the default)
;OPTIONAL KEYWORD OUTPUT:
;	xlcur	- The x-array for the light curve array (relative units
;		  of full resolution pixels)
;	lcur	- The light curve array.  The units are the same as whatever
;		  is being passed in, independent of BIN or WIDTH.  
;		       Prior to 21-Jul-94, the units were:
;		  (whatever was passed in) * (bin factor) * (width).
;METHOD:
;	DEFROI is used to mark the points on the image to make the
;	arc.  The default is to make a polynomial fit to the x and
;	y positions separately (as a function of the distance down
;	the arc). 
;HISTORY:
;	Written 21-Oct-93 by M.Morrison
;	15-Nov-93 (MDM) - Changed the calling sequence (to index,data)
;			- Added ENHANCE and SAMPLE options (as per LWA program)
;	 9-Jun-94 (MDM) - Modified to not crash when passing in a 1024x512
;			  image (make bin = 0.5 for that case).
;			- Corrected a bug for cases when bin = 0.5.
; V2.0	21-Jul-94 (MDM) - Corrected to not use the ENHANCED data for the
;			  arc signal (when /enhance was set)
;			- Corrected to normalize for the width and binning used,
;			  so that units are in the same units as what is passed
;			  in.
;			- Added documentation information
; V2.1	25-Jul-94 (MDM) - Added /RESTORE to DEFROI call
;-
;
nx = n_elements(image(*,0))
ny = n_elements(image(0,*))
qsample = keyword_set(sample)
;
code = 'S'	;default
if (keyword_set(use_spline)) then code = 'S'
if (keyword_set(use_poly)) then code = 'P'
if (n_elements(bin) eq 0) then begin
    if (nx gt 512) then bin = 0.5 else bin = 512/nx
end
if (n_elements(width0) eq 0) then width = fix(1*bin) else width=fix(width0*bin)
width = width > 1
;
img0 = rebin(image, nx*bin, ny*bin, sample=qsample)		;MDM corrected 21-Jul-94 to have img0 independent of ENHANCER
if (keyword_set(enhance)) then tv, rebin(enhancer(image, index), nx*bin, ny*bin, sample=qsample) $
			else tvscl, img0
win_i = !d.window
wshow, win_i
ss = defroi(nx*bin, ny*bin, xvert, yvert, /nofill, /restore)
;
xvert = float(xvert)
yvert = float(yvert)
n = n_elements(xvert)
;
dxvert = deriv_arr(xvert)
dyvert = deriv_arr(yvert)
rvert0 = [0,sqrt(dxvert^2 + dyvert^2)]
rvert = rvert0
for i=1,n-1 do rvert(i) = total(rvert0(0:i))    ;running sum
;
case code of
    'S': begin		;spline
		print, 'PLOT_ARC: Using the Spline Method'
		nout = 500
		rout = findgen(nout)/(nout-1) * (max(rvert)-min(rvert)) + min(rvert)
		xout = spline(rvert, xvert, rout)
		yout = spline(rvert, yvert, rout)
	end
    'P': begin
		print, 'PLOT_ARC: Using the Polynomial Method'
		if (n_elements(ndeg) eq 0) then ndeg = 4 > (n/2)
		xcoeff = poly_fit(rvert, xvert, ndeg)
		ycoeff = poly_fit(rvert, yvert, ndeg)
		nout = 500
		rout = findgen(nout)/(nout-1) * (max(rvert)-min(rvert)) + min(rvert)
		xout = poly(rout, xcoeff)
		yout = poly(rout, ycoeff)
	end
endcase
;
;;wdef, win_p, /lr, /free	;doesn't work right
win_p = 1
wdef, win_p
if (keyword_set(qdebug)) then begin
    plot, xout, yout, xrange=[0,nx*bin], yrange=[0,nx*bin], /xstyle, /ystyle
    oplot, xvert, yvert, psym=1
end
;
dx = deriv(xout)	;& dx = [dx(0), dx]	;make it the same length as xout
dy = deriv(yout)	;& dy = [dy(0), dy]
ang = atan(dy, dx)
lcur = fltarr(nout)
xlcur = (rout - min(rout))/bin * (2.^gt_res(index))
for i=0,width-1 do begin
    xout0 = xout - (i-(width-1)/2.)*cos(ang-!pi/2)
    yout0 = yout - (i-(width-1)/2.)*sin(ang-!pi/2)	;90 degrees to the deriv
    if (i eq 0)       then begin & xx1 = xout0 & yy1 = yout0 & end
    if (i eq fix(width-1)) then begin & xx2 = xout0 & yy2 = yout0 & end
    lcur = lcur + img0(xout0, yout0)
    if (keyword_set(qdebug)) then begin &     wset, win_p		& oplot, xout0, yout0 & end
end
;
lcur = lcur / width
;
if (keyword_set(qdebug)) then pause
plot, xlcur, lcur, xtit='Distance (in Full Resolution Pixels)', ytit='Intensity'
plottime, 0, 0, 'PLOT_ARC Ver 2.0

wset, win_i
tvplot, xx1, yy1
tvplot, xx2, yy2
if (keyword_set(qstop)) then stop
end
