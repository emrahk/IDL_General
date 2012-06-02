pro cov100only,lo,la,an
map_set,lo,la,an,/ortho,/isotropic,/grid,/label


;partial coverage
openr,1,'/home/ek/coverage/con100'
ar90=fltarr(2,450)
readf,1,ar90
lo90=fltarr(450)
la90=fltarr(450)
for i=0,449 do lo90(i)=ar90(0,i)
for i=0,449 do la90(i)=ar90(1,i)
plots,lo90,la90,line=2
plots,360-lo90,la90,line=2
plots,lo90+90,la90,line=2
plots,reverse(lo90)+45,la90,line=2
plots,reverse(lo90)+135,la90,line=2
plots,lo90+180,la90,line=2
plots,reverse(lo90)+225,la90,line=2
plots,lo90+270,la90,line=2
plots,lo90,-la90,line=2
plots,360-lo90,-la90,line=2
plots,lo90+90,-la90,line=2
plots,reverse(lo90)+45,-la90,line=2
plots,reverse(lo90)+135,-la90,line=2
plots,lo90+180,-la90,line=2
plots,reverse(lo90)+225,-la90,line=2
plots,lo90+270,-la90,line=2









close,1

x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2




lo90v=lo90
lo90=360-lo90v
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2

lo90=lo90v+90
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2


lo90=reverse(lo90v)+45
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2


lo90=reverse(lo90v)+135
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2

lo90=reverse(lo90v)+225
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2
plots,lo90n,-la90n,line=2

lo90=lo90v+270
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2


lo90=lo90v+180
x=sin((90-la90)*!pi/180)*cos(lo90*!pi/180)
y=sin((90-la90)*!pi/180)*sin(lo90*!pi/180)
z=cos((90-la90)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
lo90n=atan(yy/xx)*180/!pi
la90n=90-acos(zz)*180/!pi
plots,lo90n,la90n,line=2
plots,lo90n+72,la90n,line=2
plots,lo90n+144,la90n,line=2
plots,lo90n+216,la90n,line=2
plots,lo90n+288,la90n,line=2
plots,lo90n,-la90n,line=2
plots,lo90n+72,-la90n,line=2
plots,lo90n+144,-la90n,line=2
plots,lo90n+216,-la90n,line=2
plots,lo90n+288,-la90n,line=2


end
