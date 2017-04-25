;+
; Project     : HESSI
;
; Name        : SOCK_SIZE
;
; Purpose     : get sizes of remote files in bytes
;
; Category    : utility system sockets
;
; Syntax      : IDL> rsize=sock_size(rfile)
;                   
; Example     : IDL> rsize=sock_size('http://server.domain/filename')
;
; Inputs      : RFILE = remote file names
;
; Outputs     : RSIZE = remote file sizes
;
; Keywords    : ERR = string error
;
; History     : 1-Feb-2007,  D.M. Zarro (ADNET/GSFC) - Written
;               3-Feb-2007, Zarro (ADNET/GSFC) - added FTP support
;               26-Oct-2009, Zarro (ADNET) 
;                - replaced HEAD with more direct GET method
;               21-Feb-2013, Zarro (ADNET)
;                - added call to SOCK_HEAD
;               21-Feb-2015, Zarro (ADNET)
;                - moved FTP size check into SOCK_HEAD
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_size,rfile,err=err,_extra=extra,date=rdate

;-- usual error check

err=''
if ~is_string(rfile) then begin
 err='Missing input filenames'
 rdate=''
 return,0.
endif

nfiles=n_elements(rfile)
rsize=fltarr(nfiles)
rdate=strarr(nfiles)

for i=0,nfiles-1 do begin
 response=sock_head(rfile[i],size=bsize,date=bdate,_extra=extra)
 rsize[i]=bsize
 if is_string(bdate) then rdate[i]=bdate
endfor

if nfiles eq 1 then begin
 rsize=rsize[0]
 rdate=rdate[0]
endif

return,rsize
end


