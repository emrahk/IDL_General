;+
; Project     : SOHO - CDS
;
; Name        : PRINT_NAR
;
; Purpose     : Wrapper around GET_NAR
;
; Category    : planning
;
; Explanation : Print NOAA AR listing
;
; Syntax      : IDL>print_nar,tstart,tend
;
; Inputs      : TSTART = start time 
;
; Opt. Inputs : TEND = end time
;
; Outputs     : NOAA listing in HTML table format
;
; Opt. Outputs: None
;
; Keywords    : ERR = error messages
;               PREVIOUS = previous settings string
;               NO_SELECT = set to inhibit selections
;               FILE = previous settings are in a file
;               OUTPUT = output file for listing
;
; History     : Version 1,  20-June-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro print_nar,tstart,tend,err=err,previous=previous,output=output,$
           no_select=no_select,file=file,entry=entry,limit=limit
               
on_error,1
err=''

if datatype(output) eq 'STR' then begin
 break_file,output,dsk,dir,name
 outdir=trim2(dsk+dir)
 if outdir eq '' then outdir=curdir()
 if not test_dir(outdir,err=err) then return
endif       
      
if not exist(limit) then limit=60
nar=get_nar(tstart,tend,err=err,count=count,/quiet,/no_helio,limit=limit,/unique)

if err ne '' then begin
 table=err  & goto,done
endif

times=replicate({time:0l,day:0},count)
day=gt_day(nar,/str)
times.day=nar.day
times.time=nar.time
noaa=trim2(string(nar.noaa))
none=where(noaa eq '0',acount)
if acount gt 0 then noaa(none)='&nbsp'
location=nar.location 
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

allow_select=1b
if exist(no_select) then allow_select=(fix(no_select) ne 1)
check='<input type=checkbox'
id='"'+trim2(day)+','+trim2(loc)+','+trim2(noaa)+'"'
id2=trim2(day)+','+trim2(loc)+','+trim2(noaa)
name=' name='+id
value=' value='+id
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
  contents=rd_ascii(previous,lun=lun)
  if exist(lun) then if (lun gt 0) then free_lun,lun
  delim=' '
 endif else begin
  contents=previous
  delim='+'
 endelse
 pre=trim2(str2arr(contents,delim))
 chk=where_arr(id2,pre,ccount)
 if ccount gt 0 then checked(chk)=" checked " 
endif
checkbox=check+checked+value+onclick+'>'

if allow_select then begin
 label="Accept"
 head='<center><form name="NOAA"> <b>Select NOAA active regions'
endif else begin
 label="Close"
 prefix=''
 if is_number(entry) then prefix='<br>Catalog entry: '+num2str(entry)+'<b>'
 head='<center><form name="NOAA"> <b>Observed NOAA active regions</b>'+prefix
endelse


head=head+'<br><br><input type=button value='+label+' onClick="self.close();">'
if allow_select then begin
 head=head+'&nbsp &nbsp <input type=button value="Select All" onClick="checkAll();">'
 head=head+'&nbsp &nbsp <input type=button value="Reset" onClick="resetAll();">'
endif
head=head+'</b><br><br> <table border=1 cellspacing=0 cellpadding=2>'
thead='<tr bgcolor="lightblue">
th='<th align=center>'
eth='</th>
heads=['Date','Location','AR #','&nbsp ']
for i=0,n_elements(heads)-1 do thead=thead+th+heads(i)+eth

tr=replicate('<tr>',count)
td=replicate('<td align=center>',count)

tbody=tr+td+day+td+loc+td+noaa+td+checkbox
if (ccount gt 0) and (1-allow_select) then tbody=tbody(chk)

table=[head,thead,tbody,'</table></form></center>']

done:                 
if datatype(output) eq 'STR' then begin
 openw,lun,output,/get_lun
 printf,lun,table
 free_lun,lun
 espawn,'chmod a+w '+output
endif else print,table


return & end


