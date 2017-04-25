;+
; Project     : SOHO-CDS
;
; Name        : DAT2GIF
;
; Purpose     : Write 2-d data to GIF file
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : IDL> dat2gif,data,file
;
; Examples    :
;
; Inputs      : DATA = 2-d data
;               FILE = output file
;
; Opt. Inputs : None
;
; Outputs     : None
;
; Opt. Outputs: None
;
; Keywords    : XSIZE,YSIZE = new sizes to CONGRID images
;               INTERP= smooth images
;
; History     : Written 22 March 1997, D. Zarro, ARC/GSFC
;               Version 2, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;
; Contact     : dzarro@solar.stanford.edu
;-

pro dat2gif,data,file,xsize=xsize,ysize=ysize,interp=interp,$
            color=color,red=red,green=green,blue=blue,noz=noz


;-- check inputs 

sz=size(data)
if sz(0) ne 2 then begin
 message,'Input image must be 2-d',/cont
 return
endif

if datatype(file) ne 'STR' then begin
 message,'Enter output GIF filename',/cont
 return
endif

nx=sz(1) & ny=sz(2) 
if not exist(xsize) then xsize=nx
if not exist(ysize) then ysize=ny

resize=(nx ne xsize) or (ny ne ysize)

sav_dev=!d.name

use_z=1-keyword_set(noz)
if use_z then begin
 set_plot,'z'
 device,/close,set_resolution=[xsize,ysize],set_colors=!d.table_size
endif

temp=bytscl(data)
if resize then temp=congrid(temporary(temp),xsize,ysize,interp=interp) 

if use_z then begin
 tvscl,temp
 temp=tvrd()
endif

set_plot,sav_dev

;-- override color table

if n_elements(red)*n_elements(green)*n_elements(blue) eq 0 then cload=0 else cload=1

if cload then ssw_write_gif,file,temp,red,green,blue else begin
 if exist(color) then begin
  select_windows
  tvlct,rs,gs,bs,/get
  loadct,color
  ssw_write_gif,file,temp
  set_plot,sav_dev
  tvlct,rs,gs,bs
 endif
endelse

return & end


