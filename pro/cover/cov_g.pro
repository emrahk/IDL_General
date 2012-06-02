pro cov_g,lo,la,an
map_set,lo,la,an,/ortho,/isotropic,/grid,/label

;top detector

lont=findgen(45)
lant=atan(tan(65*!pi/180)*cos(lont*!pi/180))*180/!pi
lant2=reverse(lant)
lont2=lont+45
lant3=lant
lant5=lant
lant7=lant
lant4=lant2
lant6=lant2
lant8=lant2
lont3=lont2+45
lont4=lont3+45
lont5=lont4+45
lont6=lont5+45
lont7=lont6+45
lont8=lont7+45

print,lant3,lont3

plots,lont,lant
plots,lont2,lant2
plots,lont3,lant3
plots,lont4,lant4
plots,lont5,lant5
plots,lont6,lant6
plots,lont7,lant7
plots,lont8,lant8

x=cos(lant*!pi/180)*cos(lont*!pi/180)
y=cos(lant*!pi/180)*sin(lont*!pi/180)
z=sin(lant*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

;for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp


x=cos(lant2*!pi/180)*cos(lont2*!pi/180)
y=cos(lant2*!pi/180)*sin(lont2*!pi/180)
z=sin(lant2*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

;for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant3*!pi/180)*cos(lont3*!pi/180)
y=cos(lant3*!pi/180)*sin(lont3*!pi/180)
z=sin(lant3*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant4*!pi/180)*cos(lont4*!pi/180)
y=cos(lant4*!pi/180)*sin(lont4*!pi/180)
z=sin(lant4*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant5*!pi/180)*cos(lont5*!pi/180)
y=cos(lant5*!pi/180)*sin(lont5*!pi/180)
z=sin(lant5*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant6*!pi/180)*cos(lont6*!pi/180)
y=cos(lant6*!pi/180)*sin(lont6*!pi/180)
z=sin(lant6*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp


x=cos(lant7*!pi/180)*cos(lont7*!pi/180)
y=cos(lant7*!pi/180)*sin(lont7*!pi/180)
z=sin(lant7*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

;for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;plots,-lontp,lantp
;print,lantp,lontp

x=cos(lant8*!pi/180)*cos(lont8*!pi/180)
y=cos(lant8*!pi/180)*sin(lont8*!pi/180)
z=sin(lant8*!pi/180)


an=25*!pi/180

xp=x*cos(an)-y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)+z*sin(an)
zp=-x*sin(an)-y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

;for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp


x=cos(lant4*!pi/180)*cos(lont4*!pi/180)
y=cos(lant4*!pi/180)*sin(lont4*!pi/180)
z=sin(lant4*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant*!pi/180)*cos(lont*!pi/180)
y=cos(lant*!pi/180)*sin(lont*!pi/180)
z=sin(lant*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant2*!pi/180)*cos(lont2*!pi/180)
y=cos(lant2*!pi/180)*sin(lont2*!pi/180)
z=sin(lant2*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
;print,lantp,lontp
plots,-lontp,lantp

x=cos(lant3*!pi/180)*cos(lont3*!pi/180)
y=cos(lant3*!pi/180)*sin(lont3*!pi/180)
z=sin(lant3*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

;for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
print,lantp,lontp
plots,reverse(lontp),lantp

x=cos(lant5*!pi/180)*cos(lont5*!pi/180)
y=cos(lant5*!pi/180)*sin(lont5*!pi/180)
z=sin(lant5*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
print,lantp,lontp
plots,-lontp,lantp

x=cos(lant6*!pi/180)*cos(lont6*!pi/180)
y=cos(lant6*!pi/180)*sin(lont6*!pi/180)
z=sin(lant6*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
print,lantp,lontp
plots,-lontp,lantp

x=cos(lant7*!pi/180)*cos(lont7*!pi/180)
y=cos(lant7*!pi/180)*sin(lont7*!pi/180)
z=sin(lant7*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
print,lantp,lontp
plots,-lontp,lantp

x=cos(lant8*!pi/180)*cos(lont8*!pi/180)
y=cos(lant8*!pi/180)*sin(lont8*!pi/180)
z=sin(lant8*!pi/180)


an=25*!pi/180

xp=x*cos(an)+y*sin(an)*sin(an)+z*sin(an)*cos(an)
yp=y*cos(an)-z*sin(an)
zp=-x*sin(an)+y*sin(an)*cos(an)+z*cos(an)*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,44 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
plots,lontp,lantp
plots,-lontp,lantp
print,lantp,lontp


end
