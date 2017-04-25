function ace_files, t0, t1, count, _extra=_extra, daily=daily, monthly=monthly
;
;+
;
;   Name: ace_files
;
;   Purpose: return ace data file names for desired time range & type
;
;   Input Parameters:
;      t0,t1 - desired time range
;
;   Output:
;      function returns file list
;     
;   History:
;
;      5-Sep-2001 - S.L.Freeland
;      6-Sep-2001 - S.L.Freeland - handle "current" daily file (fixed name)
;-
monthly=keyword_set(monthly)
daily=keyword_set(daily) or (1-monthly)
case 1 of 
   data_chk(_extra,/struct): acetype=strlowcase((tag_names(_extra))(0))
   else: acetype='swepam'
endcase

topace=get_logenv('SSW_ACE_DATA')
if topace eq '' then topace=concat_dir('$SSWDB','ace')

case 1 of 
   keyword_set(daily): datadir=concat_dir(topace,'daily')
   else: datadir=concat_dir(topace,'monthly')
endcase

acefiles=file_list(datadir,'*ace_'+acetype+'*.txt')

break_file,acefiles,ll,pp,ff
dates=ssw_strsplit(ff,'_ace_',tail=tail,/last)

fdates=dates+(['','01'])(strlen(dates) eq 6)
ssnull=where(fdates eq '',ncnt)
if ncnt gt 0 then fdates(ssnull)=time2file(ut_time(),/date_only)
if n_params() eq 0 then t0 = file2time(fdates(0),/ecs)

if n_elements(t1) eq 0 then t1=t0

f0=(time2file(t0,/date_only))(0)
f1=(time2file(t1,/date_only))(0)
if monthly then begin 
   f0=strmid(f0,0,6)+'01'
   f1=strmid(f1,0,6)+'01'
endif
fss=where(fdates ge f0 and fdates le f1,count)

retval=''
if count gt 0 then retval=acefiles(fss) else $
   box_message,'No files found matching time/type


return,retval
end  

