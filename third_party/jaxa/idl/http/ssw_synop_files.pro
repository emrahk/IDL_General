function ssw_synop_files, time0, time1, prefix=prefix, _extra=_extra, $
   count=count, synop_parent=synop_parent
;
;   Name: ssw_synop_files
;
;   Purpose: return urls for desired time/instrument from SYNOP_DATA
;
;   Input Parameters:
;      time0 - desired time or start of desired time range
;      time1 - optional stop time of range
;
;   Output Parameters:
;      function returns list of urls matching time and optional instr/prefix
;
;   Keyword Parameters:
;      prefix - optional instrument prefix (or other pattern) to match
;      _extra - optional prefix/pattern via keyword inheritance
;     synop_parent - url of remote $SYNOP_DATA (default is soho/sdac)
;     count (output) - number of matches returned
;
;   Calling Examples:
;     all=ssw_synop_files('15-mar-2001','20-mar-2001')            ; all instr.
;     eit=ssw_synop_files('15-mar-2001','20-mar-2001',pre='eit')  ; eit only
;     eit=ssw_synop_files('15-mar-2001','20-mar-2001',/eit)       ; same
;   
;   History:
;      5-Jan-2005 - S.L.Freeland
;-

debug=keyword_set(debug)
   
count=0                 ; pessimistically, assume total failure
case n_params() of 
   0: begin 
         box_message,'Need input time or time range
         return,''
   endcase
   1: time1=reltime(time0,/days)
   else:
endcase

t0=anytim(time0,/int)
t1=anytim(time1,/int)

if not keyword_set(synop_parent) then synop_parent= $   ; default is SDAC
   'http://sohowww.nascom.nasa.gov/sdb/synop_data'      ; $SYNOP_DATA@gsfc 

tgrid=timegrid(t0,reltime(t1,/days),/days,/date_only)
if n_params() eq 1 then tgrid=tgrid(0)
dddir=time2file(tgrid,/date_only,/year2)              ; YYMMDD subdirs

synop_fits=synop_parent+'/fits'

suburl=synop_fits+'/'+dddir +'/'                      ; unix/sdac server

retval=''
for i=0,n_elements(suburl)-1 do begin
   box_message,'Listing>> ' + suburl(i)
   sock_list,suburl(i),out
   ssfits=where(strpos(out,'.fts') ne -1,fcnt)

   if fcnt gt 0 then begin 
      flist=out(ssfits)
      fnams=dddir(i) + '/' + strextract(flist,'HREF="','">')
      retval=[temporary(retval),synop_fits+'/'+fnams]
   endif else box_message,'No SYNOP_DATA for day...'
   if debug then stop
endfor

nnull=where(retval ne '',count)
if count gt 0 then retval=retval(nnull) else retval=''

if keyword_set(prefix) or data_chk(_extra,/struct) then begin 
   if n_elements(prefix) eq 0 then prefix=(tag_names(_extra))(0)
   spre=strlowcase(prefix)              ; synop_data all lowcase
   sspre=where(strpos(retval,spre) ne -1, count)
   if count gt 0 then retval=retval(sspre) else $
      box_message,'Some files for day but not with requested prefix/pattern
endif

if count gt 0 then begin 
   case n_params() of 
      1: begin 
           if t0(0).time gt 0 then begin            ; full day{, return all
              ftimes=file2time(retval,/parse)
              dtf=abs(ssw_deltat(ftimes,ref=t0))
              ss=(where(dtf eq min(dtf)))(0)
              retval=retval(ss)
              count=1
           endif
      endcase
      else: begin 
         ss=sel_timrange(file2time(retval,/int),t0,t1,/between)
         if ss(0) ne -1 then begin
            count=n_elements(ss)
            retval=retval(ss)
         endif else begin 
            box_message,'Some files on those days but in your time range'
            retval=''
            count=0
         endelse
      endcase
   endcase


endif

return,retval
end
