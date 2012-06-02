pro cov_l,lo,la,an
map_set,lo,la,an,/ortho,/isotropic,/grid,/label


lp=findgen(51)
lont=atan(sin(50*!pi/180)/sin(lp*!pi/180))*180/!pi
lant=90-acos(cos(50*!pi/180)*cos(lp*!pi/180))*180/!pi
plots,lont,lant
plots,-lont,lant
plots,lont+180,lant
plots,-lont+180,lant
;print,lont,lant

lp=findgen(51)
lont=atan(sin(lp*!pi/180)/sin(50*!pi/180))*180/!pi
lant=90-acos(cos(50*!pi/180)*cos(lp*!pi/180))*180/!pi
plots,lont,lant
plots,-lont,lant
plots,lont+180,lant
plots,-lont+180,lant

lant=90-findgen(51)
lont=fltarr(51)
for i=0,50 do lont(i)=90
plots,lont,lant
plots,-lont,lant
plots,lont+90,lant
plots,-lont+90,lant


end
