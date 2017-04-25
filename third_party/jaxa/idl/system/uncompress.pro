;+
; Project     : HESSI
;
; Name        : UNCOMPRESS
;
; Purpose     : Decompress .zip, .gz, and .Z files
;               in a platform/OS independent way
;
; Category    : system, utility,i/o
;
; Syntax      : uncompress,file,out_dir=out_dir
;
; Inputs      : FILE = file name(s)
; 
; Keywords    : ERR = error string
;               OUT_DIR = output directory [def = current]
;               OUT_FILE = name of uncompressed file
;
; History     : August 27, 2010, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro uncompress,file,out_dir=out_dir,err=err,_extra=extra,verbose=verbose,$
               out_file=out_file

dprint,'% calling uncompress..'

err=''
return_out_file=arg_present(out_file)
out_file=''

if is_blank(file) then begin
 pr_syntax,'uncompress,file [,out_dir=out_dir]'
 return
endif

;-- any files?

files=get_uniq(trim(file))
check=where(file_test(files,/regular,/read),count)
if count eq 0 then begin
 err='Could not locate input file[s].'
 message,err,/cont
 return
endif
files=files[check]

;-- determine output directory [def to current]

cd,current=current
odir=current

if ~file_test(current,/write) then begin
 err='No write access to '+temp_dir
 message,err,/cont
 return
endif
 
if is_string(out_dir) then begin
 tdir=chklog(out_dir,/pre)
 udir=file_dirname(tdir)
 if udir eq '.' then tdir=concat_dir(current,tdir)
 if file_test(tdir,/dir) then begin
  if ~file_test(tdir,/write) then begin
   err='Cannot write to '+tdir
   message,err,/cont
   return
  endif 
  odir=tdir
 endif else begin
  if ~file_test(file_dirname(tdir),/write) then begin
   err='Cannot create '+tdir
   message,err,/cont
   return
  endif
  file_mkdir,tdir
  odir=tdir
 endelse
endif

;-- figure out compressed types

zchk=where(stregex(files,'(\.zip)$',/bool),zcount)
gchk=where(stregex(files,'(\.Z|\.gz)$',/bool),gcount)
if (zcount eq 0) and (gcount eq 0) then begin
 message,'Input file[s] not compressed.',/cont
 return
endif

zipped=zcount gt 0
gzipped=gcount gt 0
verbose=keyword_set(verbose)

;-- use unzip for .zip files

if zipped then begin
 unzip=get_unzip(err=err)
 if is_string(err) then begin
  message,err,/cont
 endif else begin
  modf=' -o '
  if ~verbose then modf=' -oq '
  cmd=unzip+modf+'"'+files[zchk]+'"'+' -d '+'"'+odir+'"'
  espawn,cmd,output,/noshell,_extra=extra
  if verbose then print,output
 endelse
endif

;--- use gunzip for .gz and .Z files

if gzipped then begin
 unzip=get_unzip(err=err,/gzip)
 if is_string(err) then begin
  message,err,/cont
 endif else begin
  modf=' -df '
  if verbose then modf=' -vdf '
  in_files=files[gchk] & out_files=in_files
  if odir ne current then begin
   out_files=concat_dir(odir,file_basename(in_files))
   file_copy,in_files,out_files,/overwrite
  endif
  cmd=unzip+modf+'"'+out_files+'"'
  espawn,cmd,output,/noshell,_extra=extra
  if verbose then print,output
 endelse
endif

;-- determine names of unzipped files

if return_out_file then begin
 files=loc_file('*.*',path=odir,count=count)
 if count eq 0 then return
 chk=where(stregex(files,'[^(\.zip)(\.gz)(\.Z)]$',/bool),count)
 if count eq 0 then return
 unzipped=files[chk]
 bunzipped=file_basename(unzipped)
 nfiles=n_elements(file)
 out_file=strarr(nfiles)
 for i=0,nfiles-1 do begin
  in_file=file_basename(file[i])
  pos=stregex(in_file,'((\.gz)|(\.zip)|(\.Z))$')
  if pos gt 0 then in_file=strmid(in_file,0,pos) else continue
  chk=where(stregex(bunzipped,in_file,/bool),zcount)
  if zcount gt 0 then out_file[i]=unzipped[chk[0]]
 endfor
 if nfiles eq 1 then out_file=out_file[0]
endif


return & end
