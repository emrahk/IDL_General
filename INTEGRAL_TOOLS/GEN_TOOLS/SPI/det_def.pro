pro det_def,det1,det2,angx,dist

;define detector coordinates
st=sqrt(3.)

coord=[[0.,0.],[0.,-st],[1.5,-st/2.],[1.5,st/2.],$
       [0.,st],[-1.5,st/2.],[-1.5,-st/2.],[-1.5,-3.*st/2.],$
       [0,-2.*st],[1.5,-3.*st/2.],[3,-st],[3.,0.],[3.,st],$
       [1.5,3.*st/2.],[0.,2.*st],[-1.5,3.*st/2.],[-3.,st],$
       [-3.,0.],[-3.,-st]]

x=coord[0,det2]-coord[0,det1]
y=coord[1,det2]-coord[1,det1]

dist=sqrt(x^2+y^2)

if x eq 0 then x=x+1e-8
ang=atan(y/x)*180./!PI
angx=ang
if ((x lt 0) and (y ge 0)) then angx=180+ang
if ((x le 0) and (y lt 0)) then angx=180+ang
;if ((x eq 0) and (y lt 0)) then angx=+ang
if ((x ge 0) and (y lt 0)) then angx=360+ang

end
