;+
; Project     : HESSI
;
; Name        : EIT__DEFINE
;
; Purpose     : Define an EIT data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('eit')
;
; History     : Written 17 Feb 2001, D. Zarro, EIT/GSFC
;               Modified 17 Mar 2004, Zarro (L-3Com/GSFC) - call EIT_COLORS
;               Modified 9  Jun 2004, Gallagher (L-3Com/GSFC) - added ::LATEST
;               Modified 28 Nov 2005, Zarro (L-3Com/GSFC)
;                - added VSO search capability
;               Modified 2 Sep 2006, Zarro (ADNET/GSFC) - added color
;                                                         protection
;               Modified 9 July 2007, Zarro (ADNET/GSFC)
;                - redirected ::LATEST to search RHESSI Synoptic archive
;               Modified 20 March 2009, Zarro (ADNET)
;                - fixed call to EIT_PREP so that correct output header is
;                  passed to object
;               25 January 2010, Tolbert (Wyle)
;                - added hooks for selecting prep options
;               27 December 2011, Zarro (ADNET)
;               - fixed bug that caused downloading calibration files 
;                 even when data was already prepped
;               25-July-2015, Zarro (ADNET)
;                - removed unnecessary use of Z-buffer
;
; Contact     : dzarro@solar.stanford.edu
;-

function eit::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;------------------------------------------------------------------------
;-- setup EIT environment variables

pro eit::setenv,_extra=extra

if is_string(chklog('SSW_EIT_RESPONSE')) then return
file_env='$SSW/soho/eit/setup/setup.eit_env'
file_setenv,file_env,_extra=extra
return & end

;-------------------------------------------------------------------------
;-- check for EIT calibration data files

function eit::have_cal,err=err,verbose=verbose,no_download=no_download

common have_cal,last_check
err=''
if exist(last_check) then if last_check then return,last_check

download=~keyword_set(no_download)
verbose=keyword_set(verbose)

cal_dir=local_name('$SSWDB/soho/eit/calibrate')
test_file='cal19951209.fts'
chk=file_search(concat_dir(cal_dir,test_file),count=count)
have_cal=count eq 1

if ~have_cal and download then begin
 err='SOHO/EIT calibration files not installed.'
 if verbose then message,err,/info
 if self->have_path() then begin
  server=eit_server(network=network)
  if network then begin
   if verbose then message,'Will attempt to download calibration files from remote server...',/info
   sub_proc,'eit_norm_response','readfits(','eit_cal_readfits(',verbose=verbose
   sub_proc,'eit_find_last_cal','readfits(','eit_cal_readfits(',verbose=verbose
   sub_proc,'eit_findcalgroup','readfits(','eit_cal_readfits(',verbose=verbose
   have_cal=1b & err=''
  endif
 endif
endif

last_check=have_cal
return,have_cal

end

;-------------------------------------------------------------------------
;-- get EIT file times from file names

function eit::times,files,_extra=extra

if is_blank(files) then return,-1d

year='([0-9]{0,2}[0-9]{2})'
mon='([0-9]{2})'
day=mon
hr='([0-9]{0,2})'
min=hr
sec=hr
regex=year+mon+day+'\.'+hr+min+sec
check=stregex(files,regex,/ext,/sub)
value=anytim2utc(!stime,/ext)
times=make_array(n_elements(files),value=value)
times.year=comdim2(check[1,*])
times.month=comdim2(check[2,*])
times.day=comdim2(check[3,*])
times.hour=comdim2(check[4,*])
times.minute=comdim2(check[5,*])
times.second=comdim2(check[6,*])
times.millisecond=0

if ~is_struct(extra) then return,anytim2tai(times)
if have_tag(extra,'tai') then return,anytim2tai(times)

return,anytim2utc(times,_extra=extra)

end

;--------------------------------------------------------------------------
;-- VSO search method

function eit::search,tstart,tend,_ref_extra=extra,type=type,count=count,$
                     sizes=sizes,times=times

type='' & times=-1 & sizes=''
f=vso_files(tstart,tend,_extra=extra,inst='EIT',wmin=wmin,count=count,$
                     times=times)

;-- filter out EFZ files

if count gt 0 then chk=where(stregex(f,'\/efz',/bool),count)

if count eq 0 then begin
 message,'No EIT files found.',/info
 return,f
endif

sizes=replicate('',count)
type=strmid(wmin,0,3)+' A'

if count lt n_elements(f) then begin
 f=f[chk] & times=times[chk] & type=type[chk] & sizes=sizes[chk]
endif

if count eq 1 then begin
 f=f[0] & times=times[0] & type=type[0] & sizes=sizes[0]
endif

return,f

end

;-----------------------------------------------------------------------------
;-- search EIT files either from local archive if available, or use VSO
;   if unavailable

function eit::list,tstart,tend,count=count,vso=vso,verbose=verbose,$
              times=times,sizes=sizes,_ref_extra=extra,window=window,wavelength=wavelength

forward_function eit_files

if is_number(window) then trange=window else trange=5.

verbose=keyword_set(verbose)
files='' & count=0 & sizes=''

;-- list whole day if invalid times entered or find nearest to tstart

dstart=get_def_times(tstart,tend,dend=dend,/ecs,_extra=extra)
istart=get_def_times(tstart,tend,dend=iend,/ecs,_extra=extra)
nearest=valid_time(tstart) and ~valid_time(tend)
include=valid_time(tstart) and valid_time(tend)
if include then begin dstart=istart & dend=iend & endif

;-- check what is supported

use_vso=keyword_set(vso)
sup_eit=have_proc('eit_files') and is_dir('$EIT_TOP_DATA')
sup_vso=since_version('5.6')

vso_mess='VSO access unsupported for IDL '+!version.release
eit_mess='EIT archive not found on this system.'
if (~sup_eit) and (~sup_vso) then begin
 message,vso_mess,/info
 message,eit_mess,/info
 times=-1d
 return,''
endif

if nearest then begin
 dstart=anytim2utc(anytim2tai(tstart)-trange*3600,/ecs)
 dend=anytim2utc(anytim2tai(tstart)+trange*3600,/ecs)
endif

if verbose then message,'Searching between '+dstart+' and '+dend,/info

if use_vso and (~sup_vso) then begin
 message,vso_mess,/info
 use_vso=0b
endif

if (~use_vso) and (~sup_eit) then begin
 message,eit_mess,/info
 message,'Trying VSO..',/info
 use_vso=1b
endif

;-- search VSO

if use_vso then begin
 if verbose then message,'Searching VSO...',/info
 return,self->search(dstart,dend,times=times,sizes=sizes,$
                    wavelength=wavelength,count=count)
endif else begin

;-- search EIT archives

 if verbose then message,'Searching SOHO/EIT archives...',/info
 f1=eit_files(dstart,dend,/lz,/quiet)
 f2=eit_files(dstart,dend,/quick,/quiet)
 files=get_uniq(rem_blanks([f1,f2]),count=count)

endelse

if verbose or (count eq 0) then message,'Found '+trim(count)+' matching files',/info

if count gt 0 then begin
 if arg_present(times) or nearest then begin
  times=self->times(files,_extra=extra)
  if nearest then begin
   index=near_time(times,tstart)
   times=times[index[0]]
   files=files[index[0]]
   count=1
  endif
 endif
endif

if count gt 1 then sizes=strarr(count)
return,files

end

;------------------------------------------------------------------------------
; get latest EIT image

pro eit::latest,ofile,out_dir=out_dir,_ref_extra=extra,err=err,$
                filter = filter, bandpass=bandpass,back=back,wave=wave

  err=''

;-- default to current directory

  if is_blank(out_dir) then odir=curdir() else odir=out_dir
  if ~test_dir(odir,err=err,out=out,/verbose) then return
  odir=out

  if is_blank(back) then back=10 else back=fix(back)
  efilter='195'
  if is_number(wave) then efilter=trim(wave)
  if is_number(filter) then efilter=trim(filter)
  if is_number(bandpass) then efilter=trim(bandpass)

;-- create a SYNOP object and search backward from current UT

  synop=obj_new('eit2')
  get_utc,tend
  tstart=tend & tstart.mjd=tstart.mjd-back
  files=synop->search(tstart,tend)
  obj_destroy,synop
  chk=where(stregex(files,efilter+'_',/bool),count)
  if count eq 0 then begin
   err='No recent EIT '+efilter+' files since last '+trim(back)+' days.'
   message,err,/info
   return
  endif

  fname=files[chk[count-1]]

;-- Copy and read data into map object

  sock_copy,fname,out_dir=odir,err=err,/clobber,_extra=extra,$
            copy_file=ofile
  if err ne '' then begin
   message,err,/info
   return
  endif

  self->read,ofile,err=err,_extra=extra
  if err ne '' then begin
   message,err,/info
   return
  endif

  rm_file,ofile
  return & end

;---------------------------------------------------------------------------
;-- save EIT color table

pro eit::colors,k

if ~have_proc('eit_colors') then return
index=self->get(k,/index)
dsave=!d.name
set_plot,'Z'
tvlct,r0,g0,b0,/get
call_procedure,'eit_colors',index.wavelnth,red,green,blue,/silent
tvlct,r0,g0,b0
set_plot,dsave

self->set,k,red=red,green=green,blue=blue,/has_colors

return & end

;---------------------------------------------------------------------------
;-- check for EIT branch in !path

function eit::have_path,err=err,verbose=verbose

have_path=0b
if have_proc('read_eit') then have_path=1b else begin
 epath=local_name('$SSW/soho/eit/idl')
 if is_dir(epath) then ssw_path,/eit,/quiet
 if have_proc('read_eit') then have_path=1b else begin
  err='SOHO/EIT branch of SSW not installed. Prepping skipped.'
  if keyword_set(verbose) then message,err,/info
 endelse
endelse

return,have_path

end

;--------------------------------------------------------------------------
;-- FITS reader

pro eit::read,file,_ref_extra=extra,image_no=image_no

;-- download if URL

self->getfile,file,local_file=ofile,_extra=extra
if is_blank(ofile) then return

self->empty
have_path=self->have_path(err=err1,_extra=extra)
have_cal=self->have_cal(err=err2,_extra=extra)
nfiles=n_elements(ofile)
j=0
sel_img=(is_number(image_no))[0]
for i=0,nfiles-1 do begin
 valid=self->is_valid(ofile[i],level=level,_extra=extra)
 if ~valid then continue

 if (level eq 1) then begin
  self->fits::read,ofile[i],_extra=extra,/append
  j=self->get(/count)
  continue
 endif

;-- prep level 0 

 if have_path then read_eit,ofile[i],eindex,/nodata else $
  self->fits::read,ofile[i],_extra=extra,index=eindex,/nodata
 
;-- check for multiple images

 skip=0b
 nsub=n_elements(eindex)
 if (nsub gt 1) then begin
  if ~sel_img then image_no=self->select(eindex)
 endif else image_no=0
 nimg=n_elements(image_no)
 for k=0,nimg-1 do begin
  skip=stregex(eindex[k].object,'(partial|dark|calibration|readout|continous|lamp)',/bool,/fold)
  if skip then message,'Skipping prep for partial FOV or engineering image.',/info
  delvarx,data
  if (image_no[k] gt -1) and (image_no[k] lt nsub) then begin
   if have_path then begin
    if skip then begin
     read_eit,ofile[i],index,data,header=header
     if nsub gt 1 then begin
      data=data[*,*,image_no[k]]
      index=index[image_no[k]] 
     endif
    endif else begin
     self->prep,ofile[i],header,data,image_no=image_no[k],_extra=extra,/no_roll
     index=fitshead2struct(header)
    endelse
    index=self->partial(index,_extra=extra)
   endif else begin
    if ~have_path then xack,err1,/suppress,_extra=extra
    if ~self->have_cal() then xack,err2,/suppress,_extra=extra
    message,'Skipping prep.',/info
    self->readfits,ofile[i],data,index=index,_extra=extra
    if nsub gt 1 then begin
     index=index[image_no[k]] 
     data=data[*,*,image_no[k]]
    endif 
   endelse
   if is_struct(index) then begin
    sz=size(data)
    index.naxis1=sz[1]
    index.naxis2=sz[2]
    index=rep_tag_value(index,1,'naxis3')
    if index.sc_roll ne 0. then sc_roll_correct,index,data,_extra=extra
    if ~have_tag(index,'wavelnth') then index=add_tag(index,'0','wavelnth')
    index2map,index,data,map,/no_copy,_extra=extra,/no_roll
    map.id='SOHO EIT '+trim(index.wavelnth)
    index=rep_tag_value(index,file_basename(ofile[i]),'filename')
    self->set,j,map=map,index=index,/no_copy
    j=j+1
   endif
  endif
 endfor
endfor

count=self->get(/count)
if count gt 0 then begin
 for i=0,count-1 do begin
  self->set,i,/log_scale,grid=30,/limb
  self->colors,i
 endfor
endif else message,'No maps created.' ,/info

return & end

;--------------------------------------------------------------------------
;-- check for multiple images in level-0 files

function eit::select,index

if ~is_struct(index) then return,-1
count=n_elements(index)
if count eq 1 then return,0

output=trim(sindgen(count))+') TIME: '+trim(anytim2utc(index.date_obs,/vms))+ $
       ' WAVELENGTH: '+strpad(trim(index.wavelnth),4,/after)

list=xsel_list_multi(output,/index,cancel=cancel,$
label=index[0].filename+' - Select image numbers from list below:')
if cancel then begin
 err='Reading cancelled.'
 return,-1
endif

return,list & end

;---------------------------------------------------------------------------
;-- create filename from INDEX

function eit::get_name,index,err=err,ymd=ymd

err=''
if ~exist(index) then index=0
case 1 of
 is_string(index): nindex=fitshead2struct(index)
 is_struct(index): nindex=index
 is_number(index): begin
  if ~self->has_index(index,err=err) then return,''
  nindex=self->get(index,/index)
 end
 else: return,''
endcase

if ~have_tag(nindex,'wavelnth') then return,''

wave='00'+trim(nindex.wavelnth)
fid=time2fid(nindex.date_obs,/time,/full,/sec,err=err)
if err ne '' then return,''

ymd=time2fid(nindex.date_obs)
name='eit_'+wave+'_'+fid+'.fts'

return,name
end

;------------------------------------------------------------------------------
;-- check if file is valid

function eit::is_valid,file,err=err,level=level,verbose=verbose

verbose=keyword_set(verbose)
full_size=0b
mrd_head,file,header,err=err
level=0
valid=0b
if is_string(err) then return,valid

;-- check if valid EIT file

chk=where(stregex(header,'(INST|TEL|DET|ORIG).+EIT',/bool,/fold),count)
valid=count ne 0
if ~valid then begin
 message,'Invalid EIT file - '+file,/info
 return,valid
endif

chk=where(stregex(header,'FILENAME.+(EFZ|EFR|SEIT)',/bool,/fold),count)
if count gt 0 then level=0 else level=1

;-- check if prep'ed

if level eq 0 then begin
 chk=where(stregex(header,'Degridded',/bool,/fold),count)
 if count gt 0 then level=1
 if verbose and (level eq 1) then message,'EIT image is already prepped.',/info
endif

;-- check if full-res and full-disk

;naxis1=fxpar(header,'naxis1')
;naxis2=fxpar(header,'naxis2')
;rectangular=((1024 mod naxis1) eq 0) and ( (1024 mod naxis2) eq 0)
;if ~rectangular and (level eq 0) then begin
; message,'Cannot degrid non-rectangular image',/info
;endif

return,valid
end

;---------------------------------------------------------------------------
;-- update pointing for a partial frame image

function eit::partial,index,_ref_extra=extra

if ~is_struct(index) then return,-1
if ~have_proc('eit_partial') then return,index
return,call_function('eit_partial',index,_extra=extra)
end

;-----------------------------------------------------------------------------
;-- EIT help

pro eit::help

print,''
print,"IDL> eit=obj_new('eit')                           ;-- create EIT object
print,"IDL> files=eit->list(files,'1-may-01','2-may-01') ;-- list files
print,'IDL> eit->read,file_name                          ;-- read and prep
print,'IDL> eit->plot                                    ;-- plot
print,'IDL> map=eit->get(/map)                           ;-- extract map
print,'IDL> data=eit->get(/data)                         ;-- extract data
print,'IDL> obj_destroy,eit                              ;-- destroy
print,'or'
print,"IDL> eit=obj_new('eit')"                         ;-- create EIT object
print,'IDL> eit->latest, filter=195'                    ;-- read latest 195 image
print,'IDL> eit->plot'                                  ;-- plot
print,'IDL> obj_destroy,eit'                            ;-- destroy

return & end

;------------------------------------------------------------------------------
;-- eit data structure

pro eit__define,void

void={eit, inherits fits, inherits eit_prep}

return & end
