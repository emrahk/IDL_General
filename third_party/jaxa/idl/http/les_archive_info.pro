function les_archive_info, time0, time1, current=current, $ 
   count=count, $
   summary_url=summary_url, event_url=event_url, $
   movie_url=movie_url, sxi=sxi, eit=eit, $
   locator_url=locator_url, $
   refresh=refresh , debug=debug
;
;+       
;   Name: les_archive_info
;
;   Purpose: return info from SolarSoft Latest Events Archive
;
;   Input Parameters:
;      time0 - time or event name -or- start time of range
;      time1 - optional stop time of range
;
;   Output:        
;      default output is 'latest_events' data structure(s)
;      or as defined/limited by optional keyword switches
;      representative structure(s)
;         ** Structure <20d2d8>, 13 tags, length=176, data length=166, refs=1:
;   DATE_OBS        STRING    '2004-01-10T01:21:00.000'
;   ENAME           STRING    'gev_20040110_0116'
;   CLASS           STRING    'C1.2'
;   FSTART          STRING    '2004/01/10 01:16:00'
;   FSTOP           STRING    '2004/01/10 01:23:00'
;   FPEAK           STRING    '2004/01/10 01:21:00'
;   XCEN            INT            510
;   YCEN            INT           -145
;   HELIO           STRING    'S11W32'
;   LFILES          STRING    'SXI_20040110_011410851_BB_12.FTS,SXI_20040110'..
;
;      If two parameters are passed, records/fields within the range
;         are returned
;      If one parameter is supplied, then:
;        If date only (no time), all records for the day are returned
;        If date+time,  it is interpreted as an event time, and only 
;           the closest record is returned
;
;   Keyword Parameters:
;      summary_url (switch) - if set, output is top level summary URL(s)
;      event_url   (switch) - if set, output is event level URLS(s)
;      movie_url   (switch) - if set, output is movie_url(s)
;      sxi/eit     (switch) - preference of movie_url output
;      loc_url     (switch) - if set, output is locator image url used
;      helio       (switch) - if set, output is heliographic location(s) 
;      current     (switch) - if set, use current 'latest_events', not archive
;      refresh     (switch) - if set, force update of socket metaindex list 
;                             (socket listing -> common block)
;      count (output)       - number of valid things returned; zero if problem.. 
;
;   Calling Examples:
;      levts=les_archive_info('5-nov-2003')       ; all records for day 
;      levts=les_archive_info('5-NOV-03  10:46')  ; One record (closest)

;      levts=les_archive_info('4-nov-2003 15:00', '6-nov-2003 12:00') ; range

;      more,les_archive_info('5-nov-2003',/summary_url)             ; summary url 
;         http://www.lmsal.com/solarsoft/last_events_20031107_1014  ; ~centered
;
;   Common Blocks:
;      les_archive_info_blk - output of meta index socket listing
;
;   History:
;      14-jan-2004 - S.L.Freeland
;
;   Restrictions:
;     Requires IDL version >= 5.4 since it uses rsi 'socket' procedure 
;     BETA - only /SUMMARY_URL and default output (full dbase structures)
;            implemented as of today...
;
;   Note: although I may change the where (archive home(s) ) and how of 
;         deriving the data returned by this function, it should keep working...
;         Let me know otherwise: freeland@penumbra.nascom.nasa.gov
;-
common les_archive_info_blk, summaries, summtimes, lastsumm, lastdbase
;
current=keyword_set(current)

debug=keyword_set(debug)
metaparent=get_logenv('SSW_LATEST_EVENTS_ARCHIVE')
if metaparent eq '' then $
   metaparent='http://www.lmsal.com/solarsoft/latest_events_archive.html'

count=0                              ; somewhat pessimistically, assume failure...

if not since_version('5.4') then begin 
   box_message,'Requires IDL Version >= 5.4 due to use of <socket> procedure...'
   return,''
endif

if n_params() eq 0 and (1-current) then begin 
   box_message,'You must supply a time, event name or time range..., returning'
   return,''
endif 

refresh=keyword_set(refresh) or n_elements(summaries) eq 0

if refresh then begin 
   sock_list,metaparent,htmlindex
   htmlindex=strlowcase(htmlindex)
   sumurls=strextract(htmlindex,'href="last_events_','/index.html"')
   sumss=where(sumurls ne '',sumcnt)
   if sumcnt eq 0 then begin 
      box_message,'Problem with access or interpretation of metaindex, returning...'
      return,''
   endif
   sumurls=sumurls(sumss)
   sumurls=sumurls(sort(sumurls))   ; force chron. order
   summaries=sumurls
   summtimes=file2time(sumurls,out='utc_int',/parse_timex) 
   lastsumm=''                      ; initialize
   lastdbase=''                     ; ditto
endif

break_url,metaparent,IP,subdir,file
topurl='http://'+IP+ '/'+ subdir   ; summaries relative to this

dt0=ssw_deltat(summtimes,ref=time0,/days)
ss0=where(dt0 ge 1 and dt0 le 4, scnt)

if scnt eq 0 then begin 
  box_message,'No Latest Events archival data for input time>> ' + $
     anytim(time0,out='vms') + '..returning'
  return,''
endif 

sumurls=topurl + 'last_events_' + summaries(ss0)            
if keyword_set(summary_url) then begin        ; have enough for this return 
   retval=sumurls(scnt/2)      ; ~center
endif else begin                    ; need more detail...
   latestsumm=sumurls(scnt-1)       ; most recent (better solution sometimes..)
   case 1 of 
      current: begin 
         gevdata=get_gevloc_data()     ; current (ie, real latest_events)
         time_window,gevdata.date_obs,t0,t1,min=10
         if n_elements(time0) eq 0 then time0=t0
         if n_elements(time1) eq 0 then time1=t1
      endcase
      latestsumm ne lastsumm: begin 
         gevdata=get_gevloc_data(archive_url=latestsumm)
         lastdbase=gevdata             ; update common 
         lastsumm=latestsumm           ; update common
      endcase
      else: gevdata=lastdbase          ; else, use common 
   endcase
   if data_chk(gevdata,/struct) then begin
       retval=gevdata 
       fullday=n_params() eq 1 and $
          anytim(time0) eq anytim(time0,/date_only)    ; full day desired? 
       if fullday then time1=reltime(time0,/days)       ; 24 hours
       if data_chk(time1,/string) then time1=strtrim(time1,2)
       if 1-keyword_set(time1) then begin 
          ss=tim2dset(anytim(retval.date_obs,/int), $
                      anytim(time0,/int), delta=dts)
          if dts gt 3600 and not fullday then box_message,$
             'Warning: closest event match is ' + strtrim(dts/60.,2) + $
              ' minutes from your input time...' 
        endif else begin 
           ss=sel_timrange(anytim(retval.date_obs,/int), /between,$
                           anytim(time0,/int), anytim(time1,/int) )
       endelse
       if ss(0) ne -1 then begin 
          retval=retval(ss)
          murls=gt_tagval(retval,/url_movie,missing='')
          oldroot=strextract(murls,'last_events_summary_','/gev')
          arcurl=str_replace(murls,'last_events_summary_'+oldroot(0), $
               'latest_events_summary')
          if murls(0) ne '' then retval.url_movie=arcurl 
          case 1 of
             keyword_set(locator_url): begin 
                retval=les_archive_info(retval(0).date_obs, $
                 /summary_url) + '/' + retval(0).ename + '.png'
             endcase
             keyword_set(event_url): retval=retval.url_index
             keyword_set(sxi): $
                retval=str_replace(retval.url_movie,'_lm',$
                                                    '_sxilm')
             keyword_set(eit): retval=retval.url_movie
             keyword_set(movie_url): retval=retval.url_movie
             else:
           endcase


           
       endif else box_message,'No records within your time range...
   endif else begin
       box_message,'Unexpected output from <get_gev_loc_data.pro>
       retval=''
   endelse 	               ;
   
endelse

if debug then stop,'before return...'
   
return,retval

end

