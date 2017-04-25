;+
; Project     : SOHO-CDS
;
; Name        : URL_GET
;
; Purpose     : get a file from a URL location
;
; Category    : WWW
;
; Explanation : Uses PERL sockets for fast data transfers
;
; Syntax      : url_get,url,file,new_name,dir=out_dir
;
; Examples    :
;
; Inputs      : URL = address, e.g. http://orpheus.nascom.nasa.gov OR
;               ftp://orpheus.nascom.nasa.gov 
;               FILE = filename to retrieve
;
; Opt. Inputs : NEW_NAME = new name for file
;
;
; Outputs     : 
;
; Opt. Outputs: 
;
; Keywords    : DIR = location of retrieved file [def=current]
;               NOVER = don't copy and overwrite existing file [def= over]
;               QUIET = no messages
;               NODELETE = don't delete source file
;               OUTFILE= new name of copied file [def = same as file]
;
; Restrictions: Requires URL_GET PERL routines 
;               (located in environ var 'URL_GET')
;
; Side effects: None
;
; History     : Written 31 January 1998, D. Zarro, SAC/GSFC
;               Modified 22 August 2000, Zarro (EIT/GSFC)
;               -- added check for filename in URL and OUTFILE keyword
;  ;
; Contact     : dzarro@solar.stanford.edu
;-

pro url_get,url,file,unused,outfile=new_name,dir=new_dir,$
     nover=nover,nodelete=nodelete,quiet=quiet

if (datatype(url) ne 'STR') then begin
 pr_syntax,'url_get,url,file,[,outfile=new_name,dir=out_dir]
 return
endif

;-- check if file name part of URL

furl=url
if (datatype(file) ne 'STR') then begin
 break_file,url,dsk,dir,name,ext
 file=name+ext
 if is_blank(file) then begin
  message,'Need input file name to transfer',/cont
  return
 endif else furl=dsk+dir
endif 

;-- look for PERL

perl=ssw_bin('perl',found=found)
if found eq 0 then begin
 message,'PERL not found in current path',/cont
 return
endif

scr_path=getenv('SSW_URL_GET')
if scr_path eq '' then begin
 message,'define "SSW_URL_GET" to point to "url_get" PERL directory',/cont
 return
endif

cd,current=current
if datatype(new_name) ne 'STR' then out_name=file else out_name=new_name
if datatype(new_dir) ne 'STR' then out_dir=current else out_dir=new_dir

ok=test_open(out_dir,/write,err=err)
if not ok then return

;-- if FTP protocol, use binary transfer

url_com='./url_get '
if strpos(strlowcase(url),'ftp') gt -1 then url_com='url_get -b ' 

;-- write commands to temporary file for sourcing

over=1-keyword_set(nover) & at_least_one=0
source_file=mk_temp_file('url_get.bat')
openw,unit,source_file,/get_lun
printf,unit,'cd '+scr_path
for i=0,n_elements(file)-1 do begin
 out_file=concat_dir(out_dir,out_name(i))
 chk=loc_file(out_file,count=count)
 if (count eq 0) or over then begin
  printf,unit,url_com+furl+'/'+file(i)+' > '+out_file
  at_least_one=1
 endif
endfor
printf,unit,'cd '+current
close,unit

;-- Spawn PERL's URL_GET

verbose=1-keyword_set(quiet)
if at_least_one then begin
 if verbose then message,'Please wait. Retrieving files...',/cont
 espawn,'source '+source_file,out,count=count,/noshell
 if (count eq 1) and trim(out(0)) ne '' then message,out(0),/cont
 cd,current
endif else begin
 if verbose then message,'All files(s) already copied.',/cont
endelse

if (1-keyword_set(nodelete)) then rm_file,source_file

return & end

