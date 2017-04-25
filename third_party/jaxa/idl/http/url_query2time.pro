function url_query2time, query_str, _extra=_extra, nodef=nodef
;
;+
;   Name: url_query2time
;
;   Purpose: convert WWW FORM-POST queries to standard format
;
;   Calling Sequence:
;      time=url_query2time(/type) 		; t
;
;   Calling Examples:
;      starttime=url_query2time(/start)		; query tags start_xxx
;      stoptime =url_query2time(/stop)		; query tags stop_xxx
;      reftime  =url_query2time(/ref)		; query tags ref_xxx
;
;   History:
;      Circa 1997 - original FORM->ssw time convertor
;      10-nov-2005 - add START_TIME, STOP_TIME, DAY checks
;
if not data_chk(_extra,/struct) then begin
   message,/info,"Must supply a keyword..."
   return,query_str
endif

pre=(tag_names(_extra))(0)
start_time=gt_tagval(query_str,/START_TIME,missing= $
   gt_tagval(query_str,/PARAM1,missing=''))
stop_time=gt_tagval(query_str,/STOP_TIME,missing=  $
   gt_tagval(query_str,/PARAM2,missing=''))
day=gt_tagval(query_str,/DAY,missing='', $
   gt_tagval(query_str,/PARAM1,missing=''))

case 1 of 
   pre eq 'START' and start_time ne '': outtime=start_time
   pre eq 'STOP'  and stop_time ne '' : outtime=stop_time
   pre eq 'STOP'  and start_time ne '': outtime=$
     timegrid(start_time,days=1,/vms,/truncate)
   day ne '': outtime=timegrid(day,days=([0,1])(pre eq 'STOP'),/vms,/date_only)
   else: begin 
   
if keyword_set(nodef) then deftime=strarr(6) else begin
   ut=str2arr(strcompress(strtrim(ut_time(),2)),' ')
   deftime=[str2arr(ut(0),'-'), str2arr(ut(1),':')]
endelse

parts=strupcase(str2arr('day,month,year,hour,min,sec'))

np=n_elements(parts)

outtime=''
piece=''
delims=['','-','-','  ',':',':','']

for i=0,np-1 do begin
   ss=tag_index(query_str,pre+'_'+parts(i))
   if ss ne -1 then piece=query_str.(ss) else piece=deftime(i)
   outtime=([outtime, outtime + delims(i) + piece])(piece ne '')
endfor
endcase
endcase


return, outtime
end   
