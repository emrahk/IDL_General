;+
; Project     : RHESSI
;
; Name        : DATA_STREAM
;
; Purpose     : Convert any data into a compressed byte stream
;
; Category    : system utility sockets
;
; Syntax      : IDL> stream=data_stream(data)
;
; Inputs      : DATA = any data type (inc. structures, objects, pointers)
;
; Outputs     : STREAM = 1-D byte array
;
; Keywords    : NO_COPY = do not make copy of original data
;               TYPE = input data type 
;               DIMENSIONS = input data dimensions
;               BSIZE= size of output byte stream
;
; History     : 26 October 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function data_stream,data,no_copy=no_copy,type=type,dimensions=dimensions,$
 err=err,bsize=bsize

err=''
bsize=0l
if n_elements(data) eq 0 then begin
 err='Undefined input data.'
 mprint,err
 pr_syntax,'bytes=data_stream(data)'
 return,!null
endif

type=size(data,/type)
dimensions=size(data,/dimensions)

;-- handle special cases first

chk=where(type eq [6,8,9,10,11],count)

if count gt 0 then begin
 temp_dir=get_temp_dir()
 temp_file=get_rid(/time)+'.sav'
 out_file=concat_dir(temp_dir,temp_file)
 save,data,file=out_file
 buffer=file_stream(out_file,/compress,bsize=bsize)
 file_delete,out_file
 dimensions=1
 if keyword_set(no_copy) then destroy,data
 return,buffer 
endif

if keyword_set(no_copy) then temp=temporary(data) else temp=data

;-- convert string to byte array

if type eq 7 then begin
 temp=byte(temp)
 dimensions=size(temp,/dimensions)
endif

;-- convert scalar to array

if n_elements(temp) eq 1 then begin
 temp=reform(temp,1)
 dimensions=1
endif

buffer=zlib_compress(temporary(temp),/gzip)
bsize=n_elements(buffer)
return,buffer

end
