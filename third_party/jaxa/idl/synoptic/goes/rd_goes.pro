;+
; Project     : HESSI
;
; Name        : RD_GOES
;
; Purpose     : read GOES data
;
; Category    : synoptic gbo
;
; Syntax      : IDL> rd_goes,times,data,trange=trange
;
; Inputs      : None
;
; Outputs     : TIMES = time array (SECS79)
;               DATA  = data array (# TIMES x 2)
;
; Keywords    : TRANGE=[TSTART, TEND] = time interval to select
;               TAI = TIMES in TAI format
;               NO_CYCLE = don't search each satellite
;               SAT = satellite number to search
;                     (updated if NO_CYCLE=0)
;
; History     : Written 18 Feb 2001, D. Zarro, EITI/GSFC
;               14-Dec-2005 - changed err message text
;               Modified 5 May 2007, Zarro (ADNET/GSFC)
;                - changed /NO_SEARCH to /NO_CYCLE
;               10-Aug-2008, Kim. 
;                - Call sat_names with /since_1980)
;                - Don't print error msg about no data, just pass back
;               20-Jan-2012, Zarro (ADNET)
;                - replaced "not" with "~", and used a temporary
;                  when concatanating channel data.
;                - added more error checking for invalid times
;                - added more descriptive /VERBOSE output
;                - added GOES_SAT_LIST to control search list
;                19-Feb-2012, Zarro (ADNET)
;                - changed message,/cont to message,/info because
;                  /cont was setting !error_state
;                16-Apr-2012, Zarro (ADNET)
;                - fixed dimensions of returned DATA
;                13-Apr-2013, Zarro (ADNET)
;                - added check for start time greater than current time
;   
; Contact     : dzarro@solar.stanford.edu
;-

pro rd_goes,times,data,err=err,trange=trange,count=count,tai=tai,$
            _extra=extra,status=status,verbose=verbose,gdata=gdata,$
             type=type,sat=sat,gsat=gsat,no_cycle=no_cycle


;-- usual error checks

verbose=keyword_set(verbose)
cycle=~keyword_set(no_cycle)

err=''
count=0
delvarx,times,data
gsat=''
type=''
status=0
res='3 sec'

time_input=0
if ~valid_range(trange,/time) then begin
 err='Invalid or missing input times.'
 message,err,/info
 return
endif

stime=trange[0]
etime=trange[1]
get_utc,utc
ctime=anytim(utc)
tstart=anytim(stime)

if tstart gt ctime then begin
 err='No YOHKOH/GOES data available for specified times.'
 message,err,/info
 return
endif

tend=anytim(etime) < ctime
t1=anytim(tstart,/int)
t2=anytim(tend,/int)

;-- GOES satellite can be entered as a number (e.g. 12) or as a keyword
;   (e.g. /GOES12)

chk=have_tag(extra,'goe',index,/start,tag=tag)
if ~is_number(sat) then begin
 if chk then begin
  msat=stregex(tag[0],'goes'+'([0-9]+)',/extract,/sub,/fold)
  if is_number(msat[1]) then sat=fix(msat[1])
 endif
endif

;-- generate satellite search list

search_sats=goes_sat_list(sat,count=count,_extra=extra,err=err,/since_1980,no_cycle=no_cycle)
if count eq 0 then begin
 status=1
 gsat=''
 return
endif

;-- cycle thru each available GOES satellite 
;   unless /no_cycle set

if is_struct(extra) and (index gt -1) then extra=rem_tag(extra,index)
if have_tag(extra,'fiv',/start) then res='5 min'
if have_tag(extra,'one',/start) then res='1 min'

for i=0,n_elements(search_sats)-1 do begin
 tsat=search_sats[i]
 sat_name='GOES'+trim(tsat)
 nextra=add_tag(extra,1,sat_name)
 if verbose then message,'Searching for '+sat_name+'...',/info

 rd_gxd,t1,t2,gdata,_extra=nextra,status=status,verbose=verbose,check_sdac=0

 if is_struct(gdata) then begin
  type=sat_name+' '+res
  if verbose then message,'Found '+type+' data.',/info

;-- unpack the data

  if n_params() eq 1 then $
   if keyword_set(tai) then times=anytim(gdata,/tai) else times=anytim(gdata)
  if n_params() eq 2 then $
   data=[[temporary([gdata.lo])],[temporary([gdata.hi])]]

  count=n_elements(gdata)
  gsat=sat_name & sat=tsat
  return
 endif
endfor


gsat='GOES'+trim(sat)
no_data_error='No '+ (cycle?'YOHKOH/GOES':gsat) +' data available for specified times.'
err=no_data_error
message,no_data_error,/info

delvarx,gdata

return
end
