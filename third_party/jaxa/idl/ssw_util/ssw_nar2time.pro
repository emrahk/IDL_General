function ssw_nar2time, nar, first=first, last=last, central=central, $
   generate=generate, nrecs=nrecs, nar_records=nar_records
;
;+
;   Name: ssw_nar2time
;
;   Purpose: map fron NOAA AR# -> times on disk
;
;   Input Parameter:
;      nar - desire NOAA AR#
;
;   Output:
;      return dates when AR is on-disk (per NOAA AR dbase)
;
;   Keyword Parameters:
;      first - (switch) - if set, first time referenced
;      last  - (switch) - if set, last time referenced
;      central - (switch) if set, return times when region at 0deg Long. 
;      nar_record (output) - NAR records which match
;      nrecs - (output) - number of uniq NAR records (dates) -
;                         0 implies access problem or no matching NAR 
;      out_style - desired time format returned (def='ecs', all per anytim.pro)
;
;
common ssw_nar2time_blk, nardbase
nrecs=0
if not is_number(nar) then begin 
   box_message,'Requires input NOAA AR#
   return,''
endif

tnar=nar
if tnar ge 10000 then tnar=tnar-10000  ; 4 digit nar dbase limit...

sswdb=concat_dir('$SSWDB','packages/nar/data/nar.geny')
http='http://sohowww.nascom.nasa.gov/sdb/pakcages/nar/data/nar.geny'

if keyword_set(generate) and is_member(get_user(),'freeland') then begin 
   box_message,'Generating, please be patient'
   rd_nar,'1-sep-1991',reltime(/now),nar
   savegenx,file=sswdb,nar
   return,''
endif

if n_elements(nardbase) eq 0 then begin 
   if file_exist(sswdb) then restgenx,file=sswdb,nardbase else begin 
      outdir=get_temp_dir()
      locfile=concat_dir(outdir,'nar.geny')
      box_message,'Need to access WWW copy from master...please be patient..'
      sock_copy,http,outdir=outdir
      if file_exist(locfile) then begin 
         restgenx,file=locfile,nardbase
      endif else begin 
         box_message,'Problem with remote access...
         return,''
      endelse
   endelse
endif

ss=where(nardbase.noaa eq tnar,nrecs)

if nrecs gt 0 then begin 
   if n_elements(out_style) eq 0 then out_style='ecs'
   nar_records=nardbase(ss)
   time_window,nar_records,t0,t1,out_style=out_style
   retval=anytim(nar_records,out_style=out_style)
   case 1 of 
      keyword_set(first): begin 
         retval=t0
         nar_records=nar_records(0)
      endcase
      keyword_set(last): begin
         retval=t1
         nar_records=last_nelem(nar_records)
      endcase
      keyword_set(central): box_message,'/CENTRAL not yet implemented...
      else:
   endcase
   if not keyword_set(central) then $
      retval=anytim(retval,out_style=out_style,/truncate)
endif


return,retval
end
