;+
; Project     : Hinode
;
; Name        : XRT2__DEFINE
;
; Purpose     : Define an XRT data/map object
;
; Category    : Objects
;
; Syntax      : IDL> a=obj_new('xrt2')
;
; History     : Written 2 June 2009, D. Zarro (ADNET)
;               
; Contact     : dzarro@solar.stanford.edu
;-

function xrt2::init,_ref_extra=extra

!except=0
if ~self->fits::init(_extra=extra) then return,0

;chk=self->prep::init(_extra=extra)

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;------------------------------------------------------------------------
;-- setup XRT environment variables

pro xrt2::setenv,_extra=extra

if is_blank(chklog('XRT_CALIBRATION')) then begin
 file_env='$SSW/hinode/xrt/setup/setup.xrt_env'
 file_setenv,file_env,_extra=extra
endif

;-- include SOT for good measure

if is_blank(chklog('SOT_CALIBRATION')) then begin
 file_env='$SSW/hinode/sot/setup/setup.sot_env'
 file_setenv,file_env,_extra=extra
endif

return & end

;-----------------------------------------------------------------------------
;-- check for XRT branch in !path

function xrt2::have_path,err=err,verbose=verbose

err=''
if ~have_proc('xrt_prep') then begin
 epath=local_name('$SSW/hinode/xrt/idl')
 if is_dir(epath) then ssw_path,/xrt,/quiet
 if ~have_proc('xrt_prep') then begin
  err='Hinode/XRT branch of SSW not installed.'
  if keyword_set(verbose) then message,err,/cont
  return,0b
 endif
endif

;-- XRT_PREP needs SOT_CAT

if ~have_proc('sot_cat') then begin
 epath=local_name('$SSW/hinode/sot/idl')
 if is_dir(epath) then ssw_path,/sot,/quiet
endif

return,1b

end

;---------------------------------------------------------------------

function xrt2::have_cal,err=err,verbose=verbose

;-- ensure that calibration directories are properly defined

err=''
if ~is_dir('$SSW/hinode/xrt/idl/response') then begin
 err='XRT calibration directory not found.'
 if keyword_set(verbose) then message,err,/cont
 return,0b
endif

return,1b & end

;--------------------------------------------------------------------------
;-- FITS reader

pro xrt2::read,file,data,_ref_extra=extra,err=err

err=''
if is_blank(file) then begin
 pr_syntax,'obj->read,file'
 return
endif

self->empty
have_cal=self->have_cal(err=err1)
have_path=self->have_path(err=err2)
cpath=is_dir(local_name('SSWDB/hinode/xrt/xrt_msu_coalign'))
if ~cpath then coalign=2

err=''

;-- download files if not present

self->getfile,file,local_file=cfile,err=err,_extra=extra
if is_blank(cfile) then return
nfiles=n_elements(cfile) 

j=0
for i=0,nfiles-1 do begin
 valid=self->is_valid(cfile[i],level=level,_extra=extra)
 if ~valid then continue

 if (level gt 0) then begin
  self->fits::read,cfile[i],_extra=extra,/append
  j=self->get(/count)
  continue
 endif

 if have_cal and have_path then begin
  xrt_prep,cfile[i],0,index,data,_extra=extra,/float,/norm,/quiet,$
           coalign=coalign
 endif else begin
  if ~have_cal then message,err1,/cont
  if ~have_path then message,err2,/cont
  message,'Skipping prepping.',/cont
  self->readfits,cfile[i],data,_extra=extra,index=index
 endelse

;-- insert data into maps
 
 index=rep_tag_value(index,file_basename(cfile[i]),'filename')
 index2map,index,data,map,_extra=extra,err=err,/no_copy
 map.id=map.id+' '+index.EC_FW2_+' '+trim(index.ec_fw2)
 if is_string(err) or ~valid_map(map) then begin
  message,err,/cont
  continue
 endif
 self->set,j,index=index,map=map,/no_copy
 j=j+1
endfor

count=self->get(/count)
if count eq 0 then message,'No maps created.',/cont else begin
 for i=0,count-1 do begin
  self->set,i,/log_scale,grid=30
  self->colors,i
 endfor
endelse

return & end

;-----------------------------------------------------------------------
;-- VSO search function

function xrt2::search,tstart,tend,_ref_extra=extra,type=type,count=count

f=vso_files(tstart,tend,inst='xrt',_extra=extra,count=count,wmin=wmin,window=3600.)
if arg_present(type) and exist(wmin) then type=strmid(wmin,0,3)+' A'
if count eq 0 then message,'No files found',/cont

return,f

end

;------------------------------------------------------------------------------
;-- save XRT color table

pro xrt2::colors,k

dsave=!d.name
set_plot,'Z'
tvlct,r0,g0,b0,/get
loadct,3,/silent
tvlct,red,green,blue,/get
tvlct,r0,g0,b0
set_plot,dsave

self->set,k,red=red,green=green,blue=blue,/has_colors

return & end

;------------------------------------------------------------------------------
;-- check if valid XRT file

function xrt2::is_valid,file,err=err,verbose=verbose,$
                  level=level,_extra=extra

level=0
instrument=''
mrd_head,file,header,err=err
if is_string(err) then return,0b

s=fitshead2struct(header)
if have_tag(s,'dete',/start,index) then detector=strup(s.(index))
if have_tag(s,'instru',/start,index) then instrument=strup(s.(index))

if have_tag(s,'history') then begin
 chk=where(stregex(s.history,'XRT_PREP',/bool,/fold),count)
 level=count gt 0
endif

verbose=keyword_set(verbose)

return,instrument eq 'XRT'
end

;------------------------------------------------------------------------
;-- XRT data structure

pro xrt2__define,void                 

void={xrt2, inherits fits, inherits prep}

return & end
