;+
; Project     : VSO
;
; Name        : SOCK_READB
;
; Purpose     : Read byte data from an open socket.
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_readb,lun,buffer,bsize=bsize
;
; Inputs      : LUN = open socket LUN
;               DATA = byte array into which to read data
;
; Outputs     : BUFFER 
;
; Keywords    : ERR = error string
;               VERBOSE = set for messages
;               TIME_OUT= seconds after which to time out (def 30)
;               BSIZE = output buffer size (overrides BUFFER size)
;
; History     : 28 March 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-


pro sock_readb,lun,data,err=err,time_out=time_out,verbose=verbose,bsize=bsize

err=''

if ~is_number(time_out) then time_out=30.
success=0b
verbose=keyword_set(verbose)

if is_number(bsize) then begin
 if bsize gt 1 then data=bytarr(bsize,/nozero)
endif

bsize=n_elements(data)
if ~is_byte(data) || (bsize lt 2)then begin
 err='Output data must be byte array.'
 mprint,err
 return
endif

if ~is_socket(lun) then begin
 err='Socket unavailable.'
 mprint,err
 return
endif

on_ioerror,bail
t1=systime(/sec)
tsize=bsize
again:
readu, lun, data
tcb=(fstat(lun)).transfer_count
success=tcb eq tsize

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
 
 if (tcb lt tsize) then begin
  t2=systime(/sec)
  if (t2-t1) lt time_out then begin
   if tcb gt 0 then begin
    if n_elements(buffer) eq 0 then buffer=data[0:tcb-1] else buffer=[temporary(buffer),data[0:tcb-1]]
   endif
   data=data[tcb:tsize-1]
   tsize=n_elements(data)
   if verbose then mprint,'Retrying with '+trim(tsize)+' bytes.'
   goto,again
  endif else begin
   err='Socket not responding.'
   mprint,err
   return
  endelse
 endif 
endif 

fsize=n_elements(buffer)
if tcb gt 0 then begin
 if fsize eq 0 then buffer=data[0:tcb-1] else begin
  if fsize lt bsize then buffer=[temporary(buffer),data[0:tcb-1]]
 endelse
endif

if n_elements(buffer) ne bsize then begin
 err='Socket read unsuccessful.'
 mprint,err
 destroy,buffer,data
endif else data=temporary(buffer)

return
end
