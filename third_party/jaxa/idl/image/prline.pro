;+
; $Id: prline.pro,v 1.4 2006/08/10 18:47:21 thernis Exp $
;
; PURPOSE:
;  get a straight line profile in an image
;
; CATEGORY:
;  feature extraction
;
; DESCRIPTION:
;  Use a bilinear interpolation
;
; INPUTS:
;  im : image
;  a1 : [x,y] starting point of the profile in pix
;  a2 : [x,y] end point of the profile in pix
;  nbp : number of sample requested
;
; OUTPUTS:
;  s : size of the segment in pix
;  x,y : arrays of the sampling positions
;  nearneigh : switch to use nearest neightbor interpolation instead
;              of bilinear interpolation
;
;-

function prline,im,a1,a2,nbp,s,x,y,nearneigh=nearneigh

sim=size(im,/dim)

a=(a1[1]*a2[0]-a2[1]*a1[0])/(a2[0]-a1[0])
b=(a2[1]-a1[1])/(a2[0]-a1[0])

ramp=findgen(nbp)/float(nbp-1)

d12=sqrt(total((a1-a2)^2))
s=ramp*d12

x=ramp*(a2[0]-a1[0])+a1[0]
y=ramp*(a2[1]-a1[1])+a1[1]

p=fltarr(nbp)
if keyword_set(nearneigh) then begin
    for i=0L,nbp-1 do begin
        xr=round(x[i])
        yr=round(y[i])
        if xr ge 0 and xr lt sim[0] and yr ge 0 and yr lt sim[1] then $
          p[i]=im[round(x[i]),round(y[i])] else $
          p[i]=0
    endfor
endif else begin
    for i=0L,nbp-1 do begin
        p[i]=bilinear(im,x[i],y[i],missing=0)
    endfor
endelse

return,p
end
