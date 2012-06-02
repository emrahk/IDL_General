pro evt,noplot
;********************************************************************
; Program converts the data from events format to specified format
; and begins the widget accumulation for that format.
; Variables are:
;   (single idf data):
;        idf_hdr..................science header for an idf
;            idf..................idf #
;           date..................date & time for idf
;        spectra..................event list array
;       livetime..................livetime for idf
;            typ..................data type code ('EVTs')
;   (accumulated data):
;      idfs,idfe..................start,stop idf
;             dt..................array of start,stop dates & times
;          tlive..................accumulated livetime/position/det.
;        sp1,sp2..................split accumulated event arrays
;        idf_pos..................array of event cluster positions
;          count..................array of idf counters
;         noplot..................no plotting option
; Define the common blocks:
;***********************************************************************
common evt_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
common basecom,base,idfold,beep,chc
common ev_block,idfs,idfe,dt,tlive,sp1,sp2,idf_pos,count
common parms,start,new,clear
;***********************************************************************
; Return if waiting, else begin
;***********************************************************************
if (wait)then begin
   wait = 0
   return
endif
;***********************************************************************
; Set some variables
;***********************************************************************
len = n_elements(spectra(0,*,0))
if (ks(count) eq 0)then count = replicate(0.,len)
len_cnts = n_elements(count)
lst_cnt = count(len_cnts-1)
;***********************************************************************
; Get the cluster position and the cluster position index.
;***********************************************************************
cp = idf_hdr.clstr_postn
if(cp eq '0 (FOR +/- 3.0 DEG)' or $
cp eq '0 (FOR +/- 1.5 DEG)') then cp_ndx = 2
if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
if (start)then begin
;***********************************************************************
; Set up arrays for initial time.
;***********************************************************************
   idfs = idf & idfe = idf
   tlive = fltarr(4,4)
   dt = strarr(2,2)
   dt(0,*) = [strmid(date,0,9),strmid(date,11,18)]
   dt(1,*) = dt(0,*)
   sp1 = reform(spectra(0,*,0),len) 
   sp2 = reform(spectra(0,*,1),len)
   idf_cnt = replicate(0.,len)
   tlive(cp_ndx,*) = livetime(0,*)
   tlive(3,*) = livetime(0,*)
   idf_pos = replicate(cp_ndx,len)
endif else begin
;***********************************************************************
; Add to previous arrays
;***********************************************************************
   idfe = idf
   tlive(cp_ndx,*) = livetime(0,*) + tlive(cp_ndx,*)
   tlive(3,*) = livetime(0,*) + tlive(3,*)
   sp1 = [sp1,reform(spectra(0,*,0),len)]
   sp2 = [sp2,reform(spectra(0,*,1),len)]
   idf_pos = [idf_pos,replicate(cp_ndx,len)]
   dt(1,*) = [strmid(date,0,9),strmid(date,11,18)]
   count_add = idfe - idfs
   count = [count,replicate(count_add,len)]
endelse
;***********************************************************************
; Dispatch the events list widget if first time.
;***********************************************************************
if (ks(noplot) eq 0)then wevt 
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end
