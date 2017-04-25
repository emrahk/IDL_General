;+
; NAME:
;	FIND_EDGE_INTERCEPT
;
; PURPOSE:
;	Finds where the line defined by xline,yline hits the edges of the current plot box
; 	Results returned in xedge, yedge
;
; CATEGORY: HESSI, Graphics
;
; CALLING SEQUENCE:
;	FIND_EDGE_INTERCEPT, xline, yline, xedge, yedge
;
; INPUTS:
;	xline - 2-element array of x coordinates of endpoints of line
;	yline - 2-element array of y coordinates of endpoints of line
;
; OUTPUTS:
;	xedge - 2-element array of x coordinates of where line crosses plot boundary
;	yedge - 2-element array of y coordinates of where line crosses plot boundary
;
; EXAMPLE:
;	plot,findgen(20)+5, findgen(20)+30, /xlog,/ylog
;	xline=[14,15]
;	yline=[40,45]
;	find_edge_intercept, xline, yline, xedge, yedge
;	plots,xline,yline
;	plots,xedge,yedge
;	print,xedge,yedge
;	      23.9456      6.21533
;	      100.000      10.0000
;
; Kim Tolbert, March 2002.  Extracted from profiles2.
; Modifications:
;	22-Jun-2005, Kim.  Do calcs in double so we don't lose anything if inputs were double
;	06-Nov-2009, Kim.  Added xlimit,ylimit xlog, ylog keywords for case where ! variables aren't valid,
;	  i.e. didn't just draw plot
;
;-

pro find_edge_intercept, xline, yline, xedge, yedge, xlimit=xlimit, xlog=xlog, ylog=ylog, ylimit=ylimit

if keyword_set(xlimit) then begin
  xc = xlimit
  x_is_log = keyword_set(xlog)
endif else begin
  xc = crange('X')  
  x_is_log = !x.type  
endelse

if keyword_set(ylimit) then begin
  yc = ylimit
  y_is_log = keyword_set(ylog)
endif else begin
  yc = crange('Y')
  y_is_log = !y.type
endelse

if xline[0] eq xline[1] then begin
	xedge = xline
	yedge = yc
	return
endif

if yline[0] eq yline[1] then begin
	xedge = xc
	yedge = yline
	return
endif

yuse = y_is_log ? alog10(yline) : double(yline)
if y_is_log then yc = alog10(yc)

xuse = x_is_log ? alog10(xline) : double(xline)
if x_is_log then xc = alog10(xc)

m  = (yuse[1] - yuse[0]) / (xuse[1] - xuse[0])
b = yuse[0] - m * xuse[0]

xedge = dblarr(2) & yedge = dblarr(2)
xinter = (yc - b) / m

for i = 0,1 do begin
	if xinter[i] ge xc[0] and xinter[i] le xc[1] then begin
		xedge[i] = xinter[i] & yedge[i] = yc[i]
	endif else begin
		if xinter[i] lt xc[0] then xedge[i] = xc[0] else xedge[i] = xc[1]
		yedge[i] = m * xedge[i] + b
	endelse
endfor

if xy_dist( [xedge[0], yedge[0]], [xuse[0], yuse[0]] ) gt $
	xy_dist( [xedge[1], yedge[1]], [xuse[0], yuse[0]] ) then begin
		xedge = reverse(xedge)
		yedge = reverse(yedge)
endif

if x_is_log then xedge = 10. ^ xedge
if y_is_log then yedge = 10. ^ yedge
end
