 pro make_hist,typ,spectra
;********************************************************************
; Program packages the latest idf events list
; data arrays into histogram bin data arrays 
;    spectra.................spectra
;        typ.................'EVTs'--> 'HSTs'
; Control variables:
;       prms.................histogram binning parameters
;      burst.................Burst data if defined
;        num.................Number of good events array
; Requires program get_evt.pro
; First define the common blocks:
;********************************************************************
common evt_parms,prms,prms_save,burst
common nai,arr,nai_only
common save_block,spec_save,idf_save,wait,num
;********************************************************************
; Set some variables
;********************************************************************
typ = 'HSTs'
nbns = long(256./prms(0))
spec = lonarr(4,1,nbns)
num = fltarr(4)
;********************************************************************
; Form latest idf histogram spectral array
;********************************************************************
get_evt,spectra,pha,j1,j2,det_id,j3,j4,psa,j5,psuld,bu=burst
spectra = lonarr(4,1,nbns)
if (ks(psa) eq 0)then begin
   psa = replicate(15,n_elements(pha))
   psuld = psa
endif
if (ks(nai_only) ne 0)then begin
   if (ks(arr) eq 0)then get_nai,arr
   arr2 = reform(arr(0,*,*))
   nai_arr = arr2(psa,pha)
endif else nai_arr = j1 ge 0.
in = where(nai_arr ne 0)
if (in(0) ne -1)then begin
   psa = temporary(psa(in))
   pha = temporary(pha(in))
   det_id = temporary(det_id(in))
   psuld = temporary(psuld(in))
endif
a = psa ge prms(1) and psa le prms(2)
nm = float(nbns)*prms(0)-1.
for i = 0,3 do begin
 foo = where(det_id eq i,temp)
 num(i) = float(temp)
 case prms(3) of
    0 : d = where(det_id eq i and psuld eq 0 and a)
    1 : d = where(det_id eq i and psuld eq 1 and a)
    2 : d = where(det_id eq i and a)
 endcase 
 if (d(0) ne -1)then $
 spectra(i,0,*) = histogram(pha(d),mi=0,ma=nm,bi=prms(0))
endfor
;********************************************************************
; Thats all ffolks
;********************************************************************
return
end
