pro cal_posan,det1,det2,pos1,pos2,retpos1,retpos2,ang

;This program calculates the positions in IBIS reference frame, and
;also the scattering angle.


;For det1:

if det1 lt 8 then begin
  x0=-15.18+(det1 ge 4)*30.36
  y0=23.46-((det1 mod 4)*15.64)
  x1=pos1(1)+x0
  y1=pos1(0)+y0
  retpos1=[x1,y1]
endif else begin
  x0=-15.18+(det1 ge 12)*30.36
  y0=23.46-((det1 mod 4)*15.64)
  x1=pos1(1)+x0
  y1=pos1(0)+y0
  retpos1=[x1,y1]
endelse

;For det2:

if det2 lt 8 then begin
  x0=-15.18+(det2 ge 4)*30.36
  y0=23.46-((det2 mod 4)*15.64)
  x2=pos2(1)+x0
  y2=pos2(0)+y0
  retpos2=[x2,y2]
endif else begin
  x0=-15.18+(det2 ge 12)*30.36
  y0=23.46-((det2 mod 4)*15.64)
  x2=pos2(1)+x0
  y2=pos2(0)+y0
  retpos2=[x2,y2]
endelse

;Angle

x=x2-x1
y=y2-y1

if x eq 0 then x=x+1e-8
ang=atan(y/x)*180./!PI

if ((x lt 0) and (y ge 0)) then ang=180+ang
if ((x le 0) and (y lt 0)) then ang=180+ang
;if ((x eq 0) and (y lt 0)) then angx=+ang
if ((x ge 0) and (y lt 0)) then ang=360+ang
end
