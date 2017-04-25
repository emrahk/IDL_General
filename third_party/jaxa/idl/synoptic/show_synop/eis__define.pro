;+
; Project     : EIS
;
; Name        : EIS__DEFINE
;
; Purpose     : Define an EIS data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('eis')
;
; History     : Written 1-Jan-09 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function eis::init,_ref_extra=extra

if ~self->site::init(_extra=extra) then return,0
if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;------------------------------------------------------------------------

pro eis::cleanup

self->site::cleanup
self->fits::cleanup

return & end

;--------------------------------------------------------------------------
;-- VSO search wrapper

function eis::vso_search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,inst='eis',_extra=extra)

end

;-----------------------------------------------------------------------
function eis::search,tstart,tend,_ref_extra=extra,count=count,type=type

forward_function eis_server

type=''
count=0
if ~self->have_path(_extra=extra) then return,''

rhost=eis_server()
topdir='/hinode/eis/level0'
self->setprop,rhost=rhost,ext='fits',org='day',$
                 topdir=topdir,/full,$
                 delim='/',ftype='eis'

files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('euv/images',count) else files=''
if count eq 0 then message,'No EIS files found.',/info

return,files
end

;---------------------------------------------------------------------------
;-- check for EIS branch in !path

function eis::have_path,err=err,quiet=quiet

err=''
if ~have_proc('eis_prep.pro') then begin
 epath=local_name('$SSW/hinode/eis/idl')
 if is_dir(epath) then ssw_path,/eis,/quiet
 if ~have_proc('eis_prep.pro') then begin
  err='EIS branch of SSW not installed.'
  if ~keyword_set(quiet) then message,err,/info
  return,0b
 endif
endif

return,1b

end

;--------------------------------------------------------------------------
;-- FITS reader

pro eis::read,file,_ref_extra=extra,err=err,verbose=verbose

err='' 

verbose=keyword_set(verbose)

;-- download if URL

self->getfile,file,local_file=ofile,_extra=extra
if is_blank(ofile) then return

;-- read files

k=-1l
nfiles=n_elements(ofile)
for i=0,nfiles-1 do begin
 err=''

 valid=self->is_valid(ofile[i],level=level,err=err)
 if ~valid then continue

;-- read regular FITS file

 if level eq 2 then begin
  self->fits::read,ofile[i],_extra=extra,ext=image_no,/all,/silent
  k=self->get(/count)
  continue
 endif

;-- bail if EIS not in path

 if ~self->have_path() or ~self->have_cal() then continue

 edata=obj_new('eis_data',ofile[i])
 if ~obj_valid(edata) then continue

;-- prep level-0 data

 if edata->getfitslev() eq 0 then self->prep,edata,_extra=extra else $
  message,'Data already prepped.',/info

;-- extract wavelengths 

 swaves=edata->getline_id()
 waves=stregex(swaves,'([0-9].+)',/ext,/sub)
 waves=reform(strtrim(waves[1,*],2))
 ok=where(waves ne '',nwaves)
 if nwaves eq 0 then continue
 swaves=swaves[ok]
 waves=float(waves[ok])
 if verbose then message,'Reading '+trim(nwaves)+' wavelengths...',/info

;-- create maps

 temp=mrdfits(ofile[i],0,header)
 index=fitshead2struct(header)
 index=rem_tag(index,'extend')
 index=rep_tag_value(index,'','wavelnth')
 index=rep_tag_value(index,0.,'exptime')
 index=rep_tag_value(index,nwaves,'EIS_MAPS')
 index=rep_tag_value(index,'Prepped','EIS_PREP')
 index=rep_tag_value(index,file_basename(ofile[i]),'filename')
 
 for j=0,nwaves-1 do begin
  k=k+1
  map=edata->mk_eis_map(waves[j])
  map=rep_tag_value(map,'Hinode EIS '+swaves[j],'id')
  map.time=strtrim(map.time)
  map=rem_tag(map,['b0','rsun'])
  index.wavelnth=swaves[j]
  index.exptime=map.dur
  self->set,k,map=map,/no_copy
  self->set,k,index=index
  self->update_index,k
 endfor
endfor

count=self->get(/count)
if count gt 0 then for i=0,count-1 do self->set,i,/log_scale,grid=30,/limb

if obj_valid(edata) then obj_destroy,edata
err=''
if count eq 0 then begin
 err='No EIS data read.'
 message,err,/info
 return
endif

return & end

;---------------------------------------------------------------------------
;-- wrapper around eis_prep. Prep selection functions should go in
;   here.

pro eis::prep,file,_extra=extra

eis_prep,file,_extra=extra,/default,/quiet,/retain

return & end

;----------------------------------------------------------------------
function eis::is_valid,file,err=err,level=level,verbose=verbose

valid=0b & level=0 & err=''
verbose=keyword_set(verbose)
if is_url(file) then sock_fits,file,header=header,/nodata,err=err else $
 mrd_head,file,header,err=err
if is_string(err) then begin
 message,'Could not read header - '+file,/info
 return,valid
endif

chk0=where(stregex(header,'(INST|TEL|DET|ORIG).+EIS',/bool,/fold),count0)
chk1=where(stregex(header,'EIS_PREP',/bool,/fold),count1)
chk2=where(stregex(header,'(EIS_MAP|Prepped)',/bool,/fold),count2)

valid=(count0 gt 0)
if ~valid then begin
 err='Not a valid EIS file - '+file
 message,err,/info
 return,valid
endif

if (count2 gt 0) then begin
 level=2 
 return,valid
endif

if (count1 gt 0) then begin
 level=1
 return,valid
endif

return,valid & end

;------------------------------------------------------------------------
;-- setup EIS environment variables

pro eis::setenv,_extra=extra

if is_string(chklog('EIS_RESPONSE')) then return
file_env=local_name('$SSW/hinode/eis/setup/setup.eis_env')
file_setenv,file_env,_extra=extra
return & end

;------------------------------------------------------------------------

function eis::wavelengths

count=self->get(/count)
if count eq 0 then return,''

ids=strarr(count)
for k=0,count-1 do ids[k]=self->get(k,/id)

return,ids
end

;-------------------------------------------------------------------------
;-- plot method override

pro eis::plotman,i,_ref_extra=extra 

count=self->get(/count)
if count eq 0 then return

if count eq 1 then image_no=0
if is_number(i) then begin
 image_no=i & count=1
endif

if count gt 1 then begin
 ids=strarr(count)
 for k=0,count-1 do ids[k]=self->get(k,/id)
 ids=str_replace(ids,'EIS','')
 ids=str_replace(ids,'Hinode','')
 image_no=xsel_list_multi(ids,/index,_extra=extra,$
  label='Select wavelengths from list below:',cancel=cancel)
 if cancel then return
endif

for i=0,n_elements(image_no)-1 do begin
 k=image_no[i]
 self->fits::plotman,k,_extra=extra
endfor

return & end

;----------------------------------------------------------------------
function eis::have_cal,err=err,verbose=verbose

err=''
have_cal=is_dir(local_name('$SSW/hinode/eis/data/cal'))
if ~have_cal then err='EIS calibration directory not found. Cannot Prep data.'
if keyword_set(verbose) then message,err,/info
return,have_cal
end

;------------------------------------------------------------------------------
;-- EIS structure definition

pro eis__define,void                 

void={eis,inherits fits, inherits site, inherits prep}

return & end
