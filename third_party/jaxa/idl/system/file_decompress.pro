;+
; Project     : HESSI
;
; Name        : FILE_DECOMPRESS
;
; Purpose     : Decompress .zip, .gz, and .Z files
;               in a platform/OS independent way
;
; Category    : system, utility,i/o
;
; Syntax      : file_decompress,file,out_dir=out_dir,local_name=local_name
;
; Inputs      : FILE = file name
; 
; Keywords    : ERR = error string
;               OUT_DIR = output directory [def = current]
;               LOCAL_FILE = name of decompressed file
;
; History     : January 31, 2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro file_decompress,file,err=err,_ref_extra=extra,verbose=verbose,$
               local_file=local_file,out_dir=out_dir

local_file=''
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 mprint,err_state()
 return
endif

if is_blank(file) then begin
 err='Invalid or missing input filename.' 
 pr_syntax,'file_uncompress,file [,out_dir=out_dir]'
 return
endif

if n_elements(file) gt 1 then begin
 err='Input file must be scalar.'
 mprint,err
 return
endif
 
if ~file_test(file,/regular,/read) then begin
 err='Input file not readable.'
 mprint,err
 return
endif

file=trim(file)
if ~stregex(trim(file),'\.(gz|Z|zip)$',/bool) then begin
 mprint,'Input file not compressed.'
 local_file=file
 return
endif

if is_string(out_dir) then begin
 if file_test(out_dir,/dir) then begin
  if ~file_test(out_dir,/write) then begin
   err='No write access to '+out_dir
   mprint,err
   return
  endif
 endif else file_mkdir,out_dir
endif  

verbose=keyword_set(verbose)
local_file=def_file(file,out_dir=out_dir,err=err)
if is_string(err) then return
pos=strpos(local_file,'.',/reverse_search)
local_file=strmid(local_file,0,pos)
odir=file_dirname(local_file)

case 1 of
 stregex(file,'\.gz$',/bool) : file_gunzip,file,local_file,_extra=extra,verbose=verbose
 stregex(file,'\.zip$',/bool) : file_unzip,file,odir,_extra=extra
 stregex(file,'\.Z$',/bool) : begin
  os=os_family()
  if os ne 'unix' then begin
   err='Cannot uncompress this file type on '+os
   mprint,err
   return
  endif
  tdir=get_temp_dir()
  fname=file_basename(file)
  tfile=concat_dir(tdir,fname)
  file_copy,file,tfile,/allow_same,/overwrite
  espawn,'uncompress -f '+tfile,/noshell,err=err,_extra=extra
  tfile=str_replace(tfile,'.Z','')
  if ~file_test(tfile) then begin
   if is_blank(err) then err='Uncompress failed.'
   mprint,err
   return
  endif
  file_move,tfile,local_file,/allow_same,/overwrite
  file_chmod,local_file,/a_read,/a_write
 end
 else: donothing=1
endcase

if verbose then mprint,'Decompressed file written to '+local_file  
return & end
