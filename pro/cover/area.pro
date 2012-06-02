pro area

;plot teta and phi in terms of tetaprime and get phi in terms of teta
tetap=findgen(61)
phi=atan(tan(!pi/6)*cos((tetap*!pi/180)-!pi/6)/cos(tetap*!pi/180))*180/!pi
teta=atan(tan(tetap*!pi/180)*cos(phi*!pi/180))*180/!pi
plot,phi
oplot,teta
;set_plot,'ps'
;plot,phi
;oplot,teta
;device,/close
;set_plot,'x'
;lprint,phi
;print,teta

;relation between teta and teta' is quite linear with slope 17/20
;calculate the bottom area, do not forget the cos factor!
tet=findgen(33)*20.0/17.0
phi2=atan(tan(!pi/6)*cos(tet*!pi/180-!pi/6)/cos(tet*!pi/180))
phi2=phi2*180/!pi
;print,phi2
teta2=atan(tan(tet*!pi/180)*cos(phi*!pi/180))
; print,teta2*180/!pi
area=0.0
area2=0.0
for i=0,32 do begin
 area=area+(36-phi2(i))*cos(teta2(i))
 ;area2=area2+(36-phi2(i))
 ;print,area
 ;print,area2
endfor
print,area*2
;print,area2

; total area
tot=0.0
for j=0,90 do begin
 tot=tot+360*cos(j*!pi/180)
; print,tot
endfor
print,tot

; top area
top=0.0
for j=60,90 do begin
 top=top+360*cos(j*!pi/180)
 print,top
endfor
print,'top',top

end
