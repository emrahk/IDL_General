;+
; Project     : HESSI
;
; Name        : XCRON
;
; Purpose     : Simulate running IDL commands in a cron job
;
; Category    : Utility 
;
; Syntax      : IDL> xcron,command,tstart
;
; Inputs      : COMMAND = command to execute
;               TSTART = time after which to start
;
; Outputs     : None
;
; Keywords    : NREPEATS = # of times to repeat 
;               TEND = time to stop execution
;               WAIT_TIME = seconds to wait between execution
;               VERBOSE = send message output
;               KILL = job id to stop
;               LIST = list running jobs
;               HOURS,MINUTES = wait time in hours/minutes
;
; History     : Written 3 July 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

;----------------------------------------------------------------------------

pro xcron_event,  event                      

widget_control, event.id, get_uvalue = uservalue
if not exist(uservalue) then uservalue=''
uservalue=strtrim(uservalue,2)

if (uservalue eq 'timer') then begin

 widget_control,event.top,timer = 1

 child=widget_info(event.top,/child)
 widget_control,child,get_uvalue=info,/no_copy

;-- stop if # of repeats or max time exceeded

 if info.times_run ge info.nrepeats then begin
  xcron_kill,event.top
  return
 endif
 now=anytim2tai(!stime)
 if (info.tend gt 0) and (now gt info.tend) then begin
  xcron_kill,event.top
  return
 endif

;-- start if ready

 if (now ge info.tstart) and (info.times_run lt info.nrepeats) then begin
  if info.verbose then message,'executing at '+!stime,/cont
  s=execute(info.cmd)
  info.times_run=info.times_run+1
  if info.wait_time gt 0. then begin
   now=anytim2tai(!stime)
   info.tstart=now+info.wait_time
  endif
 endif
 widget_control,child,set_uvalue=info,/no_copy
endif

return & end

;----------------------------------------------------------------------------
;-- register cron command

pro xcron_register,cmd,id

xcron_clear
common xcron,jobs

if is_blank(cmd) then return
if not is_number(id) then return

current=''
if datatype(jobs) eq 'STC' then current=jobs.cmd
chk=where(cmd eq current,count)
if count gt 0 then begin
 cur_id=jobs[chk].id
 if xalive(cur_id) then begin
  message,'"'+cmd+'" already running ('+trim(string(cur_id))+')',/cont
  return
 endif
endif

new={cmd:cmd,id:id}
jobs=merge_struct(jobs,new)

message,'"'+cmd+'" running ('+trim(string(id))+')',/cont
return & end

;----------------------------------------------------------------------------

pro xcron_list

xcron_clear
common xcron,jobs

none='no jobs currently running'
if datatype(jobs) ne 'STC' then begin
 message,none,/cont
 return
endif

ids=jobs.id
chk=where(xalive(ids) gt 0,count)
if count eq 0 then begin
 message,none,/cont
 return
endif

message,'following jobs running -',/cont
print,''
print,'ID      COMMAND'
print,'---------------'
for i=0,n_elements(jobs)-1 do begin
 cmd=jobs[i].cmd
 id=jobs[i].id
 if xalive(id) then begin
  print,trim(string(id))+'  "'+cmd+' "'
 endif
endfor
print,''
return & end

;----------------------------------------------------------------------------

pro xcron_kill,id

xcron_clear

common xcron,jobs
if datatype(jobs) ne 'STC' then return
if not is_number(id) then return

chk=where(id eq jobs.id,count)
if count gt 0 then begin
 xkill,long(id)
 cmd=jobs[chk].cmd
 message,'stopping "'+cmd+'"',/cont 
endif

keep=where(id ne jobs.id,count)
if count gt 0 then jobs=jobs[keep] else delvarx,jobs

return & end

;---------------------------------------------------------------------------

pro xcron_check,cmd,running,id=cur_id

xcron_clear
common xcron,jobs
running=0b

if is_blank(cmd) then return
if datatype(jobs) ne 'STC' then return

current=jobs.cmd
chk=where(cmd eq current,count)
if count gt 0 then begin
 for i=0,count-1 do begin
  cur_id=jobs[chk[i]].id
  if xalive(cur_id) then begin
   running=1b
   message,'"'+cmd+'" already running ('+trim(string(cur_id))+')',/cont
   return
  endif
 endfor
endif

return & end

;-----------------------------------------------------------------------------
;-- clear dead jobs

pro xcron_clear

common xcron,jobs

if datatype(jobs) ne 'STC' then return

ids=jobs.id
chk=where(xalive(ids) gt 0,count)
if count gt 0 then jobs=jobs[chk] else delvarx,jobs

return & end

;--------------------------------------------------------------------------

pro xcron,cmd,tstart,nrepeats=nrepeats,tend=tend,wait_time=wait_time,$
             kill=id,list=list,verbose=verbose,hours=hours,minutes=minutes

;-- some checks

xcron_clear

if keyword_set(list) then begin
 xcron_list
 return
endif

if is_number(id) then begin
 xcron_kill,id
 return
endif

if is_blank(cmd) then begin
 pr_syntax,'xcron,command,tstart,[tend=tend,nrepeats=nrepeats,wait=wait]
 return
endif

;-- check if running

if n_elements(cmd) gt 1 then tcmd=arr2str(trim(cmd),delim=' & ') else tcmd=trim(cmd)
xcron_check,tcmd,running
if running then return

;-- setup invisible timer widget base

wbase=widget_base(uvalue='timer',map=0)
child=widget_base(wbase,map=0)

;-- set up control structure

if valid_time(tstart) then dstart=anytim2tai(tstart) else $
 dstart=anytim2tai(!stime)

dend=0d
if valid_time(tend) then begin
 dend=anytim2tai(tend)
 if dend le dstart then dend=0d
endif
 
if is_number(nrepeats) then nrepeats=(nrepeats > 0l) else nrepeats=1l
if is_number(wait_time) then wtime=(wait_time > 0) else wtime=0

if keyword_set(hours) then wtime=wtime*3600.
if keyword_set(minutes) then wtime=wtime*60.

verbose=keyword_set(verbose)
info={cmd:tcmd,tstart:dstart,tend:dend,times_run:0,nrepeats:nrepeats,$
      wait_time:wtime,verbose:verbose}

;-- start background timer

widget_control,child,set_uvalue=info

widget_control,wbase,/realize,timer=1

xcron_register,tcmd,wbase

xmanager,'xcron',wbase,/no_block

return & end

