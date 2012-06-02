pro phapsa_stor,hdr,idfc,sdate,spec,live,ty,idflost,nowait=nowait,$
                ulds=ulds,xulds=xulds,idfarr=idfarr,arms=arms,$
                 trigs=trigs,vetos=vetos
;*************************************************************************
; Program loads the necessary variables into a common
; block. Variables are:
;      idf_hdr..............header containing science data
;          idf..............current idf of data
;         date..............   "    date "  "
;      spectra..............spectral counts array
;     livetime..............time for spectra
;           ty..............data type
;    spec_save..............saved science header from idf-1
;    idf _save..............saved livetime from idf-1
;      idflost..............idf lost 
;       nowait..............don't stagger idfs if defined 
;         ulds..............Array of ULD vs IDF
;        xulds..............Array of XULD vs IDF
;       idfarr..............Array of IDFs
;         arms..............Array of arm rates
;        trigs..............Array of trigger rates
;        vetos..............Array of veto rates
;          num..............Number of good events array vs det
; 6/10/94 Current version
; 8/22/94 removed print statements
; 8/29/94 Returns lost idf
;*************************************************************************
common phapsa_block,idf_hdr,idf,date,spectra,livetime,typ
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
if (ks(nowait) ne 0)then begin
   spectra = spec
   idf = idfc
endif
;*************************************************************************
; Do livetime correction if needed:
;*************************************************************************
go = total(livetime) ne 0.
if (n_elements(idfarr) ne 0 and ks(spectra) ne 0 and go)then begin
   if (ks(num) eq 0)then num = float(total(total(spectra,2),2))
   dead_corr,idf,idf_hdr,livetime,idfarr,xulds,ulds,arms,trigs,vetos,$
             livetime_out,nu=num
   livetime = livetime_out
endif
;*************************************************************************
; Thats it fffolks
;*************************************************************************
return
end
