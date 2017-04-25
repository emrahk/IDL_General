;+
; Project     : VSO
;
; Name        : PREP_FILE
;
; Purpose     : PREP a file using corresponding instrument prep routine
;
; Category    : utility analysis
;
; Inputs      : FILE = string file name to prep
;
; Outputs     : PFILE = prepped file name
;
; Keywords    : EXTRA = prep keywords to pass to prep routine
;               ERR = error string
;               OUT_DIR = directory of prepped file (input)
;               USE_TEMP = output prepped file to TEMP_DIR
;
; History     : 25-Nov-2015, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro prep_file,file,pfile,_ref_extra=extra,err=err,$
              out_dir=out_dir,use_temp=use_temp

pfile=''
err=''
if is_blank(file) then begin
 pr_syntax,'prep_file,file,pfile [,out_dir=out_dir]'
 return
endif

session=session_id()
temp_dir=concat_dir(get_temp_dir(),session)
if keyword_set(use_temp) then begin
 out_dir=temp_dir
 file_mkdir,out_dir
endif

if is_string(out_dir) then begin
 if ~file_test(out_dir,/dir,/write) then begin
  err='Inaccessible output directory '+out_dir
  mprint,err
  return
 endif 
endif

uflag=0b
dfile=file
if is_url(file) then begin
 uflag=1b
 file_mkdir,temp_dir
 sock_get,file,local_file=dfile,out_dir=temp_dir,_extra=extra,err=err
 if is_string(err) then goto,cleanup
endif  

if ~file_test(dfile,/regular,/read) then begin
 err='Unreadable or missing input file - '+dfile
 mprint,err
 goto,cleanup
endif

;-- check if compressed

if is_compressed(dfile) then begin
 file_decompress,dfile,out_dir=temp_dir,local_file=ufile,err=err,_extra=extra
 if is_string(err) then goto,cleanup
 dfile=ufile
endif

;-- check for instrument/detector

dclass=get_map_class(dfile,prepped=prepped,err=err)
if string(err) || is_blank(dclass) then begin
 err='No Prep function associated with this data type.'
 mprint,err
 goto,cleanup
endif

;--check if prepped

if uflag then odir=curdir() else odir=file_dirname(def_file(file))
if is_string(out_dir) then odir=chklog(out_dir,/pre)
bfile=file_basename(dfile)
if ~stregex(bfile,'^prepped_',/bool) then bfile='prepped_'+bfile else prepped=1b
ofile=concat_dir(odir,bfile)

if prepped then begin
 file_copy,dfile,ofile,/overwrite,/force,/allow
 mprint,'Data already prepped.'
 pfile=ofile
 goto,cleanup
endif

;-- catch for unexpected errors

error=0
catch, error
if (error ne 0) then begin
 err=err_state()
 mprint,err
 catch,/cancel
 goto,cleanup
endif

pobj=obj_new(dclass)
if ~have_prop(pobj,'prep_prop') then begin
 err='No Prep function associated with this data type - '+strlowcase(dclass)
 mprint,err
 goto,cleanup
endif

pobj->read,dfile,_extra=extra,err=err

if is_blank(err) then pobj->write,ofile,_extra=extra,err=err,local_file=pfile else mprint,err

;--clean up 

cleanup:

if obj_valid(pobj) then obj_destroy,pobj
if ~keyword_set(use_temp) then file_delete,temp_dir,/allow,/quiet,/recursive

return & end

