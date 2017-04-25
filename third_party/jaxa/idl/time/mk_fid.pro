;+
; Project     : HESSI
;
; Name        : MK_FID
;
; Purpose     : create FID directory (named YYMMDD based on date/time)
;
; Category    : utility system
;
; Syntax      : mk_fid,root,times
;
; Inputs      : ROOT = root directory under which to create subdir named FID
;               TIMES = array of times to compute FID
;
; Keywords    : ERR= error string
;               OUT_DIR = created directory names
;               
; History     : Written, 3 March 2000, D. Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mk_fid,root,times,err=err,verbose=verbose,out_dir=out_dir,_extra=extra

err='' & out_dir=''
verbose=keyword_set(verbose)
if not test_dir(root,err=err) then return
if not exist(times) then begin
 err='input times are required'
 message,err,/cont
 return
endif

;-- create sub-directories

sdir=time2fid(times,_extra=extra)
out_dir=concat_dir(root,sdir)
mk_sub_dir,root,sdir,err=err

return & end


