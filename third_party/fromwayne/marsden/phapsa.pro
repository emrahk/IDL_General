pro phapsa,noplot,iarr=iarr
;**************************************************************
; program phapsa. Program governs the interaction between the
; phapsa widget (wphapsa.pro) and the event manager
; (wphapsa_event.pro). Variables are:
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;      accum.................accumulation option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accum
;     counts.................1 idf counts(position,det,psachns,chn)
;      lvtme.................1 idf livetime(position,det,psachns)
;   a_counts.................accumulated counts(position,det,chn)
; a_livetime.................accumulated livetime(position,det)
;  idfs,idfe.................idf start,stop #s for accum.
;        dts.................start,date,time array
;         dt.................start,stop date,time array
;    psachns.................# of pulse shape channels
;    phachns.................# of pulse height channels
;   num_dets.................# detectors
;       disp.................show 1 idf(0) or accumulated(1)
;        plt.................plotting option(surface,shade_surf,slice)
;  chn_slice.................slice in psa/pha space to plot
;      start.................first time(0) or repeat(1)
;        new.................new file(1) or not(0)
;      clear.................clear variable arrays if defined
;       colr.................color table value
;       fnme.................filename for storage
;        typ.................type of data set
;       iarr.................Array of idfs processed
;       wait.................if activated wait an idf
;     noplot.................if defined, no plotting
;  idf_lvtme.................array of livetimes
;  clstr_pos.................cluster position vs livetime array
; Common blocks:
;  pev_block.................between phapsa and wphapsa event manager
; First define common block and define default values:
;***********************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme,idf_lvtme,clstr_pos
common phapsa_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
;***************************************************************************
; Return if waiting, else begin
;***************************************************************************
if (wait)then begin
   wait = 0
   return
endif
if (ks(dc) eq 0)then dc = 'DET1'
if (ks(det) eq 0)then det = 1
if (ks(cp) eq 0)then cp = '0 (FOR +/- 1.5 DEG)'
if (ks(opt) eq 0)then opt = 5
if (ks(dts) eq 0)then dts = ['0','0']
if (ks(disp) eq 0)then disp = 0
if (ks(accum) eq 0)then accum = 0
if (ks(plt) eq 0)then plt = 0
if (ks(chn_slice) eq 0)then chn_slice = [5,5]
if (ks(colr) eq 0)then colr = 3
if (keyword_set(iarr) eq 0)then iarr = 0
if (ks(fnme) eq 0)then fnme = ''
;**********************************************************************
; Read headers for the sizes of the data arrays and the
; beginning idf #. also get start date,time. For initial
; plot plot detector1
;**********************************************************************
if (clear)then begin
   start = 1
   idf = 0
   spectra(*,*,*) = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
   lvtme(*,*) = 0. & a_lvtme(*,*) = 0.
   clear = 0
endif
if (start)then begin
   idfs = idf
   start = 0
   dt = strarr(2,2)
   dt(0,*) = [strmid(date,0,9),strmid(date,10,18)]
   dt(1,*) = dt(0,*)
   psachns = n_elements(spectra(0,*,0))
   phachns = n_elements(spectra(0,0,*))
   num_dets = n_elements(spectra(*,0,0))
   counts = lonarr(4,num_dets,psachns,phachns)
   a_lvtme = fltarr(4,num_dets) & lvtme = a_lvtme
   counts = reform(counts,4,num_dets,psachns,phachns)
   a_counts = counts
   idf_lvtme = fltarr(4,num_dets,1)
endif
dt(1,*) = [strmid(date,0,9),strmid(date,10,18)]
;**************************************************************************
; Accumulate counts and livetime, and form arrays according to
; cluster position. The accumulated counts and livetimes
; are summed over idf range given by idfs,idfe. First must check
; if the current data set is compatible with the previous array dimensions
; 4/29/94 Include extra dimension in arrays by request.
; 5/25/94 Documentation added:
; Idf_hdr.nd indicates the bin size and is either 1 (hi-res) or 2 (low res)
; Idf_hdr.nc indicates the detector number if in hi-res mode           
;**************************************************************************
if (new)then begin
   psachns_ = n_elements(spectra(0,*,0))
   phachns_ = n_elements(spectra(0,0,*))
   num_dets_ = n_elements(spectra(*,0,0))
endif else begin
   psachns_ = psachns
   phachns_ = phachns
   num_dets_ = num_dets
endelse
idfe = idf
nidf_old = n_elements(idf_lvtme(0,0,*))
nidf = idfe - idfs + long(1)
if (phachns_ eq phachns and psachns_ eq psachns and num_dets_ eq num_dets)$
then begin
   newsave = new
   cp = idf_hdr.clstr_postn
   if(cp eq '0 (FOR +/- 3.0 DEG)' or cp eq '0 (FOR +/- 1.5 DEG)') $
   then cp_ndx = 2
   if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
   if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
;*************************************************************************
; If new idf accumulate
; 5/29/94 Eliminate one loop for speed
;*************************************************************************
   if (new)then begin
      if (idf_hdr.nd eq 1)then begin
         a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + livetime(idf_hdr.nc)
         a_lvtme(3,*) = a_lvtme(3,*) + livetime(idf_hdr.nc)
      endif else begin
         a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + livetime
         a_lvtme(3,*) = a_lvtme(3,*) + livetime
      endelse
      a_counts(cp_ndx,*,*,*) = a_counts(cp_ndx,*,*,*) + spectra
      a_counts(3,*,*,*) = a_counts(3,*,*,*) + spectra
;************************************************************************
; Accumulate livetime vs idf
;************************************************************************
      idf_lvtme_new = fltarr(4,num_dets,nidf)
      if (num_dets ne 1)then begin
         idf_lvtme_new(cp_ndx,*,nidf-1) = livetime
         idf_lvtme_new(3,*,nidf-1) = livetime
         if (nidf ne 1)then idf_lvtme_new(*,*,0:nidf_old-1) = idf_lvtme
      endif else begin
         tt = total(livetime)/n_elements(livetime)
         if (nidf eq 1)then begin
            idf_lvtme_new(cp_ndx,nidf-1) = tt
            idf_lvtme(3,nidf-1) = tt
         endif else begin
            idf_lvtme_new(cp_ndx,0,nidf-1) = tt
            idf_lvtme_new(3,0,nidf-1) = tt
            idf_lvtme_new(*,0,0:nidf_old-1) = idf_lvtme
         endelse
      endelse
      idf_lvtme = idf_lvtme_new
;************************************************************************
; Append the cluster postion and IDF arrays. If there's a 
; discontinuity in the latest IDF entry, fill the gap with 
; a zero for the missing idf and a '-10' for the missing 
; cluster position.
;************************************************************************
      if (newsave)then begin
         if (ks(clstr_pos) eq 0) then clstr_pos = cp else $
         clstr_pos = [clstr_pos,cp]
         if (ks(iarr) eq 0)then iarr = idf else iarr = [iarr,idf]
         len  = n_elements(iarr)
         if (len ne 1)then begin
            if (iarr(len-2) ne iarr(len-1)-1l)then begin
               del = iarr(len-1) - iarr(len-2) - 1
               isub = lonarr(del)
               csub = string(isub - 10)
               iarr = [[iarr(0:len-2),isub],idf]
               clstr_pos = [[clstr_pos(0:len-2),csub],cp]
            endif
         endif
      endif
      if (total(iarr) ne 0)then begin
         idfs = iarr(0)
         idfe = max(iarr)
      endif
   endif
;************************************************************************
; Select arrays for current parameters
;************************************************************************
   counts(cp_ndx,*,*,*) = spectra & counts(3,*,*,*) = spectra
   if (idf_hdr.nd eq 1)then begin
      lvtme(cp_ndx,*) = livetime(idf_hdr.nc)
   endif else begin
      lvtme(cp_ndx,*) = livetime
   endelse    
   rates0 = fltarr(num_dets,psachns,phachns) & rates1 = rates0 
   brate = fltarr(psachns,phachns)
   sbrate = brate
;************************************************************************
; idf_hdr.nd gives whether its low res (all dets) or 
; individual detector (high res).
;************************************************************************
   if (idf_hdr.nd eq 1) then begin
      dc = strcompress('DET' + string(idf_hdr.nc + 1),/remove_all)
      det_str = strarr(1)
      det_str(0) = strcompress('DET' + string(idf_hdr.nc + 1))
      det = 1
   endif else begin
      det_str = strcompress('DET' + $
      string(indgen(num_dets+1)+1),/remove_all)
      det_str(num_dets) = ' DET SUM'
      det_ = where(dc eq det_str)
      det = det_(0) + 1
   endelse
;**************************************************************************
; Start update loop where user can change displayed values.
;**************************************************************************
   for i = 0,num_dets - 1 do begin
    if(opt eq 1)then begin
;***************************************************************************
; on - sum off rates (NET ON). This only works for accum mode
;***************************************************************************
       if (a_lvtme(2,i) ne 0. and total(a_lvtme(0:1,i)) ne 0.) $
        then begin
          sbrate = a_counts(2,i,*,*)/a_lvtme(2,i)
          tbcts = a_counts(0,i,*,*) + a_counts(1,i,*,*)
          tbtme = total(a_lvtme(0:1,i))
          brate(*,*) = tbcts/tbtme
          rates1(i,*,*) = sbrate - brate
       endif else begin
          rates1(i,*,*) = 0.
       endelse
       if (disp eq 0)then rates0(i,*,*) = 0. 
    endif
    if(opt eq 2)then begin
;***************************************************************************
; off(+) - off(-) (NET OFF). This only works for accum mode
;***************************************************************************
       if(a_lvtme(0,i) ne 0. and a_lvtme(1,i) ne 0.) then begin
          brate1 = a_counts(0,i,*,*)/a_lvtme(0,i)
          brate2 = a_counts(1,i,*,*)/a_lvtme(1,i)
          rates1(i,*,*) = brate1 - brate2
       endif else begin
          rates1(i,*,*) = 0.
       endelse
       if (disp eq 0)then rates0(i,*,*) = 0.
    endif
    if (opt gt 2)then begin
;***************************************************************************        ; single orientation
;***************************************************************************
       op = opt - 3
       if(lvtme(op,i) ne 0.)then begin
          rates0(i,*,*) = counts(op,i,*,*)/lvtme(op,i)
       endif else begin
          rates0(i,*,*) = 0.
       endelse
       op = opt - 3
       if (a_lvtme(op,i) ne 0.)then begin
          rates1(i,*,*) = a_counts(op,i,*,*)/a_lvtme(op,i)    
       endif else begin
          rates1(i,*,*) = 0.
       endelse
    endif
   endfor
;*************************************************************************
; user selected data
;*************************************************************************
   select_p
endif
;*************************************************************************
; Call plotting routine
;*************************************************************************
if (ks(noplot) eq 0)then wphapsa          
;*************************************************************************
; Thats all folks
;*************************************************************************
return
end
