;+
; Project     : HESSI
;
; Name        : GET_UNZIP
;
; Purpose     : find UNZIP command 
;
; Category    : system, utility,i/o
;
; Syntax      : cmd=get_unzip()
;
; Inputs      : None
; 
; Keywords    : GZIP = return GUNZIP command
;               ERR = error string
;
; History     : August 27, 2010, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

 function get_unzip,err=err,gzip=gzip

 err=''

 if keyword_set(gzip) then cmd='gzip' else cmd='unzip'
 if os_family(/lower) eq 'unix' then if have_exe(cmd,out=out) then return,out

 zip_cmd=local_name('$SSW/gen/exe/zip/'+cmd+'.exe')
 chk=loc_file(zip_cmd,count=count)
 if count ne 0 then return,zip_cmd

 err=cmd+' not found on this system.'
 message,err,/cont
 return,''
 end
