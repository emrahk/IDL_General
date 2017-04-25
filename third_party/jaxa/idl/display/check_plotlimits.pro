;+
; Name: check_plotlimits
;
; Purpose: Check plot limits.  If min is set, but max is 0, autoscale max and viceversa.
;	Once x limits are set, if y is to be autoscaled, the use only those points whose
;	x values are within x limits to autoscale y.
;	If axis is log, then make sure limits are positive.
;
; History:
;	Written: Kim, 2/2000
;-

pro check_plotlimits, xrange, yrange, xdata, ydata, new_xrange, new_yrange, xlog=xlog, ylog=ylog

new_xrange = xrange
new_yrange = yrange

checkvar, xlog, 0
checkvar, ylog, 0

xuse = indgen( n_elements(xdata) )
xcount = n_elements(xuse)

; if only one x limit is set, then have to autoscale the other (e.g. so it
;	doesn't plot with limits [10.,0.])

if total(xrange) ne 0. then begin
	if xrange[0] eq 0. then new_xrange[0] = min(xdata)
	if xrange[1] eq 0. then new_xrange[1] = max(xdata)
	xuse = where (xdata ge xrange[0] and xdata le xrange[1], xcount)
endif

; for y limits, use only points within x limits already chosen
if total(yrange) ne 0. then begin
	if xcount gt 0 then begin
		if yrange[0] eq 0. then new_yrange[0] = min(ydata[xuse])
		if yrange[1] eq 0. then new_yrange[1] = max(ydata[xuse])
	endif
endif

; if axis is log then set limits so negative values are used.

if xlog then begin
	q = where (xdata gt 0., count)
	if new_xrange[0] eq 0 then begin
		if count gt 0 then new_xrange[0]=min(xdata(q)) else new_xrange[0]=.1
	endif
	if new_xrange[1] eq 0 then begin
		if count gt 0 then new_xrange[1]=max(xdata(q)) else new_xrange[1]=1.
	endif
endif

if ylog then begin
	q = where (ydata gt 0., count)
	if new_yrange[0] eq 0 then begin
		if count gt 0 then new_yrange[0]=min(ydata(q)) else new_yrange[0]=.1
	endif
	if new_yrange[1] eq 0 then begin
		if count gt 0 then new_yrange[1]=max(ydata(q)) else new_yrange[1]=1.
	endif
endif

;print, 'new_xrange = ', new_xrange, '  new_yrange = ', new_yrange
;print,'new x times = ', anytim(new_xrange,/ecs)

end