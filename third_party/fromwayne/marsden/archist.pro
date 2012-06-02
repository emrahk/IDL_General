pro archist,noplot,iarr=iarr,sp=sp,cpout=cpout
;********************************************************************
; pro archist.pro. Program governs the interaction between the
; archive histogram widget (warchist.pro) and the event manager
; (warchist_event.pro). Variables are:
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accumulated
;     counts.................1 idf counts(position,det,chn)
;      lvtme.................1 idf livetme(position,det)
;   a_counts.................accumulated counts(position,det,chn)
;    a_lvtme.................accumulated livetme(position,det)
;  idfs,idfe.................idf start,stop #s for accum.
;        idf.................current idf
;        dts.................start,date,time array
;         dt.................start,stop date,time array
;   num_spec.................# of spectra/det
;   num_chns.................# channels
;   num_dets.................# detectors
;       iarr.................Array of IDFs processed
;       disp.................show 1 idf(0) of accumulated(1)
;      start.................first time(0) or subsequent(1)
;        new.................new file(1) or not(0)
;  num_lines.................# of gaussina lines
;      trate.................total count rate (all chns)
;       fnme.................filename for storage
;        typ.................type of data set
;       wait.................if activated wait an idf
;     noplot.................if defined, no plotting
;  idf_lvtme.................array of livetimes vs idf
;  clstr_pos.................cluster position vs idf
;         sp.................spectral array
;         cp.................cluster position output
; Common blocks:
;  archev_block.................between archist and warchist event 
;              manager
; archist_block.................stores accumulation variables
; First define common block and define default values:
;********************************************************************
common archev_block,dc,opt,counts,lvtme,idfs,idfe,$
                 disp,a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,$
                 rates0,rates1,num_chns,num_spec,det_str,fnme,$
                 idf_lvtme,clstr_pos
common archist_block,idf_hdr,idf,date,spectra,livetime,typ
common parms,start,new,clear
;********************************************************************
; Set some defaults
;********************************************************************
if (ks(dc) eq 0)then dc = 'DET1'
if (ks(cp) eq 0)then cp = '0 (FOR +/- 1.5 DEG)'
if (ks(opt) eq 0)then opt = 5
if (ks(disp) eq 0)then disp = 0
if (ks(fnme) eq 0)then fnme = ''
;********************************************************************
; Get initial arrays if just starting accumulation
;********************************************************************
if (clear)then begin
   start = 1
   idf = 0
   spectra(*,*,*) = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
   lvtme(*,*,*) = 0 & a_lvtme(*,*) = 0
   clear = 0
endif
if (start)then init,start,idf,date,spectra,idfs,dt,num_spec,$
 num_dets,num_chns,a_counts,a_lvtme,counts,lvtme,idf_lvtme
;********************************************************************
; Accumulate counts and livetime, and form arrays according to
; cluster position. First must check if the 
; current data set is compatible with the previous array dimensions
;********************************************************************
if (new)then begin
   num_spec_ = n_elements(spectra(0,*,0))
   num_chns_ = n_elements(spectra(0,0,*))
   num_dets_ = n_elements(spectra(*,0,0))
endif else begin
   num_spec_ = num_spec
   num_chns_ = num_chns
   num_dets_ = num_dets
endelse
;********************************************************************
; Accumulate the dates and times correctly
;********************************************************************
if (dt(0,0) eq '')then begin
   dt(0,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
   dt(1,*) = dt(0,*)
endif else begin
   dt(1,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
endelse
;********************************************************************
; Do some other stuff
;********************************************************************
idfe = idf
if (idfs eq 0)then idfs = idf
livetime = transpose(livetime)
a = num_spec_ eq num_spec
b = num_chns eq num_chns_
c = num_dets eq num_dets_
if (a and b and c)then begin
   spnew = spectra
   newsave = new
   startup,new,dc,idf_hdr,date,a_lvtme,a_counts,spectra,livetime,$
    num_dets,num_spec,num_chns,disp,cp,dt,cp_ndx,counts,lvtme,rates0,$
     rates1,det,det_str,idf_lvtme,sw=1,clstr_pos=clstr_pos
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
   idfs = iarr(0) & idfe = max(iarr)
;*********************************************************************
; Now process latest choice for display
;*********************************************************************
   do_latest,dc,opt,counts,lvtme,disp,a_counts,a_lvtme,det,cp,dt,$
    num_dets,rates0,rates1,num_chns,num_spec
;*********************************************************************
; User selected data
;*********************************************************************
   if(disp eq 0)then rates = rates0 else rates = rates1
   det = where(det_str eq dc) + 1
   det = det(0)
   int = 1
   select,disp,det,num_dets,int,rates,lvtme,a_lvtme,num_chns,num_spec,$
    rt,ltime,trate,opt
;*************************************************************************
; Get net Flux:
;*************************************************************************
   if (disp eq 1 and opt lt 3)then begin
      lv = reform(idf_lvtme(2,*,*,*))
      if (det eq 6 and opt eq 1)then begin
         if (num_spec gt 1)then time = total(lv,2)
         if (total(time) eq 0.)then rt(*,*) = 0.
      endif
      if (det lt 6 and opt eq 1)then begin
         if (det ne 5)then lv = reform(lv(det-1,*,*)) $
         else lv = total(lv,1)/float(num_dets)
         if (num_spec gt 1)then time = total(lv,1) else time = lv
         if (total(time) eq 0.)then rt = 0.
      endif
      if (opt eq 2)then rt = rt/200.
      if (opt eq 1 or opt eq 2)then trate = strcompress(float(trate)/200.)
   endif 
endif 
if (n_elements(spnew) eq 0)then sp = -1 else sp = spnew 
if (n_elements(cp) eq 0)then cpout = -1 else cpout = cp          
;**********************************************************************
; Call the histogram display widget
;**********************************************************************
if (ks(noplot) eq 0)then $
warchist,det,rt,idfs,idfe,cp,dt,ltime,opt,num_spec,disp,trate,fnme           ;**********************************************************************
; Thats all folks
;**********************************************************************
return
end
