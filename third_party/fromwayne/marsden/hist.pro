pro hist,noplot,pr=pr,iarr=iarr
;**************************************************************
; pro hist.pro. Program governs the interaction between the
; histogram widget (whist.pro) and the event manager
; (whist_event.pro). Variables are:
;         dc.................detector code
;        int.................integration  
;         cp.................cluster position
;        opt.................data display option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accumulated
;     counts.................1 idf counts(position,det,num_spec,chn)
;      lvtme.................1 idf livetme(position,det,num_spec)
;   a_counts.................accumulated counts(position,det,chn)
;    a_lvtme.................accumulated livetme(position,det)
;  idfs,idfe.................idf start,stop #s for accum.
;        idf.................current idf
;        dts.................start,date,time array
;         dt.................start,stop date,time array
;   num_spec.................# of spectra/det
;   num_chns.................# channels
;   num_dets.................# detectors
;       disp.................show 1 idf(0) of accumulated(1)
;      start.................first time(0) or subsequent(1)
;        new.................new file(1) or not(0)
;  num_lines.................# of gaussian lines
;      clear.................clear variable arrays if defined
;      trate.................total count rate (all chns)
;       fnme.................filename for storage
;        typ.................type of data set
;        rep.................repeat or not 
;       wait.................if activated wait an idf
;     noplot.................no plotting option if defined
;  idf_lvtme.................array of livetimes vs idf #
;  clstr_pos.................cluster position vs idf
;       iarr.................array of IDFs contributing data
;      ltime.................livetime for currently diplayed rate
;         pr.................phase resolved spectroscopy if defined
; Common blocks:
;  hev_block.................between hist and whist event manager
; hist_block.................stores accumulation variables
; First define common block and define default values:
;***************************************************************************
common hev_block,dc,opt,int,counts,lvtme,idfs,idfe,disp,a_counts,$
                  a_lvtme,det,rt,cp,dt,num_dets,rates0,rates1,$
                   num_chns,num_spec,det_str,fnme,idf_lvtme,clstr_pos,$
                    ltime,prs
common hist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
common met,iarr_common
;***************************************************************************
; Return if waiting, else begin
;***************************************************************************
if (wait)then begin
   wait = 0
   return
endif
if (keyword_set(cp) eq 0)then cp = '0 (FOR +/- 1.5 DEG)'
if (keyword_set(opt) eq 0)then opt = 5
if (keyword_set(int) eq 0)then int = 1
if (keyword_set(dts) eq 0)then dts = ['0','0']
if (keyword_set(disp) eq 0)then disp = 0
if (keyword_set(num_lines) eq 0)then num_lines = 1
if (keyword_set(iarr) eq 0)then iarr = 0
if (ks(pr) ne 0)then prs = 1 else prs = 0
if (ks(fnme) eq 0)then fnme = ''
;*****************************************************************************
; Get initial arrays if just starting accumulation
;*****************************************************************************
if (clear)then begin
   start = 1 & idf = 0
   spectra(*,*,*) = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
   lvtme(*,*,*) = 0
   if (prs) then a_lvtme(*,*,*) = 0. else a_lvtme(*,*) = 0.
   clear = 0
endif
if (start)then init,start,idf,date,spectra,idfs,dt,num_spec,$
 num_dets,num_chns,a_counts,a_lvtme,counts,lvtme,idf_lvtme,$
 pr=prs
;*****************************************************************************
; Accumulate counts and lvtme, and form arrays according to
; cluster position. The accumulated counts and livetmes
; are summed over integrations/idf. First must check if the 
; current data set is compatible with the previous array dimensions.
; If its phase resolved spectroscopy, must *not* sum over 
; integrations for the accumulated counts, because those are the
; phase bins! 
;*****************************************************************************
if (num_dets lt 5)then begin
   if (keyword_set(dc) eq 0)then dc = 'DET1'
endif else begin
   if (keyword_set(dc) eq 0)then dc = '1'
endelse
if (new)then begin
   num_spec_ = n_elements(spectra(0,*,0))
   num_chns_ = n_elements(spectra(0,0,*))
   num_dets_ = n_elements(spectra(*,0,0))
endif else begin
   num_spec_ = num_spec
   num_chns_ = num_chns
   num_dets_ = num_dets
endelse
;****************************************************************************
; Accumulate the dates and times correctly
;****************************************************************************
if (dt(0,0) eq '')then begin
   dt(0,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
   dt(1,*) = dt(0,*)
endif else begin
   dt(1,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
endelse
;****************************************************************************
; Do some other stuff
;****************************************************************************
a = num_spec_ eq num_spec
b = num_chns eq num_chns_
c = num_dets eq num_dets_
if (a and b and c)then begin 
   newsave = new
   startup,new,dc,idf_hdr,date,a_lvtme,a_counts,spectra,livetime,$
    num_dets,num_spec,num_chns,disp,cp,dt,cp_ndx,counts,lvtme,rates0,$
     rates1,det,det_str,idf_lvtme,pr=prs     
;************************************************************************
; Append the cluster postion and IDF arrays. If there's a 
; discontinuity in the latest IDF entry, fill the gap with 
; a zero for the missing idf and a '-10' for the missing 
; cluster position.
;************************************************************************
   if (newsave)then begin
      if (ks(clstr_pos) eq 0) then clstr_pos = cp else $
      clstr_pos = [temporary(clstr_pos),cp]
      if (ks(iarr) eq 0)then iarr = idf else iarr = [temporary(iarr),idf]
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
      iarr_common = iarr
   endif
   if (total(iarr) ne 0)then begin
      idfs = iarr(0)
      idfe = max(iarr)
   endif
;****************************************************************************
; Now incorporate data from latest idf for rates
;****************************************************************************
   do_latest,dc,opt,counts,lvtme,disp,a_counts,a_lvtme,det,cp,dt,$
             num_dets,rates0,rates1,num_chns,num_spec
;***************************************************************************
; User selected data
;***************************************************************************
   if(disp eq 0)then begin
      rates = rates0 
   endif else begin
      rates = rates1 
   endelse
   det = where(det_str eq dc) + 1
   det = det(0)
   select,disp,det,num_dets,int,rates,lvtme,a_lvtme,num_chns,num_spec,$
    rt,ltime,trate,opt
;*************************************************************************
; Find net rate.
;*************************************************************************
   if (disp eq 1 and opt lt 3)then begin
      lv = reform(idf_lvtme(2,*,*,*))
      if (det eq 6 and opt eq 1 and num_dets lt 5)then begin
         time = total(lv,2)
         if (total(time) eq 0.)then rt(*,*) = 0.
      endif
      if (det ne 6 and opt eq 1)then begin
         if (det ne 5)then lv = reform(lv(det-1,*,*)) $
         else lv = total(lv,1)/float(num_dets)
         if (num_spec gt 1)then time = total(lv,1) else time = lv
         if (total(time) eq 0.)then rt = 0.
      endif
      if (opt eq 2)then begin
         rt = rt/200.
         trate = strcompress(float(trate)/(16.*200.))
      endif
      if (opt eq 1)then trate = strcompress(float(trate)/(200.))
   endif             
endif
;*************************************************************************
; Call the histogram display widget
;*************************************************************************
if (ks(noplot) eq 0)then $
whist,det,rt,idfs,idfe,cp,dt,ltime,opt,num_spec,int,disp,trate,fnme,pr=prs
;*************************************************************************
; Thats all folks
;*************************************************************************
return
end
