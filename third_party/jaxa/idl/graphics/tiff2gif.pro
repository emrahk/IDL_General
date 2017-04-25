;+
; Project     : SOHO-CDS
;
; Name        : TIFF2GIF
;
; Purpose     : convert TIFF to GIF files
;
; Category    : Utility
;
; Explanation :
;
; Syntax      : IDL> tiff2gif,tiff_file
;
; Examples    : 
;
; Inputs      : TIFF_FILE = list of TIFF filenames OR directory name
;               containing files.
;
; Opt. Inputs : None
;
; Outputs     : GIF files 
;
; Opt. Outputs: 
;
; Keywords    : OUT_DIR = output directory for GIF files
;                         [def is same as input location of TIFF files)
;               SIZE = size of GIF files 
;                      (e.g. size=512, or size=[512,512] to rebin to 512)
;               VERBOSE = print messages
;   
;               FLIP = flip N/S
;     
;               JPEG = out JPEG instead
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 8 June 1999 D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


pro tiff2gif,files,out_dir=out_dir,size=gsize,verbose=verbose,help=help,$
             flip=flip,jpeg=jpeg


if keyword_set(help) then begin
 pr_syntax,'tiff2gif,files,[out_dir=out_dir,size=size,flip=flip]
 return
endif

;-- check if input is directory or file listing

verbose=keyword_set(verbose)
flip=keyword_set(flip)

if datatype(files) eq 'STR' then infiles=files else infiles=''
if trim(infiles) eq '' then infiles=curdir()
if is_dir(infiles) then begin
 tiff_list=loc_file('*.tif*',path=infiles,count=count)
 if count eq 0 then tiff_list=loc_file('*.TIF*',path=files,count=count)
 if count eq 0 then begin
  message,'could not find TIFF files in "'+infiles+'"',/cont
  return
 endif
endif else tiff_list=infiles

;-- determine output location

if is_dir(out_dir) then temp=out_dir else begin
 break_file,tiff_list,dsk,dir,names,ext
 temp=dsk+dir
 if trim(temp(0)) eq '' then temp=curdir() else temp=temp(0)
endelse

if not write_dir(temp) then begin
 message,'no write access to output directory "'+temp+'"',/cont
 return
endif

;-- now do the work
;   output files will have ".gif" or ".jpg" ext
;   only rebin if requested

if exist(gsize) then begin
 nx=gsize(0)
 if n_elements(gsize) eq 2 then ny=gsize(1) else ny=nx
 req_rebin=1b
endif else req_rebin=0b

ext='.gif'
if keyword_set(jpeg) then ext='.jpg'
out_list=concat_dir(temp,names+ext)

did_one=0b
for i=0,n_elements(tiff_list)-1 do begin
 is_tiff=query_tiff(tiff_list(i),info)
 if is_tiff then begin
  if verbose then message,'converting file "'+tiff_list(i)+'"',/cont
  a=read_tiff(tiff_list(i),r,g,b)
  if req_rebin then begin
   ax=data_chk(a,/nx) & ay=data_chk(a,/ny)
   do_rebin=(ax ne nx) or (ay ne ny)
  endif else do_rebin=0b
  if do_rebin then a=congrid(a,nx,ny)
  if verbose then message,'writing file "'+out_list(i)+'"',/cont
  if flip then a=rotate(a,7) 
  tvlct,r,g,b
;  write_gif,out_list(i),a,r,g,b
  saveimage,out_list(i),jpeg=jpeg
  did_one=1b
 endif
endfor

if not did_one then message,'no TIFF files converted',/cont

return & end


