pro net_on,a_counts,a_lvtme,rates,trates,prs=prs
;*********************************************************************
; Program calculates net on source rate
; Input variables:
;	a_counts..............accumulated counts array
;        a_lvtme..............     "     livetime  "
;            prs..............phase resolved spectroscopy flag
; Output variables:
;          rates..............array of rates/detector
;         trates..............total rates/detector
; Set up variables:
;*********************************************************************
if (ks(prs) ne 0)then begin
   num_dets = 1 
   src_lvtme = reform(a_lvtme(2,*,*))
   bkg_lvtme = total(a_lvtme(0:1,*,*))
   num_chns = n_elements(a_counts(0,0,0,*))
   num_spec = n_elements(a_counts(0,0,*,0))
   rates = fltarr(num_dets,num_spec,num_chns)
   trates = fltarr(num_dets,num_spec)
   tbrate = fltarr(num_spec)
   tsbrate = fltarr(num_spec)
endif else begin
   num_dets = n_elements(a_lvtme(0,*))
   src_lvtme = reform(a_lvtme(2,*))
   bkg_lvtme = total(a_lvtme(0:1,*),1)
   num_chns = n_elements(a_counts(0,0,*)) 
   rates = fltarr(num_dets,num_chns)
   trates = fltarr(num_dets)
endelse
chans = replicate(1.,num_chns)
if (ks(num_spec) eq 0)then begin
;*********************************************************************
; First do the case of *not* phase resolved spec.
;*********************************************************************
   for i = 0,num_dets-1 do begin
    if (src_lvtme(i) ne 0. and bkg_lvtme(i) ne 0.)then begin
       sbrate = 0. & brate = 0.
       sbrate = reform(a_counts(2,i,*)/src_lvtme(i),num_chns)
       brate = (a_counts(0,i,*)+a_counts(1,i,*))/bkg_lvtme(i)
       brate = reform(brate,num_chns)
       tbrate = total(a_counts(0:1,i,*))/bkg_lvtme(i)
       tsbrate = total(a_counts(2,i,*))/src_lvtme(i)    
       trates(i) = tsbrate - tbrate
       rates(i,*) = sbrate - brate
    endif
   endfor
endif else begin
;*********************************************************************
; Now for the phase resolved stuff. 
;*********************************************************************
   sbrate = fltarr(num_spec,num_chns) & brate = sbrate 
   in = where(src_lvtme ne 0. and bkg_lvtme ne 0.,q)
   if (in(0) ne -1)then begin
      lvsrc = src_lvtme(in)#chans
      lvbkg = bkg_lvtme(in)#chans
      sbrate(in,*) = a_counts(2,0,in,*)/lvsrc
      brate(in,*) = (a_counts(0,0,in,*)+a_counts(1,0,in,*))/lvbkg
      rates(0,*,*) = sbrate - brate
      trates(0,*) = total(sbrate - brate,2)
   endif
endelse
;*********************************************************************
; Thats all ffolks
;*********************************************************************
return
end
