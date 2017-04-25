;+
; Project     : SOHO-CDS
;
; Name        : MAP2JPEG
;
; Purpose     : make series of JPEG images from series of maps
;
; Category    : imaging
;
; Syntax      : map2jpeg,map,names
;
; Inputs      : MAP = array of map structures
;               NAMES = array of output JPEG names [def = framei.jpeg]
;
; Keywords    : DRANGE = [dmin,dmax], min and max values to scale data
;               SIZE = [min,max], dimensions of JPEGs  (def= [512,512])
;               PREFIX = If NAMES isn't provided, then jpeg file names will be
;                       prefixnn.jpeg where nn is the image number
;               NOSCALE = If set, don't scale to min/max of all images (def=0)
;               STATUS = Returns 0/1 for failure/success
;
; History     : Written 11 Jan 2000, D. Zarro, SM&A/GSFC
;               10-Feb-2005, Kim Tolbert.  Corrected !p.colors->!p.color, added
;                       noscale and status keywords
;
; Contact     : dzarro@solar.stanford.edu
;-

pro map2jpeg,map,names,drange=drange,prefix=prefix,_extra=extra,$
                      size=gsize, noscale=noscale, status=status

status = 0

if not valid_map(map) then begin
 pr_syntax,'map2jpeg,map,names'
 return
endif

if not test_dir(curdir()) then return

;-- create output names

nmaps=n_elements(map)
if (datatype(names) eq 'STR') and (n_elements(names) eq nmaps) then fnames=names else begin
 ids=trim(str_format(sindgen(nmaps),'(i4.2)'))
 if datatype(prefix) eq 'STR' then gfix=prefix else gfix='frame'
 fnames=gfix+ids+'.jpeg'
endelse

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
   if exist(csave) then !p.color=csave
   status = 0
   return
endif

psave=!d.name
set_plot,'z',/copy
xsize=500 & ysize=500
ncolors=!d.table_size
csave=!p.color
if not exist(gsize) then zsize=[xsize,ysize] else $
  zsize=[gsize(0),gsize(n_elements(gsize)-1)]
device,/close,set_resolution=zsize,set_colors=ncolors
!p.color=ncolors-1

tvlct,rs,gs,bs,/get

for i=0,nmaps-1 do begin
 plot_map,map(i),drange=drange,_extra=extra
 dprint,'% writing fnames(i)..'
 image = mk_24bit(tvrd(), rs, gs, bs)
 device,/close
 write_jpeg, fnames(i), image, /true
endfor

path = file_break(fnames[0], /path)
just_names = file_break(fnames)
prstr, just_names, file=concat_dir(path,'jpeg_files.txt') ; write ascii file of jpeg file names

if exist(psave) then set_plot,psave
if exist(csave) then !p.color=csave

status=1
return & end


