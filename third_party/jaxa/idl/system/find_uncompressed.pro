;+
; Project     : RHESSI
;
; Name        : FIND_UNCOMPRESSED
;
; Purpose     : uncompress a file
;
; Category    : utility,i/o
;
; Explanation : Uncompresses file by spawning appropriate uncompress function
;
; Syntax      : dfile=find_uncompressed(file)
;
; Inputs      : FILE = file to uncompress
;
; Outputs     : DFILE = uncompressed file
;
; Keywords    : ERR = error message
;               STATUS = 1 for success
;                      = 2 if previously uncompressed version returned
;                          from TEMP_DIR
;               TEMP_DIR = name of temporary directory in which
;                         uncompressed files are saved ($HOME/.uncompressed)
;               OUT_DIR = user specified directory for uncompressed files
;               LIMIT = number of uncompressed files to keep in temporary
;                       directory
;               LOOK_ONLY = only look for previously uncompressed file 
;               FORCE = force uncompress even if previously uncompressed 
;               RESET = clear memory of previously uncompressed files
;
; History     : Written 10 Jan 1999, D. Zarro (SMA/GSFC)
;               Modified 15 Feb 2000, Zarro (SM&A/GSFC) -- check
;                for directory creation 
;               Modified 15 April 2000, Zarro (SM&A/GSFC) -- made Windows
;                compatible
;               Modified 31 May 2002, Zarro (LAC/GSFC) - added check
;                for invalid USE_DIR
;               Modified 10 Feb 2004, Zarro (L-3Com/GSFC) - added LIMIT
;               Modified 17 Sep 2005, Zarro (L-3Com/GSFC) - replaced TEST_DIR
;                by WRITE_DIR.
;               26-Aug-2010, Zarro (ADNET) - added .zip support
;
; Contact     : dzarro@solar.stanford.edu
;-

function find_uncompressed,file,err=err,count=count,$
           temp_dir=temp_dir,out_dir=out_dir,_extra=extra,$
           limit=limit,status=status,reset=reset,look_only=look_only,$
           force=force
                       
common uncompressed,cfiles

if keyword_set(reset) then delvarx,cfiles

err=''
count=0
status=0

if ~is_number(limit) then limit=10

if is_blank(file) then begin
 pr_syntax,'dfile=find_uncompressed(file)'
 return,''
endif

if n_elements(file) ne 1 then begin
 err='Input filename must be scalar.'
 message,err,/cont
 return,''
endif

chk=loc_file(file,count=count)
if count eq 0 then begin
 err='Input file missing.'
 message,err,/cont
 return,''
endif

compressed=is_compressed(file)
if ~compressed then begin
 err='Filename missing compressed extension (gz,zip,Z).'
 message,err,/cont
 return,''
endif

;-- directory to store uncompressed files

temp=get_temp_dir()
temp_dir=concat_dir(temp,'.uncompressed')
if is_string(out_dir) then temp_dir=chklog(out_dir,/pre)

;-- check if uncompressed previously

force=keyword_set(force)
cd,current=current
dname=file_dirname(file)
ifile=file
if dname eq '.' then ifile=concat_dir(current,file)
if is_struct(cfiles) and ~force then begin
 cdirs=file_dirname(cfiles.zfile)
 chk=where( (ifile eq cfiles.file) and (temp_dir eq cdirs), zcount)
 if zcount gt 0 then begin
  tfiles=(cfiles[chk]).zfile
  ok=where(file_test(tfiles),count)
  if count eq 1 then begin
   status=2
   return,tfiles[ok[0]]
  endif
 endif
endif

if keyword_set(look_only) then return,''

uncompress,ifile,out_dir=temp_dir,out_file=zfile,_extra=extra,err=err
if is_string(err) then return,''

;-- delete uncompressed files to conserve disk space

if limit gt 0 then begin
 if is_struct(cfiles) then begin
  chk=where(zfile eq cfiles.zfile,count)
  if count eq 0 then begin
   cfiles=[temporary(cfiles),{file:ifile,zfile:zfile}]
   nfiles=n_elements(cfiles)
   if (nfiles gt limit) then begin
    dprint,'% FIND_UNCOMPRESSED: deleting '+(cfiles[0]).zfile
    file_delete,(cfiles[0]).zfile,/quiet
    cfiles=cfiles[1:(nfiles-1)]
   endif
  endif
 endif else cfiles={file:ifile,zfile:zfile}
endif

status=1
count=1

return,zfile & end
