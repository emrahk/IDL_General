function yohkoh_legacy_files, time0, time1, _extra=_extra, $
   ssc=ssc, topurl=topurl, count=count, debug=debug, $
   force_url=force_url, quiet=quiet
;
;+
;   Name: yohkoh_legacy_files
;
;   Purpose: return Yohkoh Legacy filenames for user input times
;
;   Input Parameters:
;      time0 - time or start of time range
;      time1 - optional end time if range
;     
;   Output:
;       function returns list of files (paths if local else URLs)
; 
;   Keyword Parameters:
;      ssc - if set, default to SSC files
;      count - number of files/urls returned
;      force_url - if set, return URLs even if data is 'local'
;                  (only required at Legacy host sites + URLS desired)
; 
;   History:
;      14-Feb-2005 - S.L.Freeland - hook new SSC-FITS->CoSEC/SSW
;      16-nov-2006 - S.L.Freeland - html parse case independent
;
;-
common yohkoh_legacy_files_blk, last_dir,last_listing
debug=keyword_set(debug)
loud=1-keyword_set(quiet)
if n_elements(last_dir) eq 0 then begin 
   last_dir=''
   last_listing=''
endif

deflegacy=get_logenv('YOHKOH_LEGACY')
defssc=get_logenv('YOHKOH_LEGACY_SSC')
force_url=keyword_set(force_url)
local=file_exist(deflegacy) 
case 1 of
   data_chk(topurl,/string):
   keyword_set(ssc) and defssc ne '': topurl=defssc
   local and (1-force_url): topurl=deflegacy
   else: topurl='http://solar.physics.montana.edu/ylegacy/ssc_fits/'
endcase

case n_params() of
   0: begin 
         box_message,'Need a time or time range...'
         return,''
   endcase
   1: time1=time0
   else:
endcase

tgrid=timegrid(anytim(time0,/utc_int),anytim(time1,/utc_int), $
                      /quiet,/days, /ecs,  /date_only)

retval=''
ndays=n_elements(tgrid)

topurl=topurl+(['','/'])(str_lastpos(topurl,'/') ne strlen(topurl)-1)

sdurls=topurl+tgrid+'/'
retval=''  

for i=0,ndays-1 do begin 
   box_message,['listing>> ' + sdurls(i)]
   if local then begin 
      files=findfile(sdurls(i))
      ss=where(strpos(files,'.fts') ne -1,count)
      if count gt 0 then retval=[temporary(retval),sdurls(i)+files] 
   endif else begin 
      if sdurls(i) ne last_dir then begin
         sock_list,sdurls(i),sdlist
         last_dir=sdurls(i)
         last_listing=sdlist
      endif else sdlist=last_listing ; use cached value 
      ssfts=where(strpos(sdlist,'.fts') ne -1, fcnt)
      if fcnt gt 0 then begin
         parsref=(['href="','HREF="'])(strpos(sdlist(ssfts(0)),'HREF=') ne -1)
         rettmp=sdurls(i)+strarrcompress(strextract(sdlist(ssfts),parsref,'">'))
         if rettmp(0) ne '' then retval = [temporary(retval),rettmp] else $
             box_message,'Problem with html listing parse...'
      endif
   endelse
endfor

ssok=where(retval ne '',count)
if count gt 0 then begin
   retval=retval(ssok) 
   case 1 of 
      n_params() eq 1 and anytim(time0) ne anytim(time0,/date_only): begin 
         ftimes=file2time(retval,/parse,out='int')
         ss=tim2dset(ftimes,time0)
         retval=retval(ss)              ; return closest
      endcase
      n_params() eq 2: begin
         ftimes=file2time(retval,/parse,out='int')
         ss=sel_timrange(ftimes,anytim(time0,/int),anytim(time1,/int),/between)
         if ss(0) ne -1 then retval=retval(ss) else begin 
            box_message,'No files in your time range...'
            retval=''
         endelse
      endcase
      else:
   endcase
endif else  retval=retval(0) 

if debug then stop,'retval'
return,retval
end



