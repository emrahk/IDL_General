;+
;Name:
;	FIT_BACKGRND
;Call:
;       Background_rate=FIT_BACKGND( t_d, rate, erate, order, trange1, trange2, sigma=sigma, $
;	selected=selected, ltime=ltime, exp=exp)
;
;PURPOSE:
;	This function fits the count rate, RATE, to a polynomial of order, ORDER, or an
;	exponential over the background intervals specified by the limits in TRANGE1 and TRANGE2
;	or the indices in SELECTED.
;	Return the value of the fit for each time interval in T_D.
; Sigma is composed of the standard deviation due to the counting statistics
; on the data and another component, yband, the uncertainty in the absolute level
; of the background based on the scatter between the time intervals (see change of 27-Sep-2010 - 
; yband component not included in sigma anymore.)
;
;Calls:
;	POLY, POLYFITW, F_DIV, CHECKVAR, CURVEFIT, F_EXP_PRO
;
;Inputs:
;	t_d - time array, n  or (2 x n) where n is the number of time bins.
;		if t_d is dimensioned 2xn, then the first column is the
;		start times and the second column is the end times.
;		if t_d is dimensioned n, then intervals are uniform and
;		t_d is the center of each interval. t_d is monotonic.
;
;	rate - count rate vector, n elements.
;	erate - uncertainties on rate
;	ltime - livetime of each interval in rate, used for weighting (Note: this is a keyword)
;
;	selected - indices of selected points in t_d and rate to use in fit (Note: this is a keyword)
;	or
;	trange1 - 2 points on the range covered by t_d.  Should be prior
;		to the event (flare).
;	trange2 - 2 points after the event along t_d.
;
;	order - polynomial to fit over the ranges specified by
;		trange1 and trange2 or selected.  Default is 1.  Not used if exp keyword is set.
;	exp - if set, fit to exponential instead of polynomial.   (Note: this is a keyword)
;
; OUTPUT KEYWORDS:
; SIGMA - the average standard deviation in the fit.
; COEFF_VALUE - the value of the fit coefficient(s)
; COEFF_SIGMA - the sigma on the coefficient(s)
;
;History:
;RAS, 92/1/27
;17-oct-93, modified to take time arrays with start and stop edges
;21-apr-94, fixed bug in use of order (degree of fit)
;	    also allows order 0, straight average
;30-aug-95, fixed sigma calculation
;23-aug-96, fixed basic sigma calculation
;09-sep-2004, Kim.  Fixed sigma again - previously er^2*lt, now (er*lt)^2
;09-Aug-2005, Kim.  Changed keyword_set(selected) to exist(selected)
;11-Jan-2006, Kim.  Fixed bug in computing xedges (changed + to - for last point)
;30-Jul-2009, Kim.  Added exponential fit option
;11-Dec-2009, Kim. Was using f_exp for exponential fit.  But that was made into a
;  function, and fit_backgrnd needs a procedure, so use f_exp_pro
;12-aug-2010, ras, sigma for poly 0 bkg is just sigma from sqrt counts
;27-Sep-2010, Kim. Don't add yband component to sigma.  Just use st. dev. due to counting
;  statistics. This change recommended by RAS - says we don't understand yband enough.
;04-Apr-2013. Kim. Use poly_fit instead of polyfitw (obsolete), and added keywords to pass out 
;  the coefficients and sigmas on the coefficients.
;-


function fit_backgrnd, t_d, rate, erate, order, trange1, trange2, sigma=sigma, $
	selected=selected, ltime=ltime, exp=exp, coeff_value=coeff_value, coeff_sigma=coeff_sigma

checkvar, order, 1

order_t = (size(t_d))(0) ;what are the dimensions of t_d
if order_t eq 1 then begin ; transform to edges
	ntd = n_elements( t_d) -1
	xedges = [1.5* t_d(0)-.5*t_d(1), ( t_d(1:*)+t_d) / 2.,  $
	       1.5*t_d(ntd) - 0.5*t_d(ntd-1) ]
endif else xedges = [ (t_d(0,*))(*), t_d(1, n_elements(t_d(1,*))-1)]

if not exist(selected) then begin
;*******************
;TRANSFORM THE TIME RANGES INTO INDEX RANGES
	t1 = trange1(sort(trange1))
	t2 = trange2(sort(trange2))

	n1s = ((where( xedges ge t1(0), nx))(0) -1)>0
	n1e = ((where( xedges ge t1(1), nx))(0) -1)>0
	nrange1 = indgen((n1e-n1s)>1) + n1s

	n2s = ((where( xedges ge t2(0), nx))(0) -1)>0
	n2e = ((where( xedges ge t2(1), nx))(0) -1)>0
	nrange2 = indgen((n2e-n2s)>1) + n2s

	r = [nrange1, nrange2]
;*******************
endif else r = selected

xm = .5* (xedges + xedges(1:*))

weight = fcheck( ltime, xm*0.0+1.)

;sigma =   f_div(sqrt(total( erate(r)*ltime(r))),total(ltime(r))) ;old bad calculation
sigma =   f_div( sqrt(total( (erate[r]*ltime[r])^2 ) ), total(ltime[r]) )

if keyword_set(exp) then begin

  ; Do Exponential fit
  ;
  ;find starting parameters for exp fit by using average of first and last group of points
  ; find_contig finds the groups, and ss2d will be [n,2] giving start of each group, followed by
  ; end of each group
  j = find_contig(r, ss, ss2d)
  ; If fewer than 3 data points, or there was only one group of data, just take average
  nr = n_elements(r)
  if nr lt 3 then begin
    back = average(rate[r])
  endif else begin

    ; if only one group make 2 groups by dividing in half
    if size(ss2d,/n_dim) eq 1 then begin
      rc = [ [r[0], r[nr/2]], [r[nr/2 - 1], r[nr-1] ] ]
    endif else rc = r[ss2d]
    ; find a,b such that y = a * exp(b*x) for x1,y1 and x2,y2 (ave x,y values for first and last group)

    last = n_elements(rc[*,0]) - 1
    x1 = average(xm[rc[0,0]:rc[0,1]])
    y1 = average(rate[rc[0,0]:rc[0,1]])
    x2 = average(xm[rc[last,0]:rc[last,1]])
    y2 = average(rate[rc[last,0]:rc[last,1]])
    b = alog(y1/y2) / (x1-x2)
    a = y1 / (exp(b*x1))
    start_parm = [a, b, 0.]  ; our starting guess
    parm = start_parm

    ; Find new parameters (parm) that are best fit to data selected (r)
    w = curvefit (xm[r], rate[r], weight[r], parm, chisq=chi, fita=[1,1,0],$
      function_name='f_exp_pro', status=status, yerror=yband, itmax=100)
    ; status = 1 means chisq was increasing without bounds.  In that case, compute back from start_parm
    coeff_value = status eq 1 ? start_parm : parm
    coeff_sigma = coeff_value * 0. 

;    print,'starting, fit params,st,chi = ', trim(savep),trim(parm), trim(status), trim(chi)

    ; Compute back at each xm point using computed parm values. Combine sigma with error from fit.
    
    f_exp_pro, xm, coeff_value, back
;   sigma = sigma + yband

  endelse

endif else begin

  ; Do Polynomial fit of order ORDER

  if order eq 0 then begin
  	counts = total( rate[r]*ltime[r] )
  	live   = total(ltime[r])
  	back   = f_div(counts,live) + xm*0.0
  	yband =0.0
  	coeff_value = back[0]
  	coeff_sigma = f_div(sqrt(counts), live)

  endif else begin
;  	coeff= polyfitw(xm[r],rate[r],weight[r], order > 1, yfit, yband)
;    back = poly( xm, coeff)
;    
    ; Switch to using new poly_fit. Guard against negative or zero weights. Kim 4/4/2013
    q = where(weight[r] gt 0., kgood)
    r = r[q]
    coeff_value = poly_fit(xm[r], rate[r], order>1, chisq=chisq, measure_errors=f_div(1.,sqrt(weight[r])), sigma=coeff_sigma, $
      yfit=yfit, yband=yband, yerror=yerror)
    back = poly( xm, coeff_value)
  endelse
  ; guard against degenerate ybands emerging from polyfitw when there
  ; are no degrees of freedom.
;  if n_elements(r) gt ((order>1)+1) then sigma = sigma + avg(yband)
endelse

return, back

end

