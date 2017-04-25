;+
; $Id: mkcirc.pro,v 1.2 2006/08/10 18:47:21 thernis Exp $
; 
; PURPOSE:
;  Draw a circle in an image
; 
; CATEGORY:
;  visualization, masking
;
; INPUTS:
;  sx,sy : size of the image in pix
;  cx,cy : center of the circle in pix
;  r : radius of the circle in pix
;
; OUTPUTS:
;  return : an image with a pretty circle inside
;
;-


function mkcirc,sx,sy,cx,cy,r

im=bytarr(sx,sy)

x=(findgen(sx,sy) mod sx )-cx
y=(findgen(sx,sy) / sy)-cy

m=where(x^2+y^2 le r^2,cnt)

if cnt gt 0 then im(m)=1B


return,im
end
