;+
; Project     : SOHO
;
; Name        : GET_SOHO_ROLL
;
; Purpose     : retrieve current SOHO roll state
;
; Category    : planning
;
; Syntax      : IDL> roll=get_soho_roll(date)
;
; Inputs      : DATE = required date of roll [def = current UT]
;
; Outputs     : ROLL = roll degrees clockwise from N
;
; Keywords    : VERBOSE = set for output
;               FORCE = set to force reading (otherwise cache is used)
;               REMOTE = force reading via socket (mainly for testing)
;
; Restrictions: None yet
;
; History     : Written 3 July 2003, D. Zarro (EER/GSFC)
;               Modified 1 October 2003, Zarro (GSI/GSFC) - removed "break" for
;               backwards IDL compatibility.
;               Modified 16 March 2004, Zarro (L-3Com/GSFC) - added sort
;               to roll_data.
;               Modified 26 Dec 2005, Zarro (L-3Com/GSFC) - removed depecrated
;               /NO_PROTOCOL keyword 
;               Modified 22 Aug 2008, Zarro (ADNET) - checked for tabs
;               in roll data file. 
;
; Contact     : dzarro@solar.stanford.edu
;-
;-------------------------------------------------------------------------------
;
;-- utility function to parse roll data file

function parse_soho_roll,roll_data,date,force=force

common parse_soho_roll,last_date,last_roll

if keyword_set(force) then delvarx,last_date,last_roll
if is_blank(roll_data) then return,0

;-- convert to UTC

if valid_time(date) then utc=anytim2utc(date) else get_utc,utc 
cdate=anytim2tai(utc)

;-- return last roll if date unchanged

if (valid_time(last_date) and exist(last_roll) ) then begin
 if cdate eq last_date then return,last_roll
endif

;-- search for last roll change before input date
 
roll_value=0.
nr=n_elements(roll_data) 
for i=nr-1,0,-1 do begin
 val=str2arr(strcompress(strtrim(roll_data[i],2)),delim=' ')
 if n_elements(val) ge 3 then begin
  rtime=val[0]+' '+val[1]
  if valid_time(rtime) then begin
   rtime=anytim2tai(rtime)
   if cdate ge rtime then begin
    roll_value=float(val[2])
    last_roll=roll_value
    last_date=cdate 
    return,roll_value
   endif
  endif
 endif
endfor

return,roll_value

end

;----------------------------------------------------------------------------

function get_soho_roll,date,verbose=verbose,force=force,remote=remote,err=err

common get_soho_roll,roll_data,roll_time

err=''
verbose=keyword_set(verbose)

get_utc,now & now=anytim2tai(now)
if valid_time(date) then cdate=anytim2tai(date) else cdate=now

;-- check if need to re-read roll history

force=keyword_set(force)
if valid_time(roll_time) then if (cdate-roll_time) gt 24.*3600.d then force=1b
if force then delvarx,roll_data,roll_time
remote=keyword_set(remote)

;-- check if roll data available 

if is_blank(roll_data) then begin

;-- search locally first

 roll_name='/attitude/roll/nominal_roll_attitude.dat' 
 if not remote then begin
  roll_file=local_name('$ANCIL_DATA'+roll_name)
  chk=loc_file(roll_file,count=count,err=err)
  if count gt 0 then begin
   if verbose then message,'reading '+chk[0],/cont
   roll_data=rd_ascii(chk[0])
  endif
 endif

;-- check remotely if not found

 if is_blank(roll_data) then begin
  err=''
  if allow_sockets(err=err) then begin
   server=synop_server(/full,/soho)
   url_file=server+'/data/ancillary'+roll_name
   if verbose then message,'reading '+url_file,/cont
   sock_list,url_file,roll_data,err=err
  endif
 endif

;-- remove comment lines

 if is_string(roll_data) then begin
  ok=where(strpos(roll_data,'#') eq -1,count)
  if count eq 0 then begin
   roll_data=''
   err='No data in roll file'
  endif else begin
   roll_data=roll_data[ok]
   roll_time=now
   if count gt 1 then begin
    s=sort(roll_data)
    roll_data=roll_data[s]
   endif
  endelse
 endif
 
endif

;-- bail out and default to 0 roll if can't find files

if is_string(err) then begin
 message,err,/cont
 return,0.
endif

;-- determine current roll value based on date

return,parse_soho_roll(roll_data,date,force=force)

end

