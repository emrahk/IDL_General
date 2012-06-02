pro select_p
;***********************************************************************
; Program calculates user selected rates and livetimes to display
; for the phapsa widget. Variables are:
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;      accum.................accumulation option
;     update.................do changes
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
; Common blocks:
;  pev_block.................between phapsa and wphapsa event manager
; 5/12/94 Eliminate 'update'
; First define common block:
;************************************************************************
common pev_block,dc,opt,counts,lvtme,idfs,idfe,disp,$
                 a_counts,a_lvtme,chn_slice,det,rt,cp,dt,ltime,$
                 rates0,rates1,det_str,psachns,phachns,plt,num_dets,$
                 colr,fnme
common nai,arr,nai_only
;*************************************************************************
; Do for single idf
;*************************************************************************
if (ks(arr) eq 0)then get_nai
if (ks(nai_only) eq 0)then nai_only = 0
nai_arr = reform(arr(0,*,*),64,256)
mask = 1. - float(nai_only)*float(nai_arr eq 0)
rt = fltarr(psachns,phachns)
if(disp eq 0)then begin
   rt(*,*) = mask*rates0(det-1,*,*)
   if (opt gt 2)then begin
      time = lvtme(opt-3,det-1)
   endif else begin
      a = lvtme(0,det-1) ne 0.
      b = lvtme(1,det-1) ne 0.
      ab = [a,b]
      t = float(total(ab))
      if (opt eq 2)then begin
         if (t ne 0.)then time = total(lvtme(0:1,det-1))/t
      endif else begin
         time = lvtme(2,det-1)
      endelse
   endelse
endif else begin
;************************************************************************
; Do it for accumulated idfs
;************************************************************************
   rt(*,*) = mask*rates1(det-1,*,*)
   if (opt gt 2)then begin
      time = a_lvtme(opt-3,det-1)
   endif else begin
      a = a_lvtme(0,det-1) ne 0.
      b = a_lvtme(1,det-1) ne 0.
      ab = [a,b]
      t = float(total(ab))
      if (opt eq 2)then begin
         if (t ne 0.)then time = total(a_lvtme(0:1,det-1))/t
      endif else begin
         time = a_lvtme(2,det-1)
      endelse
   endelse   
endelse
if (ks(time))then ltime = string(time) else ltime = '0.0'
;************************************************************************
; Thats all ffolks
;************************************************************************
return
end
