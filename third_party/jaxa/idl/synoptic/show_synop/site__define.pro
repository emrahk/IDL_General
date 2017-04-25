;+
; Project : HESSI
;
; Name        : SITE__DEFINE
;
; Purpose     : Define a site object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('site')
;
; History     : Written 4 Jan 2000, D. Zarro, SM&A/GSFC
;               Modified 23 Jan 2008, Zarro (ADNET)
;               - added multiple time interval option
;               Modified 1-Jan-2010, Zarro (ADNET)
;               - replaced FTP spawning with IDLnetURL object
;               Modified 12-Feb-2010, Zarro (ADNET)
;               - added 'suffix' property to add to search directories
;               Modified 19-Feb-2010, Zarro (ADNET)
;               - added 'round' property to round search start time to day
;                 boundary
;               Modified 14-August-2012, Zarro (ADNET)
;               - made /use_network the default for searching
;               Modified 18-Feb-2013, Kim Tolbert
;               - added 'none' option for org, and use file_basename
;                 in parse_time
;               Modified 31-July-2013, Zarro (ADNET)
;               - improved STREGEX checks for file type and extension
;               Modified 22-Oct-2013, Zarro (ADNET)
;                - moved SITE property and RSEARCH method from
;                  SHOW_SYNOP class
;               Modified 12-Oct-2014, Zarro (ADNET)
;                - removed unused LAST_COUNT property
;               12-Feb-2015, Zarro (ADNET)
;                - changed username/password usage for FTP searches
;
; Contact     : dzarro@solar.stanford.edu
;-

;---------------------------------------------------------------------------
;-- constructor

function site::init,_ref_extra=extra,err=err

err=''

;-- defaults:

self.intervals=ptr_new(/all)
tstart=anytim2utc(!stime)
tstart.time=0
tend=tstart
tend.mjd=tend.mjd+1
org='day'
self->setprop,tstart=tstart,tend=tend,org=org,_extra=extra,err=err
success=err eq ''
return,success

end

;--------------------------------------------------------------------------

pro site::cleanup

ptr_free,self.intervals
dprint,'% SITE::CLEANUP'

return & end

;-------------------------------------------------------------------------
pro site::rsearch,files,count=count,err=err,_ref_extra=extra

files='' & err='' & count=0

smess='Searching not currently supported for this site.'
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 if is_string(err) then xack,err
 message,/reset
 return
endif

tstart=self->getprop(/tstart)
tend=self->getprop(/tend)
rsite=self->getprop(/site)
robj=obj_new(rsite,err=err)

;-- quit if no associated object with site

if ~obj_valid(robj) then begin
 if is_blank(err) then err=smess
 xack,err
 return
endif

;-- quit if missing a search method

if ~have_method(robj,'search') then begin
 err=smess
 obj_destroy,robj
 xack,err
 return
endif

files=robj->search(tstart,tend,count=count,err=err,_extra=extra)

obj_destroy,robj
if is_string(err) then xack,err,/suppress

return & end

;--------------------------------------------------------------------------
;-- directory organization of remote data

function site::valid_org,org

if datatype(org,/tname) ne 'STRING' then return,0b
valid_orgs=['hour','day','month','year','doy','none']
chk=where(strtrim(strlowcase(org),2) eq valid_orgs,count)

return, (count gt 0)

end

;-------------------------------------------------------------------
;-- clear sub-intervals

pro site::clear_intervals

*self.intervals=0.

return & end

;--------------------------------------------------------------------
;-- get number of intervals used

function site::get_intervals,count=count

count=0 & intervals=-1
sz=size(*self.intervals)
if (sz[0] eq 2) and (sz[1] eq 2) then begin
 count=sz[2] & intervals=*self.intervals
endif

;-- trap single interval

if (sz[0] eq 1) and (sz[1] eq 2) then begin
 count=sz[0] & intervals=*self.intervals
endif

;-- trap null interval

if (count eq 1) then begin
 if (intervals[0] eq 0.) and (intervals[1] eq 0.) then begin
  count=0 & intervals=-1
 endif
endif

return,intervals

end

;--------------------------------------------------------------------------
;-- set properties

pro site::setprop,site=site,tstart=tstart,tend=tend,ext=ext,ftype=ftype,back=back,$
              err=err,rhost=rhost,suffix=suffix,round=round,$
              topdir=topdir,$
              cache=cache,forward=forward,_extra=extra,intervals=intervals,$
              org=org,last_time=last_time,full=full,$
              no_order=no_order,delim=delim,password=password,username=username

err=''

if size(site,/tname) eq 'STRING' then self.site=trim(site)

;-- rationalize some control properties

if is_string(delim,/blank) then self.delim=trim(delim)
if exist(full) then self.full=keyword_set(full)
if is_string(rhost) then self.rhost=trim(rhost)
if is_string(topdir) then begin
 tdir=trim2(topdir)
 if ~stregex(tdir,'^/',/bool) then tdir='/'+tdir
 self.topdir=tdir
endif

if is_string(ext,/blank) then begin
 if is_string(ext) then begin
  fext=str_replace(ext,'.','') 
  fext=str_replace(fext,'*','')
 endif else fext=''
 self.ext=strcompress(fext,/remove)
endif

if is_string(password,/blank) then self.password=trim2(password)
if is_string(username,/blank) then self.username=trim2(username)
if is_string(suffix,/blank) then self.suffix=trim2(suffix)
if exist(round) then self.round=keyword_set(round)

if is_string(ftype,/blank) then begin
 if is_string(ftype) then ftype=trim2(ftype) else ftype=''
 self.ftype=ftype
endif


if exist(cache) then self.cache=keyword_set(cache)
if self->valid_org(org) then self.org=trim2(org)
if is_number(last_time) then self.last_time= 0b > byte(last_time) < 1b

;-- check for sub-intervals

sz=size(intervals)
if ((sz[0] eq 2) or (sz[0] eq 1)) and (sz[1] eq 2) then *self.intervals=intervals

;-- rationalize start/end times

terr=''
if exist(tstart) then begin
 t1=anytim2tai(tstart,err=terr)
 if terr eq '' then self.tstart=t1 else begin
  err=terr
  mprint,err
 endelse
endif

if exist(tend) then begin
 t2=anytim2tai(tend,err=terr)
 if terr eq '' then self.tend=t2 else begin
  err=terr
  mprint,err
 endelse
endif

if exist(back) then begin
 back=nint(back)
 day_sec=86400d
 if back ne 0 then begin
  tend=self.tstart+day_sec
  tstart=tend-back*day_sec
  self.tstart=tstart
  self.tend=tend
 endif
endif

if exist(forward) then begin
 forward=nint(forward)
 if forward ne 0 then begin
  tstart=self.tstart
  tend=tstart+forward*86400d
  self.tstart=tstart
  self.tend=tend
 endif
endif

if keyword_set(no_order) then return

t1=self.tstart & t2=self.tend
self.tend=t2 > t1
self.tstart= t1 < t2

return & end

;---------------------------------------------------------------------------
;-- show properties

pro site::show

print,''
print,'SITE properties:'
print,'----------------'
print,'% topdir: ',self.topdir
print,'% ext: ',self.ext
print,'% ftype: ',self.ftype
print,'% cache: ',self.cache
print,'% org: ',self.org
print,'% full: ',self.full
print,'% delim: ',self.delim

if self.tstart gt 0 then print,'% tstart: ',anytim2utc(self.tstart,/vms)
if self.tend gt 0 then print,'% tend:   ',anytim2utc(self.tend,/vms)

return & end

;-----------------------------------------------------------------------------
;-- define remote subdirectories

function site::get_sdir,_extra=extra

if self.org eq 'none' then return, ''

return,get_fid(self.tstart,self.tend,_extra=extra,delim=self.delim,$
               full=self.full,org=self.org)

end

;------------------------------------------------------------------------------
;-- validate required properties

function site::valid,list=list,err=err

err=''

if self.tstart le 0 then begin
 err='missing start time'
 mprint,err
 return,0b
endif

if self.tend le 0 then begin
 err='Missing end time.'
 mprint,err
 return,0b
endif

dstart=anytim2utc(self.tstart,/ext,err=err)
if (err ne '') then begin
 mprint,'Missing or invalid start time.'
 return,0b
endif

dend=anytim2utc(self.tend,/ext,err=err)
if (err ne '') then begin
 mprint,'Missing or invalid end time.'
 return,0b
endif

return,1b & end

;---------------------------------------------------------------------------
;-- create unique identifier to cache search results under

function site::get_cache_id

rhost=self->getprop(/rhost)
topdir=self->getprop(/topdir)
ftype=self->getprop(/ftype)
site_id=rhost+'_'+topdir+'_'+ftype

return,site_id

end

;---------------------------------------------------------------------------
;-- cache list results

pro site::list_cache,data,_ref_extra=extra

cache_id=self->get_cache_id()
tstart=self->getprop(/tstart)
tend=self->getprop(/tend)
round=self->getprop(/round)
if round then tstart=round_time(tstart)
list_cache,cache_id,tstart,tend,data,_extra=extra

return & end

;-----------------------------------------------------------------------------
;-- list remote files

pro site::list,ofiles,times=otimes,sizes=osizes,count=count,cats=ocats,$
                      stimes=ostimes,err=err,_extra=extra,no_search=no_search

count=0 & ofiles='' & osizes='' & otimes=-1.d & ocats='' & ostimes=''
err='' & within=0b

;-- check cache for recent listing

tstart=self->getprop(/tstart)
tend=self->getprop(/tend)
round=self->getprop(/round)
cache=self->getprop(/cache)
search=1b
if cache then begin
 self->list_cache,data,within=within,count=count,_extra=extra
 if within then search=0b
 if ~search then mprint,'Restoring from last cached search...'
endif else self->list_cache,/delete

;-- search if cache is off or outside last search time range

if search and ~keyword_set(no_search) then begin
 self->rsearch,ofiles,times=otimes,sizes=osizes,count=count,type=type
 if count gt 0 then begin
  odata={files:ofiles[0],times:otimes[0],sizes:osizes[0],cats:ocats[0],stimes:ostimes[0]}
  data=replicate(odata,count)
  if (n_elements(type) eq count) then ocats=type
  if (n_elements(osizes) ne count) then osizes=strarr(count) 
  ostimes=temporary(anytim2utc(otimes,/ecs,/trun))
  data.files=temporary(ofiles)
  data.sizes=temporary(osizes)
  data.cats=temporary(ocats)
  data.stimes=temporary(ostimes)
  data.times=temporary(otimes)
  if cache then self->list_cache,data,/set
 endif
endif

;-- filter sub-intervals

if count gt 0 then begin
 intervals=self->get_intervals(count=n_intervals)
 if n_intervals gt 0 then begin
  if round then tstart=round_time(tstart)
  ss=where_times(data.times,tstart=tstart,tend=tend,intervals=intervals,count=count)
  if (count gt 0) and (count lt n_elements(data)) then data=data[ss]
 endif
endif

;-- unpack data

if count gt 0 then begin
 ofiles=data.files
 osizes=data.sizes
 otimes=data.times
 ostimes=data.stimes
 ocats=data.cats
endif else begin
 ofiles='' & osizes='' & otimes=-1.d & ocats='' & ostimes=''
endelse

return & end


;-----------------------------------------------------------------------------

function site::parse_time,input,_ref_extra=extra

if size(input,/tname) ne 'STRING' then return, ''
return,parse_time(file_basename(input),_extra=extra)

end

;--------------------------------------------------------------------------------
function site::search,tstart,tend,_ref_extra=extra,count=count,$
                   times=times

times=-1 & count=0 

rhost=self->getprop(/rhost)
password=self->getprop(/password)
username=self->getprop(/username)
round=self->getprop(/round)

dstart=get_def_times(tstart,tend,dend=dend,_extra=extra,/tai)
self->setprop,tstart=dstart,tend=dend
sdirs=self->get_sdir()
url=rhost+self->getprop(/topdir)+'/'+sdirs+'/'
suffix=self->getprop(/suffix)
if is_string(suffix) then url=url+suffix+'/'
slist=''
cancel=0b
for i=0,n_elements(sdirs)-1 do begin
 sock_dir,url[i],out,_extra=extra,username=username,password=password,/use_network
 slist=[temporary(slist),temporary(out)]
endfor

if cancel then begin
 xkill,wbase
 mprint,'Cancelled.'
endif 

slist=strtrim(slist)
fext=self->getprop(/ext)
ftype=self->getprop(/ftype)
case 1 of
 is_string(ftype) and is_blank(fext): regex='^'+ftype+'.*'
 is_blank(ftype) and is_string(fext): regex='.+\.'+fext+'.*'
 is_string(ftype) and is_string(fext): regex='^'+ftype+'.*\.'+fext+'.*'
 else: do_nothing=1
endcase
if is_string(regex) then $
 chk=where(stregex(file_basename(slist),regex,/bool),count) else chk=where(slist ne '',count)

dprint,'% Regex: ',regex

if count eq 0 then begin
 mprint,'No files found.'
 return,''
endif
if count lt n_elements(slist) then slist=slist[chk]

stimes=self->parse_time(slist,_extra=extra,/tai)
if round then dstart=round_time(dstart)
chk=where((stimes ge dstart) and (stimes lt dend), count)

if count eq 0 then begin
 mprint,'No files found.'
 return,''
endif

if count lt n_elements(slist) then begin
 slist=slist[chk]
 stimes=stimes[chk]
endif

times=temporary(stimes)
if count eq 1 then begin
 times=times[0] & slist=slist[0]
endif

return,slist

end

;------------------------------------------------------------------------------
;-- define site object

pro site__define

; topdir : top directory on remote site
; ext : filename extension
; ftype: filename type
; tstart/tend: start/end times to copy
; cache: cache listing
; org: directory resolution of remote files (hour, day, month, year, doy, none)
; last_time: save last time interval when searching
; delim: delimiter for remote subdirs (e.g.delim='/' for 99/02/01)
; suffix: suffix to append to directory name
; full: use full year name for remote subdirs (e.g. 2002/02/01)
; round: round start search times to start of current day

temp={site,site:'',rhost:'',topdir:'',ext:'',ftype:'',tstart:0d,tend:0d,$
      intervals:ptr_new(),password:'',username:'',$
      cache:0b,org:'',full:0b,suffix:'',round:0b,$
      last_time:1b,delim:'',inherits gen}

return & end
