pro msclr_stor,hdr,idfc,sdate,spec,live,ty,idflost,nowait=nowait,$
               ulds=ulds,xulds=xulds,idfarr=idfarr,arms=arms,$
               trigs=trigs,vetos=vetos,manual=manual,evts=evts,$
               mode=mode
;*************************************************************************
; Program loads the necessary variables into a common
; block. Variables are:
;      idf_hdr..............header containing science data
;          idf..............current idf of data
;         date..............   "    date "  "
;      spectra..............spectral counts array
;     livetime..............time for spectra
;           ty..............data type
;         wait..............if activated wait an idf
;    spec_save..............saved science header from idf-1
;    idf _save..............saved livetime from idf-1
;      idflost..............idf lost
;       nowait..............don't stagger if defined 
;         ulds..............Array of ULD vs IDF
;        xulds..............Array of XULD vs IDF
;         arms..............Array of arm rates
;        trigs..............Array of trigger rates
;        vetos..............Array of veto rates
;       idfarr..............Array of IDFs
;        tedgs..............Array of Start/Stop times for each time bin
;       manual..............Timing correction MET --> TT
;         evts..............Store on-source event times/pha
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; 5/16/94 Modified for 'xs' restart of session
; 8/22/94 Removed print statements 
; 8/29/94 Returns lost idf
;*************************************************************************
common msclr_block,idf_hdr,idf,date,spectra,livetime,typ,tedgs
common save_block,spec_save,idf_save,wait,num
;*************************************************************************
; Check if first idf or if idf was skipped
;*************************************************************************
if (ks(idf) eq 0)then begin
   if (ks(spec_save) eq 0)then begin
      wait = 1
      spec_save = spec
      idf_save = idfc
      idf = idfc
   endif else begin
      spectra = spec_save
      idf = idf_save
   endelse
endif else begin
   if (idfc ne idf_save+1)then begin
      wait = 1
      spec_save = spec
      idf_save = idfc
      idflst = idf_save + 1
   endif else begin
      spectra = spec_save
      spec_save = spec
      idf = idf_save
      idf_save = idfc
   endelse
endelse
;*************************************************************************
; Return lost idf if defined
;*************************************************************************
if (ks(idflst) ne 0)then idflost = idflst else idflost = -1
;*************************************************************************
; Store the common block variables
;*************************************************************************
date = sdate
livetime = live
idf_hdr = hdr
typ = ty
idfc = idf
if (ks(nowait) ne 0)then begin
   spectra = spec
   idf = idfc
   wait = 0
endif
;*************************************************************************
; Set the number of good events. I apologize for this program being 
; a P.O.S.:
;*************************************************************************
if (n_elements(spectra) gt 1)then begin
   livetime_save = livetime
   spectra_save = spectra
   if (n_elements(mode) ne 0)then begin
      make_ms,typ,spectra,idf_hdr,man=manual,ev=evts,id=idf,$
               li=livetime,te=tedgs
   endif else begin
      q = n_elements(spectra(0,0,*))
      tedgs = dblarr(2,q)
      dt = 16d/q
      tedgs(0,*) = dindgen(q)*dt
      tedgs(1,*) = tedgs(0,*) + dt
   endelse
;*************************************************************************
; Do livetime correction if needed.
; Must do special case if multiscalar mode with summed detectors.
;*************************************************************************
   go = total(livetime) ne 0. and n_elements(ulds) gt 1
   if (go)then begin
      sz_live = size(livetime)
      nlive = n_elements(livetime)
      if (sz_live(0) eq 1)then livetime = reform(livetime,1,nlive)
      if (ks(num) eq 0)then num = float(reform(total(spectra,3)))
      if (n_elements(livetime) eq 1)then begin
         flag = 1
         tt = total(livetime)
         livetime_new = replicate(tt,4)
         livetime_new = reform(livetime_new,1,4)
         livetime = livetime_new
         num = replicate(total(spectra)/4.,4)
      endif else flag = 0
      dead_corr,idf,idf_hdr,livetime,idfarr,xulds,ulds,arms,trigs,vetos,$
             livetime_out,nu=num
      livetime = livetime_out
      if (flag)then livetime = total(livetime)/4.
   endif
endif
;*************************************************************************
; Thats it fffolks
;*************************************************************************
return
end
