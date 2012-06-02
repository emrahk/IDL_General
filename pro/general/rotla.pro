function rotla,longi,lati
x=sin((90-lati)*!pi/180)*cos(longi*!pi/180)
y=sin((90-lati)*!pi/180)*sin(longi*!pi/180)
z=cos((90-lati)*!pi/180)
xx=x*cos(!pi/3)+z*sin(!pi/3)
yy=y
zz=-x*sin(!pi/3)+z*cos(!pi/3)
return,90-acos(zz)*180/!pi
end
