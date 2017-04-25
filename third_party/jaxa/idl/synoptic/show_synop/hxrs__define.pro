;+
; Project     : HESSI
;
; Name        : HXRS__DEFINE
;
; Purpose     : Define a HXRS data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('hxrs')
;
; History     : Written 17 Jul 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function hxrs::init,_ref_extra=extra

if ~self->utplot::init(_extra=extra) then return,0
site=obj_new('site',_extra=extra)
if ~obj_valid(site) then return,0
self.site=site
self.site->setprop,rhost='solar.sec.noaa.gov',topdir='pub/hxrs',org='year',smode=0
self->set_format

return,1

end

;----------------------------------------------------------------------
pro hxrs::setprop,_ref_extra=extra

self.site->setprop,_extra=extra

return & end

;----------------------------------------------------------------------
function hxrs::get,_ref_extra=extra,status=status

chk=self.site->getprop(_extra=extra,status=status)
if status then return,chk
return,self->utplot::get(_extra=extra,status=status)

end

;--------------------------------------------------------------------------
;-- FTP search method

function hxrs::search,tstart,tend,_ref_extra=extra

return,self.site->flist(tstart,tend,_extra=extra)

end

;-----------------------------------------------------------------------------
;-- cleanup

pro hxrs::cleanup

dprint,'% HXRS::CLEANUP'

self->utplot::cleanup
obj_destroy,self.site

return
end

;-----------------------------------------------------------------------------
;-- get remote subdirectory id's based on file dates

;function hxrs::get_sdir

;return,''

;end

;-----------------------------------------------------------------------------
;-- HXRS reader

pro hxrs::read,file,err=err,header=header,nodata=nodata

err='' & header=''

;-- check for HXRS FITS reader

if ~have_proc('read_hxrs_4_spex') then begin
 if is_dir('$SSW/hxrs/idl',out=out) then add_path,out,/expand,/append else begin
  err='HXRS IDL directories need to be included in !path'
  message,err,/cont
  return
 endelse
endif

 
;-- allow reading compressed files

compressed=is_compressed(file,type)
if (not compressed) then begin
 if not valid_fits(file) then begin
  err='Invalid FITS file'
  message,err,/cont
  return
 endif
endif

;-- use MRDFITS to decompress on the fly if file is compressed and version > 5.3

man_decompress=idl_release(upper=5.3) or $
               ((type eq 'Z') and (os_family(/lower) eq 'windows'))

if man_decompress then dfile=find_compressed(file,err=err) else dfile=file
if err ne '' then return

dform=self->get(/format)
dprint,'% Format: ',dform

;-- header only

if keyword_set(nodata) then begin
 mrd_head,dfile,header,err=err
 return
endif

read_hxrs_4_spex,file=dfile,flux=flux,eflux=eflux,ut=ut,dformat=dform,$
                 title=title,edges=edges,units=units,area=area,ltime=ltime

tbase=(ut[0,0]+ut[1,0])/2.
utbase=anytim(tbase,/utc_int)

bands=str_format(edges[0,*],'(f7.2)')+' - '+trim(str_format(edges[1,*],'(f7.2)'))
bands=bands+' Kev '

;-- copy data to UTPLOT object

self->set,xdata=ut-tbase,ydata=transpose(flux),dim1_ids=bands,$
      dim1_unit='Energy (KeV)',$
      data_unit='Flux ('+units+')',id=title,/no_copy,filename=dfile,$
      /ylog,/all,/dim1_enab_sum,nsum=100,/positive,/dim1_sel

return & end

;----------------------------------------------------------------------------
;-- driver to mirror HXRS files from NOAA to $SYNOP_DATA

pro hxrs::synop,_extra=extra

message,'copying HXRS synoptic data',/cont

;-- default settings

get_utc,utc
utc.time=0
self.site->setprop,tstart=utc,back=30,/subdir,err=err,_extra=extra,/gzip
if err ne '' then return

self->setprop,ldir='$SYNOP_DATA/lightcurves',err=err

if err eq '' then self->copy

return & end

;---------------------------------------------------------------------------

pro hxrs::set_format,format

;-- default to SHIELD'ed data

if is_string(format) then begin
 dform=strupcase(trim(format))
 valid_format=['SHIELD','NOSHIELD','TOTAL']
 chk=where(dform eq valid_format,count)
 if count eq 0 then self.format='SHIELD' else self.format=valid_format[chk[0]]
endif else self.format='SHIELD'

return & end

;---------------------------------------------------------------------------

pro hxrs__define                 

self={hxrs,format:'',site:obj_new(), inherits utplot}

return & end


