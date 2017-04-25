;+
; Project     : HESSI
;
; Name        : OVSA_LTC_DEFINE
;
; Purpose     : Define an OVVSA lightcurve data object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('ovsa_ltc')
;
; History     : Written 22 May 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init

function ovsa_ltc::init,_ref_extra=extra

self.site=obj_new('site')
if not obj_valid(self.site) then return,0

self.fits=obj_new('fits')
if not obj_valid(self.fits) then return,0

if not self->utplot::init(_extra=extra) then return,0

self->set,/fits,rhost='www.ovsa.njit.edu',ext=''

;-- useful pointers/objects for storage

self.index_ptr=ptr_new(/all)
self.data_ptr=ptr_new(/all)
self.feed=ptr_new(/all)
self.multiple=1b
self->set,/positive,plot_type='utplot',/dim1_sel
return,1

end

;-----------------------------------------------------------------------------

pro ovsa_ltc::cleanup

obj_destroy,self.site
obj_destroy,self.fits
self->utplot::cleanup

return & end

;---------------------------------------------------------------------
;-- GET method

function ovsa_ltc::get,_ref_extra=extra,antenna=antenna,feed=feed

if keyword_set(antenna) then return,self.antenna
if keyword_set(feed) then return,*self.feed

if is_string(extra) then return,self->getprop(_extra=extra)

return,'' & end

;----------------------------------------------------------------------
;-- SET method

pro ovsa_ltc::set,_ref_extra=extra,fits=fits,gif=gif,antenna=antenna

if is_number(antenna) then begin
 feed=self->get(/feed)
 nfeed=n_elements(feed)
 self.antenna=0 > antenna < (nfeed-1)
endif

if keyword_set(fits) then begin
 ftype='*.fts' & topdir='/pub/data/fits'
endif

if keyword_set(gif) then begin
 ftype='*.gif' & topdir='/pub/data/gifs'
endif

self.site->setprop,ftype=ftype,topdir=topdir,_extra=extra

if is_string(extra) then begin
 self.fits->set,_extra=extra
 self->utplot::set,_extra=extra
endif

return & end

;-----------------------------------------------------------------------------
;-- get remote subdirectory id's based on file dates

function ovsa_ltc::get_sdir

fids=self.site->get_sdir(/full,/no_day)

return,fids

end

;----------------------------------------------------------------------------
;-- driver to ftp files to $SYNOP_DATA

pro ovsa_ltc::synop,_extra=extra

message,'copying OVSA synoptic data',/cont

;-- default settings

get_utc,utc
utc.time=0
self->set,tstart=utc,back=30,/subdir,err=err,_extra=extra
if err ne '' then return

self->set,ldir='$SYNOP_DATA/lightcurves',/fits,/gzip,err=err

if err eq '' then self->copy

return & end

;----------------------------------------------------------------------------
;-- ovsa_ltc FITS reader

pro ovsa_ltc::read,file,data,header=header,index=index,err=err,_ref_extra=extra,$
                    nodata=nodata

err=''
if n_elements(file) gt 1 then begin
 err='Cannot read multiple files'
 message,err,/cont
 return
endif

;-- read file

self.fits->read,file,data,header=header,extension=1,index=index,$
                    nodata=nodata 


if keyword_set(nodata) then return

no_copy=n_params() lt 2

dir=file_break(file,/path)

self->empty
if not is_struct(data) then return
if no_copy then *self.data_ptr=temporary(data) else $
 *self.data_ptr=data

if not is_struct(index) then begin
 err='Problem reading file.'
 message,err,/cont
 return
endif

*self.index_ptr=index
*self.header_ptr=header
*self.feed=(*self.data_ptr).FEED_NUMBER_AND_POLARIZATION
freq=(*self.data_ptr).freq_ghz
dim1_ids=trim2(str_format(freq,'(f5.1)')+' GHz ')
dim1_vals=float(freq)
self->set,dim1_ids=dim1_ids,dim1_vals=dim1_vals,dim1_use=indgen(4)
self->set_file,file

return & end

;---------------------------------------------------------------------------

pro ovsa_ltc::plot,_ref_extra=extra,select=select

if not self->has_data() then begin
 message,'No data in object',/cont
 return
endif

self->options,_extra=extra,cancel=cancel,title='File: '+self->get_file(),$
               skip=1-keyword_set(select)
if cancel then return

self->utplot::plot,_extra=extra

return & end

;----------------------------------------------------------------------------
;-- retrieve current filename

function ovsa_ltc::get_file

filename=self->get(/filename)

pos=strpos(filename,'-')
if pos eq -1 then return,filename

return,strmid(filename,pos+1,strlen(filename))

end

;----------------------------------------------------------------------------
;-- set new filename based on antenna choice

pro ovsa_ltc::set_file,filename

if is_blank(filename) then filename=self->get_file()
if is_blank(filename) then return
antenna=fix(self->get(/antenna))
self->set,filename=trim(antenna)+'-'+filename
return

end

;-----------------------------------------------------------------------------
;-- select antenna/polarization option

pro ovsa_ltc::options,group=group,title=title,cancel=cancel,$
              skip_selection=skip_selection

cancel=0b
if not self->has_data() then return

if (1-keyword_set(skip_selection)) then begin

;-- get new selections

 self->select,group=group,title=title
 cancel=self->get(/cancel)
 if cancel then return
endif 

antenna=self->get(/antenna)
dim1_ids=self->get(/dim1_ids)
dim1_use=self->get(/dim1_use)
feed=self->get(/feed)
id='OVSA '+feed[antenna]

data=transpose((*self.data_ptr).channel_freq_time[antenna,*,*])
time=(*self.data_ptr).time_msec/1000.

utbase=(*self.index_ptr).date_obs
utbase=anytim2utc(utbase,/vms,/date_only)

;-- update UTPLOT object with new selection

dim1_unit='frequency (GHz)'
data_unit = 'Flux (SFU)'

self->set,xdata=time,ydata=data,/secs,utbase=utbase,/no_copy,$
          dim1_use=dim1_use,dim1_ids=dim1_ids,dim1_unit=dim1_unit,$
          data_unit=data_unit,/dim1_enab_sum,id=id

self->set_file

return & end

;--------------------------------------------------------------------------
;-- check if antenna has data

function ovsa_ltc::check_antenna,antenna,err=err

err=''
if not is_number(antenna) then antenna=-1
feed=self->get(/feed)
nfeed=n_elements(feed)
if (antenna gt nfeed-1) or (antenna lt 0) then begin
 err='Antenna value out of range (0 - '+trim(nfeed-1)+')'
 message,err,/cont
 return,0b
endif

data=(*self.data_ptr).channel_freq_time[antenna,*,*]
chk=where( finite(data,/inf) or finite(data,/nan),count)
ndata=n_elements(data)
if count gt 0 then data[chk]=0
chk=where(data eq 0,count)
if count eq ndata then begin
 err='Warning. Zero data for '+feed[antenna]+'.'
 message,err,/cont
 return,0b
endif

(*self.data_ptr).channel_freq_time[antenna,*,*]=temporary(data)

return,1b
end

;---------------------------------------------------------------------------
;-- check if object has data

function ovsa_ltc::has_data

if not ptr_valid(self.data_ptr) then return,0b
return,exist(*self.data_ptr) 

end

;-----------------------------------------------------------------------

pro ovsa_ltc::ant,event

widget_control,event.top,get_uvalue=self
antenna=event.index
self->set,antenna = antenna

return
end

;-----------------------------------------------------------------------

pro ovsa_ltc::accept,event

widget_control,event.top,get_uvalue=self

wtext=self->get(/wtext)

if self->get(/dim1_sel) then begin
 wchan=self->get(/wchan)
 s=widget_info(wchan,/list_select)
 if s[0] eq -1 then begin
  widget_control,wtext,set_value='Select at least one channel.',/append
  return
 endif else self->set,dim1_use=s
endif

antenna=self->get(/antenna)

if not self->check_antenna(antenna,err=err) then begin
 widget_control,wtext,set_value=err,/append
 return
endif

self.cancel=0b
xkill,event.top 

return
end

;----------------------------------------------------------------------------
;-- antennae/polarization options

pro ovsa_ltc::select,group=group,title=title

feed=self->get(/feed)
file=self->get_file()
bfont=self->get(/bfont)
lfont=self->get(/lfont)

base = widget_mbase (group=group,/column, $
                      title='OVSA Antennae/Polarization Options', $
                      /modal)

if is_string(title) then begin
 wbase2=widget_base(base,/column,/frame)
 label=widget_label(wbase2,value=' ',font=lfont)
 label=widget_label(wbase2,value=title,font=lfont)
 label=widget_label(wbase2,value='  ',font=lfont)
endif

wbase=widget_base(base,/column,/frame)

;-- antenna choices

temp=widget_base(wbase,/row)
label=widget_label(temp,value='Select Antenna and Polarization:',font=lfont)

want = widget_droplist (temp,font=bfont,$
                          value=' ' + feed + ' ',uvalue='ant')
widget_control,want,set_droplist_select=self->get(/antenna)

;-- channel choices

if self->get(/dim1_sel) then self->wchan,wbase

;-- message box

cbase=widget_base(wbase,/row,/align_center)
self.wtext=widget_text(cbase,ysize=4,xsize=50,font=lfont)

tbase=widget_base(base,/row,/align_center)
waccept = widget_button(tbase, value='Accept',uvalue='accept',font=bfont)
wcancel = widget_button(tbase, value='Cancel',uvalue='cancel',font=bfont)

xrealize,base,group=group,/center,/screen

widget_control,base,set_uvalue=self
xmanager,'self->select',base,event='obj_event'

return
end

;------------------------------------------------------------------------------
;-- ovsa_ltc site structure

pro ovsa_ltc__define

self={ovsa_ltc,data_ptr:ptr_new(),index_ptr:ptr_new(),fits:obj_new(), $
      antenna:0,feed:ptr_new(), site:obj_new(),multiple:0b, inherits utplot}

return & end

