function get_from_plot,x,y

;+
; NAME
;	get_from_plot
; PURPOSE
;	To click a box on a plot and return the indices of the data
;	points that fall in that box.
; CALLING EXAMPLE
;	ss=get_from_plot(xdata,ydata)
; INPUT
;	xdata = x-array for making plot.
;	ydata = y-array for making plot.
; OUTPUT
;	vector of indices of data points falling within the box
; HISTORY
;	24-Jul-2001  LWA  Logic cribbed from plot_fov.pro
;-

    selfov = bytarr(n_elements(x))
    get_boxcorn, x0, y0, x1, y1, /data
    draw_boxcorn, x0, y0, x1, y1, /data
    print, 'X Range: ', x0, x1
    print, 'Y Range: ', y0, y1
    ss = where( (x ge x0) and (x le x1) and (y ge y0) and (y le y1))
    if (ss(0) ne -1) then selfov(ss) = 1
    print, 'There are ', strtrim(fix(total(selfov)),2), ' images selected'

return,ss

end

