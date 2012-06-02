960     103.1182     185.4170      
 103.2591     154.5130     103.5066     118.1710     103.6768     100.6030      
 104.0172     77.33860     104.3783     61.22990     104.7966     49.13570      
 105.4133     38.21490     106.0817     30.66280     106.9730     24.34860      
 108.3055     19.15270     109.9156     15.45880     112.1926     12.65220      
 115.7978     10.30260     121.0418     8.724430     126.6360     7.820160      
 137.0662     6.951000     152.1470     6.352380     181.5870     5.845nt+180,lant
plots,-lont+180,lant
plots,lont+90,lant
plots,-lont+90,lant
plots,lont+270,lant
plots,-lont+270,lant
;plots,lont2,lant2
;plots,lont3,lant3
;plots,lont4,lant4
;plots,lont5,lant5
;plots,lont6,lant6
;plots,lont7,lant7
;plots,lont8,lant8

x=cos(lant*!pi/180)*cos(lont*!pi/180)
y=cos(lant*!pi/180)*sin(lont*!pi/180)
z=sin(lant*!pi/180)


an=25*!pi/180

xp=x
yp=y*cos(an)-z*sin(an)
zp=x*sin(an)+z*cos(an)

lantp=asin(zp)*180/!pi
lontp=atan(yp/xp)*180/!pi

for i=0,24 do if lontp(i) LT 0 then lontp(i)=lontp(i)+180
;plots,lontp,lantp
;print,lantp,lontp
;plots,-lontp,lantp


end
