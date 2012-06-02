pro net_off,a_counts,a_lvtme,rates,trates,prs=prs
;******************************************************************
; Program calculates net off source rate, defined as off(+) 
; minus off(-).
; Input variables:
;	a_counts..............accumulated counts array
;        a_lvtme..............     "     livetime  "
;            prs..............phase resolved spectroscopy flag
; Output variables:
;          rates..............array of rates/detector
;         trates..............total rates/detector
;            sig..............sigma for each channel 
; First the common block:
;*****************************************************************
common netoff,sig           
;*****************************************************************
; Now begin program
;*****************************************************************
if (ks(prs) ne 0)then begin
   num_dets = 1 
   blvtme_plus = reform(a_lvtme(0,*,*))
   blvtme_minus = reform(a_lvtme(1,*,*))
   num_chns = n_elements(a_counts(0,0,0,*))
   num_spec = n_elements(a_counts(0,0,*,0))
   rates = fltarr(num_dets,num_spec,num_chns)
   trates = fltarr(num_dets,num_spec)
   tbrate = fltarr(num_spec)
   tsbrate = fltarr(num_spec)
endif else begin
   num_dets = n_elements(a_lvtme(0,*))
   blvtme_plus = reform(a_lvtme(0,*,*))
   blvtme_minus = reform(a_lvtme(1,*))
   num_chns = n_elements(a_counts(0,0,*)) 
   rates = fltarr(num_dets,num_chns)
   trates = fltarr(num_dets)
endelse
sig = rates
chans = replicate(1.,num_chns)
if (ks(num_spec) eq 0)then begin
;*********************************************************************
; First do the case of *not* phase resolved spec.
;*********************************************************************
   for i = 0,num_dets-1 do begin
    if (blvtme_minus(i) ne 0. and blvtme_plus(i) ne 0.)then begin
       brate1 = a_counts(0,i,*)/blvtme_plus(i)
       sig1 = sqrt(a_counts(0,i,*))/blvtme_plus(i)
       tbrate1 = total(brate1)
       brate2 = a_counts(1,i,*)/blvtme_minus(i)
       sig2 = sqrt(a_counts(1,i,*))/blvtme_minus(i)
       tbrate2 = total(brate2)
       sig(i,*) = sqrt(sig1^2 + sig2^2)
       rates(i,*) = brate1 - brate2
       trates(i) = tbrate1 - tbrate2
    endif
   endfor
endif else begin
;*********************************************************************
; Now for the phase-resolved stuff. 
;*********************************************************************
   in = where(blvtme_plus ne 0. and blvtme_minus ne 0.,q)
   if (in(0) ne -1)then begin
      blvtme_m = blvtme_minus(in)#chans
      blvtme_p = blvtme_plus(in)#chans
      brate1 = a_counts(0,0,in,*)/blvtme_p
      sig1 = sqrt(a_counts(0,0,in,*))/blvtme_p
      brate2 = a_counts(1,0,in,*)/blvtme_m
      sig2 = sqrt(a_counts(1,0,in,*))/blvtme_m
      rates(0,in,*) = brate1 - brate2
      sig(0,in,*) = sqrt(sig1^2 + sig2^2)
      trates = total(rates,3)
   endif
endelse
;*****************************************************************
; Thats all ffolks
;*****************************************************************
return
end
