;+
; Project     : STEREO
;
; Name        : RICE_DECOMP
;
; Purpose     : Decompress RICE compressed file
;
; Category    : system utility 
;
; Syntax      : IDL> rfile=rice_decomp(file)
;
; Inputs      : FILE = RICE compressed file name
;
; Outputs     : RFILE = decompressed file name
;
; Keywords    : ERR= error string
;
; History     : 21-Nov-2011, Zarro (ADNET) - written
;               23-Dec-2014, Zarro (ADNET)
;                - moved input error checking to is_rice_comp
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-
                                                                                         
function rice_decomp,file,err=err,_ref_extra=extra,verbose=verbose

err=''

verbose=keyword_set(verbose)
if ~is_rice_comp(file,_extra=extra,err=err,verbose=verbose) then begin
 if is_string(file) then return,file else return,''
endif

if ~have_proc('mreadfits_tilecomp') then begin
 epath=local_name('$SSW/vobs/ontology/idl/jsoc')
 if is_dir(epath) then add_path,epath,/quiet,/append
 if ~have_proc('mreadfits_tilecomp') then begin
  err='Missing RICE decompressor function - mreadfits_tilecomp.'
  message,err,/info
  return,''
 endif
endif

;-- always return to current directory in case we switched or had errors

cd,current=cdir
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 cd,cdir
 return,''
endif

rdir=file_dirname(file)
rfile=file_basename(file)
outdir=concat_dir(get_temp_dir(),'rice_decomp')
mk_dir,outdir

;-- check if already decompressed

pfile=concat_dir(outdir,rfile)
if file_test(pfile,/read) then begin
 if verbose then message,'Using previously decompressed file.',/info
 return,pfile
endif

;-- kluge for Windows

if os_family() eq 'Windows' then begin
 cd,rdir & hide=1
endif else rfile=file

if verbose then message,'Decompressing file...',/info

mreadfits_tilecomp,rfile,index,/nodata,fnames_uncomp=fname_uncomp,$
 /silent,/noshell,/only_uncompress,_extra=extra,hide=hide,outdir=outdir

cd,cdir
if file_test(fname_uncomp,/read) then begin
 file_move,fname_uncomp,pfile,/allow_same,/overwrite,_extra=extra
 return,pfile
endif

err='RICE-decompression failed.'
message,err,/info
return,''

end
