pro vistoolmult,dis,ps=ps,file=file


;;this program takes the chi2 map as an input and plots this as a nice
;;way on the SPI drawing. This version differentiates between which
;;detector hit first 

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(file)) THEN file='vistoolmult.ps'



if ps eq 1 then begin
  set_plot,'ps'
  device,filename=file
  device,/color
  loadct,5
  device,ysize=14.
  device,xsize=15.
endif

plot,[0.,0.],[0.,0.],xr=[-20.,20.],yr=[-20.,20.]


st=5.196153

coord=[[0.,0.],[6.,0.],[3.,st],[-3.,st],$
       [-6.,0.],[-3.,-st],[3.,-st],[9.,-st],$
       [12.,0.],[9.,st],[6.,2.*st],[0.,2.*st],[-6.,2.*st],$
       [-9.,st],[-12.,0.],[-9.,-st],[-6.,-2.*st],$
       [0.,-2.*st],[6.,-2.*st]]


for i=0,18 do xyouts,coord[0,i]-.2,coord[1,i]-.2,strtrim(string(i),1)


rad=3.23476
num=0.
redis=dis*200./max(dis)

for i=0,18 do begin
  rad=3.23476
  oplot,[rad*cos(!PI/6.),0.]+coord[0,i],[rad*cos(!PI/3.),rad]+coord[1,i]
oplot,[0.,-rad*cos(!PI/6.)]+coord[0,i],[rad,rad*cos(!PI/3.)]+coord[1,i]
oplot,[-rad*cos(!PI/6.),-rad*cos(!PI/6.)]+coord[0,i],[rad*cos(!PI/3.),-rad*cos(!PI/3.)]+coord[1,i]
oplot,[-rad*cos(!PI/6.),0.]+coord[0,i],[-rad*cos(!PI/3.),-rad]+coord[1,i]
oplot,[0.,rad*cos(!PI/6.)]+coord[0,i],[-rad,-rad*cos(!PI/3.)]+coord[1,i]
oplot,[rad*cos(!PI/6.),rad*cos(!PI/6.)]+coord[0,i],[-rad*cos(!PI/3.),rad*cos(!PI/3.)]+coord[1,i]
   for j=0,5 do begin
     ang=(!PI/6.)+(j*(!PI/3.))
     if redis(i,j) ne 0. then begin
        num=num+1
        col=256-(floor(redis(i,j)))-55
        if col lt 0 then col=0
    endif else col=255
      
;     print,i,j,ind
     rad=3.232


     polyfill,coord[0,i]+[(rad/2.)*cos(ang),rad*cos(ang),rad*cos(ang-(!PI/3.)),(rad/2.)*cos(ang-(!PI/3.))],coord[1,i]+[(rad/2.)*sin(ang),rad*sin(ang),rad*sin(ang-(!PI/3.)),(rad/2)*sin(ang-(!PI/3.))],color=col
   endfor

endfor

x=indgen(256)
for j=0,255 do boxc,(j-128)*36./256,17.,(j-127)*36./256,19.,255-j
xyouts,(50-128)*36./256.,15,'0%'
xyouts,(95-128)*36./256.,15,'25%'
xyouts,(145-128)*36./256.,15,'50%'
xyouts,(195-128)*36./256.,15 ,'75%'
xyouts,(240-128)*36./256.,15,'100% max'

;xyouts,-16,-17,'Red. chi^2='+strtrim(string(totchi2/num),1)


if ps eq 1 then begin
   device,/close
   set_plot,'x'
endif


end
