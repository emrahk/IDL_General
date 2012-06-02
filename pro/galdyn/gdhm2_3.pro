pro gdhm2_3

E=2*(-0.337)
R=0.14
ind=findgen(51)/100.-0.5
xdot=0
ydot=sqrt(-0.674-0.8*alog(0.0196+(ind^2)/0.81)-xdot^2)
plot,ind,ydot,yrange=[-2.,2.]
for i=0,50 do begin
    xdot=0.0+i*0.03
    print,xdot
    ydot=sqrt(E-alog(R^2+(ind^2)/0.81)-xdot^2)
    oplot,ind,ydot
endfor
end
