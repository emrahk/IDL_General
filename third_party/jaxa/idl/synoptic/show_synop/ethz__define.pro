;+
; Project     : HESSI
;
; Name        : ETHZ__DEFINE
;
; Purpose     : Define a site object for Phoenix Radio Spectrogram data
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('ethz')
;
; History     : Written 18 Nov 2002, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function ethz::init,_ref_extra=extra

if ~self->specread::init(_extra=extra) then return,0

self.site=obj_new('site')
if ~obj_valid(self.site) then return,0

self.site->setprop,rhost='http://soleil.i4ds.ch',ext='fit',org='day',$
                 topdir='/solarradio/data/1998-2009_Phoenix-2',/full,$
                 delim='/',ftype='BLEN'

return,1
end

;---------------------------------------------------------------------

pro ethz::cleanup

self->specread::cleanup
obj_destroy,self.site

return & end

;------------------------------------------------------------------------
;-- store FITS info in object

pro ethz::set_fits,file,index,data,index1,data1,header=header

if ~is_struct(index) then return

frequency=data1.frequency*index1.tscal2+index1.tzero2

if (index.cdelt1 gt 0.) then $
 time=index.crval1+index.cdelt1*dindgen(index.naxis1) else $
  time=data1.time*index1.tscal1+index1.tzero1

utbase=anytim2utc(index.time_d$obs+' '+index.date_d$obs,/vms)

freq=string(float(frequency),format='(i7.0)')+' MHz'
dunit='Flux (45*log10[SFU + 10]'
self->set,xdata=time,ydata=data,dim1_ids=freq,dim1_unit='Frequency (MHz)',$
             data_unit=dunit,id='Phoenix: '+utbase,/no_copy,$
             dim1_vals=float(frequency),utbase=utbase,/secs,$
             filename=file,dim1_use=indgen(4),/positive,header=header

return & end

;-----------------------------------------------------------------------
function ethz::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
files=self.site->search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('radio/spectrograms',count) else files=''
if count eq 0 then message,'No files found.',/info
return,files
end

;------------------------------------------------------------------------------
;-- self structure

pro ethz__define                 

self={ethz,inherits specread, site:obj_new()}

return & end

