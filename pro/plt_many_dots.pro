; this assumes you have plotted the axes, titles, etc, with
;   plot, 0, /nodata, xrange=[40,100], yrange=[0, 60],		$
;		xticks=6, yticks=6, xminor=1, yminor=1, 		$
;		xtitle='Anode 1 Channel, ytitle='Anode 2 Channel', $
;		position=[.1, .1, .45, .45], [etc]

pro plt_many_dots, x, y, xrange, yrange, maxdots=maxdots
; features. The first is that x1 and y1 are "fuzzed" so that every pair
; does not plot on top of every equal pair -- i.e, if the pair
; (30,30) occurs 100 times, you do not get a single dot at (30,30),
; which would be indistinguishable from a single occurrence, but instead
; get 100 points uniformly distributed inside the 
; (29.5 -> 30.5, 29.5 -> 30.5) square. The second feature is for when
; this saturates, you will set maxdots which will use a maximum of maxdots
; for the hottest pixel and scale everything else linearly.

; parameters
;  x = array (presumed integer) of x values
;  y = array (presumed integer) of y values
;  xrange = 2-element array of min and max x values to plot; e.g, [40,100]
;  yrange = 2-element array of min and max y values to plot

; extract the elements of xrange and yrange
x0 = xrange[0]
x1 = xrange[1]
y0 = yrange[0]
y1 = yrange[1]
nx = long(x1 - x0 + 1L)
ny = long(y1 - y0 + 1L)

; first, build a 2-d array of the plot area and determine how many
;   "counts" each pixel has.
tmp = (y - y0) * nx + x - x0
plt_area = histogram(tmp, min=0L, max=nx*ny-1, binsiz=1L)
maxpix = 1.0 * max(plt_area)
if maxpix gt maxdots then begin
; unfortunately, I am going to use an inefficient loop to do the oplot
	plt_area = fix(plt_area * (maxdots/maxpix) + 0.5)
	rng = where(plt_area gt 0, ct)
	for i=0, ct-1 do begin
		k = rng(i)
		xp = x0 + k mod nx + randomu(seed, plt_area(k)) - 0.5
		yp = y0 + k / nx   + randomu(seed, plt_area(k)) - 0.5
		oplot, xp, yp, psym=3
	endfor
endif else begin
	r1 = randomu(seed, n_elements(x)) - 0.5
	r2 = randomu(seed, n_elements(y)) - 0.5
	oplot, psym=3, x+r1, y+r2
endelse
end
