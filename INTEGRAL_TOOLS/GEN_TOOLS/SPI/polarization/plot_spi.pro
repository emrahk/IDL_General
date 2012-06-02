pro plot_spi

st=5.196153

coord=[[0.,0.],[6.,0.],[3.,st],[-3.,st],$
       [-6.,0.],[-3.,-st],[3.,-st],[9.,-st],$
       [12.,0.],[9.,st],[6.,2.*st],[0.,2.*st],[-6.,2.*st],$
       [-9.,st],[-12.,0.],[-9.,-st],[-6.,-2.*st],$
       [0.,-2.*st],[6.,-2.*st]]


rad=3.23476

for i=0,18 do begin

oplot,[rad*cos(!PI/6.),0.]+coord[0,i],[rad*cos(!PI/3.),rad]+coord[1,i]
oplot,[0.,-rad*cos(!PI/6.)]+coord[0,i],[rad,rad*cos(!PI/3.)]+coord[1,i]
oplot,[-rad*cos(!PI/6.),-rad*cos(!PI/6.)]+coord[0,i],[rad*cos(!PI/3.),-rad*cos(!PI/3.)]+coord[1,i]
oplot,[-rad*cos(!PI/6.),0.]+coord[0,i],[-rad*cos(!PI/3.),-rad]+coord[1,i]
oplot,[0.,rad*cos(!PI/6.)]+coord[0,i],[-rad,-rad*cos(!PI/3.)]+coord[1,i]
oplot,[rad*cos(!PI/6.),rad*cos(!PI/6.)]+coord[0,i],[-rad*cos(!PI/3.),rad*cos(!PI/3.)]+coord[1,i]

endfor

end
