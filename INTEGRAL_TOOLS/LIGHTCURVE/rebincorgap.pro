pro rebincorgap,time,gpbin,rebinarr

;for 1s bins for now
maxs=floor(max(time)-time(0))
rebinarr=fltarr(maxs)
;gpbin=gpbin-0.005
for i=0,maxs-1 do begin
   tst=float(i)
   tend=float(i+1)
   cin=n_elements(where((time ge tst) and (time lt tend)))
   rebinarr(i)=cin*(1./(1.-gpbin(i)))
endfor

end
