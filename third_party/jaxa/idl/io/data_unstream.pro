;+
; Project     : RHESSI
;
; Name        : DATA_UNSTREAM
;
; Purpose     : Convert a byte stream back to original data
;
; Category    : system utility sockets
;
; Syntax      : IDL> odata=data_unstream(data)
;
; Inputs      : SDATA = streamed data byte array
;
; Outputs     : ODATA = reconstructed data array
;
; Keywords    : TYPE = output data type 
;               DIMENSIONS = output data dimensions
;
; History     : 26 October 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function data_unstream,sdata,dimensions=dimensions,type=type,err=err,no_copy=no_copy

err=''

dtype=size(sdata,/type)
if (dtype ne 1) || (n_elements(sdata) le 1) then begin
 err='Input data stream must be in byte array format.'
 mprint,err
 return,!null
endif

if ~is_number(type) then begin
 err='Need data type for output.'
 mprint,err
 return,!null
endif

;-- set a catch for errors

error=0
catch, error
if (error ne 0) then begin
 catch,/cancel
 err=err_state()
 mprint,'Called from '+get_caller()
 mprint,err
 return,!null
endif

if keyword_set(no_copy) then temp=temporary(sdata) else temp=sdata

;-- default to 1-D output data

if (is_number(dimensions))[0] then dims=dimensions else dims=1

;-- handle special cases first

chk=where(type eq [6,8,9,10,11],count)
if count gt 0 then begin
 temp_dir=get_temp_dir()
 temp_file=get_rid(/time)+'.sav'
 out_file=concat_dir(temp_dir,temp_file)
 openw,lun,out_file,/get_lun
 writeu,lun,zlib_uncompress(temp,type=1,/gzip)
 close_lun,lun
 restore,file=out_file
 file_delete,out_file
 return,data
endif

if n_elements(temp) eq 1 then begin
 err='Input data must be array.'
 mprint,err
 return,!null
endif

if type eq 7 then dtype=1 else dtype=type
buffer=zlib_uncompress(temporary(temp),type=dtype,dimensions=dimensions,/gzip)
if n_elements(buffer) eq 1 then buffer=buffer[0]
if type eq 7 then return,string(buffer)

return,buffer
end
