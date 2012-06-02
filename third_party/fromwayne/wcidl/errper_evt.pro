pro errper_evt, time, period, prange, chi2, periods=xord,nperiods=nper

;;
;;
if (n_params() eq 0)then begin
   print,'USAGE : errper_evt,times,period,prange,chi2,[periods=],[nperiods=]'
   print,' '
   print,'INPUTS:'
   print,'   times : array of event times'
   print,'   period: pulsation period'
   print,'   prange: 2-D array specifying search range'
   print,'OUTPUTS:'
   print,'   chi2:   Array of chi-squared statistics'
   print,' '
   print,'OPTIONAL INPUTS:'
   print,'   nperiods: Number of steps in prange (default 20)'
   print,'OPTIONAL OUTPUTS:'
   print,'   periods:  Array of periods corresponding to chi2'
   print,' '
   return
endif
;;
;;

szt=size(time)
sz=szt(1)

if (keyword_set(nper) eq 0) then nper = 20.0d

chi2=dblarr(nper+1)
xord=dblarr(nper+1)

binsize=(max(prange)-min(prange))/nper

fold_evt_arr,time,period,15,baseflc
for i=0.0d,nper do begin
   pr=min(prange) + i*binsize
   fold_evt_arr,time,pr,15.d,flc
   xord(i)=pr
   chi2(i)=total((flc-baseflc)^2.d/flc)
endfor

return
end

;;
;;fin
;;

