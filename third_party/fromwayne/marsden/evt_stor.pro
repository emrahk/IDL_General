pro evt_stor,hdr,idfc,sdate,spec,live,ty,idflost
;**********************************************************************
; Program loads the necessary variables into a common
; block. Variables are:
;      idf_hdr..............structure containing science header
;          idf..............current idf of data
;         date..............   "    date "  "
;      spectra..............spectral counts array
;     livetime..............time for spectra
;           ty..............data type
;         wait..............if activated wait an idf
;    spec_save..............saved science header from idf-1
;    idf _save..............saved livetime from idf-1
;      idflost..............idf lost  
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; 5/16/94 modified for 'xs' restart of session
; 1/5/95  returns lost idf
;**********************************************************************
common evt_block,idf_hdr,idf,date,spectra,livetime,typ
common save_block,spec_save,idf_save,wait
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
;**********************************************************************
; Thats all ffolks
;**********************************************************************
return
end
 
