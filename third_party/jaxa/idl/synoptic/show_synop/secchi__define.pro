;+
; Project     : STEREO
;
; Name        : SECCHI__DEFINE
;
; Purpose     : Define a SECCHI data/map object
;
; Category    : Objects
;
; Syntax      : IDL> a=obj_new('secchi')
;
; Examples    : IDL> a->read,'20070501_000400_n4euA.fts' ;-- read FITS file
;               IDL> a->plot                             ;-- plot image
;               IDL> map=a->getmap()                     ;-- access map
;               IDL> data=a->getdata()                   ;-- access data
;                       
;               Searching via VSO:                                     
;               IDL> files=a->search('1-may-07','02:00 1-may-07')
;               IDL> print,files[0]
;               http://stereo-ssc.nascom.nasa.gov/data/ins_data/secchi/L0/a/img/euvi/20070501/20070501_000400_n4euA.fts
;               IDL> a->read,files[0],/verbose
;
; History     : Written 13 May 2007, D. Zarro (ADNET)
;               Modified 31-Oct-2007 William Thompson (ADNET)
;                - modified for COR1/COR2
;               Modified 26 March 2009 - Zarro (ADNET)
;                - renamed index2map method to mk_map
;               13-Oct-2009, Zarro (ADNET)
;                - renamed mk_map to mk_secchi_map
;               25-May-2010, Zarro (ADNET)
;                - fixed bug causing roll_center to be offset relative
;                  to Sun center.
;               1-July-2010, Zarro (ADNET)
;                - fixed another bug with the roll_center offset. It
;                  never ends.
;               21-Nov-2011, Zarro (ADNET)
;                - added support for RICE compressed files.
;               20-Dec-2011, Zarro (ADNET)
;                - register SPICE DLM's during INIT
;               11-April-2012, Zarro (ADNET)
;                - fixed potential bug with RICE-compressed files on 
;                  Windows systems.
;               21-August-2012, Zarro (ADNET)
;                - switched to using WCS software for more accurate
;                  map coordinates.
;               5-July-2013, Zarro (ADNET)
;                - intercepted OUTSIZE keyword  
;               24-May-2014, Zarro (ADNET)
;                - added /APPEND when reading level 1 files
;               11-June-2014, Zarro (ADNET)
;                - added /KEEP_LIMB when resizing or rolling image
;               25-July-2015, Zarro (ADNET)
;                - removed unnecessary use of Z-buffer
;
; Contact     : dzarro@solar.stanford.edu
;-

function secchi::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

self->register_dlm

return,1 & end

;------------------------------------------------------------------------
;-- setup SECCHI environment variables

pro secchi::setenv,_extra=extra

if is_string(chklog('SECCHI_CAL')) then return
file_env=local_name('$SSW/stereo/secchi/setup/setup.secchi_env')
file_setenv,file_env,_extra=extra
return & end

;-----------------------------------------------------------------------------
;-- check for SECCHI branch in !path

function secchi::have_path,err=err,verbose=verbose

err=''
if ~have_proc('sccreadfits') then begin
 epath=local_name('$SSW/stereo/secchi/idl')
 if is_dir(epath) then ssw_path,/secchi,/quiet
 if ~have_proc('sccreadfits') then begin
  err='STEREO/SECCHI branch of SSW not installed.'
  if keyword_set(verbose) then mprint,err
  return,0b
 endif
endif

return,1b
end

;----------------------------------------------------------
;-- register DLM to read SPICE files

pro secchi::register_dlm,status

common register_dlm,registered

status=0b
if exist(registered) then begin
 status=registered
 return
endif

if have_proc('register_stereo_spice_dlm') then begin
 register_stereo_spice_dlm
 registered=1b
 status=registered
endif

return

end

;---------------------------------------------------------------------

function secchi::have_cal,err=err,verbose=verbose

;-- ensure that calibration directories are properly defined

err=''
if ~is_dir('$SSW_SECCHI/calibration') then begin
 err='$SSW_SECCHI/calibration directory not found.'
 if keyword_set(verbose) then mprint,err
 return,0b
endif

SSW_SECCHI=local_name('$SSW/stereo/secchi')
mklog,'SSW_SECCHI',SSW_SECCHI
SECCHI_CAL=local_name('$SSW_SECCHI/calibration')
mklog,'SECCHI_CAL',SECCHI_CAL

return,1b & end

;--------------------------------------------------------------------------
;-- FITS reader

pro secchi::read,file,data,_extra=extra,err=err,verbose=verbose

forward_function discri_pobj,def_lasco_hdr
err=''

;-- download files if not present

self->getfile,file,local_file=cfile,err=err,_extra=extra
if is_blank(cfile) or is_string(err) then return

self->empty
have_cal=self->have_cal(err=err1)
have_path=self->have_path(err=err2)

j=0
nfiles=n_elements(cfile) 
for i=0,nfiles-1 do begin

 valid=self->is_valid(cfile[i],level=level,_extra=extra,err=err)

 if ~valid then continue
 
;-- intercept outsize keyword

 if is_struct(extra) then begin
  if have_tag(extra,'out',pos,/start) then begin
   var=extra.(pos)
   chk=where(valid_num(var),count)
   if count eq n_elements(var) then begin
    outsize=var
    if n_elements(outsize) eq 1 then outsize=[outsize,outsize]
    extra=rem_tag(extra,pos)
    if ~is_struct(extra) then delvarx,extra
   endif
  endif
 endif

 if have_cal and have_path and (level eq 0) then begin
  secchi_prep,cfile[i],index,data,_extra=extra,/rectify,silent=~keyword_set(verbose)
 endif else begin
  if (level eq 0) then begin
   if ~have_cal then xack,err1,/suppress
   if ~have_path then xack,err2,/suppress
   mprint,'Skipping prepping.'
  endif
  self->fits::read,cfile[i],_extra=extra,/append,err=err
  if is_blank(err) then j=j+self->get(/count)
  continue
 endelse

 ;-- insert data into maps

 index=rep_tag_value(index,file_basename(cfile[i]),'filename')
 self->mk_secchi_map,j,index,data,err=err,_extra=extra,outsize=outsize
 if is_string(err) then continue
 j=j+1
endfor

count=self->get(/count)
if count gt 0 then begin
 for i=0,count-1 do begin
  id=self->get(i,/id)
  if stregex(id,'EUVI',/bool) then self->set,i,/log_scale,grid=30,/limb
  self->colors,i
 endfor
endif else mprint,'No maps created.'

return & end

;---------------------------------------------------------------------
;-- store INDEX and DATA into MAP objects

pro secchi::mk_secchi_map,i,index,data,err=err,_extra=extra,$
           roll_correct=roll_correct,earth_view=earth_view,outsize=outsize


err=''
if ~is_number(i) then i=0

;-- check inputs

if ~is_struct(index) or (n_elements(index) ne 1) then begin
 err='Input index is not a valid structure.'
 mprint,err
 return
endif

ndim=size(data,/n_dim)
if (ndim ne 2) then begin
 err='Input image is not a 2-D array.'
 mprint,err
 return
endif

;-- add STEREO-specific properties

id=index.OBSRVTRY+' '+index.INSTRUME+' '+index.DETECTOR+' '+trim(index.WAVELNTH)

wcs=fitshead2wcs(index)
wcs2map,data,wcs,map,id=id,/no_copy

earth_view=keyword_set(earth_view)
roll_correct=keyword_set(roll_correct)
resize=exist(outsize)
case 1 of
 earth_view: self->earth_view,index,map,_extra=extra,outsize=outsize
 roll_correct: self->roll_correct,index,map,_extra=extra,outsize=outsize
 resize: begin
  mprint,'Resizing to ['+trim(outsize[0])+','+trim(outsize[1])+']...'
  map=drot_map(map,outsize=outsize,/keep_limb)
  self->update_pc,index,map
 end
 else: do_nothing=1
endcase

self->set,i,map=map,/no_copy
self->set,i,index=index

return & end

;-----------------------------------------------------------------------
pro secchi::roll_correct,index,map,_extra=extra

if ~valid_map(map) or ~is_struct(index) then return
if (nint(index.crota) mod 360.) eq 0 then begin
 mprint,'Map already roll-corrected.'
 return
endif

;-- roll correct

mprint,'Correcting for spacecraft roll...'

map=drot_map(map,roll=0.,_extra=extra,/same_center,/keep_limb)
index.crota=0.
self->update_pc,index,map

return & end

;-------------------------------------------------------------------------
pro secchi::earth_view,index,map,_extra=extra

if ~valid_map(map) or ~is_struct(index) then return

mprint,'Correcting to Earth-view...'
map=map2earth(map,/remap,_extra=extra)
index.hglt_obs=map.b0
index.hgln_obs=map.l0
index.rsun=map.rsun
index.crota=0.
self->update_pc,index,map

return & end

;--------------------------------------------------------------------------
pro secchi::update_pc,index,map

index.pc1_1=1 & index.pc1_2=0 & index.pc2_1=0 & index.pc2_2=1
nx=index.naxis1 & ny=index.naxis2
index.crpix1=comp_fits_crpix(map.xc,map.dx,nx,index.crval1)                                            
index.crpix2=comp_fits_crpix(map.yc,map.dy,ny,index.crval2)

return & end

;--------------------------------------------------------------------------
;-- VSO search function

function secchi::search,tstart,tend,_ref_extra=extra,$
                 euvi=euvi,cor1=cor1,cor2=cor2,det=det,type=type

case 1 of
 keyword_set(euvi): det='euvi'
 keyword_set(cor1): det='cor1'
 keyword_set(cor2): det='cor2'
 else: do_nothing=''
endcase

f=vso_files(tstart,tend,inst='secchi',_extra=extra,det=det,wmin=wmin,window=3600.)
if arg_present(type) and exist(wmin) then type=string(wmin,'(I5.0)')+' A'
return,f

end

;------------------------------------------------------------------------------
;-- save SECCHI color table

pro secchi::colors,k

if ~have_proc('secchi_colors') then return
index=self->get(k,/index)
if ~is_struct(index) then return
dsave=!d.name
set_plot,'Z'
tvlct,rold,gold,bold,/get
secchi_colors,index.detector,index.wavelnth,red,green,blue
self->set,k,red=red,green=green,blue=blue,/has_colors
tvlct,rold,gold,bold
set_plot,dsave

return & end

;------------------------------------------------------------------------------
;-- check if valid SECCHI file

function secchi::is_valid,file,err=err,detector=detector,$
                  level=level,_extra=extra,euvi=euvi,cor1=cor1,cor2=cor2

level=0 
detector='' & instrument=''
mrd_head,file,header,err=err
if is_string(err) then return,0b

s=fitshead2struct(header)
if have_tag(s,'dete',/start,index) then detector=strup(s.(index))
if have_tag(s,'inst',/start,index) then instrument=strup(s.(index))

if have_tag(s,'history') then begin
 chk=where(stregex(s.history,'(Applied Flat Field)|(Applied calibration factor)',/bool,/fold),count)
 level=count gt 0
endif

if keyword_set(euvi) and detector ne 'EUVI' then begin
 err=file+' - header is not EUVI.' & mprint,err & return,0b
endif

if keyword_set(cor1) and detector ne 'COR1' then begin
 err=file+' - header is not COR1.' & mprint,err & return,0b
endif

if keyword_set(cor2) and detector ne 'COR2' then begin
 err=file+' - header is not COR2.' & mprint,err & return,0
endif

valid=instrument eq 'SECCHI'

if ~valid then begin
 err=file+' - header is not STEREO/SECCHI.'
 mprint,err
endif

return,instrument eq 'SECCHI'
end

;------------------------------------------------------------------------
;-- SECCHI data structure

pro secchi__define,void                 

void={secchi, inherits fits, inherits prep}

return & end
