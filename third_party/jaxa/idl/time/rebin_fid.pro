;+
; Project     : HESSI
;
; Name        : REBIN_FID
;
; Purpose     : Rebin files read by FIND_FID
;
; Category    : HESSI, GBO, utility
;
; Explanation : 
;
; Syntax      : IDL> rebin_fid,tstart,tend,factor,files
;
; Inputs      : TSTART = search start time
;               TEND   = search end time
;               FACTOR = factor to rebin files by
;
; Opt. Inputs : None
;
; Outputs     : FILES = found files (rounded to nearest day)
;
; Opt. Outputs: None
;
; Keywords    : Same as FIND_FID
;               OUTDIR = output directory for rebinned files
;               CLOBBER = clobber existing rebinned files.
;
; Common      : None
;
; Restrictions: Unix systems only.
;               Currently only GIF supported
;
; Side effects: None
;
; History     : Version 1,  14-April-1999,  D.M. Zarro (SM&A/GSFC),  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro rebin_fid,t1,t2,factor,files,_extra=extra,count=count,outdir=outdir,$
                   err=err,clobber=clobber,verbose=verbose

;-- input error checks

err=''
delvarx,files
count=0
verbose=keyword_set(verbose)

if not exist(factor) then begin
 pr_syntax,'rebin_fid,t1,t2,files,factor'
 return
endif

if not data_chk(outdir,/string) then begin
 err='Need to specify target directory for rebinned files'
 message,err,/cont
 return
endif

if not chk_dir(outdir,err=err) then begin
 message,'target directory '+outdir+' does not exist',/cont
 return
endif

;-- first check source directory

find_fid,t1,t2,tfiles,_extra=extra,err=err,count=count
if count eq 0 then begin
 if verbose then message,err,/cont
 return
endif

;-- if first file is not GIF then bail out now

if not valid_gif(tfiles(0),err=err) then begin
 if verbose then message,err,/cont
 return
endif

;-- now check if binned copy already exists in target directory
;   If not, then create it.

clobber=keyword_set(clobber)
for i=0,count-1 do begin
 break_file,tfiles(i),dsk,dir,name,ext
 outfile=concat_dir(outdir,name+ext)
 vcheck=loc_file(outfile,count=vcount)
 if (vcount eq 0) or clobber then rebin_gif,tfiles(i),outfile,factor
 files=append_arr(files,outfile)
endfor

espawn,'chmod -R g+w '+outdir,out
       
return & end



