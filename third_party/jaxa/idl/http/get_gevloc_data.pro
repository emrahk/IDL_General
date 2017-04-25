function get_gevloc_data, enames, path=path, gevloc_file=gevloc_file, $
   force_remote=force_remote, merge=merge, temp=temp, $
   archive_url=archive_url
;
;+
;   Name: get_gevloc_data
;
;   Purpose: return contents of gev/flare location file (structure vector)
;
;   Input Parameters:
;      enames - optional specfic event name pattern to search/return
;              (if not supplied, entire contens of gevloc file returned)
;
;   Keyword Parameters:
;      path (input) - subdirectory to use (default is current 'last_events')
;      gevloc_file - subdirectory used (if gevloc file found)
;      force_remote - (switch) - if set, force remote access via sock_copy
; 
;  Calling Sequence:
;     gevloc=get_gevloc_data()       ; return entire 'latest_events' data
;     gevloc=get_gevloc_data(enames) ; specific events (using gev_YYYYMMDD_HHMM)
;               
;
;   History:
;      10-Apr-2001 - S.L.Freeland - helper utility for last_events maint
;      16-Apr-2001 - S.L.Freeland - use sockets if not local and >+5.4 IDL
;      11-Apr-2003 - S.L.Freeland - add /MERGE and /TEMP functions
;      14-Jan-2004 - S.L.Freeland - add ARCHIVE_URL keyword&function
;
;   Restrictions:
;      for remote access, requires IDL >= 5.4
;
;-
force_remote=keyword_set(force_remote) or keyword_set(archive_url)
gevloc_fname='ssw_gev_locate.geny'
temp=keyword_set(temp)
merge=keyword_set(merge)
 
tempdir=(['','_temp'])(temp)

if not data_chk(path,/string) then path= $
   '/net/diapason/www1/htdocs/solarsoft/last_events' + tempdir + '/'
if merge then begin                              ; recursive
   primary=get_gevloc_data(force_remote=force_remote)
   tempgev=get_gevloc_data(force_remote=force_remote,/temp)
   case 1 of 
      data_chk(primary,/struct) and data_chk(tempgev,/struct): begin    ; merge
         box_message,'Merging...
         merged=concat_struct(primary,tempgev)
         order=sort(merged.ename)
         merged=merged(order)
         merged=merged(uniq(merged.ename))
         retval=merged
      endcase
      data_chk(primary,/struct): retval=primary
      data_chk(tempgev,/struct): retval=tempgev
      else: box_message,'Nothing in primary -OR- temporary
   endcase
   return,retval
endif

file=file_list(path,gevloc_fname)                    ; local? 
if data_chk(archive_url,/string) then $ 
   http_parent=archive_url else       $                   ; use archive
      http_parent='www.lmsal.com/solarsoft/latest_events' ; default=latest

if not file_exist(file(0)) or force_remote then begin ; try remote 
   if temp then return,-1 ; unstructured exit (no TEMP if is often expected)
   if since_version('5.4') then begin                 ; need RSI socket
      outdir=get_temp_dir()                           ; where to stick it
      url=concat_dir(http_parent,gevloc_fname)
      dtemp=!d.name
      set_plot,'z
      box_message,['Retrieving latest events dbase: ' , url]
      ssw_file_delete,concat_dir(outdir,gevloc_fname)
      sock_copy,url,out_dir=outdir
      set_plot,dtemp
      file=concat_dir(outdir,gevloc_fname)            ; where it should be now
   endif else box_message,'You need IDL version >= 5.4 to access the latest events location file remotely'
   if not file_exist(file(0)) then begin 
      box_message,'Cannot find latest events file, returning
      return,-1
   endif
endif

gevloc_file=file(0)              ;  return name via GEVLOC_FILE keyword
restgenx,file=file(0),gevloc     ; file -> gevloc structure vector

ss=where(gevloc.helio ne '',sscnt)
if sscnt eq 0 then begin 
   box_message,'No location solutions in file...'
   return,-1
endif
retval=gevloc(ss)                    ; default is entire contents

if n_elements(enames) gt 0 then begin  
   times=enames     				   ; times in?
   if strpos(string(enames(0)),'_') ne -1 then $   ; event names in?
       times=file2time(enames,out='ints')
   etimes=anytim(retval.date_obs,out='ints')       ; dbase event times
   ss=tim2dset(etimes,times,delta_sec=dts)         ; user:events
   if max(dts) gt 30.*60 then $                    ; warn if "big" dT
      box_message,'At least one record differs from your input by > 30 minutes'
   retval=retval(ss)
endif

; add implied URLs for page & movie
urltop=concat_dir(http_parent,retval.ename)
urls_index=urltop+'.html'
urls_movie=concat_dir(str_replace(urltop,'_events','_events_summary') $
     ,retval.ename) + '_lm.html'

retval=add_tag(retval,'','url_index')
retval=add_tag(retval,'','url_movie')
retval.url_index=urls_index
retval.url_movie=urls_movie
return,retval
end
