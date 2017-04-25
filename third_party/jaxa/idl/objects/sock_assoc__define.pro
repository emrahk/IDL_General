;+
; Project     : VSO
;
; Name        : SOCK_ASSOC__DEFINE
;
; Purpose     : Object wrapper around ASSOC function that supports
;               reading socket units.
;
; Category    : utility system sockets i/o
;
; Syntax      : IDL> assoc=obj_new('sock_assoc')
;               IDL> assoc->set,file='http://host.domain/image.dat',data=fltarr(1024,1024)
;
;               IDL> data1=assoc->read(0)
;               IDL> data2=assoc->read(1)
;
; Inputs      : None
;
; Outputs     : ASSOC = object with read method to access records 
;
; Keywords    : DATA = expression that defines record structure
;               FILE = URL of file to read
;               OFFSET = byte offset to start of data [def=0]
;
; History     : 26-November-2012, Zarro (ADNET) - Written
;
;-

function sock_assoc::init,_extra=extra

self.data=ptr_new(/all)
if is_struct(extra) then self->set,_extra=extra

return,1
end

;------------------------------------------------------------

pro sock_assoc::cleanup

ptr_free,self.data

return & end

;-----------------------------------------------------------

function sock_assoc::get,_ref_extra=extra

return,self->getprop(_extra=extra)

end

;------------------------------------------------------------

pro sock_assoc::set,file=file,data=data,offset=offset,_extra=extra

if is_number(offset) then self.offset=offset
if exist(data) then *self.data=temporary(data) 
if is_url(file) then begin
 stc=url_parse(file)
 self.url=file
 self.host=stc.host
 self.port=fix(stc.port)
endif

return & end

;----------------------------------------------------------------
pro sock_assoc::open,err=err

err=''
if is_blank(self.url) then begin
 err='URL file not set.'
 message,err,/info
 return
endif


if ~exist(*self.data) or is_scalar(*self.data) then begin
 err='Data array descriptor not set.'
 message,err,/info
 return
endif

;-- already opened?

do_open=1b
is_open=is_socket(self.unit,host=ohost,port=oport)
if is_open then begin 
 if (self.host eq ohost) and (self.port eq oport) then begin
  message,'Reading from unit - '+trim(self.unit),/info
  do_open=0b
  unit=self.unit
 endif
endif

if do_open then begin
 sock_open,unit,self.host,port=self.port,err=err
 if is_string(err) then return
 self.unit=unit
endif

return & end

;----------------------------------------------------------------------------

function sock_assoc::read,record,_ref_extra=extra

if try_network() then return,self->read_new(record,_extra=extra) else $
 return,self->read_old(record,_extra=extra)

end

;-------------------------------------------------------------

function sock_assoc::read_old,record,err=err,no_close=no_close,_extra=extra,$
         verbose=verbose

self->open,err=err
if is_string(err) then return,-1

;-- figure out how many bytes to request

if ~is_number(record) then record=0 else record = record > 0

nbytes=long(n_bytes(*self.data))
range_start=self.offset+nbytes*long(record)
range_end=range_start+nbytes-1
range=strtrim(range_start,2)+'-'+strtrim(range_end,2)

;-- create and send range request

sock_request,self.url,request,range=range,no_close=no_close,_extra=extra
sock_send,self.unit,request
sock_receive,self.unit,response
sock_content,response,chunked=chunked

chk=where(stregex(response,'Accept-Ranges: bytes',/bool),count)
if count eq 0 then begin
 err='Error reading URL file.'
 message,err,/info
 if keyword_set(verbose) then begin
  print,'   '
  print,response
 endif
 close_lun,self.unit
 return,-1
endif

;-- read requested bytes

data=*self.data
sock_read,self.unit,data,_extra=extra,chunked=chunked,err=err
if ~keyword_set(no_close) then close_lun,self.unit

if is_string(err) then return,-1 else return,data
end

;---------------------------------------------------------------------------------
function sock_assoc::read_new,record,err=err,no_close=no_close,_extra=extra,$
         verbose=verbose

;-- figure out how many bytes to request

if ~is_number(record) then record=0 else record = record > 0

nbytes=long(n_bytes(*self.data))
range_start=self.offset+nbytes*long(record)
range_end=range_start+nbytes-1
range=strtrim(range_start,2)+'-'+strtrim(range_end,2)

;-- read requested bytes

sock_list,self.url,buff,/buffer,range=range,response_header=response,$
 response_code=code,err=err

if is_string(err) then begin
 message,err,/info
 return,-1
endif

chk=where(stregex(response,'Accept-Ranges: bytes',/bool),count)
if count eq 0 then begin
 err='Error reading file [byte-serving not supported].'
 message,err,/info
endif


nbytes=n_bytes(*self.data)
if nbytes ne n_elements(buff) then begin
 err='Error reading file [bytes mismatch].'
 message,err,/info
 return,-1
endif

dimensions=size(*self.data,/dimension)
type=size(*self.data,/tname)
if type eq 'INT' then type='FIX'

data=call_function(type,temporary(buff),0,dimensions)

return,data
end

;--------------------------------------------------------------
pro sock_assoc__define                                                                
                                                                               
void={ sock_assoc, $                                                                    
       data:ptr_new(),$
       unit:0L,$                                                            
       offset:0L,$
       url:'',$
       host:'',$
       port:0,$
       inherits dotprop, inherits gen}
 
return & end                                              
