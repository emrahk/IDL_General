;+
; Project     : HESSI
;
; Name        : FIND_FID
;
; Purpose     : find files based on encoded fid names (yymmdd_hhmm)
;
; Category    : HESSI, GBO, utility
;
; Explanation : 
;
; Syntax      : IDL> find_fid,tstart,tend,files
;
; Inputs      : TSTART = search start time
;               TEND   = search end time
;
; Opt. Inputs : None
;
; Outputs     : FILES = found files (rounded to nearest day)
;
; Opt. Outputs: None
;
; Keywords    : EXT = extension to search for (def = '.gif')
;               INDIR = root directory name to search
;               COUNT = # of files found
;               PATTERN = special pattern to search for (def = '*')
;
; Common      : None
;
; Restrictions: Unix systems only.
;               Assumes files are stored in subdirs encoded with "ext/yymmdd".
;
; Side effects: None
;
; History     : Version 1,  14-April-1999,  D.M. Zarro (SM&A/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro find_fid,t1,t2,files,pattern=pattern,err=err,$
  indir=indir,count=count,ext=ext,verbose=verbose

err=''

if n_params() lt 3 then begin
 pr_syntax,'find_fid,tstart,tend,files'
 return
endif

tstart=anytim2utc(t1,err=err)
if err ne '' then begin message,err,/cont & return & endif

tend=anytim2utc(t2,err=err)
if err ne '' then begin message,err,/cont & return & endif

;-- set defaults

verbose=keyword_set(verbose)
if not data_chk(ext,/string) then ext='gif'
if not data_chk(pattern,/string) then pattern='*'
data_dir=getenv('SUMMARY_DATA')
if data_dir eq '' then data_dir=curdir()
if not data_chk(indir,/string) then indir=concat_dir(data_dir,ext)

;-- look for starting/end directories to search

count=0
delvarx,files
dstart=tstart.mjd
dend=tend.mjd
last_temp=''
wild=strpos(pattern,'*') gt -1
get_utc,cur_utc
for i=dstart,dend do begin
 if i gt cur_utc.mjd then goto,done
 temp=date_code({mjd:long(i),time:0l})
 if temp ne last_temp then begin
  if verbose then message,'searching '+temp,/cont
  if strpos(temp,'19') eq 0 then temp=strmid(temp,2,strlen(temp))
  search_dir=concat_dir(indir,temp)
  if wild then search_file=pattern+'.'+ext else search_file='*'+pattern+'*.'+ext
  v=loc_file(concat_dir(search_dir,search_file),count=vcount)
  if vcount gt 0 then files=append_arr(files,v)
 endif
 last_temp=temp
endfor

done: count=n_elements(files)

if count eq 0 then err='No files found'
return & end



