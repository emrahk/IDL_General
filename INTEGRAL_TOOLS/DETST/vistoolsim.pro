pro vistoolsim,chi2,ps=ps,file=file

;this program takes the chi2 map as an input and plots this as a nice
;way on the SPI drawing. This version has no differentiation of which
;detector hit first.

if (NOT keyword_set(ps)) THEN ps=0
if (NOT keyword_set(file)) THEN file='vistoolsimwij.ps'


if ps eq 1 then begin
  set_plot,'ps'
  device,filename=file
  device,/color
  loadct,5
  device,ysize=14.
  device,xsize=15.
endif


mapx=[[1,2,3,4,5,6],[8,9,2,0,6,7],[9,10,11,3,0,1],[2,11,12,13,4,0],$
[0,3,13,14,15,5],[6,0,4,15,16,17],[7,1,0,5,17,18],[100,8,1,6,18,100],$
[100,100,9,1,7,100],[100,100,10,2,1,8],[100,100,100,11,2,9],$
[10,100,100,12,3,2],[11,100,100,100,13,3],[3,12,100,100,14,4],$
[4,13,100,100,100,15],[5,4,14,100,100,16],[17,5,15,100,100,100],$
[18,6,5,16,100,100],[100,7,6,17,100,100]]

plot,[0.,0.],[0.,0.],xr=[-20.,20.],yr=[-20.,20.],$
xtickname=replicate(' ',5),ytickname=replicate(' ',5),ticklen=0.


st=5.196153

coord=[[0.,0.],[6.,0.],[3.,st],[-3.,st],$
       [-6.,0.],[-3.,-st],[3.,-st],[9.,-st],$
       [12.,0.],[9.,st],[6.,2.*st],[0.,2.*st],[-6.,2.*st],$
       [-9.,st],[-12.,0.],[-9.,-st],[-6.,-2.*st],$
       [0.,-2.*st],[6.,-2.*st]]


num=0.
totchi2=0.

for i=0,18 do xyouts,coord[0,i]-.3,coord[1,i]-.2,strtrim(string(i),1)


rad=3.23476


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
     col1=256-(floor(chi2(i,j))*2)-55
     if col1 lt 0 then col1=0
     if mapx(j,i) ne 100 then begin
        num=num+1.
        totchi2=totchi2+chi2(i,j)
        ind=where(mapx(*,mapx(j,i)) eq i)
        col2=256-(floor(chi2(mapx(j,i),ind(0)))*2)-55
        if col2 lt 0 then col2=0
        col=(col1+col2)/2
    endif else col=255
    
 ;    print,i,j,ind
     rad=3.232

     polyfill,coord[0,i]+[(rad/2.)*cos(ang),rad*cos(ang),rad*cos(ang-(!PI/3.)),(rad/2.)*cos(ang-(!PI/3.))],coord[1,i]+[(rad/2.)*sin(ang),rad*sin(ang),rad*sin(ang-(!PI/3.)),(rad/2)*sin(ang-(!PI/3.))],color=col
   endfor

endfor

x=indgen(256)
for j=0,255 do boxc,(j-128)*36./256,-16.,(j-127)*36./256,-18.,255-j
xyouts,(20-128)*36/256.,-19.0,'Chi^2:'
xyouts,(50-128)*36./256.,-19.0,'0'
xyouts,(95-128)*36./256.,-19.0,'25'
xyouts,(145-128)*36./256.,-19.0,'50'
xyouts,(195-128)*36./256.,-19.0,'75'
xyouts,(240-128)*36./256.,-19.0,'100'

xyouts,-19,-15,'Red. chi^2='+strtrim(string(totchi2/num),1)


;IBIS and JEM-X

xyouts,-3,17.7,'IBIS',size=2.5,charthick=3.
arrow,0.,14.,0.,16.5,/data,thick=4

;jems circles
r=5.5
tet=findgen(100)*!PI/50.
x=r*cos(tet)
y=r*sin(tet)
oplot,11+x,19.5+y
xyouts,8.2,17,'JMX 1',size=1.5,charthick=2.
oplot,-11+x,19.5+y
xyouts,-14.2,17,'JMX 2',size=1.5,charthick=2.

if ps eq 1 then begin
   device,/close
   set_plot,'x'
endif


end
