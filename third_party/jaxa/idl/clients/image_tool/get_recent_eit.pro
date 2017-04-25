;+
; Project     : SOHO-CDS
;
; Name        : GET_RECENT_EIT
;
; Purpose     : get recent EIT images 
;
; Category    : planning
;
; Explanation : check SOHO PRIVATE & SUMMARY data locations
;
; Syntax      : file=get_recent_eit(date)
;
; Examples    :
;
; Inputs      : None
;
; Opt. Inputs : DATE = date to retrieve [def=current day]
;
; Outputs     : 
;
; Opt. Outputs: FILES= most recent EIT file
;
; Keywords    : WAVE = EIT wavelength to select [def=304]
;               PATH = path to EIT directories 
;                      [used to override PRIVATE/SUMMARY locations]
;               ERR = error string
;               COUNT = no of files found
;               BACK= # of days backward to look [def=2]
;               QUIET = no output messages
;               FULL_DISK = select full-disk images only
;               NEAREST = get image nearest in time to DATE
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 14 May 1998 D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_recent_eit,date,back=back,wave=wave,err=err,count=count,quiet=quiet,$
                    path=epath,full_disk=full_disk,nearest=nearest

on_error,1
err=''
quiet=keyword_set(quiet)
loud=1-quiet
count=0
wavelen=[304,284,195,171]
if not exist(wave) then wave=304 else begin
 clook=where(wave eq wavelen,wcount)
 if wcount eq 0 then begin
  err='No such wavelength - '+trim(string(wave))
  if loud then message,err,/cont
  return,''
 endif
endelse
cerr=''
cdate=anytim2utc(date,err=cerr)
if cerr ne '' then get_utc,cdate
ctime=anytim2tai(cdate)
cdate.time=0
if not exist(back) then back=2

;-- data locations

if datatype(epath) eq 'STR' then begin
 if chk_dir(epath) then begin
  cpath=loc_file(epath,count=ecount)
  if ecount gt 0 then path0=cpath
 endif
endif

private_data=trim(getenv('PRIVATE_DATA'))
summary_data=(getenv('SUMMARY_DATA'))
if private_data ne '' then path1=concat_dir(private_data,'eit')
if summary_data ne '' then path2=concat_dir(summary_data,'eit')
if (not exist(path1)) and (not exist(path2)) and (not exist(path0)) then begin
 err='SOHO PRIVATE_DATA & SUMMARY_DATA environment variables are undefined'
 if loud then message,err,/cont
 return,''
endif

;-- setup search paths 

if exist(path0) then path=path0
if exist(path1) then if exist(path) then path=[path,path1] else path=path1
if exist(path2) then if exist(path) then path=[path,path2] else path=path2

if keyword_set(full_disk) then type='fd' else type='*'
nearest=keyword_set(nearest)

for i=0,back do begin
 pdate=cdate
 pdate.mjd=pdate.mjd-i
 pcode=date_code(pdate)
 pattern='seit_00'+trim(string(wave))+'_'+type+'_'+pcode+'*.fts*'
 dprint,'% pattern, path: ',pattern,path
 eit_file=loc_file(pattern,path=path,count=count)
 if count gt 0 then begin
  etime=file2time(eit_file)
  etime=anytim2tai(etime)
  if nearest then begin
   diff=abs(etime-ctime)
   near=where(diff eq min(diff))
  endif else near=where(etime eq max(etime))
  return,eit_file(near(0))
 endif
endfor

err='No recent EIT files found for specified wavelength'
if loud then message,err,/cont

return,'' & end

