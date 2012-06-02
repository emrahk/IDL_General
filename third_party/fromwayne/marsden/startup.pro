pro startup,new,dc,idf_hdr,date,a_lvtme,a_counts,spectra,livetime,$
            num_dets,num_spec,num_chns,disp,cp,dt,cp_ndx,counts,lvtme,$
            rates0,rates1,det,det_str,idf_lvtme,area=area,prs=prs,$
            clstr_pos=clstr_pos,swapped=swapped
;***************************************************************************
; Program loads counts and livetime arrays.
; Variables are:
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
;     idf_lvtme...................array of livetimes for each idf
;       swapped...................corrects for transposed data
;            cp...................cluster position (current IDF)
;            dt...................date string
;        cp_ndx...................cluster position index
;        counts...................counts array for cp
;         lvtme...................livetime  "   "   "
;        rates0...................array of rates (1 IDF)
;        rates1...................  "    "    "  (accum)
;           det...................detector choice
;       det_str...................detector string
;          area...................effective area vs idf
;     clstr_pos...................cluster postion vs idf
;           prs...................pulse phase spectroscopy flag
; 6/10/94 Current version
; 8/22/94 Remove print statements
; 4/31/95 Removed date stuff (done elsewhere)
; 11/9/95 Accumulates livetime/idf
; First list common block:
;***************************************************************************
common response,response,x,y,ra,dec
;***************************************************************************
; Fix some control variables
;***************************************************************************
if (num_spec eq 0) then num_spec = 1
cp = idf_hdr.clstr_postn
len = strlen(date)
p = strpos(' ',date)
if(cp eq '0 (FOR +/- 3.0 DEG)' or cp eq '0 (FOR +/- 1.5 DEG)') then $
cp_ndx = 2
if(cp eq '+3.0' or cp eq '+1.5')then cp_ndx = 0
if(cp eq '-3.0' or cp eq '-1.5')then cp_ndx = 1
n = n_elements(spectra(*,0,0))
nint = n_elements(spectra(0,*,0))
if (total(idf_lvtme) eq 0)then nidf_old = 0 else $
nidf_old = n_elements(idf_lvtme(0,0,0,*))
;***************************************************************************
; Now add new idf to accumulated arrays. Convert data from old format if 
; doing saved file (from 'xs'). Need to do special case if phase resolved
; spectroscopy. First find the total spectra over integrations.
;***************************************************************************
if (new)then begin
   clstr = strcompress(idf_hdr.clstr_id)
   idf = idf_hdr.idf_num
   tspectra = total(spectra,2)
;***************************************************************************
; Weird case - reform livetime array
;***************************************************************************
   sz = size(livetime)
   if (ks(swapped) ne 0 and sz(0) eq 1)then $
   livetime = reform(temporary(livetime),4,1)
;***************************************************************************
; Now find the accumulated livetime array.
;***************************************************************************
   if (ks(prs) eq 0 and ks(swapped) eq 1)then begin
      a_lvtme(cp_ndx,*) = temporary(a_lvtme(cp_ndx,*)) + total(livetime,2)
      a_lvtme(3,*) = temporary(a_lvtme(3,*)) + total(livetime,2)
   endif
   if (ks(prs) ne 0)then begin
      livetime = reform(temporary(livetime))
      a_lvtme(cp_ndx,0,*) = temporary(a_lvtme(cp_ndx,0,*)) + livetime
      a_lvtme(3,0,*) = temporary(a_lvtme(3,0,*)) + livetime 
   endif
   if (ks(prs) eq 0 and ks(swapped) eq 0)then begin
      a_lvtme(cp_ndx,*) = temporary(a_lvtme(cp_ndx,*)) + total(livetime,1)
      a_lvtme(3,*) = temporary(a_lvtme(3,*)) + total(livetime,1)
   endif
;***************************************************************************
; Now get the accumulated counts array
;***************************************************************************
   if (ks(prs) eq 0)then begin
      a_counts(cp_ndx,*,*) = temporary(a_counts(cp_ndx,*,*)) + tspectra(*,*)
      a_counts(3,*,*) = temporary(a_counts(3,*,*)) + tspectra(*,*)
   endif else begin
      a_counts(cp_ndx,*,*,*) = temporary(a_counts(cp_ndx,*,*,*)) + spectra
      a_counts(3,*,*,*) = temporary(a_counts(3,*,*,*)) + spectra
   endelse 
;***************************************************************************      ;Set the arrays for the current IDF
;***************************************************************************
   lvtme(*) = 0.
   counts(*) = 0l
   counts(cp_ndx,*,*,*) = spectra
   lvtme(cp_ndx,*,*) = transpose(livetime)
   counts(3,*,*,*) = spectra
   lvtme(3,*,*) = transpose(livetime)
;***************************************************************************
; Section for accumulating livetimes per idf
;***************************************************************************
   nidf = nidf_old+long(1)
   idf_lvtme_new = fltarr(4,n,nint,nidf)
   if (ks(swapped) eq 0)then begin
     idf_lvtme_new(cp_ndx,*,*,nidf-1) = transpose(livetime)
     idf_lvtme_new(3,*,*,nidf-1) = transpose(livetime)
   endif else begin
     idf_lvtme_new(cp_ndx,*,*,nidf-1) = livetime
     idf_lvtme_new(3,*,*,nidf-1) = livetime
   endelse
   if (nidf ne 1)then idf_lvtme_new(*,*,*,0:nidf_old-1) = idf_lvtme
   idf_lvtme = reform(idf_lvtme_new,4,n,nint,nidf)
;***************************************************************************
; Section for accumulating area and cluster position per idf
;***************************************************************************
   if (ks(clstr_pos) eq 0)then clstr_pos = cp else $
                               clstr_pos = [temporary(clstr_pos),cp]
   area = 1.
endif
sz_cnts = size(counts)
if (sz_cnts(1) ne 4)then begin
   cnts = lonarr(4,num_dets,num_spec,num_chns)
   if (ks(prs) eq 0)then begin
      a_cnts = lonarr(4,num_dets,num_chns) 
      a_cnts(0:2,*,*) = a_counts
   endif else begin
      a_cnts = lonarr(4,num_dets,num_spec,num_chns)
      a_cnts(0:2,*,*,*) = a_counts
   endelse
   lv = fltarr(4,num_dets,num_spec)
   a_lv = fltarr(4,num_dets)
   lv(0:2,*,*) = lvtme
   a_lv(0:2,*) = a_lvtme
   counts = cnts
   a_counts = a_cnts
   a_lvtme = a_lv
   lvtme = lv
endif
;***************************************************************************
; Set up rates arrays 
;***************************************************************************
rates0 = fltarr(num_dets,num_spec,num_chns)
if (ks(prs) eq 0)then rates1 = fltarr(num_dets,num_chns) else $
rates1 = rates0
brate = fltarr(num_chns)
sbrate = brate
;***************************************************************************
; Make the detector choice string and detector variable det
;***************************************************************************
if (num_dets lt 5)then begin
   d1 = strcompress('DET' + string(indgen(num_dets) + 1),/remove_all)
   d2 = ['DET SUM','SHOW ALL']
   det_str = [strcompress(d1,/remove_all),d2]
   det = where(det_str eq dc) + 1
   det = det(0)
endif else begin
   d1 = strcompress(indgen(num_dets)+1,/remove_all)
   d2 = 'SUM'
   det_str = [d1,d2]
   det = where(det_str eq dc) + 1
   det = det(0)
endelse
new = 0
;****************************************************************************
; Thats all ffolks
;****************************************************************************
return
end
