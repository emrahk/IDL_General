;+
; Project     : HESSI
;
; Name        : UNZIP
;
; Purpose     : Unzip .zip file 
;
; Category    : system, utility,i/o
;
; Syntax      : unzip,file,out_dir=out_dir
;
; Inputs      : FILE = file name
; 
; Keywords    : ERR = error string
;               OUT_DIR = output directory [def = current]
;
; History     : August 27, 2010, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro unzip,file,out_dir=out_dir,err=err,_extra=extra,verbose=verbose

err=''

unzip=get_unzip(err=err)
if is_string(err) then return

if is_blank(file) then begin
 pr_syntax,'unzip,file [,out_dir=out_dir]'
 return
endif

;-- determine output directory

file=trim(file)
odir=file_dirname(file[0])
if odir eq '.' then odir=curdir() 
if is_string(out_dir) then odir=out_dir
if ~test_dir(odir,err=err,/verb) then return

chk=where(stregex(file,'(\.zip)$',/bool),count)
if count eq 0 then begin
 message,'Input file[s] do not have .zip extension.'
 return
endif

modf=' -o '
if ~keyword_set(verbose) then modf=' -oq '
cmd=unzip+modf+file[chk]+' -d '+'"'+odir+'"'
espawn,cmd,/noshell,_extra=extra

return & end
