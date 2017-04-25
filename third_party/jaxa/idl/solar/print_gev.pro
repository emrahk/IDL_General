;+
; Project     : SOHO - CDS
;
; Name        : PRINT_GEV
;
; Purpose     : Wrapper around GET_GEV
;
; Category    : planning
;
; Explanation : Get GOES Event listing
;
; Syntax      : IDL>print_gev,tstart,tend
;
; Inputs      : TSTART = start time 
;
; Opt. Inputs : TEND = end time
;
; Outputs     : GOES event listing in HTML table format
;
; Opt. Outputs: None
;
; Keywords    : ERR = error messages
;               PREVIOUS = previous settings
;               FILE = previous settings are in a file
;               NO_SELECT = disable selections
;               OUTPUT = output file for listing
;
; History     : Version 1,  20-June-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro print_gev,tstart,tend,err=err,previous=previous,no_select=no_select,$
              file=file,entry=entry,limit=limit,output=output

err=''
count=0

if datatype(output) eq 'STR' then begin
 break_file,output,dsk,dir,name
 outdir=trim2(dsk+dir)
 if outdir eq '' then outdir=curdir()
 if not test_dir(outdir,err=err) then return
endif            

;-- call RD_GEV

if not exist(limit) then limit=60
gev=get_gev(tstart,tend,count=count,err=err,/quiet,limit=limit)

if err ne '' then begin
 table=err  & goto,done
endif
                                                
times=replicate({time:0l,day:0},count)
day=gt_day(gev,/str) & tstart=gt_time(gev,/str) 
times.day=gev.day
times.time=gev.time
tpeak=times & tpeak.time=tpeak.time+gev.peak*1000
tstop=times & tstop.time=tstop.time+gev.duration*1000
tpeak=gt_time(tpeak,/str)
tstop=gt_time(tstop,/str)
class=trim2(string(gev.st$class))
halpha=trim2(string(gev.st$halpha))
noaa=trim2(string(gev.noaa))
none=where(noaa eq '0',acount)
if acount gt 0 then noaa(none)='&nbsp'
location=gev.location 
ns=location(1,*) & ew=location(0,*) 
none=where( (abs(ns) gt 970) or (abs(ew) gt 970),zcount)
south=where(ns lt 0,scount)
north=where(ns ge 0,ncount)
east=where(ew lt 0,ecount)
west=where(ew ge 0,wcount)
ns=string(abs(ns),'(i2.2)')
ew=string(abs(ew),'(i2.2)')
if scount gt 0 then ns(south)='S'+ns(south)
if ncount gt 0 then ns(north)='N'+ns(north)
if ecount gt 0 then ew(east)='E'+ew(east)
if wcount gt 0 then ew(west)='W'+ew(west)
loc=ns+ew
if zcount gt 0 then loc(none)='&nbsp'

;-- construct check boxes

tstart=strmid(tstart,0,5)
tpeak=strmid(tpeak,0,5)
tstop=strmid(tstop,0,5)
check='<input type=checkbox'
id='"'+trim2(day)+','+trim2(tstart)+','+trim2(class)+'"'
id2=trim2(day)+','+trim2(tstart)+','+trim2(class)
name=' name='+id
value=' value='+id

allow_select=1b
if exist(no_select) then allow_select=(fix(no_select) ne 1)

if allow_select then begin
 onclick=' onClick="addValue(this.value,this.checked);"'
endif else begin
 onclick=' onClick="this.checked=!(this.checked);"'
endelse

;-- check for previous settings

checked=strarr(count)
ccount=0
if datatype(previous) eq 'STR' then begin
 if keyword_set(file) then begin
  previous=rd_ascii(previous,lun=lun)
  if exist(lun) then if (lun gt 0) then free_lun,lun
  delim=' '
 endif else delim='+'
 pre=trim2(str2arr(previous,delim))
 chk=where_arr(id2,pre,ccount)
 if ccount gt 0 then checked(chk)=" checked "
endif

checkbox=check+checked+value+onclick+'>'   

if allow_select then begin
 head='<center><form name="GOES"> <b>Select GOES events (times in UT)'
endif else begin
 prefix=''
 if is_number(entry) then prefix='<br>Catalog entry: '+num2str(entry)+'<b>'
 head='<center><form name="GOES"><b>Observed GOES events (times in UT)</b>'+prefix
endelse

if allow_select then label="Accept" else label="Close"
head=head+'<br><br><input type=button value='+label+' onClick="self.close();">'
if allow_select then begin
 head=head+'&nbsp &nbsp <input type=button value="Select All" onClick="checkAll();">'
 head=head+'&nbsp &nbsp <input type=button value="Reset" onClick="resetAll();">'
endif
head=head+'</b><br><br> <table border=1 cellspacing=0 cellpadding=2>'
thead='<tr bgcolor="lightblue">
th='<th align=center>'
eth='</th>
heads=['Date','&nbsp Start &nbsp','&nbsp Peak &nbsp','&nbsp End &nbsp','&nbsp Class &nbsp',' Location ',' NOAA AR # ','&nbsp']
for i=0,n_elements(heads)-1 do thead=thead+th+heads(i)+eth

tr=replicate('<tr>',count)
td=replicate('<td align=center>',count)

tbody=tr+td+day+td+tstart+td+tpeak+td+tstop+td+class+td+loc+td+noaa+td+checkbox

if (ccount gt 0) and (1-allow_select) then tbody=tbody(chk)
                                           
table=[head,thead,tbody,'</table></form></center>']

done:                 
if datatype(output) eq 'STR' then begin
 openw,lun,output,/get_lun
 printf,lun,table
 close,lun
 free_lun,lun,/force
 espawn,'chmod a+w '+output
endif else print,table

return & end


