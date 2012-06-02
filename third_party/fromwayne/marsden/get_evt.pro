pro get_evt,spectra,pha,evt_time,lst_evts,det_id,mfc4,agc,psa,shields,$
            psuld,xuld,t_pulse,mfc8,burst=burst
;***********************************************************************
; Program decoms the event records and loads the single event data into 
; idl arrays. Data is passed in terms of two long words in for each
; event and decommed according to memo DFM 30061-710-036. 
; Variables are:
;        spectra.................array of events
;            pha.................pulse height of event
;       evt_time.................time of event
;       lst_evts.................lost events
;         det_id.................detector id
;           mfc4.................major frame counter (4 bit)
;            agc.................auto gain control flag
;            psa.................pulse shape of event
;        shields.................array of shield (1-5) veto flags
;          psuld.................pulse shape uld flag
;           xuld................. pulse height uld flag
;        t_pulse.................test pulser flag
;           mfc8.................major frame counter (8 bit)
;          burst.................First 32 bits only for burst data
; 5/27/95 Eliminated a small loop
; 5/30/95 Simplified code with get_bit_val.pro
; 8/1/95 Handles burst list data.
; Needs program get_bit_val.pro
; First do usage:
;***********************************************************************
if (n_params() eq 0)then begin
   print,'USAGE:GET_EVT,SPECTRA,PHA,EVT_TIME,LOST_EVENTS,DET_ID,' + $
         'MFC4,AGC,PSA,SHIELDS,PSULD,XULD,TEST_PULSE,MFC8,[BURST=]'
   return
endif
;***************************************************************************
; Get some variables
;***************************************************************************
if (ks(burst) eq 0)then begin
   num_evts = n_elements(spectra(0,*,0))
   s1 = reform(spectra(0,*,0),num_evts)
   s2 = reform(spectra(0,*,1),num_evts)
endif else begin
   num_evts = n_elements(spectra)
   s1 = reform(spectra,1,num_evts)
endelse
;***********************************************************************
; Decomm the first longword array
;***********************************************************************
arr = get_bit_val(s1,[0,8,25,27],[7,24,26,28],dim=32)
pha = reform(arr(0,*),num_evts)
evt_time = reform(arr(1,*),num_evts)
lost_events = reform(arr(2,*),num_evts)
det_id = reform(arr(3,*),num_evts)
m1  = get_bit_val(s1,29,31,dim=32)
;***********************************************************************
; Define truncated mfc4 for burst data and return. But first compute 
; the good burst event times
;***********************************************************************
if (ks(burst) eq 1)then begin
   mfc4 = m1
   sm = shift(mfc4,-1)
   in =where(mfc4 gt 0 and sm eq 0,n)
   nevts = n_elements(evt_time)
   if (in(n-1) eq nevts-1)then begin
      in = in(0:n-2)
      n = n-1
   endif
   add = 8*(indgen(n)+1)
   for i = 0,n-2 do mfc4(in(i)+1:in(i+1)) = mfc4(in(i)+1:in(i+1))+add(i)
   mfc4(in(n-1)+1:*) = mfc4(in(n-1)+1:*) + add(n-1)
   sm = shift(mfc4,-1)
   in = where(sm-mfc4 gt 2,n)
   if (in(0) ne -1)then begin
      mfc4 = mfc4(0:in(0)) 
      det_id = det_id(0:in(0))
      evt_time = evt_time(0:in(0))
      pha = pha(0:in(0))
   endif
   evt_time = double(mfc4) + double(evt_time)/2d^(17.)
   return
endif
;***********************************************************************
; Decomm the second longword array
; Special maneuvers for mjfc4, which is split b/w long1/long2
;***********************************************************************
m2 = get_bit_val(s2,0,0,dim=32)
m = m1 + 8*m2
mfc4 = get_bit_val(m,0,3,dim=4)
lb = [1,2,8,9,10,11,12,13,14,15,16]
ub = [1,7,8,9,10,11,12,13,14,15,23]
arr = get_bit_val(s2,lb,ub,dim=32)
agc = reform(arr(0,*),num_evts)
psa = reform(arr(1,*),num_evts)
shields = arr(2:6,*)
psuld = reform(arr(7,*),num_evts)
xuld = reform(arr(8,*),num_evts)
t_pulse = reform(arr(9,*),num_evts)
mfc8 = reform(arr(10,*),num_evts)
;***********************************************************************
; Convert the event time to seconds
;***********************************************************************
evt_time = double(mfc4) + double(evt_time)/2d^(17.)
;***********************************************************************
; Correct for rollover
;***********************************************************************
evt_time_new = evt_time(0:num_evts-2)
shift_time = shift(evt_time,-1)
shift_time = shift_time(0:num_evts-2)
roll = where(shift_time + 3d lt evt_time_new)
if (roll(0) ne -1)then $
evt_time(roll(0)+1l:num_evts-1) = evt_time(roll(0)+1l:num_evts-1) + 8d
;***********************************************************************
; Thats all ffolks
;***********************************************************************
return
end


