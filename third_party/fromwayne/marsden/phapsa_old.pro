pro phapsa
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
;       wait.................if activated wait an idf
; Common blocks:
;  pev_block.................between phapsa and wphapsa event manager
; First define common block and define default values:
; 5/11/94 Eliminate 'Update' variable
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; First define common block and define default values:
;***********************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme
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
if (ks(fnme) eq 0)then fnme = ''
;**********************************************************************
; Read headers for the sizes of the data arrays and the
; beginning idf #. also get start date,time. For initial
; plot plot detector1
;**********************************************************************
if (clear)then begin
   print,'CLEARING ARRAYS!!'
   start = 1
   idf = 0
   spectra(*,*,*) = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
   lvtme(*,*,*) = 0 & a_lvtme(*,*) = 0
   clear = 0
endif
if (start)then begin
   idfs = idf
   start = 0
   dt = strarr(2,2)
   dt(0,*) = [strmid(date,0,9),strmid(date,11,18)]
   dt(1,*) = dt(0,*)
   psachns = n_elements(spectra(0,*,0))
   phachns = n_elements(spectra(0,0,*))
   num_dets = n_elements(spectra(*,0,0))
   counts = lonarr(4,num_dets,psachns,phachns)
   a_lvtme = fltarr(4,num_dets) & lvtme = a_lvtme
   counts = reform(counts,4,num_dets,psachns,phachns) & a_counts = counts
endif
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
if (phachns_ eq phachns and psachns_ eq psachns and num_dets_ eq num_dets)$
then begin
   cp = idf_hdr.clstr_postn
   if(cp eq '0 (FOR +/- 3.0 DEG)' or cp eq '0 (FOR +/- 1.5 DEG)') $
   then cp_ndx = 2
   if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
   if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
   if (disp eq 0)then begin 
      dt(0,*) = [strmid(date,0,9),strmid(date,11,18)]
      dt(1,*) = dt(0,*)
   endif else begin
      dt(1,*) = [strmid(date,0,9),strmid(date,11,18)]
   endelse
;*************************************************************************
; If new idf accumulate
;*************************************************************************
   if (new)then begin
      if (idf_hdr.nd eq 1)then begin
         a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + livetime(idf_hdr.nc)
         a_lvtme(3,*) = a_lvtme(3,*) + livetime(idf_hdr.nc)
      endif else begin
         a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + livetime
         a_lvtme(3,*) = a_lvtme(3,*) + livetime
      endelse
      for i = 0,num_dets - 1 do begin
       a_counts(cp_ndx,i,*,*) = a_counts(cp_ndx,i,*,*) + spectra(i,*,*)
       a_counts(3,i,*,*) = a_counts(3,i,*,*) + spectra(i,*,*)
      endfor
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
      print,'ND=1, DET_STR=',det_str
      det = 1
   endif else begin
      det_str = strcompress('DET' + $
      string(indgen(num_dets+1)+1),/remove_all)
      det_str(num_dets) = 'SUM'
      det_ = where(dc eq det_str)
      det = det_(0) + 1
      print,'ND=',idf_hdr.nd,', DET_STR=',det_str 
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
          for k = 0,phachns-1 do begin
           for j = 0,psachns-1 do begin
            brate(j,k) = total(a_counts(0:1,i,j,k))/total(a_livetime(0:1,i))
           endfor
          endfor
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
;*************************************************************************
; Incompatible IDF - print error beep + message
;*************************************************************************
endif else begin
   print,string(7b)
   print,'!!INCOMPATIBLE ARRAY DIMENSIONS :IDF ',idfe,'!!'
   print,'IDF ',idfe - 1,':'
   print,'PHACHNS=',phachns
   print,'NUM_DETS=',num_dets
   print,'PSACHNS=',psachns
   print,'IDF ',idfe,':'
   print,'PHACHNS_=',phachns_
   print,'NUM_DETS_=',num_dets_
   print,'PSACHNS_=',psachns_
   print,'IDF ',idfe,' NOT ACCUMULATED'
endelse
;*************************************************************************
; Call plotting routine
;*************************************************************************
;if (not(ks(time)))then time = '0.'
;ltime = time
wphapsa          
;*************************************************************************
; Thats all folks
;*************************************************************************
return
end
