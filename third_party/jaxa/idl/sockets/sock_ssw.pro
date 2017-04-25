;+
; Project     : HESSI
;
; Name        : SOCK_SSW
;
; Purpose     : return URL of a SSW routine for retrieval by a socket
;
; Category    : utility system sockets
;
; Syntax      : IDL> url=sock_ssw(file)
;                   
; Inputs      : FILE = remote file name to find
;
; Outputs     : URL = URL path to file
;
; Keywords    : ERR   = string error message
;
; Example     : IDL> url=sock_ssw('xdoc')
;
; History     : 10-Feb-2004  D.M. Zarro (L-3Com/GSFC)  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_ssw,file,err=err,_ref_extra=extra

common sock_run,map,mtime

err=''
if is_blank(file) then begin
 err='missing input file'
 pr_syntax,'url=sock_ssw(file)'
 return,''
endif

;-- download and read map file if older than about an hour

ssw_server=ssw_server()
temp=get_temp_dir()
download=1b
if exist(mtime) then download=(systime(/sec)-mtime) gt 3600.
if ~exist(map) then download=1b

if download then begin
 ssw_map=ssw_server+'/solarsoft/gen/setup/ssw_map.dat'
 sock_copy,ssw_map,out_dir=temp,err=err,/clobber,_extra=extra
 if is_string(err) then return,''
 map=rd_ascii(concat_dir(temp,'ssw_map.dat'))
 mtime=systime(/sec)
endif

;-- search for file path in map file

pfile=strtrim(strlowcase(file),2)
if not stregex(pfile,'.pro',/bool) then pfile=pfile+'.pro'
chk=where(stregex(map,'\/'+pfile,/bool),count)
if count eq 0 then begin
 err=pfile+' not found on $SSW server'
 message,err,/cont
 return,''
endif
fpath=map[chk[0]]
url=str_replace(fpath,'$SSW',ssw_server+'/solarsoft')

return,url

end


