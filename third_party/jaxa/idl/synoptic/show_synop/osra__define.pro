;+
; Project     : HESSI
;
; Name        : OSRA__DEFINE
;
; Purpose     : Define a site object for Observatory of Solar Radioastronomy 
;               of the Astrophysical Institute, Potsdam 
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('osra')
;
; History     : Written 18 Nov 2002, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function osra::init,_ref_extra=extra

if not self->specread::init(_extra=extra) then return,0

self.site->setprop,rhost='ooo.aip.de',ext='.fits',/full,delim='/',$
                 topdir='/osra/fits',ftype='osra',smode=0,org='month'

return,1
end

;----------------------------------------------------------------------------
;-- pass FITS header info into object

pro osra::set_fits,file,index,data,index1,data1,header=header

if not is_struct(index) then return

utbase=anytim2utc(index.date_obs,/vms)
time=index.crval2+index.cdelt2*(findgen(index.naxis2))

frequency=data1.frequency*index1.tscal1
freq=string(float(frequency),format='(i7.0)')+' MHz'

dunit='Flux (log10)'
self->set,xdata=time,ydata=transpose(data),dim1_ids=freq,dim1_unit='Frequency (MHz)',$
             data_unit=dunit,id='OSRA: '+utbase,/no_copy,$
             dim1_vals=float(frequency),/secs,utbase=utbase,$
             filename=file,dim1_use=indgen(4),/positive,header=header

return & end

;------------------------------------------------------------------------------
;-- self structure

pro osra__define                 

self={osra,inherits specread}

return & end

