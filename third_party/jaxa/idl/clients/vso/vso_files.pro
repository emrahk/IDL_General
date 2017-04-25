;+
; Project     : VSO
;
; Name        : VSO_FILES
;
; Purpose     : Wrapper around VSO_SEARCH that returns URL file names
;
; Category    : utility system sockets
;
; Example     : IDL> urls=vso_files('1-may-07','2-May-07',inst='trace')
;
; Inputs      : TSTART, TEND = start, end times to search
;
; Outputs     : URLS = URLs of search results
;
; Keywords    : TIMES = times (TAI) of returned files
;               SIZES = sizes (bytes) of returned files
;               COUNT = # of returned files
;               WMIN  = minimum wavelength (if available)
;               RECOVER_URLS = recover missing URLs
;
; History     : Written 3-Jan-2008, D.M. Zarro (ADNET/GSFC)
;               Modified 12-Nov-2014, Zarro (ADNET)
;                - added support for TSTART input to be a filename
;               Modified 12-Feb-2016, Zarro (ADNET)
;                - added check for blank URL's
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function vso_files,tstart,tend,times=times,sizes=sizes,count=count,$
                    _ref_extra=extra,window=window,wmin=wmin,fids=fids,$
                   recover_urls=recover_urls

return_sizes=arg_present(sizes)
return_times=arg_present(times)

times=-1.0d & sizes=''
urls='' & count=0 & nearest=0b & fids=''
failure='No records with URLs found.'

if is_blank(extra) then begin
 pr_syntax,'files=vso_files(tstart [,tend],inst=inst)'
 return,''
endif

if (valid_time(tstart) || is_string(tstart)) && ~valid_time(tend) then begin
 if is_number(window) then win=window/2. else win=3600.
 if valid_time(tstart) then dstart=anytim2tai(tstart) else dstart=parse_time(tstart,/tai)
 vstart=dstart-win
 vend=dstart+2*win
 vstart=anytim2utc(vstart,/vms)
 vend=anytim2utc(vend,/vms)
 nearest=1b
endif else vstart=get_def_times(tstart,tend,dend=vend,_extra=extra,/vms)

;-- search VSO

records=vso_search(vstart,vend,_extra=extra,/url)
if ~have_tag(records,'url') then begin
 mprint,failure & return,''
endif

;-- try to recover missing URL's

chk=where(records.url ne '',count)
if (count eq 0) then begin
 if ~keyword_set(recover_urls) then begin
  mprint,failure & return,''
 endif
 chk=vso_get(records[0],/nodown)
 if chk.url eq '' then begin
  mprint,failure & return,''
 endif
 mprint,'Building URls...'
 stc=url_parse(chk.url)
 server='http://'+stc.host
 dir=str_replace(stc.path,records[0].fileid,'')
 records.url=server+'/'+dir+records.fileid
 count=n_elements(records)
endif 

if count lt n_elements(records) then records=records[chk]

;-- sort results and find records nearest start time

if count gt 1 then begin
 fids=get_uniq(records.fileid,sorder)
 records=records[sorder]
endif

urls=records.url
have_sizes=have_tag(records,'size')
have_wave=have_tag(records,'wave')

if nearest then begin
 count=1
 dtimes=anytim2tai(records.time.start)
 diff=abs(dtimes-dstart)
 ok=where(diff eq min(diff))
 ok=ok[0]
 urls=records[ok].url
 if have_sizes then sizes=trim(records[ok].size)
 if have_wave then wmin=trim(records[ok].wave.min)
 if n_elements(wmin) eq 1 then wmin=wmin[0]
 return,urls 
endif


count=n_elements(urls)

if return_sizes && have_sizes then begin
 sizes=strtrim(records.size,2)
 chk=where(long(sizes) eq 0l,dcount)
 if dcount gt 0 then sizes[chk]=''
endif

if arg_present(wmin) && have_wave then wmin=strtrim(records.wave.min,2)
if return_times then times=anytim2tai(records.time.start)
if n_elements(wmin) eq 1 then wmin=wmin[0]

return,urls

end
