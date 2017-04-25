;+
; Project     : SOHO-CDS
;
; Name        : MAP2MPEG
;
; Purpose     : make MPEG movie from series of maps
;
; Category    : imaging
;
; Syntax      : map2mpeg,map,file
;
; Inputs      : MAP = array of map structures
;               FILE = MPEG file name
;
; Keywords    : DRANGE = [dmin,dmax], min and max values to scale data
;               SIZE = [min,max], dimensions of MPEG movie (def= [512,512])
;               NOSCALE = If set, don't scale to min/max of all images (def=0)
;               STATUS = Returns 0/1 for failure/success
;
; History     : Written 11 Jan 2000, D. Zarro, SM&A/GSFC
;               Modified 1 Dec 2004, Zarro (L-3Com/GSFC)
;                - made compression quality default to 100.
;               10-Feb-2005, Kim Tolbert.  Added noscale and status keywords, and added
;                  catch error handler to reset device and close mpeg if error.
;
; Contact     : dzarro@solar.stanford.edu
;-

pro map2mpeg,map,file,drange=drange,_extra=extra,size=msize,verbose=verbose, $
   noscale=noscale, status=status

status=0
;-- check inputs

if not have_proc('mpeg_open') then begin
 message,'current version of IDL does not support this operation',/cont
 return
endif

if (not valid_map(map)) or (datatype(file) ne 'STR') then begin
 pr_syntax,'map2mpeg,maps,file'
 return
endif

break_file,file,dsk,dir
out_dir=dsk+dir
if trim(out_dir) eq '' then out_dir=curdir()
if not test_dir(out_dir) then return

nmaps=n_elements(map)
if nmaps lt 2 then begin
 message,'need at least 2 maps to make an MPEG movie',/cont
 return
endif

if n_elements(drange) ne 2 then begin
 if keyword_set(noscale) then drange=[0.,0.] else begin
    dmin=min(map.data,max=dmax)
    drange=[dmin,dmax]
 endelse
endif

catch, err
if err ne 0 then begin
   catch, /cancel
   message, !error_state.msg + '  Aborting.', /cont
   if exist(psave) then set_plot,psave
   if exist(id) then mpeg_close,id
   status = 0
   return
endif

;--  Method:
;    plot map to Z-buffer, read it back, scale it to 24 bit, and load it
;    into MPEG object

psave=!d.name
set_plot,'z',/copy
zsize=[512,512]
if exist(msize) then zsize=[msize(0),msize(n_elements(msize)-1)]
id=mpeg_open(zsize,_extra=extra,quality=100)

;-- get color table

ncolors=!d.table_size
device,/close,set_resolution=zsize,set_colors=ncolors
tvlct,rs,gs,bs,/get

for i=0,nmaps-1 do begin
 if keyword_set(verbose) then message,'loading image map '+trim(i),/cont
 plot_map,map[i],drange=drange,_extra=extra
 image24=mk_24bit(tvrd(),rs,gs,bs)
 device,/close
 mpeg_put,id,image=image24,frame=i,/order
endfor

if exist(psave) then set_plot,psave
mpeg_save,id,file=file
mpeg_close,id
message,'MPEG movie saved to '+file,/cont
status=1

return & end


