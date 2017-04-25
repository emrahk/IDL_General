;+
; Project     : RHESSI
;
; Name        : FILE_STREAM
;
; Purpose     : Convert file into a byte stream
;
; Category    : system utility sockets
;
; Syntax      : IDL> stream=file_stream(file)
;
; Inputs      : FILE = file name
;
; Outputs     : DATA = 1-D byte array
;
; Keywords    : COMPRESS = compress stream
;               OSIZE = original byte size of file
;               BSIZE = compressed byte size (if compressed)
;
; History     : 26 October 2015, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function file_stream,file,compress=compress,err=err,bsize=bsize,osize=osize

err=''
bsize=0l

if is_blank(file) then begin
 err='Missing input file name.'
 pr_syntax,'data=file_stream(file)'
 return,!null
endif

if ~file_test(file,/read) then begin
 err='Input file not found.'
 mprint,err
 return,!null
endif

compressed=is_compressed(file)
openr,lun,file,/get_lun
osize=(fstat(lun)).size
data=bytarr(osize,/nozero)
readu,lun,data
close_lun,lun

if keyword_set(compress) && ~compressed then data=zlib_compress(temporary(data),/gzip) 

bsize=n_elements(data)
return,data

end

