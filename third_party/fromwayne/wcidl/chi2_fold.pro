pro chi2_fold,counts,time,prange,chi2,nperiods=nperiods,$
              periods=periods,nbins=nbins,dof=dof,silent=silent,$
              pdot=pdot,ppdot=ppdot
;*******************************************************************
; Program folds a light curve on a range of periods, 
; and calculates for each folded light curve chi-squared 
; versus a constant signal. The variables are:
;     counts.........array of counts versus time
;       time.........array of time bins
;     prange.........[min,max] period to search (s)
;       chi2.........chi-squared vs period
;   nperiods.........# of periods searched in prange
;    periods.........Centers of period bins
;      nbins.........# of phase bins in flc
;        dof.........# of degrees of freedom
;     silent.........No printouts
;       pdot.........1st period derivative
;      ppdot.........2nd period derivative
; Requires program fold_time_arr.pro
; First do usage:
;********************************************************************
if (n_elements(counts) eq 0)then begin
   print,'USAGE: chi2_fold,counts,time,prange,chi2,' + $
         '[nperiods=# periods in prange (20)],[periods=periods],' + $
         '[nbins=# phase bins in flc (10)],[pdot=(0)],[ppdot=(0)]' + $
         '[dof=# degrees of freedom],[silent=(boolean)]'
   return
endif
;********************************************************************
; Set some variables
;********************************************************************
if (n_elements(nperiods) eq 0)then nperiods = 20d else $
nperiods = double(nperiods)
prange = double(prange)
if (n_elements(nbins) eq 0)then nbins = 10
dp = (max(prange) - min(prange))
periods = min(prange) + dp*dindgen(nperiods)/(nperiods-1d) + $
          dp/(2d * nperiods)
chi2 = fltarr(nperiods)
dof = nperiods - 1
;********************************************************************
; Start the loop. First get the folded light curve.
;********************************************************************
for i = 0,nperiods - 1 do begin
   if (n_elements(silent) eq 0)then print,$
   'Folding period ',periods(i)
   fold_time_arr,time,counts,periods(i),flc,np=nbins,pd=pdot,pp=ppdot
;********************************************************************
; Calculate the mean, error and chi-squared.
;********************************************************************
   avg = float(total(flc))/float(nbins)
   chi2(i) = total((float(flc)-avg)^2./float(flc))
endfor
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end 
