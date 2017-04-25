;+
; Project     : SDO
;
; Name        : EVE__DEFINE
;
; Purpose     : Class definition for SDO/EVE
;
; Category    : Objects
;
; History     : Written 28 September 2010, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function eve::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,inst='eve',_extra=extra)

end

;------------------------------------------------------------------------
function eve::search2,tstart,tend,_ref_extra=extra,count=count,type=type,$
                     times=times

type=''
server='lasp.colorado.edu'
path='/eve/data_access/evewebdataproducts/level2'

nearest=valid_time(tstart) and ~valid_time(tend)
dstart=get_def_times(tstart,tend,dend=dend,/tai,_extra=extra)

files=sock_files(server,dstart,dend,path=path,org='doy',/no_filter,_extra=extra,count=count,read_timeout=10)

;-- extract file times

if (count gt 0) then begin
 regex='.+_([0-9]{4})([0-9]{1,3})_([0-9]{0,3}).+'
 rtimes=stregex(files,regex,/sub,/extract)
 year=comdim2(rtimes[1,*])
 doy=comdim2(rtimes[2,*])
 hour=comdim2(rtimes[3,*])
 utc=doy2utc(fix(doy),fix(year))
 utc.time=long(hour)*3600l*1000l
 times=anytim2tai(utc)
 ok=where_times(times,tstart=round_time(dstart,/hour),tend=round_time(dend,/hour),count=count)
 if (count gt 0) and (count lt n_elements(files)) then begin
  files=files[ok]
  times=times[ok]
 endif
endif

if count gt 0 then type=replicate('euv/lightcurves',count) else begin
 files='' & times=-1.d
endelse
if count eq 1 then begin
 files=files[0] & times=times[0] & type=type[0]
endif
if count eq 0 then message,'No files found.',/info

if nearest and (count gt 1) then begin
 diff=abs(times-dstart)
 chk=(where(diff eq min(diff)))[0]
 files=files[chk]
 times=times[chk]
 type=type[chk]
endif

return,files
end

;------------------------------------------------------

pro eve::read,file,err=err,_ref_extra=extra

err='SDO/EVE reader not available.'
message,err,/info

return & end

;------------------------------------------------------
pro eve__define,void                 

void={eve, inherits utplot}

return & end
