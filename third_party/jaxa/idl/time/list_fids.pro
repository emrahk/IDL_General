;+
; Project     : HINODE/EIS
;
; Name        : LIST_FIDS
;
; Purpose     : List files by file ID's (e.g. *20070201*)
;
; Category    : synoptic gbo
;
; Syntax      : IDL> files=list_fids(tstart,tend)
;
; Keywords    : PATH = path to search [def = current]
;               PREFIX/SUFFIX = prefix/suffix search characters 
;               (e.g. prefix*20070201*suffix)
;               BACK = no of days backward to search [def=0]
;
; History     : Written 15 Feb 2007, D. Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function list_fids,tstart,tend,path=path,prefix=prefix,suffix=suffix,$
                   count=count,verbose=verbose,_extra=extra

count=0
dstart=get_def_times(tstart,tend,dend=dend,/utc,$
                     no_next=~valid_time(tend),round=~valid_time(tstart),_extra=extra)

;--create file id's to search

if is_blank(path) then path=curdir()
if ~is_dir(path,out=fpath) then begin
 message,'directory '+path+' does not exist',/cont
 return,''
endif

if is_blank(prefix) then prefix='*' 
if is_blank(suffix) then suffix='*'
verbose=keyword_set(verbose)
mstart=dstart.mjd
mend=dend.mjd
ftime=dstart
for i=mstart,mend do begin
 fid=prefix+time2fid(ftime,/full)+suffix
 if verbose then message,'searching '+fid,/cont
 files=file_search(fpath,fid,count=fcount)
 ftime.mjd=ftime.mjd+1
 if fcount gt 0 then out=append_arr(out,files,/no_copy) 
endfor

if is_string(out) then begin
 count=n_elements(out) 
 if count eq 1 then out=out[0]
endif else out=''

return,out
end
