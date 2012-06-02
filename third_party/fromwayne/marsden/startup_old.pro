
pro startup,new,dc,idf_hdr,date,a_lvtme,a_counts,spectra,livetime,$
            num_dets,num_spec,num_chns,disp,cp,dt,cp_ndx,counts,lvtme,$
            rates0,rates1,det,det_str,swapped
;***************************************************************************
; Program loads counts and livetime arrays.
; Input variables are:
;            dc...................detector code
;           new...................new file(1) or not(0)
;	idf_hdr...................data header
;	   disp...................display option (0=1 IDF,1 = accum)
;          date...................date string
;       a_lvtme...................livetime (accum)
;      a_counts...................counts (accum)
;       spectra...................spectral array for current IDF
;      livetime...................livetime   "    "     "     "
;      num_dets...................number of detectors
;      num_spec...................number of spectra/IDF (integrations)
;      num_chns...................number of Pha channels
;       swapped...................corrects for transposed data
; Output variables are:
;            cp...................cluster position (current IDF)
;            dt...................date string
;        cp_ndx...................cluster position index
;        counts...................counts array for cp
;         lvtme...................livetime  "   "   "
;        rates0...................array of rates (1 IDF)
;        rates1...................  "    "    "  (accum)
;           det...................detector choice
;       det_str...................detector string
; Modified: HELL NO!
; 4-28-94 Extra dimension for 'ANY' added to counts/livetime arrays
;     "   Array operations for loops
; 5-5-94 Oops must reform counts array if restarting old data file 
; First get dates and cluster position:
;***************************************************************************
if (num_spec eq 0) then num_spec = 1
cp = idf_hdr.clstr_postn
len = strlen(date)
p = strpos(' ',date)
if (disp eq 0)then begin 
   dt(0,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
   dt(1,*) = dt(0,*)
endif else begin
   dt(1,*) = [strmid(date,0,9),strmid(date,10,strlen(date) - 9)]
endelse
if(cp eq '0 (FOR +/- 3.0 DEG)' or cp eq '0 (FOR +/- 1.5 DEG)') then cp_ndx = 2
if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
;****************************************************************************
; Now get 'no data' mask spc0 & spc00. Purpose is to make sure livetime
; for no data is not accumulated.
; 5/19/94 new addition spc00,spc0 - tele you which dets are on
;****************************************************************************
n = n_elements(spectra(*,0,0))
nint = n_elements(spectra(0,*,0))
spc0 = replicate(1.,n) 
if (ks(swapped))then spc00 = replicate(1.,n,nint) else $
                     spc00 = replicate(1.,nint,n)
for i = 0,n-1 do begin
 nz = where(spectra(i,0,*) ne 0)
 if (nz(0) eq -1)then begin
    spc0(i) = 0.
    if (ks(swapped))then spc00(i,*) = 0. else spc00(*,i) = 0.
 endif
endfor
;***************************************************************************
; Now add new idf to accumulated arrays. Convert data from old format if 
; doing saved file (from 'xs').
; 5/19/94 Sum over accumulations fixed
; 5/29/94 Problem accumulating w/nint=1 fixed
;***************************************************************************
if (new)then begin
   print,'ADDING TO A_LIVETIME AND A_COUNTS'
   tspectra = lonarr(n_elements(spectra(*,0,0)),n_elements(spectra(0,0,*)))
   for i = 0,nint-1 do tspectra(*,*) = spectra(*,i,*) + tspectra(*,*)
   if (ks(swapped))then begin
      n = n_elements(livetime(0,*))
      tlvtme = livetime#(replicate(1.,n)*spc0)
   endif else begin
      n = n_elements(livetime(*,0))
      tlvtme = (replicate(1.,n)*spc0)#livetime
   endelse
   if (nint eq 1)then begin
      a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + livetime
      a_lvtme(3,*) = a_lvtme(3,*) + livetime
   endif else begin
      a_lvtme(cp_ndx,*) = a_lvtme(cp_ndx,*) + tlvtme(*)
      a_lvtme(3,*) = a_lvtme(3,*) + tlvtme(*)  
   endelse
   a_counts(cp_ndx,*,*) = a_counts(cp_ndx,*,*) + tspectra(*,*)
   a_counts(3,*,*) = a_counts(3,*,*) + tspectra(*,*)
endif
sz_cnts = size(counts)
if (sz_cnts(1) ne 4)then begin
   cnts = lonarr(4,num_dets,num_spec,num_chns)
   a_cnts = lonarr(4,num_dets,num_chns)
   lv = fltarr(4,num_dets,num_spec)
   a_lv = fltarr(4,num_dets)
   cnts(0:2,*,*,*) = counts
   a_cnts(0:2,*,*) = a_counts
   lv(0:2,*,*) = lvtme
   a_lv(0:2,*) = a_lvtme
   counts = cnts
   a_counts = a_cnts
   a_lvtme = a_lv
   lvtme = lv
endif
;***************************************************************************
; Set current idf arrays 
;***************************************************************************
counts(cp_ndx,*,*,*) = spectra
lvtme(cp_ndx,*,*) = livetime*spc00
counts(3,*,*,*) = spectra
lvtme(3,*,*) = livetime*spc00
rates0 = fltarr(num_dets,num_spec,num_chns)
rates1 = fltarr(num_dets,num_chns) 
brate = fltarr(num_chns)
sbrate = brate
d1 = strcompress('DET' + string(indgen(num_dets) + 1),/remove_all)
d2 = ['DET SUM','SHOW ALL']
det_str = [strcompress(d1,/remove_all),d2]
det = where(det_str eq dc) + 1
det = det(0)
print,'DET=',det
new = 0
;****************************************************************************
; Thats all ffolks
;****************************************************************************
return
end
