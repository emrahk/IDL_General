;+
; Project     : HESSI
;
; Name        : KISF__DEFINE
;
; Purpose     : Define a KISF data object for Kiepenheuer-Institute Obs.
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('kisf')
;
; History     : Written 15 March 2000, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function kisf::init,_ref_extra=extra

ret=self->site::init(_extra=extra)
                     
if not ret then return,ret
           
self->setprop,/fits,rhost='ftp.kis.uni-freiburg.de',org='month'

return,1

end

;------------------------------------------------------------------------------
;-- SET method

pro kisf::setprop,fits=fits,jpeg=jpeg,err=err,_extra=extra

;-- set file type and location to download

if keyword_set(fits) then begin
 ext='.fts' & topdir='/halpha/all_fits'
endif

if keyword_set(jpeg) then begin
 ext='.jpg' & topdir='/halpha/all_jpeg'
endif

self->site::setprop,ext=ext,topdir=topdir,_extra=extra,err=err

return & end
                                      

;-----------------------------------------------------------------------------
;-- get remote subdirectory id's based on file dates

function kisf::get_sdir
      
ids=self->site::get_sdir(/full,/no_day)

year=strmid(ids,0,4)
mon=strmid(ids,4,2)

if self.ext eq '.fts' then fids=year+'_fits/'+mon else $
 fids=year+'_jpeg/'+mon 

return,fids

end

;----------------------------------------------------------------------------
;-- driver to ftp KISF files to $SYNOP_DATA

pro kisf::synop,_extra=extra

message,'copying KISF synoptic data',/cont

;-- default settings

get_utc,utc
utc.time=0
self->setprop,tstart=utc,back=10,gzip=-1,/subdir,err=err,_extra=extra

if err ne '' then return

;-- start with FITS

self->setprop,ldir='$SYNOP_DATA/images',/fits,err=err

if err eq '' then begin
 self->copy,count=count
 if count gt 0 then synop_link,'kisf',back=10,_extra=extra
endif

;-- then do JPEGS

;self->setprop,ldir='$SYNOP_DATA/www',/jpeg
;if err eq '' then self->copy

return & end
                                         
;------------------------------------------------------------------------------
;-- KISF site structure

pro kisf__define                 

self={kisf,inherits site}

return & end

