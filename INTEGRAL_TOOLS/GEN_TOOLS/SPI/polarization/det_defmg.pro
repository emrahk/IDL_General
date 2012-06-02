pro det_defmg,det1,det2,pos1,pos2,retpos1,retpos2,angx

;define detector coordinates in MGEANT units !!!!!

st=5.196153

coord=[[0.,0.],[6.,0.],[3.,st],[-3.,st],$
       [-6.,0.],[-3.,-st],[3.,-st],[9.,-st],$
       [12.,0.],[9.,st],[6.,2.*st],[0.,2.*st],[-6.,2.*st],$
       [-9.,st],[-12.,0.],[-9.,-st],[-6.,-2.*st],$
       [0.,-2.*st],[6.,-2.*st]]

x1=pos1(1)+coord[0,det1]
y1=-pos1(0)+coord[1,det1]
retpos1=[x1,y1]

x2=pos2(1)+coord[0,det2]
y2=-pos2(0)+coord[1,det2]
retpos2=[x2,y2]

x=x2-x1
y=(y2-y1)

if x eq 0 then x=x+1e-8
ang=atan(y/x)*180./!PI
angx=ang
if ((x lt 0) and (y ge 0)) then angx=180+ang
if ((x le 0) and (y lt 0)) then angx=180+ang
;if ((x eq 0) and (y lt 0)) then angx=+ang
if ((x ge 0) and (y lt 0)) then angx=360+ang

end
