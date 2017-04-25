;+
; Project     : HESSI
;
; Name        : MDI__DEFINE
;
; Purpose     : Define an MDI data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('mdi')
;
; History     : Written 17 Feb 2001, D. Zarro, EIT/GSFC
;               3-Jan-2015, Zarro (ADNET)
;               - added check for MDI SSW branch
;
; Contact     : dzarro@solar.stanford.edu
;-
;----------------------------------------------------------------------------
;-- FITS reader

pro mdi::read,file,_ref_extra=extra

self->getfile,file,local_file=ofile,_extra=extra
if is_blank(ofile) then return
have_path=self->have_path(_extra=extra)
nfiles=n_elements(ofile)
k=0
for i=0,nfiles-1 do begin
 if ~self->is_valid(ofile[i],_extra=extra) then continue
 if have_path then begin
  rd_mdi,ofile[i],index,data
  if ~is_struct(index) then continue
  index2map,index,data,map,_extra=extra,/no_copy
 endif else self->fits::read,ofile[i],index=index,data,_extra=extra
 id=''
 if have_tag(index,'obs_mode') then begin
  tag=index.obs_mode
  case 1 of 
   stregex(tag,'intensi|contin',/bool,/fold): id='Intensitygram'
   stregex(tag,'doppler',/bool,/fold): id='Dopplergram'
   stregex(tag,'magnet',/bool,/fold): id='Magnetogram'
  else: id=''
  endcase
 endif
 map.id=strtrim('SOHO MDI '+id,2)
 index=rep_tag_value(index,file_basename(ofile[i]),'filename')
 self->set,k,map=map,index=index,grid=30,/limb,/no_copy
 self->colors,k
 k=k+1
endfor

return & end

;-------------------------------------------------------------------
;-- set MDI colors

pro mdi::colors,k
dsave=!d.name
set_plot,'z'
tvlct,r0,g0,b0,/get
loadct,0
tvlct,red,green,blue,/get
tvlct,r0,g0,b0
set_plot,dsave
self->set,k,red=red,green=green,blue=blue,/has_colors
return & end

;--------------------------------------------------------------------------
;-- check if already flatfielded

function mdi::flatfielded

return,self->has_history('Flatfield applied')

end

;--------------------------------------------------------------------------
;-- check if already darklimb corrected

function mdi::limb_corrected

return,self->has_history('Dark limb corrected')

end

;--------------------------------------------------------------------------
;-- apply limb correction

pro mdi::limb_correct,err=err
err=''

if ~self->has_data() then begin
 err='No image read'
 message,err,/cont
 return
endif

;-- flatfield first and correct for possible roll

if ~self->flatfielded() then self->flatfield,err=err

if is_string(err) then return

if self->limb_corrected() then begin
 message,'Image already limb corrected.',/info
 return
endif

time=self->get(/time)
xc=self->get(/xc)
yc=self->get(/yc)
nx=self->get(/nx)
ny=self->get(/ny)
dx=self->get(/dx)
dy=self->get(/dy)
soho=self->get(/soho)
pbr=pb0r(time,soho=soho,/arcsec)
radius=2.*pbr(2)/(dx+dy)

crpix1=comp_fits_crpix(xc,dx,nx)
crpix2=comp_fits_crpix(yc,dy,ny)

map=self->get(/map,/no_copy)
darklimb_correct,map.data,temp_img,limbxyr=[crpix1,crpix2,radius],lambda=6767

;bdata=cscale(temporary(temp_img),/no_copy)
map.data=temporary(temp_img)

self->set,map=map,/no_copy

;-- update history

self->update_history,'Dark limb corrected'

return & end

;-----------------------------------------------------------------------------
;-- apply flatfield

pro mdi::flatfield,err=err,flat_file=flat_file,init=init

common mdi_flatfield,flat_map

if keyword_set(init) then delvarx,flat_map
err=''

if ~self->has_data() then begin
 err='No image read'
 message,err,/cont
 return
endif

index=self->get(/index) & id=self->get(/id)

if ~stregex(index.filename,'igram',/bool) and ~stregex(id,'intensitygram',/bool,/fold) then begin
 message,'Can only flatfield intensitygrams.',/cont
 return
endif

;-- check if already flatfielded

if self->flatfielded() then begin
 message,'Image already flatfielded.',/info
 return
endif
 
nx=self->get(/nx)
ny=self->get(/ny)
dx=self->get(/dx)
dy=self->get(/dy)

if (nx ne 1024) or (ny ne 1024) or ((dx lt 1.) and (dy le 1.)) then begin
 err='Image is not full-disk'
 message,err,/cont
 return
endif

;-- read flat field file

if ~valid_map(flat_map) then begin
 flatfield_file ='$SSWDB/soho/mdi/flatfield/mdi_flat_jan2001.fits'
 if is_string(flat_file) then flatfield_file=flat_file
 loc=loc_file(flatfield_file,count=count)
 if count eq 0 then begin
  err='Unable to locate latest MDI flatfield file.'
  message,err,/cont
  return
 endif
 flat=obj_new('fits')
 flat->read,flatfield_file
 flat_map=flat->get(/map,/no_copy)
 obj_destroy,flat
endif

;-- normalize MDI image

map=self->get(/map,/no_copy)

map.data = temporary(flat_map.data)*temporary(map.data)

self->set,map=map,/no_copy

;-- update history

self->update_history,'Flatfield applied'

return & end

;--------------------------------------------------------------------------
;-- SOI search method

function mdi::search,tstart,tend,_ref_extra=extra,type=type,$
  times=times,sizes=sizes,count=count,verbose=verbose,continuum=continuum

;-- search one day ahead and behind if looking for data nearest tstart

nearest=valid_time(tstart) and ~valid_time(tend)
if nearest then begin
 back=1. & forward=1.
endif

paths_prepend='m'
if keyword_set(continuum) then paths_prepend='c'
dstart=get_def_times(tstart,tend,dend=dend,_extra=extra,/vms,back=back,forward=forward)
parent='http://www.lmsal.com/solarsoft/soho/mdi'
files=ssw_time2filelist(dstart,dend,/flat,/month,parent=parent,$
                        paths_prepend=paths_prepend,count=count)

;-- bail if no files found

if count eq 0 then begin
 count=0 & times=-1 & sizes='' & type=''
 return,''
endif

;-- find file nearest start time if end time not entered

times=parse_time(files,/tai)
if nearest then begin
 diff=abs(anytim2tai(tstart)-times)
 ok=where(diff eq min(diff))
 times=times[ok] & files=files[ok] & count=1
endif

sizes=strarr(count)
if keyword_set(continuum) then type=replicate('optical/images',count) else $
 type=replicate('magnetic/images',count)

if count eq 1 then begin
 files=files[0] & sizes=sizes[0] & type=type[0] & times=times[0]
endif

return,files

end

;---------------------------------------------------------------------
;-- check if file is valid

function mdi::is_valid,file,err=err,verbose=verbose

verbose=keyword_set(verbose)
mrd_head,file,header,err=err
if is_string(err) then return,0b

;-- check if valid MDI file

chk=where(stregex(header,'(INST|TEL|DET|ORIG)?.+MDI',/bool,/fold),count)
valid=count ne 0 
if ~valid then begin
 message,'Invalid MDI file - '+file,/cont
 return,0b
endif

return,1b

end
;---------------------------------------------------------------------------
;-- check for MDI branch in !path

function mdi::have_path,err=err,verbose=verbose

have_path=0b
if have_proc('rd_mdi') then have_path=1b else begin
 epath=local_name('$SSW/soho/mdi/idl')
 if is_dir(epath) then ssw_path,/mdi,/quiet
 if have_proc('read_mdi') then have_path=1b else begin
  err='SOHO/MDI branch of SSW not installed. Using standard FITS reader.'
  if keyword_set(verbose) then message,err,/info
endelse
endelse

return,have_path

end


;------------------------------------------------------------------------------
;-- MDI data structure

pro mdi__define                 

self={mdi,inherits fits}

return & end

