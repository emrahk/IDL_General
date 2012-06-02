pro am_stor,hdr,idfc,sdate,spec,live,ty
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
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; 5/16/94 modified for 'xs' restart of session
; 8/22/94 Removed print statements
; 8/29/94 Returns lost idf
; 5/9/95 Eliminated lost idf stuff (not necessary)
;*************************************************************************
common am_block,idf_hdr,idf,date,spectra,livetime,typ
;*************************************************************************
; Store the common block variables
;*************************************************************************
date = sdate
livetime = live
idf_hdr = hdr
typ = ty
spectra = spec
idf = idfc
;*************************************************************************
; Thats it fffolks
;*************************************************************************
return
end
