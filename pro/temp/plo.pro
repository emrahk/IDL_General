pro plo
loadct,6
map_set,0,0,0,/aitoff,/isotropic
openr,1,'/home/ek/coverage/tam'
ar=fltarr(3,65160)
readf,1,ar
close,1

plots,0.0,-90.0
;for la=0,90 do plots,358.0,-90.0+la,color=50+floor(la*144.0/90.0),/continue
;for la=0,90 do plots,359.0,-90.0+la,color=50+floor(la*144.0/90.0),/continue
;for la=0,90 do plots,1.0,-90.0+la,color=50+floor(la*144.0/90.0),/continue
;for la=0,90 do plots,2.0,-90.0+la,color=50+floor(la*144.0/90.0),/continue
for la=0,90 do plots,0.0,-90.0+la,color=50+floor(la*144.0/90.0),/continue



plots,0.0,0.0
for lat=0,44 do for lon=1,179 do begin
plots,2*lon,2*lat,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
plots,2*lon,2*lat+1,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
plots,2*lon-2,2*lat+1,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
plots,2*lon-2,2*lat+2,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
plots,2*lon,2*lat+2,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
plots,2*lon,2*lat,color=50+(ar(2,91*(2*lon+1)+2*lat+1)-100.0),/continue
endfor




end
