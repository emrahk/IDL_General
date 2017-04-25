;+
; Project     : VSO
;
; Name        : SOCK_RECVAR
;
; Purpose     : Receive a variable sent from an open socket
;
; Category    : sockets
;
; Inputs      : LUN = socket logical unit number
;
; Outputs     : NAME = string name of variable
;               VALUE = variable value
;
; Keywords    : FORMAT = type of value ('data','file','command','get','status')
;               SESSION = unique session ID to identify sender
;               ERR = error string
;               DISCONNECTED = 1 if server disconnected
;
; History     : 22-Nov-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_recvar,lun,name,value,err=err,verbose=verbose,format=format,session=session,$
           disconnected=disconnected,nowait=nowait,main_level=main_level

 on_ioerror,bail
 disconnected=0b
 success=0b
 err=''
 name='' & value=!null & format='' & verbose=0b

 if ~is_number(lun) then begin
  pr_syntax,'sock_recvar,socket_lun,variable_name,variable_value'
  return
 endif

 if ~is_socket(lun) then begin
  err='Client-Server not connected.'
  mprint,err
  disconnected=1b
  return
 endif

 hsize=0L
 readu,lun,hsize
  if hsize eq 0 then begin
  err='Cannot read data.'
  mprint,err
  disconnected=1b
  return
 endif

 hdata=bytarr(hsize,/nozero)
 readu,lun,hdata
 jheader=data_unstream(hdata,type=7,err=err)
 if is_string(err) then begin
  disconnected=1b
  return
 endif
 header=json_parse(jheader,/tostruct,/toarray)
 bsize=header.bsize
 buffer=bytarr(bsize,/nozero)
 name=header.name
 type=header.type
 compressed=header.compressed
 format=header.format
 session=header.session
 dimensions=header.dimensions
 nowait=header.nowait
 verbose=header.verbose
 main_level=header.main_level
 if verbose then mprint,'Receiving variable "'+name+'"'
 ReadU, lun, Buffer, Transfer_Count = TC
 T = TC
 While (T ne bsize) Do Begin
  B = BytArr(bsize - T,/nozero)
  ReadU, lun, B, Transfer_Count = TC
  If (TC ne 0) then Begin
   Buffer[T] = B[0:TC - 1]
   T += TC
  Endif
 Endwhile
 if verbose then mprint,'Read '+trim(t)+' bytes.'
 if t ne bsize then begin
  err='Data partially read.'
  mprint,err
  return
 endif
 if format eq 'file' then begin
  if compressed then value=zlib_uncompress(temporary(buffer),type=1,dimensions=dimensions) else value=temporary(buffer) 
 endif else value=data_unstream(buffer,type=type,dimensions=dimensions,err=err,/no_copy)
 success=1b
 bail:

 if ~success then begin
  mprint,err_state()
  err='Error reading data from socket.' 
  mprint,err
  disconnected=1b
 endif

 return & end
