function ssw_time2paths,time0,time1, parentx, parent=parent, file_pat=file_pat, $ 
      daily=daily, monthly=monthly, weekly=weekly, exist=exist, $
      count=count,year2_digit=year2_digit , flat=flat, $
      hourly=hourly, delimit=delimit, recursing=recursing, times=times, $
      sub_dir=sub_dir, append_dir=append_dir
;
;+
;   Name: ssw_time2paths
;
;   Purpose: return implied path list for time range; optionally w/file search
;
;   Input Parameters:
;      time0, time1 - desired time range - OR time0 may be time or time vector
;      parentx - optional positional synonym for keywor PARENT  (see that)
;
;   Output Parameters:
;     function returns directory list 
;       -OR- full file path  if FILE_PAT supplied 
;
;   Keyword Parameters:
;     parent - path to top of tree (may be NFS path or URL for example)
;     file_pat - optional file pattern for file search 
;     daily - set if organization is <parent>/yyyy/mm/dd/
;     monthly - set if organization is <parent>/yyyy/mm/
;     weekly  - set if organization is <parent>/weekid (per anytim2weekinfo.pro)
;     exist - if set, check for existence and return only those   
;             (could be much slower; default returns "idealized" list)
;     count - number of elements returned by this function
;     flat - switch - if set,paths are flattened
;            e.g. <parent>/yyyymmdd instead of <parent>/yyyy/mm/dd/
;     delimit - optional delimiter <parent>/yyyy<delimit><mm>[<delimit>dd]
;     hourly - (switch) - if set, add hourly subdirs (sdo-like)  - yyyy/mm/dd/Hhh00/
;     times - optional input times - (or may use single parameter TIME0) 
;     sub_dir - optional subdirectory/subpaths string appended to chron piece
;     append_dir - synonym for sub_dir
;
;   Calling Example:
;      paths=ssw_time2paths('1-jan-1999','31-jan-1999',parent='/top',/daily)
;      paths=ssw_time2paths('1-jan-1999','31-jan-1999','/top',/daily) ; same
;      help,paths & more,[paths(0:3),last_nelem(paths,3)]
; 
;      paths=ssw_time2paths(TIMES=index [,parent=parent] [,/monthly] [,/flat]) ; times-> implied path
;
;   History:
;      22-Aug-2005 - S.L.Freeland - common client/service utility
;       2-nov-2005 - S.L.Freeland - add /QUIET to timegrid call
;      24-apr-2006 - S.L.Freeland - truncate times to /DATE_ONLY to force
;                    pickup of last element 
;       4-dec-2006 - S.L.Freeland - add /FLAT keyword&function (STEREO for ex)
;      27-oct-2009 - S.L.Freeland - handle "incomplete" months
;      12-may-2010 - S.L.Freeland - add TIMES keyword & function
;      28-jan-2013 - S.L.Freeland - allow TIME0 single positional parameter (acts like TIMES keyword)
;      15-apr-2013 - S.L.Freeland - add SUB_DIR/APPEND_DIR (synonyms) keyword + function
;
;-
count=0
recursing=keyword_set(recursing)
y2=keyword_set(year2_digit) ; if yy/ not yyyy/
exist=keyword_set(exist)
monthly=keyword_set(monthly)
weekly=keyword_set(weekly) 
daily=1-(monthly or weekly) ; default=daily
days=daily + keyword_set(weekly)
if monthly then delvarx,days ; assure only one keyword set...
hourly=keyword_set(hourly)
flat=keyword_set(flat)

case 1 of 
   keyword_set(parent):
   data_chk(parentx,/string): parent=parentx
   else: parent=curdir()
endcase

if n_params() eq 1 and n_elements(times) eq 0 then times=time0 ; allow positionaly input vector

if keyword_set(times) then begin ; unstructured after thought...
   dates=anytim(times,/ecs,/date_only)
   if monthly then dates=strmid(dates,0,7)
   if hourly then dates=dates+'/H'+strmid(anytim(times,/time_only,/ecs),0,2)+'00'
   if data_chk(delimit,/string) then dates=str_replace(dates,'/',delimit(0))
   if keyword_set(flat) then dates=strcompress(str_replace(dates,'/',' '),/remove)
   if y2 then dates=strmid(dates,2,100)
   retval=concat_dir(parent,dates)
   return, retval  ; !!! EARLY EXIT !!! if TIMES keyword or only TIME0 defined
endif



if n_params() lt 2 then begin 
   box_message,'Need start and stop times.., returning'
   return,''
endif

case 1 of 
   hourly: begin 
      dtx=ssw_deltat(time0,time1,/min)
      if dtx lt 60 then t1=reltime(time0,/hours,out='ecs') else t1=time1 
      pgrid=timegrid(time0,t1,hours=1, out='ecs')
      pgrid=str_replace(pgrid,':','')
      dd=ssw_strsplit(pgrid,' ',/head, tail=hh)
      pgrid=dd+'/'+'H'+strmid(strtrim(hh,2),0,2) + '00' 
   endcase
   else: begin 
      pgrid=timegrid(anytim(time0,/date_only),anytim(time1,/date_only),$
         days=days, /quiet, month=monthly,out='ecs',/date_only)
         if keyword_set(weekly) then pgrid=anytim2weekinfo(pgrid,/first) else $
            pgrid=strmid(temporary(pgrid),0,5-(y2*2)+(5-monthly*3))
      if monthly and not recursing then begin ; handle "incomplete" months 
         pgrid=[pgrid,ssw_time2paths(time1,time1,flat=flat,parent=' ',/monthly,/recursing)]
         pgrid=pgrid(uniq(pgrid))
      endif 
      if keyword_set(delimit) then $
         pgrid=str_replace(pgrid,'/',delimit(0))
   endcase
endcase
pgrid=pgrid(uniq(pgrid))
if keyword_set(flat) then $
   pgrid=strcompress(str_replace(pgrid,'/',' '),/remove) ; flatten
urls=total(strpos(parent,'://') ne -1) gt 0 ; urls?  

case 1 of 
   recursing: retval=pgrid
   urls: retval=parent+'/'+pgrid 
   else: retval=concat_dir(parent,pgrid)
endcase

if keyword_set(file_pat) then retval=file_list(retval,file_pat) else begin 
   if exist then begin
      sse=where(file_exist(retval),count)
      if count gt 0 then retval=retval(sse) else retval=''
   endif
endelse 
retval=retval(uniq(retval)) 
count=total(retval ne '')

if count gt 0 then begin ; optional append_dir/sub_dir
   if keyword_set(append_dir) then retval=concat_dir(retval,append_dir) else $
      if keyword_set(sub_dir) then retval=concat_dir(retval,sub_dir)
endif

return,retval
end

