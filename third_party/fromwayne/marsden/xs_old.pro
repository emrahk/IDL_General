pro xs,fil
;************************************************************************
; Program xs.pro restarts a previously saved session
; Variables are :
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
;       disp.................show 1 idf(0) of accumulated(1)
;      start.................first time(0) or subsequent(1)
;        new.................new file(1) or not(0)
;  num_lines.................# of gaussian lines
;      trate.................total count rate (all chns)
;       fnme.................filename for storage
;        typ.................type of data set
;        fil.................stored session data file
;  spec_save.................saved science header from idf-1
;  idf _save.................saved livetime from idf-1
; First get the filename of the session and restore it   
;************************************************************************
common parms,start,new,clear
common save_block,spec_save,idf_save,wait
if (not(ks(start)))then begin
   start = 0 & new = 0 & clear = 0
endif
if (not(ks(fil)))then fil = 'idlsave.dat'
restore,fil
;***********************************************************************
; Read typ and restart session. Must put variables in proper common
; block first. First do archive histogram:
; 5/11/94 Eliminate 'Update' variable
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
;***********************************************************************
spec_save = spectra
idf_save = idf
wait = 0
if (typ eq 'ARCh')then begin
   archist_stor,idf_hdr,idf,date,spectra,livetime,typ
   archev_stor,dc,opt,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,num_chns,$
    num_spec,det_str,fnme
   archist
endif
if (typ eq 'HSTs')then begin
   hist_stor,idf_hdr,idf,date,spectra,livetime,typ
   hev_stor,dc,opt,int,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,num_chns,$
    num_spec,det_str,fnme
   hist
endif
if (typ eq 'CALh')then begin
   calhist_stor,idf_hdr,idf,date,spectra,livetime,typ
   chev_stor,dc,opt,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,det,rt,ltime,cp,dt,num_dets,rates0,rates1,num_chns,$
    num_spec,det_str,fnme
   calhist
endif
if (typ eq 'MSCs')then begin
   msclr_stor,idf_hdr,idf,date,spectra,livetime,typ
   mev_stor,dc,opt,accum,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,det,cp,dt,num_dets,pha_edgs,num_tm_bins,pha_choice,ltime,$
    ft,periods,fold,fnme
   msclr
endif
if (typ eq 'PHSs')then begin
   phapsa_stor,idf_hdr,idf,date,spectra,livetime,typ
   pev_stor,dc,opt,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,chn_slice,det,rt,cp,dt,ltime,rates0,rates1,det_str,$
    psachns,phachns,plt,num_dets,colr,fnme
   phapsa
endif
if (typ eq 'ARCm')then begin
   am_stor,idf_hdr,idf,date,spectra,livetime,typ
   amev_stor,dc,opt,accum,counts,lvtme,idfs,idfe,disp,a_counts,$
    a_lvtme,det,cp,dt,num_dets,pha_edgs,num_tm_bins,pha_choice,ltime,$
    ft,periods,fold,fnme
   am
endif
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end 
