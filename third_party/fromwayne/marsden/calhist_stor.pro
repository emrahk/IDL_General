pro calhist_stor,hdr,idfc,sdate,spec,live,ty
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
; 8/22/94 Removed print statements
;*************************************************************************
common calhist_block,idf_hdr,idf,date,spectra,livetime,typ
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
; Thats all ffolks
;*************************************************************************
return
end
