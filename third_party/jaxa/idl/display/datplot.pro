;+
; PROJECT:
;       SDAC
; Name:
;	DATPLOT
;
; CALLING SEQUENCE:
;	datplot,xl,xh,y [,xnew,ynew , STAIRS=STAIRS, color=color [,/OUTPLOT] ]
;
;	or
;	datplot,dummy1, dummy2, xs=xs, y [, xnew,ynew , $
;	STAIRS=STAIRS, color=color [,/OUTPLOT] ]
;
; PURPOSE:
;	This procedure is used to OVERplot histograms between channel edges.
; CATEGORY:
;	1-D Graphics.
; INPUTS:
;	xl - Low edges of abscissae
;	xh - High edges of abscissae
;	y  - Ordinates
;
; Optional Inputs:
;	xs - xl and xhi are packed into xs(0,*) and xs(1,*)
;	if xs is passed, then y is still the third argument,
;	  the first two arguments are not used but required
;
; Optional Outputs:
;	xnew - If /stairs, then array used for abscissae bins
;	ynew - If /stairs, then ordinate array
;
; KEYWORDS:
;	OUTPLOT - if set, interpret abscissae as time values for OUTPLOT
;		If the abscissae is datatype structure, it is interpreted
;		using Anytim().  Xnew  will have Utbase removed.
;
;	/stairs - connect all the bins together, looks like stairs
;	/nolegs - leave the ends floating under stairs option
;	color   - plotting color to use, as with linecolors
;	psym  - symbol to plot at center of horizontal bar, def=no effect
;	sysmsize - size of symbol, def=0.1
;	All remaining keywords available to OPLOT
; CALLS:
;	FCOLOR
;
; RESTRICTIONS:
;       Initial call to plot must be made to establish scaling. For
;	overplotting only.
;
; MODIFICATION HISTORY:
;	91/12/06, FOR VERSION2
;       	18-oct-93, ras, nolegs and color
;	19-may-94, ras, indicate gaps between intervals using stairs
;	Version 4, RAS, 17-Jun-1997, protect case of a single data interval to plot.
;	Version 5, RAS, 29-mar-2001, direct support for Utplot through OUTPLOT
;   Kim, 17-Apr-2001, Add keyword nsum so nsum will not be in oplotextra, and can
;     be excluded from call to oplot.  Changed default for psym to !p.psym, and don't
;     oplot the symbols if psym=0 OR psym=10.  Also use abs(psym).
;   Kim, 18-Nov-2007, Made nsum work properly.
;	Kim, 30-Jan-2008, Corrected error - xlog and ylog were being passed to oplot - invalid
; CONTACT:
;	richard.schwartz@gsfc.nasa.gov
;-

pro datplot,xl,xh,y,xnew,ynew, xs=xs, _extra=oplotextra, $
    OUTPLOT=outplot, $
    STAIRS=STAIRS, color=color, nolegs=nolegs, psym=psym, symsize=symsize, nsum=nsum, $
    xlog=xlog, ylog=ylog

checkvar, xlog, !x.type
checkvar, ylog, !y.type
checkvar, nsum, !p.nsum

xtype = size(/tname, xs)
if xtype eq 'UNDEFINED' then begin
	xtype = size(/tname, xl)

	xlo = anytim(xl)
	xhi = anytim(xh)
	endif

use_utbase = xtype EQ 'STRUCT'
if n_elements(outplot) eq 1 then use_utbase = outplot

if n_elements(xs) ge 2 then begin
    xs1 = anytim( xs)
    xlo  = xs1(0,*)
    xhi  = xs1(1,*)
    endif

f_color = fcheck( color, !p.color )
if !d.name eq 'TEK' then f_color = ([0,intarr(15)+1])(f_color)

nx = n_elements(xlo)

utbase    = ([ 0.0, getutbase()])(use_utbase)
xhi       = anytim(xhi) - utbase
xlo       = anytim(xlo) - utbase



;find where data bins are not contiguous
if nx gt 1 then $
  wncont = where( abs(xhi - xlo(1:*)) ge .01 *abs(xhi-xlo) , nncont) $
else nncont = 0

; if nsum is not 1, need to group bins together manually.
if nsum gt 1 then begin
   if nncont gt 0 then begin
      message,'Ignoring nsum = ' + trim(nsum) + ' setting - data are not contiguous.', /cont
   endif else begin
      if nsum gt nx then begin
        message,'NSUM is > number of points.  Invalid.  Ignoring NSUM.', /cont
      endif else begin
	      new = ceil( float(nx) / nsum)	;new number of points to plot
	      missing = new*nsum - nx
	      nx = new
	      last_xhi = last_item(xhi)
	      ; take every nsum element of xlow and xhigh. If missing last high because
	      ; there are extra values after last nsum group, add last value of original xhi
	      xlo = xlo[0:*:nsum]
	      xhi = xhi[nsum-1:*:nsum]
	      if n_elements(xlo) gt n_elements(xhi) then xhi = [xhi, last_xhi]
	      ; tack NaNs to end of y array to make last group have nsum values so we can use reform
	      ysum = missing gt 0 ? [y, fltarr(missing)*!values.f_nan] : y
	      ysum = reform(ysum, nsum, nx)

          ; Wherever y is NaN set to 0. so won't add into sum.  Also set yfinite to 0.
          ; for same points, so when getting total # points to divide by, isn't included.
          ; (For ylog, include y < 0 in test for good/bad values)
	      if ylog then begin
	        qbad = where (ysum le 0 or finite(ysum) eq 0, cbad, complement=qgood)
	        if qgood[0] ne -1 then ysum[qgood] = alog10(ysum[qgood])
	        yfinite = finite(ysum)
	        if cbad gt 0 then yfinite[qbad] = 0.
	      endif else begin
	      	qbad = where (finite(ysum) eq 0,cbad)
	      	yfinite = finite(ysum)
	      endelse
	      ; where ysum isn't finite, set it to 0.
	      ; yfinite will be an array of 0s and 1s showing which values were finite, By totalling
	      ; yfinite in the same way as ysum, it will have # valid points in each bin, and we
	      ; can divide by it to get average.

	      if cbad gt 0 then ysum[qbad] = 0.
	      ytot = total(ysum,1)
	      ntot = total(yfinite,1)
	      y = f_div(ytot, ntot)
	      ; if ylog, take 10^y, but where y was 0., set to NaN
	      if ylog then begin
	      	 qbad = where (y eq 0., cbad)
	      	 y = 10. ^ y
	      	 if cbad gt 0 then y[qbad] = !values.f_nan
	      endif
	  endelse
   endelse
endif



;PLOT BARS
if NOT KEYWORD_SET(STAIRS) then begin

   for i=0L,nx-1L do $
     oplot, [xlo(i),xhi(i)], [y(i),y(i)], psy=0,$
       color=f_color,  _extra=oplotextra, nsum=1

endif else begin

    ;OR PLOT STAIRS

    xnew = transpose( reform( [xlo(*),xhi(*)],nx,2) )
    ynew = transpose( reform( [y(*),y(*)], nx, 2) )
    if not keyword_set(nolegs) then begin
        xnew = [ xnew(0), xnew(*), xnew(nx*2-1) ]
        yrange = crange('y')
        ynew = [ yrange(0), ynew(*), yrange(0) ]
    endif

    oplot,xnew, ynew,PSYM=0,color=f_color, _extra=oplotextra, nsum=1

    if nncont gt 0 then $ ;overplot blanks during gaps
      for i=0L, nncont-1L do $
        oplot, [xhi(wncont(i)),xlo(wncont(i)+1)], [y(wncont(i)),y(wncont(i)+1)], $
          psym=0, color = !p.background, _extra=oplotextra, nsum=1


endelse

; if plotting a symbol, plot it at center of x bin (check for x axis log)
checkvar, psym, !p.psym
checkvar, symsize,0.1
if psym ne 0 and psym ne 10 then begin
	if xlog then xm = sqrt(xlo*xhi) else xm=(xlo+xhi)/2
	oplot, xm, y, psym=abs(psym), symsize=symsize, color = f_color, _extra=oplotextra, $
	   nsum=1
endif

end

