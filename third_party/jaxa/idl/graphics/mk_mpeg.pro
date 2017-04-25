;+
; Project     : SOHO-CDS
;
; Name        : MK_MPEG
;
; Purpose     : make an MPEG movie from a series of image files (def = GIF)
;
; Category    : imaging
;
; Syntax      : mk_mpeg,images,file
;
; Inputs      : IMAGE = array of GIF filenames
;               FILE = output MPEG name
;
; Keywords    : JPEG = set for JPEG
;
; History     : Written 11 Jan 2000, D. Zarro, SM&A/GSFC
;               Modified 8 Dec 2004, Zarro (L-3Com/GSFC) 
;                - made QUALITY=100 the default
;                   
; Contact     : dzarro@solar.stanford.edu
;-

pro mk_mpeg,images,file,jpeg=jpeg,verbose=verbose,_extra=extra

if not have_proc('mpeg_open') then begin
 message,'current version of IDL does not support this operation',/cont
 return
endif

if n_elements(images) lt 2 then begin
 message,'enter at least 2 filenames to make an MPEG movie',/cont
 return
endif

if datatype(file) ne 'STR' then begin
 pr_syntax,'mk_mpeg,in_files,out_file'
 return
endif

break_file,file,dsk,dir
out_dir=trim(dsk+dir)
if trim(out_dir) eq '' then out_dir=curdir()
if not test_dir(out_dir) then return

do_jpeg=keyword_set(jpeg)
j=-1

for i=0,n_elements(images)-1 do begin
 
;-- read files and load color tables

 if do_jpeg then ok=query_jpeg(images(i),info) else ok=query_gif(images(i))
 if ok then begin
  if do_jpeg then read_jpeg,images(i),image24,/true else begin
   read_gif,images(i),data,r,g,b

;-- make 24 bit

   image24=mk_24bit(data,r,g,b)

  endelse

;-- set output size and create MPEG object

  if not exist(dims) then dims=[data_chk(data,/nx),data_chk(data,/ny)]

  if not exist(id) then id=mpeg_open(dims,_extra=extra,quality=100)  

;-- plot and load into object
  
  j=j+1
  mpeg_put,id,image=image24,frame=j,/order
  if keyword_set(verbose) then message,'loading '+images(i),/cont
 endif

endfor

if exist(id) then begin
 mpeg_save,id,file=file
 mpeg_close,id
 message,'MPEG movie saved to '+file,/cont
endif else message,'problems creating MPEG movie',/cont

if exist(psave) then set_plot,psave

return & end

