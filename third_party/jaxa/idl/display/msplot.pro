pro msplot, x, a, xsp, ysp, norm=norm,xtitle=xtitle,ytitle=ytitle,$
           title=title,noax=noax,psym=psym
;
;+
; NAME:
;	msplot
; PURPOSE:
;	plot multiple data sets on a single set of axes
; CALLING SEQUENCE:
;	msplot, x, a, xsp, ysp, noaxe=noaxe
; INPUTS:
;	x = 	x array
;	y = 	set of n y arrays (*, n)
;	xsp =	x spacing between plots 
;	ysp =	y spacing between plots 
; KEYWORD PARAMETERS:
;	/norm	plot data with each array normalized to unity
;       /noax  don't plot axes
; MODIFICATION HISTORY:
;	JTM, Jan 1984 as routine pseudo
;	JTM, Sep 1992 renamed mplot and added /norm
;       DMZ, Mar 1993 - beefed up
;-
;
;	determine size of a
;
        on_error,1
	idem = size(a)
	m = idem(1)
	n = idem(2)
        if idem(0) lt 2 then message,'insufficient # of points to make map'
	ymin = fltarr(n)
	ymax = fltarr(n)
;
	if keyword_set(norm) then begin
	   saveit = a
	   for i = 0, n-1 do a(*,i) = a(*,i)/max(a(*,i))
	endif
;
;	determine scales
;
        if n_elements(ysp) eq 0 then ysp=0
        if n_elements(xsp) eq 0 then xsp=0
        if n_elements(psym) eq 0 then psym=0

	for i = 0, n-1 do begin
	  ymin(i) = min(a(*,i) + i*ysp)
	  ymax(i) = max(a(*,i) + i*ysp)
	  endfor
	tymin = min(ymin)
	tymax = max(ymax)
	txmin = x(0) < (x(0) + (n-1)*xsp)
	txmax = x(m-1) > (x(m-1) + (n-1)*xsp)
        xrange=[txmin,txmax] & s=sort(xrange)
        xrange=xrange(s)

;
;	do the plots
;
	yscratch = a(*,0)
	plot, x,yscratch,xrange=xrange,yrange=[tymin,tymax],$
          xtitle=xtitle,ytitle=ytitle,title=title,psym=psym

	if keyword_set(noax) then erase
	for i = 1, n-1 do begin
	  xscratch = x + i*xsp
	  yscratch = a(*,i) + i*ysp
	  oplot, xscratch, yscratch,psym=psym
	endfor

;
	if keyword_set(norm) then a = saveit
;
	return
	end

