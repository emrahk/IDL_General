;+
; Project     : VSO
;                  
; Name        : FILE_TIME
;               
; Purpose     : Get access and modification file times using FILE_INFO
;                             
; Category    : system utility 
;               
; Syntax      : IDL> time=file_time(file)
;
; Inputs:     : FILE = file name
;
; Outputs     : TIME = file modification time
;
; Keywords    : /ACCESS = return access time
;               /UTC = return time in UTC [def is local]
;               /TAI = return time TAI format
;               
; History     : Written, 15-Nov-2014, Zarro (ADNET)
;               8-Mar-2015, Zarro (ADNET)
;                - removed FILE_TEST
;
; Contact     : dzarro@solar.stanford.edu
;-    

function file_time,file,time,access=access,creation=creation,$
               err=err,_extra=extra,tai=tai,utc=utc


if (n_elements(file) ne 1) || is_blank(file) then begin
 err='Input file must be scalar string.'
 mprint,err
 return,''
endif

stc=file_info(file)

if ~stc.exists then begin
 err='Input file does not exist.'
 mprint,err
 return,''
endif

case 1 of
 keyword_set(creation): dtime=stc.ctime
 keyword_set(access) : dtime=stc.atime
 else: dtime=stc.mtime
endcase

time=systim(0,dtime,utc=utc)

;-- convert to TAI

if keyword_set(tai) then begin
 time=systim(0,dtime,/utc)
 time=anytim2tai(time)
endif

return,time & end
