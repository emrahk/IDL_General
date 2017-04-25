FUNCTION cross_corr, iim1, iim2, smax0, iim1s, WEIGHTS=weights, PRINT=print

;+
;NAME:
;		cross_corr
;PURPOSE:
;		Perform a cross correlation match on two images
;SAMPLE CALLING SEQUENCE:
;		offset = cross_corr(img1, img2, max_shift)
;		offset = cross_corr(img1, img2, max_shift, img1s)
;INPUTS:        iim1: 2-D image, any type.
;               iim2: 2-D image, any type.
;               smax: integer = maximum search distance in +/- X and Y directions.
;
;OUTPUTS:       iim1s:  fltarr(nx,ny) = iim1 shifted by calculated offset vector.
;                       Ideally iim1s = iim2. Note that iim1s will have bad edges.
;
;RETURNS:       offset: fltarr(2). offset(0) = x-offset in pixels FROM iim1 to iim2.
;                                  offset(1) = y-offset in pixels FROM iim1 to iim2.
;
;
;HISTORY:       Written by T. Berger 6-Nov-96.
;		 6-Nov-96 (MDM) - Removed call to function AVG
;				- Removed "on_error,2"
;				- Corrected undefined "xmax" and adjusted 
;				  so smax is not changed internally
;-
;
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
nx = sz1(1)
ny = sz1(2)

im1 = float(iim1)
im1r = ROTATE(im1,1)
im2 = float(iim2)
im2r = ROTATE(im2,1)

if not keyword_set(WEIGHTS) then w = REPLICATE(1.,nx,ny) else w=weights

;shift distance even:
if ((smax0 mod 2) ne 0) then smax = smax0 + 1 else smax = smax0

;shifting to find minimum pixel:
dcc = 2*smax+1
cc = fltarr(dcc,dcc)
b = total(im1)/n_elements(im1) - total(im2)/n_elements(im2)

for i=0,smax do $
        for j=0,smax do begin
                cc(i+smax,j+smax) = TOTAL( ABS(w*(im1  - shift(im2, i, j))-b ) )   ;A
                cc(smax-i,smax-j) = TOTAL( ABS(w*(im1  - shift(im2,-i,-j))-b ) )   ;B
                cc(j+smax,smax-i) = TOTAL( ABS(w*(im1r - shift(im2r, i, j))-b) )   ;C
                cc(smax-j,smax+i) = TOTAL( ABS(w*(im1r - shift(im2r,-i,-j))-b) )   ;D
        end

cc = cc/cc(smax-1,smax-1)
mincc = min(cc)
cx = ( where(cc eq mincc) ) mod dcc
cy = ( where(cc eq mincc) )/dcc

offset = fltarr(2)

;if cross-correlation is perfect, no need to interpolate:
if mincc eq 0. then begin

        offset(0) = cx
        offset(1) = cy

end else begin

        ;parabolic interpolation about minimum:

        xi = [cx-1,cx,cx+1]
        yi = [cy-1,cy,cy+1]
        ccx2 = ( cc([xi],[cy,cy,cy]) )^2.
        ccy2 = ( cc([cx,cx,cx],[yi]) )^2.

        xn = ccx2(2)-ccx2(1)
        xd = ccx2(0)-2.*ccx2(1)+ccx2(2)
        yn = ccy2(2)-ccy2(1)
        yd = ccy2(0)-2.*ccy2(1)+ccy2(2)

        if xd ne 0. then $
                offset(0) = xi(2) - ( xn/xd + 0.5 ) else offset(0) = float(cx)
        if yd ne 0. then $
                offset(1) = yi(2) - ( yn/yd + 0.5 ) else offset(1) = float(cy)

end
offset = smax-offset

;diagnostics:
if keyword_set(print) then begin
        print,'Offsets (px): ',offset   
        print,'Runtime = ',systime(1)-t, ' seconds'
end

;shifted image: shift im1 onto im2 using calculated offsets.

iim1s = POLY_2D(im1,[-offset(0),0,1,0],[-offset(1),1,0,0],2)

RETURN, offset
END
