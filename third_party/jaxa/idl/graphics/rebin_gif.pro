;+
; Project     : SOHO - CDS
;
; Name        : REBIN_GIF
;
; Purpose     : rebin GIF file by given factor
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : IDL>rebin_gif,old,new,factor
;
; Inputs      : OLD = old filename
;               NEW = new filename
;               FACTOR = rebin factor = fx or [fx,fy]
;               SMOOTH = smooth image
;               PIXELS = if set, factor is interpreted as pixel values
;
; Opt. Inputs : None
;
; Outputs     : new rebinned GIF file
;
; Opt. Outputs: None
;
; Keywords    : SIZE = new output pixel size
;               PIXELS = interpret factor as pixels
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  14-Aug-1997,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro rebin_gif,old,new,factor,err=err,interp=interp,size=psize,pixels=pixels

;-- check inputs

err='Syntax: reduce_gif,old,new,factor'

if (datatype(old) ne 'STR') or (datatype(new) ne 'STR') then begin
 message,err,/cont
 return
endif

if not exist(factor) then begin
 message,err,/cont
 return
endif

if n_elements(factor) eq 1 then begin
 fx=factor & fy=factor
endif else begin
 fx=factor(0) & fy=factor(1)
endelse


pixels=keyword_set(pixels)
if (fx eq 1) and (fy eq 1) and (not pixels) then begin
 message,'No rebin necessary',/cont
 return
endif

chk=loc_file(old,count=count)
if count eq 0 then begin
 err='Cannot locate: '+old
 message,err,/cont
 return
endif

break_file,new,dsk,dir
outdir=trim(dsk+dir)
cd,curr=curr
if outdir eq '' then outdir=curr
chk=test_open(outdir,/write)
if not chk then begin
 err='Cannot write to: '+outdir
 message,err,/cont
 return
endif

;-- now read and rebin

read_gif,old,image,r,g,b
sz=size(image)
nx=float(sz(1)) & ny=float(sz(2))

if pixels then begin
 if (nx eq fx) and (ny eq fy) then begin
  message,'No rebin necessary',/cont
  return
 endif
 new_x=fx & new_y=fy
endif else begin
 new_x=nx*fx & new_y=ny*fy
endelse

image=congrid(temporary(image),new_x,new_y,interp=smooth)
psize=(size(image))(1:2)
write_gif,new,image,r,g,b

return & end

