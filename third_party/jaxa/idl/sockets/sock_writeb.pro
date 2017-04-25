;+
; Project     : VSO
;
; Name        : SOCK_WRITEB
;
; Purpose     : Write byte data to an open socket.
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_writeb,lun,data
;
; Inputs      : LUN = open socket LUN
;               DATA = byte data array
;
; Outputs     : 
;
; Keywords    : ERR = error string
;               VERBOSE = set for messages
;               TIME_OUT= seconds after which to time out (def 30)
;
; History     : 13 February 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_writeb,lun,data,time_out=time_out,verbose=verbose,err=err

if ~is_socket(lun) then begin
 err='Socket unavailable.'
 mprint,err
 return
endif

if ~is_byte(data) then return
if ~is_number(time_out) then time_out=30
verbose=keyword_set(verbose)
bsize=n_elements(data)
osize=bsize
tsize=0l

success=0b

on_ioerror,bail

t1=systime(/sec)
again: flush,lun
writeu,lun, data
tcb=(fstat(lun)).Transfer_Count

;if verbose then mprint,'Sent '+trim(tcb)+' bytes of '+trim(osize)+' bytes.'
success=tcb eq bsize

;-- beware, ugly ass goto shit below. 
;-- need to jump through hoops in case of network latency.

bail: 
if ~success then begin 
 tstat=fstat(lun)
 tcb=tstat.Transfer_Count
 topen=tstat.open 

 if ~topen then begin
  err='Socket disconnected.'
  mprint,err
  return
 endif

 if (tcb lt bsize) then begin
  t2=systime(/sec)
  if (t2-t1) lt time_out then begin
   data=data[tcb:bsize-1]
   bsize=n_elements(data)
   tsize=tsize+tcb
   if verbose then mprint,'Retrying with '+trim(bsize)+' bytes.'
   goto,again 
  endif else begin
   err='Socket not responding.'
   mprint,err
   return
  endelse
 endif

 tsize=tsize+tcb
 mprint,'Sent '+trim(tsize)+' bytes of '+trim(osize)+' bytes.'

 if tsize ne osize then begin
  err='Error writing data to socket.'
  mprint,err
  serr=err_state()
  if is_string(serr) then mprint,serr
 endif
endif

return & end
