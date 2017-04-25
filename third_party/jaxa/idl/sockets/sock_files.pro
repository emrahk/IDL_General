;+
; Project     : HESSI
;
; Name        : SOCK_FILES
;
; Purpose     : List files on remote server
;
; Category    : utility sockets 
;
; Syntax      : IDL> files=sock_files(server,tstart,tend)
;
; Inputs      : SERVER = server to search
;               TSTART, TEND = start/end times to search [inclusive]
;
; Outputs     : FILES = files found, with full path
;
; Keywords    : PATH   = directory to search
;               COUNT = # of files found
;             : ERR = error string input
;               NO_FILTER = don't filter times
;
; Restrictions: Files on remote server must be organized by year/mon/day
;               subdirectories, e.g. /2002/12/10
;
; History     : Written 7 Jan 2003, D. Zarro (EER/GSFC)
;               Modified 28-Sep-2010, Zarro (ADNET)
;                -  add NO_FILTER
;               Modified 27-Jul-2014, Zarro (ADNET)
;                - added /use_network to HAVE_NETWORK call.
;
; Contact     : dzarro@solar.stanford.edu
;-

function sock_files,server,tstart,tend,count=count,path=path,err=err,type=type,$
                   _extra=extra,no_filter=no_filter,times=times


count=0
err=''

if is_blank(server) then begin
 pr_syntax,'files=sock_files(server,path,tstart,tend)'
 return,''
endif

;-- ping server

check=have_network(server,err=err,_extra=extra,/use_network)
if ~check then return,''

if is_blank(path) then spath='' else spath=trim(path)

;-- construct remote directory names to search

fid=get_fid(tstart,tend,/full,delim='/',dstart=dstart,dend=dend,$
            _extra=extra)

;-- list via sockets

if is_blank(type) then stype='*.*' else stype=trim(type)

for i=0,n_elements(fid)-1 do begin
 rfiles=sock_find(server,stype,path=spath+'/'+fid[i],count=rcount,_extra=extra)
 if rcount gt 0 then begin
  if exist(files) then files=[temporary(files),temporary(rfiles)] else $
   files=temporary(rfiles)
 endif
endfor

count=n_elements(files)
if count eq 0 then return,''

if arg_present(times) and ~keyword_set(no_filter) then begin
 times=parse_time(files,/tai,_extra=extra)
 ok=where_times(times,tstart=dstart,tend=dend,count=count)
 if count gt 0 then return,''
 if count lt n_elements(files) then begin
  files=files[ok]
  times=times[ok]
 endif
 if count eq 1 then begin
  files=files[0]
  times=times[0]
 endif
endif

return,files & end


