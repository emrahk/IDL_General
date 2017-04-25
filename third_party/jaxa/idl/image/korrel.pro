
;+
; NAME:
;        KORREL
; PURPOSE:
;        Calculate the x/y offset between an image (or a series of images)
;        and a reference image.  Offsets are a co-registration
;        algorithm.
; CATEGORY:
;        Image Processing
; CALLING SEQUENCE:
;        xy = korrel(image,reference,size,offset)
; INPUTS:
;        image = 2-D or 3-D array.  Image(s) to be registered with reference.
;        reference = 2-D array.  Reference image for co-registration.
;        size = 2-element integer vector.  Size of the subimage of reference
;               which is actually registered with image.  Make shure that
;               this subimage completely falls within image.
;        offset = 2-element integer vector.  Coordinates of first pixel of
;                 the registration subimage within reference.
; OUTPUTS:
;        xy = float(2,*).  x and y offsets of image(s) compared to reference.
;             Positive values indicate that the first pixel of reference
;             falls within the boundaries of image.
; KEYWORDS (INPUT):
;        time = time in msec for each image (vector).  If supplied, the output
;        array will be float(3,*), with xy(2,*) = time.
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;        Minimizes the sum of the pixel differences between the two images.
;        Algorithm is brute force and not CPU efficient, but very robust
;        (supposedly more robust than cross correlation).
;        To make the same algorithm faster using a Monte Carlo Method: see
;        Barnea and Silverman, 1972, IEEE Trans. Comput. Vol. C-21, p. 179.
; MODIFICATION HISTORY:
;        JPW, Jan. 1992
;        JPW, Aug. 92 im and ref can have different size now.
;-

function korrel,im,ref,s,o,time=tt

; set and/or check input parameters and create some arrays

si = size(im)
if si(0) eq 3 then nim = si(3) else nim = 1     ; number of images to be reg.
xy = fltarr(2,nim)                              ; output variable
sr = size(ref)
if n_elements(s) ne 0 then  s = ((s>1)<sr(1:2))<si(1:2) $
   else  s = (sr(1:2)<si(1:2))*3/4              ; default size for subimage
sp = si(1:2)-s+1                                ; size of correlation map
if n_elements(o) ne 0 then  o = (o>0)<(sr(1:2)-s) $
   else  o = (sr(1:2)-s)/2                      ; default offset of subimage
rf = ref(o(0):o(0)+s(0)-1,o(1):o(1)+s(1)-1)     ; subimage
pp = fltarr(sp(0),sp(1))                        ; correlation map

; loop through each image

for k=0,nim-1 do begin
    ; calc. correlation map
    for j=0,sp(1)-1 do for i=0,sp(0)-1 do $
        pp(i,j) = total(abs(im(i:i+s(0)-1,j:j+s(1)-1,k) - rf))
    mpp = where(pp eq min(pp))                  ; get the minimum
    xp = mpp(0) mod sp(0)                       ; 1-D offset -> x/y
    yp = mpp(0)/sp(0)
    xy(*,k) = [xp,yp] - o

    ; interpolate by fitting a parabola through minimum
    if (xp gt 0 and xp lt sp(0)-1) then begin
       a = pp(xp-1,yp) + pp(xp+1,yp) - 2 * pp(xp,yp)   ; coefficients of
       b = pp(xp-1,yp) - pp(xp+1,yp)                   ; parabola
       if a ne 0.0 then xy(0,k) = xy(0,k) + 0.5 * b/a
    endif
    if (yp gt 0 and yp lt sp(1)-1) then begin
       a = pp(xp,yp-1) + pp(xp,yp+1) - 2 * pp(xp,yp)   ; coefficients of
       b = pp(xp,yp-1) - pp(xp,yp+1)                   ; parabola
       if a ne 0.0 then xy(1,k) = xy(1,k) + 0.5 * b/a
    endif

    if (xp eq 0 or xp eq sp(0)-1 or yp eq 0 or yp eq sp(1)-1) then $
       print,'Warning! Border reached on image',k
endfor

; add time to output if time keyword supplied
if n_elements(tt) eq nim then xy = [[xy],transpose(float(tt))]

return,xy
end
