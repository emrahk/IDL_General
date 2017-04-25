;+
; $Id: plotcircle.pro,v 1.3 2006/08/10 18:47:21 thernis Exp $
;
; PURPOSE:
;  simply draw a circle on the current window
;
; CATEGORY:
;  visualization, geometry
;
; INPUTS:
;  cntr : [x,y] center of the circle in pix
;  r : radius of the circle in pix
;  sector : [a1,a2] : plot only the angular sector from angle a1 to a2,
;                     in rad
; OUTPUTS:
;  display on the current window
;
;-

pro plotcircle,cntr,radius,nbvert,sector=sector

if n_elements(nbvert) eq 0 then nbvert=100L

if n_elements(sector) eq 0 then begin
    angle=lgen(nbvert,0.,!pi/4)
    
    for i=0,nbvert-1 do begin
        x=radius*cos(angle[i])
        y=radius*sin(angle[i])
        
        plots,[cntr[0]+x,cntr[1]+y],/device,psym=3
        plots,[cntr[0]-x,cntr[1]+y],/device,psym=3
        plots,[cntr[0]-x,cntr[1]-y],/device,psym=3
        plots,[cntr[0]+x,cntr[1]-y],/device,psym=3
        plots,[cntr[0]+y,cntr[1]+x],/device,psym=3
        plots,[cntr[0]-y,cntr[1]+x],/device,psym=3
        plots,[cntr[0]-y,cntr[1]-x],/device,psym=3
        plots,[cntr[0]+y,cntr[1]-x],/device,psym=3
        
    endfor
endif else begin
    sectorlenght=sector[1]-sector[0]
    nbquarter=sectorlenght/(!pi/4)
    nbvert*=nbquarter
    angle=lgen(nbvert,sector[0],sector[1])
    
    plots,[cntr[0]+radius*cos(angle[0]),$
           cntr[1]+radius*sin(angle[0])],/device
    for i=1,nbvert-1 do begin
        plots,[cntr[0]+radius*cos(angle[i]),$
               cntr[1]+radius*sin(angle[i])],/device,/continue
    endfor
endelse



return
end
