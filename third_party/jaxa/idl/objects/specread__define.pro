;+
; Project     : HESSI
;
; Name        : specread__DEFINE
;
; Purpose     : Define a general SPECTROGRAM reader object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('specread')
;
; History     : Written 18 Nov 2002, D. Zarro (EER/GSFC)
;               Modified 8 March 2007, Zarro (ADNET)
;                - made FITS and SITE into helper objects instead of
;                  inherited objects to avoid use of ADD_METHOD
;               Modified 27 October 2009, Zarro (ADNET)
;                - removed FITS object as it was expecting to store
;                  the spectrogram as a map object.
;                - Moved SITE object to child class where it belongs
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function specread::init,_ref_extra=extra

return,self->specplot::init(_extra=extra) 

end

;-----------------------------------------------------------------------

pro specread::cleanup

self->specplot::cleanup

return & end

;----------------------------------------------------------------------------
;-- FITS read method

pro specread::read,file,data,header=header,index=index,err=err,$
                     nodata=nodata,_ref_extra=extra

err=''

if n_elements(file) gt 1 then begin
 err='Cannot read multiple files.'
 message,err,/info
 return
endif

if is_blank(file) then begin
 err='Blank file name entered.'
 message,err,/info
 return
endif
 
chk=file_search(file,count=count)
if count eq 0 then begin
 err='Could not find file.'
 message,err,/info
 return
endif

if keyword_set(nodata) then begin
 mrd_head,file,header,extension=extension,_extra=extra
 return
endif

;-- read main data

data=mrdfits(file,0,header,_extra=extra,status=status)
if status ne 0 then begin
 err='Error reading file.'
 message,err,/info
 return
endif

;-- read next extension

data1=mrdfits(file,1,header1,_extra=extra,status=status)
if status ne 0 then begin
 err='Error reading file.'
 message,err,/info
 return
endif

index=fitshead2struct(header)
index1=fitshead2struct(header1)
self->set_fits,file,index,data,index1,data1,header=header

return & end

;---------------------------------------------------------------------------
;-- placeholder method for passing FITS data to SPECTROGRAM object

pro specread::set_fits,file,index,data,index1,data1,header=header

return & end

;------------------------------------------------------------------------------
;-- define class structure

pro specread__define                 

self={specread, inherits specplot}

return & end

