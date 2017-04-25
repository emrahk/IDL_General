;+
; Project     : VSO
;
; Name        : RPC__DEFINE
;
; Purpose     : Wrapper around IDL_RPC_CLIENT class
;
; Category    : utility system sockets objects
;
; Syntax      : IDL> o=obj_new('rpc')
;
; Inputs      : None
;
; Outputs     : IDL RPC object
;
; Keywords    : See IDL_RPC_CLIENT__DEFINE
;
; History     : 27-Oct-2015, Zarro (ADNET) - Written
;
; Contact:    : dzarro@stanford.edu
;-
;----------------------------------------------------------------------------

function rpc::init,url,_ref_extra=extra

ok=self->idl_rpc_client::init()
if ~ok then return,0

status=self->rpcinit(host='localhost',_extra=extra)
if status eq 0 then mprint,'RPC server not running.' else mprint,'Connection opened.'
self.buff_size=32000L

return,1

end

;-------------------------------------------------------------------------------
pro rpc::getvar,name,val,_ref_extra=extra,err=err

err='' & val=!null

if is_blank(name) then begin
 err='Missing or invalid variable name.'
 mprint,err
 return
endif

;-- check type of variable to retrieve

self->execute,'type=size('+name+',/type)'
s=self->rpcgetvariable(name='type',val=type)
if s eq 0 then begin
 err='Problem getting data type.'
 mprint,err
 return
endif

if type eq 0 then begin
 err='Undefined data value.'
 mprint,err
 return
endif

;-- check non-numeric or string types

do_stream=0b
chk=where(type eq [6,8,9,10,11],count)
nbytes=1
case 1 of
 count ne 0: do_stream=1b
 type eq 7: begin
  self->execute,'nbytes=get_nbytes(byte('+name+'))'
  s=self->rpcgetvariable(name='nbytes',val=nbytes)
  if nbytes gt self.buff_size then do_stream=1b
 end
 else: begin 
  self->execute,'nbytes=get_nbytes('+name+')'
  s=self->rpcgetvariable(name='nbytes',val=nbytes)
  if nbytes gt self.buff_size then do_stream=1b
 end
endcase

if do_stream then begin
 self->down_stream,name,val,err=err,_extra=extra
 return
endif

status=self->rpcgetvariable(name=name,val=val,_extra=extra)
if status eq 0 then begin
 err='Problem getting data.'
 mprint,err
 return
endif

return
end

;------------------------------------------------------------------------------------------------

pro rpc::setvar,name,val,_ref_extra=extra,err=err

err=''
if is_blank(name) then begin
 err='Missing or invalid variable name.'
 mprint,err
 return
endif
 
type=size(val,/type)
if type eq 0 then begin
 err='Undefined data value.'
 mprint,err
 return
endif

;-- check non-numeric or string types

do_stream=0b
chk=where(type eq [6,8,9,10,11],count)
nbytes=1
case 1 of
 count ne 0: do_stream=1b
 type eq 7: begin
  nbytes=get_nbytes(byte(val))
  if nbytes gt self.buff_size then do_stream=1b
 end
 else: begin 
  nbytes=get_nbytes(val)
  if nbytes gt self.buff_size then do_stream=1b
 end
endcase

if do_stream then begin
 self->up_stream,name,val,err=err,_extra=extra
 return
endif

status=self->rpcsetvariable(name=name,val=val,_extra=extra)
if status eq 0 then begin
 err='Problem setting data.'
 mprint,err
 return
endif

return

end

;---------------------------------------------------------------------------------
;-- stream byte data to RPC server

pro rpc::up_stream,name,val,err=err,verbose=verbose

err=''
if is_blank(name) then return
if n_elements(val) eq 0 then return

bdata=data_stream(val,err=err,type=type,dimensions=dimensions)
if is_string(err) then return

bsize=n_elements(bdata)

s=self->rpcsetvariable(name='type',value=type)
s=self->rpcsetvariable(name='dimensions',value=dimensions)

if keyword_set(verbose) then mprint,'Uploading '+trim(bsize)+' bytes...'

;-- do non-buffer case first

if bsize le self.buff_size then begin
 s=self->rpcsetvariable(name='bdata',value=bdata)
 str=name+'=data_unstream(bdata,type=type,dimensions=dimensions,err=err,/no_copy)'
 self->execute,str,err=err
 return
endif

;-- write data to server in chunks

tname='t'+session_id()
istart=0L 
repeat begin
 iend=(istart+self.buff_size-1) < (bsize-1L)
 tdata=bdata[istart:iend]
 s=self->rpcsetvariable(name='tdata',value=tdata)
 str=tname+'=append_arr('+tname+',tdata,/no_copy)'
 self->execute,str
 istart=iend+1
 iend=(istart+self.buff_size-1) < (bsize-1L)
endrep until (istart eq bsize)

str=name+'=data_unstream('+tname+',type=type,dimensions=dimensions,err=err,/no_copy)'
self->execute,str,err=err

return
end

;---------------------------------------------------------------------------------
;-- stream byte data from RPC server

pro rpc::down_stream,name,val,err=err,verbose=verbose

err='' & val=!null
if is_blank(name) then return
tname='t'+session_id()
str=tname+'=data_stream('+name+',err=err,type=type,dimensions=dimensions)'
self->execute,str,err=err
if is_string(err) then return

self->execute,'bsize=n_elements('+tname+')'
s=self->rpcgetvariable(name='bsize',value=bsize)
s=self->rpcgetvariable(name='type',value=type)
s=self->rpcgetvariable(name='dimensions',value=dimensions)

;-- do non-buffer case first

if bsize le self.buff_size then begin
 s=self->rpcgetvariable(name=tname,value=bdata)
 self->execute,'destroy,'+tname
 val=data_unstream(bdata,type=type,dimensions=dimensions,err=err,/no_copy)
 return
endif

;-- read data from server in chunks

istart=0L 
repeat begin
 iend=(istart+self.buff_size-1) < (bsize-1L)
 str='bdata='+tname+'['+trim(istart)+':'+trim(iend)+']'
 self->execute,str
 s=self->rpcgetvariable(name='bdata',val=bdata)
 tdata=append_arr(tdata,bdata,/no_copy)
 istart=iend+1
 iend=(istart+self.buff_size-1) < (bsize-1L)
endrep until (istart eq bsize)

val=data_unstream(tdata,type=type,dimensions=dimensions,err=err,/no_copy)
self->execute,'destroy,'+tname

return
end

;-----------------------------------------------------------------------------
;-- execute string command on RPC server

pro rpc::execute,str,err=err,status=status

err_req=arg_present(err)
err='' & err2=''
status=0
if is_blank(str) then return
status=self->rpcexecutestr(str)
if status eq 0 then begin
 err2='RPC command failed to execute.'
 mprint,err2
endif

if err_req then s=self->rpcgetvariable(name='err',val=err) else err=err2
if is_string(err) then mprint,err

return & end

;------------------------------------------------------------------------------
;-- upload file to RPC server

pro rpc::upload,file,out_file=out_file,err=err,_ref_extra=extra,verbose=verbose,session=session

err=''
if is_blank(file) then begin
 err='File name not entered.'
 mprint,err
 return
endif

if ~file_test(file,/read) then begin
 err='Missing or unreadable file.'
 mprint,err
 return
endif

;-- read file into byte array

openr,lun,file,/get_lun
fsize=(fstat(lun)).size
buff=bytarr(fsize,/nozero)
readu,lun,buff
close_lun,lun

;-- stream it to RPC server

if is_blank(session) then session=session_id()
fname='f'+session

self->up_stream,fname,buff,err=err,_extra=extra,verbose=verbose
if is_string(err) then return

ofile=fname+'_'+file_basename(file)
str='write_stream,'+fname+',"'+ofile+'",out_dir=rpc_dir(),err=err'
self->execute,str,err=err
if is_blank(err) && keyword_set(verbose) then begin
 self->execute,'rdir=rpc_dir()'
 self->getvar,'rdir',rdir
 out_file=concat_dir(rdir,ofile)
 mprint,'File uploaded successfully to '+out_file
endif

;-- cleanup memory

destroy,buff
self->execute,'destroy,'+fname

return & end

;------------------------------------------------------------------------------------
pro rpc::help,name

if is_blank(name) then return
out=''
status=self->rpcexecutestr('help,'+name+',out=out')
if status eq 1 then self->getvar,'out',out else out='Problem getting data.'
mprint,out
return
end

;-----------------------------------------------
pro rpc__define

temp={rpc, buff_size:0l, inherits idl_rpc_client, inherits dotprop}

return & end
