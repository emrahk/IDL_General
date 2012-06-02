pro calhist
;**************************************************************
; pro calhist.pro. Program governs the interaction between the
; histogram widget (wcalhist.pro) and the event manager
; (wcalhist_event.pro). Variables are:
;         dc.................detector code
;         cp.................cluster position
;        opt.................data display option
;    idf_hdr.................science header data
;     rates0.................counts/sec for single idf
;     rates1.................counts/sec for accum
;     counts.................1 idf counts(position,det,num_spec,chn)
;      lvtme.................1 idf livteme(position,det,num_spec)
;   a_counts.................hist_accumulated counts(position,det,chn)
;    a_lvtme.................hist_accumulated livetme(position,det)
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
;      trate.................total count rate (all chns)
;       fnme.................filename for storage
;        typ.................type of data set 
; Common blocks:
;  hev_block.................between calhist and wcalhist event manager
; calhist_block..............stores accumulation variables
; 5/11/94 Eliminate 'Update' variable
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; First define common block and define default values:
;********************************************************************
common chev_block,dc,opt,counts,lvtme,idfs,idfe,$
                 disp,a_counts,a_lvtme,det,rt,ltime,cp,dt,num_dets,$
                 rates0,rates1,num_chns,num_spec,det_str,fnme
common calhist_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common parms,start,new,clear
;***************************************************************************
; Return if waiting, else begin
;***************************************************************************
if (wait)then begin
   wait = 0
   return
endif
if (keyword_set(dc) eq 0)then dc = 'DET1'
if (keyword_set(cp) eq 0)then cp = '0 (FOR +/- 1.5 DEG)'
if (keyword_set(opt) eq 0)then opt = 5
if (keyword_set(dts) eq 0)then dts = ['0','0']
if (keyword_set(disp) eq 0)then disp = 0
if (ks(fnme) eq 0)then fnme = ''
;*****************************************************************************
; Get initial arrays if just starting accumulation
;*****************************************************************************
if (clear)then begin
   print,'CLEARING ARRAYS!!'
   date = '' & idf = 0
   start = 1
   spectra(*,*,*) = 0
   counts(*,*,*,*) = 0 & a_counts(*,*,*) = 0
   lvtme(*,*,*) = 0 & a_lvtme(*,*) = 0
   clear = 0
endif
if (start)then init,start,idf,date,spectra,idfs,dt,num_spec,$
 num_dets,num_chns,a_counts,a_lvtme,counts,lvtme
;*****************************************************************************
; Accumulate counts and lvtme, and form arrays according to
; cluster position. The accumulated counts and livetimes
; are summed over integrations/idf. First must check if the 
; current data set is compatible with the previous array dimensions
;*****************************************************************************
if (new)then begin
   num_spec_ = n_elements(spectra(0,*,0))
   num_chns_ = n_elements(spectra(0,0,*))
   num_dets_ = n_elements(spectra(*,0,0))
endif else begin
   num_spec_ = num_spec
   num_chns_ = num_chns
   num_dets_ = num_dets
endelse
idfe = idf
if (idfs eq 0)then idfs = idf
if (dt(0,0) eq '')then begin
   dt(0,0) = dt(1,0) & dt(0,1) = dt(1,1)
endif
livetime = transpose(livetime)
a = num_spec_ eq num_spec
b = num_chns eq num_chns_
c = num_dets eq num_dets_
if (a and b and c)then begin
   startup,new,dc,idf_hdr,date,a_lvtme,a_counts,spectra,livetime,$
    num_dets,num_spec,num_chns,disp,cp,dt,cp_ndx,counts,lvtme,rates0,$
     rates1,det,det_str,1
;****************************************************************************
; Now process latest choice for display
;****************************************************************************
   do_latest,dc,opt,counts,lvtme,disp,a_counts,a_lvtme,det,cp,dt,$
    num_dets,rates0,rates1,num_chns,num_spec
;***************************************************************************
; User selected data
;***************************************************************************
   if(disp eq 0)then rates = rates0 else rates = rates1
   det = where(det_str eq dc) + 1
   det = det(0)
   print,'DET=',det
   int = 1
   select,disp,det,num_dets,int,rates,lvtme,a_lvtme,num_chns,num_spec,$
    rt,ltime,trate,opt
endif else begin
;*************************************************************************
; Incompatible IDF - print error beep + message
;*************************************************************************   print,string(7b)
   print,'!!INCOMPATIBLE ARRAY DIMENSIONS :IDF ',idfe,'!!'
   print,'IDF ',idfe - 1,':'
   print,'NUM_SPEC=',num_spec
   print,'NUM_DETS=',num_dets
   print,'NUM__CHNS=',num_chns
   print,'IDF ',idfe,':'
   print,'NUM_SPEC_=',num_spec_
   print,'NUM_DETS_=',num_dets_
   print,'NUM__CHNS_=',num_chns_
   print,'IDF ',idfe,' NOT ACCUMULATED'
endelse
print,'IDFS,IDFE=',idfs,' ',idfe
;*************************************************************************
; Call the callibration histogram display widget
;*************************************************************************
wcalhist,det,rt,idfs,idfe,cp,dt,ltime,opt,num_spec,int,disp,trate,fnme           
;*************************************************************************
; Thats all folks
;*************************************************************************
return
end
