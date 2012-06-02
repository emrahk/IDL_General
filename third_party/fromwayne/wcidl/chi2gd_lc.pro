pro chi2gd_lc, time, counts, prange, period, chi2, periods=xord, nper=nperiods

szt=size(time)
sz=szt(1)

if (keyword_set(nperiods) eq 0) then nperiods=20.d
nperiods=nperiods+1.d

chi2=dblarr(nperiods)
xord=dblarr(nperiods)

binsize=(prange(1)-prange(0))/(nperiods-1.d)

fold_time_arr,time,counts,period,baseflc,nph=15
for i=0.0d,nperiods-1.0d do begin
   pr=prange(0) + i*binsize
   xord(i)=pr
   fold_time_arr,time,counts,pr,flc,nph=15
   chi2(i)=total((flc-baseflc)^2/baseflc)
endfor

return
end
