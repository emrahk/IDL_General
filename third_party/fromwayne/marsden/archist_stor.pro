pro archist_stor,hdr,idfc,sdate,sp,live,ty,roll
;*************************************************************************
; Program loads the necessary variables into a common
; block. Variables are:
;      idf_hdr..............header containing science data
;          idf..............current idf of data
;         date..............   "    date "  "
;           sp..............spectral counts array
;     livetime..............time for spectra
;           ty..............data type
;         roll..............if defined don't check for rollover
;    spec_save..............saved science header from idf-1
;    idf _save..............saved livetime from idf-1
;      idflost..............idf lost  
; 5/13/94 Adds variable "wait" to catch up an idf for real science header 
;    "    Adds common block for temp arrays
; 5/16/94 Modified for 'xs' restart of session
; 8/22/94 Removed print statements
; 8/29/94 Returns lost idf
; 5/9/95 Eliminated save block, skipped idf stuff (not necessary)
;*************************************************************************
common archist_block,idf_hdr,idf,date,spectra,livetime,typ
;*************************************************************************
; Decompress the spectral array
; Compression is as follows:
;    PHA RANGE:               BIN WIDTH:
;      0 - 63                   2 PHA
;     64 - 127                  4 PHA
;    128 - 255                  8 PHA
; Thus there are 64 compresed channels corresponding to 256
; original PHA channels.
;*************************************************************************
if (ks(roll) eq 0)then begin
   sz_sp = size(sp) 
   spec = lonarr(4,1,256)
   for j = 0,3 do begin
    arr = 0
    s = reform(sp(j,0,*),64)
    decomp,s(0:31),2.,arr_add
    arr = [arr,arr_add]
    decomp,s(32:47),4.,arr_add
    arr = [arr,arr_add]
    decomp,s(48:63),8.,arr_add
    arr = [arr,arr_add]
    spec(j,0,*) = arr(1:256)
;************************************************************************
; Check for rollover at the data compression boundaries
; Channel to channel correlation greater than 5 sigma 
; constitutes rollover.
;************************************************************************
    cnts = reform(spec(j,0,*),256)
    sig = 5.
    rollover,cnts,sig
    spec(j,0,*) = cnts
   endfor
endif else begin
   spec = sp
endelse
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
; Thats all fffolks
;*************************************************************************
return
end
