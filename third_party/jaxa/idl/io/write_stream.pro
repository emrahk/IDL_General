;+
; Project     : VSO
;
; Name        : WRITE_STREAM
;
; Purpose     : Write buffer stream to file
;
; Category    : utility system sockets
;
; Syntax      : IDL> write_stream,file,buffer
;
; Inputs      : BUFFER = byte array
;               FILE = buffer filename
;
; Outputs     : OUT_DIR = output directory (def = current)
;               UNCOMPRESS = uncompress input before writing
;               LOCAL_FILE = name of output file
;
; Keywords    : ERR = error message
;
; History     : 27-Oct-2015, Zarro (ADNET) - Written
;
; Contact:    : dzarro@stanford.edu
;-

pro write_stream,file,buff,err=err,verbose=verbose,$
                 uncompress=uncompress,local_file=local_file,_extra=extra

err=''
local_file=''
if is_blank(file) then begin
 err='Missing output file name.'
 pr_syntax,'write_stream,file,buff [,/uncompress]'
 return
endif

if ~is_byte(buff) || (n_elements(buff) lt 2)then begin
 err='Input buffer must be byte array.'
 mprint,err
 return
endif

error=0
catch, error
if (error ne 0) then begin
 err=err_state()
 mprint,err
 catch,/cancel
 return
endif

ofile=def_file(file,_extra=extra,err=err)
if is_string(err) then return
openw,lun,ofile,/get_lun,error=status

if status ne 0 then begin
 err=err_state()
 mprint,err
 return
endif

if keyword_set(uncompress) then writeu,lun,zlib_uncompress(buff,/gzip) else $
 writeu,lun,buff
local_file=ofile
close_lun,lun
if keyword_set(verbose) then mprint,'Wrote '+trim(n_elements(buff))+' bytes to '+local_file

return & end
