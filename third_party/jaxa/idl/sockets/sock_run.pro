;+
; Project     : HESSI
;
; Name        : SOCK_RUN
;
; Purpose     : run (compile) a socket version of an SSW routine
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_run,file
;                   
; Inputs      : FILE = remote file name to run
;
; Outputs     : None
;
; Keywords    : ERR   = string error message
;
; Example     : IDL> sock_run,'xdoc'
;
; History     : 10-Feb-2004  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_run,file,err=err,_ref_extra=extra

err=''
if is_blank(file) then begin
 err='missing input file'
 pr_syntax,'sock_run,file'
 return
endif

url=sock_ssw(file,err=err,_extra=extra)
if is_string(err) then return

;-- now download and compile SSW version of file

temp=get_temp_dir()
sock_copy,url,/clobber,out_dir=temp,_extra=extra,err=err
if is_string(err) then return

cd,temp,curr=curr
pfile=file_break(file,/no_ext)
resolve_routine,pfile,/either,/compile_full_file
cd,curr

return
end


