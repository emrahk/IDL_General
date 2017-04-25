;+
; Project     : HESSI
;
; Name        : RSTN__DEFINE
;
; Purpose     : Define a RSTN data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('rstn')
;
; History     : Written 15 March 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function rstn::init,_ref_extra=extra

if ~self->utplot::init(_extra=extra) then return,0
site=obj_new('site',_extra=extra)
if obj_valid(site) then self.site=site else return,0

self.site->setprop,rhost='www.ngdc.noaa.gov',topdir='STP/SOLAR_DATA/SOLAR_RADIO/RSTN',$
   ext='.apl',/rename,binary=0,org='month',/gzip

return,1

end

;-----------------------------------------------------------------------------
;-- cleanup

pro rstn::cleanup

dprint,'% RSTN::CLEANUP'

obj_destroy,self.site
self->utplot::cleanup

return
end

;------------------------------------------------------------------------------
;-- SETPROP wrapper

pro rstn::setprop,ref__extra=extra,obs=obs,err=err

if is_string(obs) then self.obs=trim(obs) else self.obs='LEAR'
if is_struct(extra) then self.site->setprop,_extra=extra

return & end

;------------------------------------------------------------------------------
;-- GETPROP wrapper

function rstn::get,_ref_extra=extra,count=count

chk=self->utplot::get(_extra=extra)
if exist(chk) then return,chk else return,self.site->getprop(_extra=extra,count=count)

end

;-----------------------------------------------------------------------------
;-- RSTN to time converter method

function rstn::parse_time,file,err=err,names=names,_extra=extra,$
               ss=ss,count=count,tai=tai,vms=vms,truncate=truncate

err='' & ss=-1 & count=0

if size(file,/tname) ne 'STRING' then begin
 err='invalid file input'
 message,err,/cont
 return,''
endif

np=n_elements(file)

regex='(.+/)?([0-9]{1,2})([a-z]+)([0-9]{1,2})\.(.+)'
s=strtrim(stregex(file,regex,/subex,/extra,/fold),2)

dprint,'% '+get_caller()+' calling rstn::parse_time'

times={year:0l,month:0l,day:0l,hour:0l,$
       minute:0l,second:0l,millisecond:0l}

times=replicate(times,np)
times.year=reform(s[4,*],np,/overwrite)
times.month=str_format(get_month(reform(s[3,*],np,/overwrite))+1,'(i2.2)')
times.day=reform(s[2,*],np,/overwrite)
times.hour=str_format(strarr(np),'(i2.2)')

;-- quick Y2K fix year

chk1=where(times.year le 50,count1)
if count1 gt 0 then times[chk1].year=times[chk1].year+2000l
chk2=where( (times.year gt 50) and (times.year lt 100) ,count2)
if count2 gt 0 then times[chk2].year=times[chk2].year+1900l


names=reform(s[0,*],np)
ss=where(trim2(names) ne '',count)

if keyword_set(tai) then return,anytim2tai(times)
if keyword_set(vms) then return,anytim2utc(times,/vms,truncate=truncate)

return,times

end

;-----------------------------------------------------------------------------
;-- FILE to IAU name converter method

function rstn::rename_files,files,count=count

names=''

times=self->parse_time(files,count=count)

if count gt 0 then begin
 names='rstn_radio_lc_'+time2fid(times,/time,/full)+'.ltc'
endif

return,names

end

;-----------------------------------------------------------------------------
;-- get remote subdirectory id's based on file dates

function rstn::get_sdir

fids=self.obs+self.site->get_sdir(/no_day)

return,fids

end

;----------------------------------------------------------------------------
;-- driver to ftp RSTN files to $SYNOP_DATA

pro rstn::synop,_extra=extra

message,'copying RSTN synoptic data',/cont

;-- default settings

get_utc,utc
utc.time=0
self.site->setprop,ldir='$SYNOP_DATA/lightcurves',/subdir,$
                 tstart=utc,err=err,back=60,_extra=extra

if err ne '' then return

self.site->copy

return & end

;----------------------------------------------------------------------------
;-- RSTN file reader

pro rstn::read,file,err=err,_extra=extra,header=header,nodata=nodata

header=''
if keyword_set(nodata) then return

rd_rstn,file,time,data,err=err,freq=freq,/tai
if err ne '' then return
utbase=anytim2utc(time[0],/vms)

self->set,xdata=time,ydata=data,/tai,$
          dim1_ids=freq,dim1_unit='Frequency (MHz)',$
          data_unit='Flux (SFU)',id='RSTN: '+utbase,/no_copy,filename=file,$
          /all,nsum=100,/dim1_enab_sum,/positive,/dim1_sel

return & end

;------------------------------------------------------------------------------
;-- RSTN site structure

pro rstn__define                 

self={rstn,obs:'', site:obj_new(), inherits utplot}

return & end


