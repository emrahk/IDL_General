;+
; Project     : SOHO-CDS
;
; Name        : ARR2GIF
;
; Purpose     : Write images to a series of GIF files
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : IDL> arr2gif,images,file
;
; Examples    :
;
; Inputs      : IMAGES = times series of 2-d images (x,y,t)
;
; Opt. Inputs : None
;
; Outputs     : FILE = filename with listing of individual GIF filenames
;
; Opt. Outputs: None
;
; Keywords    : XSIZE,YSIZE = new sizes to CONGRID images
;               FILE = filename with listing of individual GIF filenames
;               OUT_DIR = output directory for GIF files (def=curr or home)
;               INTERP= smooth images
;
; History     : Written 22 March 1997, D. Zarro, ARC/GSFC
;               Version 2, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;
; Contact     : dzarro@solar.stanford.edu
;-

pro arr2gif,images,file=file,xsize=xsize,ysize=ysize,interp=interp,$
            out_dir=out_dir,pict=pict

;-- check inputs 

sz=size(images)
if (sz(0) ne 2) and (sz(0) ne 3) then begin
 message,'Input images must be 2-d (x,y) or 3-d (x,y,t)',/cont
 return
endif

nx=sz(1) & ny=sz(2) 
if sz(0) eq 2 then nt=1 else nt=sz(3)

if not exist(xsize) then xsize=nx
if not exist(ysize) then ysize=ny

rescale=datatype(images) ne 'BYT' 
resize=(nx ne xsize) or (ny ne ysize)

;-- determine where to list gif files
;-- each file will be named: gif.i

home=getenv('HOME')
cd,curr=curr
if datatype(out_dir) ne 'STR' then out_dir=curr
if not test_open(out_dir,/write,/quiet) then out_dir=curr
if not test_open(out_dir,/write,/quiet) then out_dir=home
out_dir=expand_tilde(out_dir)
if keyword_set(pict) then ofile='pict' else ofile='gif'
file=concat_dir(out_dir,ofile+'.lis')
openw,unit,file,/get_lun
for i=0,nt-1 do begin
 app=trim(string(i))
 if i lt 10 then app='0'+app
 temp=concat_dir(out_dir,ofile+'.'+app)
 if rescale then tarr=bytscl(images(*,*,i)) else tarr=images(*,*,i)
 if resize then tarr=congrid(temporary(tarr),xsize,ysize,interp=interp)
 ssw_write_gif,temp,tarr
 printf,unit,temp
endfor

message,strupcase(ofile)+' file listing in: '+file,/cont
close,unit & free_lun,unit
return & end

