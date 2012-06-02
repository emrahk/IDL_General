pro gdhm2_4

E=2*(-0.337)
R=0.14
ind=findgen(51)/100.-0.5
xdot=0
ydot=sqrt(-0.674-alog(0.0196+(ind^2)/1.21)-xdot^2)
plot,ind,ydot
for i=0,75 do begin
    xdot=0.0+i*0.03
    print,xdot
    ydot=sqrt(E-alog(R^2+(ind^2)/0.81)-xdot^2)
    oplot,ind,ydot
endfor
end
