;+
; Name: find_pixel_intersects
;
; Purpose: Finds pixel element numbers in image intersected by a line
;
; Project:  HESSI
;
; Calling Sequence:
;	xy = find_pixel_intersects (xedge, yedge, xaxis, yaxis, image_size, ylog=ylog, $
;   	dist=dist, xvals=xvals, yvals=yvals
;
; Method:
;	Divide the line into twice as many pixels as there are on the diagonal (to make sure at least
;	one point falls in any pixel the line passes through) and calculate the x, y coords at each length
;	along the line.   Calculate the edges of the pixels xpix, ypix, and use find_ix to find the
;	element number of the image that each x,y falls in. Then return all the unique x,y element pairs.
;
; Input arguments:
;	xedge, yedge - 2-element arrays of x and y coordinates where start and end of line crosses edges of
;		image shown (can be zoomed in) in data coordinates
;	xaxis - edges of x axis bins of full image (non-zoomed) in data coordinates
;	yaxis - edges of y axis bins of full image (non-zoomed) in data coordinates
;	image_size - 2-element array of number of pixels in x and y direction (if zoomed in, this
;		is the zoomed-in size of the image)
;
; Input Keywords:
;	ylog - If set, y axis is log scale
;
; Output Optional keywords:
;	xvals, yvals - x,y data coordinates of the center of each image element returned by the function
;	dist - distance along the line to each xvals,yvals pair
;
; Written: Kim Tolbert, 18-Mar-2002
; Modifications:
;	29-Mar-2005, Kim:  Deleted x0_full,y0_full,dpixel_size input arguments.  Instead pass in
;		xaxis,yaxis.  This allows for the possibility of uneven bins (as in spectrograms).  Also
;		added ylog keyword (also for spectrograms)
;	22-Apr-2005, Kim.  Corrected if ylog -> if keyword_set(ylog)
;	9-May-2005, Kim.  Corrected bug - was getting but not using unique pairs (xinter,yinter)
;
;-

;---------------------------------------------------------------------------------


function find_pixel_intersects, xedge, yedge, xaxis, yaxis, image_size, ylog=ylog, $
	dist=dist, xvals=xvals, yvals=yvals


; number of points to use will be twice the number of pixels there are on the diagonal
np = 2 * sqrt(image_size[0]^2 + image_size[1]^2)

x = xedge[0] + indgen(np+1) * (xedge[1]-xedge[0])/np
if keyword_set(ylog) then begin
	y = yedge[0] * 10. ^ (indgen(np+1) * (alog10(yedge[1])-alog10(yedge[0]))/np)
endif else begin
	y = yedge[0] + indgen(np+1) * (yedge[1]-yedge[0])/np
endelse

;xpix = x0_full + dpixel_size[0] * indgen(full_image_size[1])
;ypix = y0_full + dpixel_size[1] * indgen(full_image_size[2])

; find pixel elements that x and y fall inside of
ix = value_locate(xaxis, x)
iy = value_locate(yaxis, y)

; find unique x,y element pairs
q = uniq(trim(ix) + trim(iy))
xinter = ix[q]
yinter = iy[q]

xaxis_mid = get_edge_products(xaxis, /mean)  ;midpoints of full x axis
yaxis_mid = get_edge_products(yaxis, /mean)  ;midpoints of full y axis

; xvals,yvals are data coords at center of each of those pixels
xvals = xaxis_mid[xinter]
yvals = yaxis_mid[yinter]

;distance along line to each xvals,yvals point
dist = sqrt((xvals-xedge[0])^2 + (yvals-yedge[0])^2)

return, [[xinter],[yinter]]

end
