pro fold_evt_arr,evt_time,per,nbns,phz_arr,pdot=pdot,$
                  ppdot=ppdot,del=del,fdot=fdot,ffdot=ffdot,$
                   ph=ph
;************************************************************
; Program folds a photon event time array on a given 
; period. Variables are:
;       evt_time...............photon arrival times (s)
;            per...............period to fold
;           nbns...............number of bins/period
;        phz_arr...............counts/phase array
;           pdot...............1st period derivative
;          ppdot...............2nd period derivative
;           fdot...............first frequency derivative
;          ffdot...............second frequency derivative
;             ph...............phase shift
; Uses program frac_phase.pro
; First do usage:
;************************************************************
if (n_params() eq 0)then begin
   print,'USE : FOLD_EVT_ARR,EVT_TIME,PER,NBNS,' + $
          'PHZ_ARR,[PDOT=],[PPDOT=],[DEL=],[FDOT=],' + $
           '[FFDOT=],[ph=(phase shift)]'
   return
endif
;************************************************************
; Set some variables
;************************************************************
dnbns = double(nbns)
;************************************************************
; Get the fractional phase to order pdot and ppdot.
;************************************************************
if (ks(pdot) eq 0)then pdot = 0d
if (ks(ppdot) eq 0)then ppdot = 0d
if (ks(ph) eq 0)then ph = 0d
p = double(per)
pd = double(pdot) & pdd = double(ppdot)
f = 1d/p
frac_phase,f,evt_time,frac_phz,pd=pd,pp=pdd,fd=fdot,$
           ff=ffdot,ph=ph
;ntmes = n_elements(evt_time)
;************************************************************
; Loop (not) through the phase bins
;************************************************************
phz_arr = histogram(frac_phz,bi=1d/dnbns,min=0d,max=1d)
tph = phz_arr
phz_arr = phz_arr(0:nbns-1)
;stop
;************************************************************
; Thats all ffolks
;************************************************************
return
end 

