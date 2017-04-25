;+
; Project     : SOHO-CDS
;
; Name        : FILE2FID
;
; Purpose     : move files from a directory into another based on file 
;               date/time               
;
; Category    : planning
;
; Explanation : looks at files encoded with "_yyyymmdd_hhmm"
;               and moves them into appropriate directory
;               e.g. out_dir/yymmdd
;
; Syntax      : file2fid,files,out_dir
;
; Inputs      : FILES = array of filenames, complete with path
;               OUT_DIR = target directory for files
;;
; Keywords    : COPY = copy files instead of move
;               NOCLOBBER = don't clobber existing files 
;               OUT_FILES = renamed output files
;
; Restrictions: Unix only 
;
; History     : Written 1 Feb 1999 D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

pro file2fid,files,out_dir,copy=copy,noclobber=noclobber,err=err,$
                   out_files=out_files

err=''
                 
if os_family(/lower) ne 'unix' then begin
 message,'sorry, UNIX only',/cont
endif

if is_blank(files) then begin
 pr_syntax,'file2fid,files,out_dir,[copy=copy,noclobber=noclobber]'
 return
endif

;-- output directory
                 
if is_blank(out_dir) then out_dir=curdir() 

;-- check write access

if not test_dir(out_dir,out=out,err=err) then return

;-- now do the real work

delvarx,out_files
clobber=1-keyword_set(noclobber)
if keyword_set(copy) then cmd='cp ' else cmd='mv -f '
nf=n_elements(files)
for i=0,nf-1 do begin
 time=fid2time(files[i],ymd=ymd,err=err)

 if (err eq '') and (ymd ne '') then begin

;-- ensure target directory is created

  sub_dir=concat_dir(out,ymd)
  if not is_dir(sub_dir) then mk_dir,sub_dir,/u_write,/g_write,/a_read

;-- check if copy of file exists there

  break_file,files[i],dsk,dir,fname,ext
  target=concat_dir(sub_dir,fname+ext)
  chk_target=loc_file(target,count=fcount)

;-- move there if clobber or file isn't there

  if clobber or (fcount eq 0) then espawn,cmd+files[i]+' '+sub_dir,/noshell
                                   
  out_files=append_arr(out_files,target,/no_copy)
 endif

endfor

return & end

