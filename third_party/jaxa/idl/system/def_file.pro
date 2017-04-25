;+
; Project     : VSO
;
; Name        : DEF_FILE
;
; Purpose     : Return filename with full default path.
;
; Category    : utility system 
;
; Syntax      : IDL> ofile=def_file(file,out_dir)
;
; Inputs      : FILE = file name
;
; Outputs     : OFILE = file name with full path
;
; Keywords    : ERR = error message
;               OUT_DIR = default output directory
;
; History     : 26-Dec-2015, Zarro (ADNET) - Written
;
; Contact:    : dzarro@stanford.edu

function def_file,file,out_dir=out_dir,err=err

err=''
if is_blank(file) then begin
 err='File name not entered.'
 mprint,err
 return,''
endif

fbase=file_basename(file)
fdir=file_dirname(file)
odir=fdir
if (odir eq '') || (odir eq '.') then odir=curdir()
if is_string(out_dir) then begin
 if ~file_test(out_dir,/dir) then begin
  err='Non-existent directory '+out_dir
  mprint,err
  return,''
 endif 
 odir=out_dir
endif

if ~file_test(odir,/write) then begin
 err='No write access to '+odir
 mprint,err
 return,''
endif

odir=chklog(odir,/pre)
ofile=concat_dir(odir,fbase)
return,ofile
end
