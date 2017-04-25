FUNCTION rigid_align, iim1, iim2, dm, sigma, weights=w, error=error, print=print

;Solves the normal equations for the 2-D displacement vector between input 
; images IIM1 and IIM2. Ideally IIM1 and IIM2 are two images of the same
; object with a homogeneous shift in the x and y directions.
;
;INPUTS:	iim1 = 2-D image, any type (converted to float internally).
;		iim2 = 2-D image, any type (converted to float internally).
;		weights = 2-D image of statistical weights on pixels of iim1 and iim2.
;		error = switch keyword for calculating error on fit.
;		print = switch keyword for printing out the offset vector and other info.
;
;OUTPUTS:	dm = fltarr(nx,ny): calculated difference image.
;		sigma = fltarr(2): standard deviation of offsets.
;
;RETURNS:	offset = fltarr(2).	offset(0) = x-displacement in pixels.
;					offset(1) = y-displacement in pixels.
;
;HISTORY:	1. Written by T. Berger 2-Nov-1996. Based on code by T. Tarbell
;		   in IDL and D. Shine in ANA.	
 
ON_ERROR,2
t = systime(1)

sz1 = size(iim1)
sz2 = size(iim2)
if sz1(0) ne 2 or sz2(0) ne 2 then begin
	message,'Images must be 2-d'
	RETURN, -1
end
if sz1(1) ne sz2(1) or sz1(2) ne sz2(2) then begin
	message,'Images must be of identical dimension'
	RETURN, -1
end

im1 = float(iim1)
im2 = float(iim2)
im = im1+im2

nx = sz1(1)
nx1 = nx - 1
nx2 = nx - 2
ny = sz1(2)
ny1 = ny - 1
ny2 = ny - 2

if (not keyword_set(w)) then w = (REPLICATE(1.,nx,ny))

dx1 = im1 - shift(im1,1,0)
dx2 = im2 - shift(im2,1,0)
dx = (dx1+dx2)/w

dy1 = im1 - shift(im1,0,1)
dy2 = im2 - shift(im2,0,1)
dy = (dy1+dy2)/w

dt = (im1-im2)/w
dtx = dt + shift(dt,1,0)
dty = dt + shift(dt,0,1)

offset = fltarr(2)
offset(0) = total(dtx*dx)/total(dx*dx)
offset(1) = total(dty*dy)/total(dy*dy)

if keyword_set(ERROR) then begin
 	idx = POLYFILLV([0,0,nx1,nx1],[0,ny1,ny1,0],nx,ny)
	a = [[dx(idx)],[dy(idx)]]
	c = INVERT( TRANSPOSE(a)#a )
	sigma = sqrt([c(0,0),c(1,1)])
end

dm = offset(0)*dx + offset(1)*dy

if (keyword_set(print)) then begin
	print,'  Offset (px):',offset
	if keyword_set(ERROR) then print,'  Sigma (px):',sigma
	print,'  RMS Distortion noise:',stdev(dm)
	print,'  Runtime = ',systime(1)-t, ' seconds'
end

RETURN, offset
END
