;+
; Project     : HESSI
;
; Name        : HFITS__DEFINE
;
; Purpose     : Define a HFITS class that reads remote FITS files via HTTP
;
; Explanation : 
;               
;               f='~zarro/synop/mdi_mag_fd_20001126_0136.fits ; file to read
;               a=obj_new('hfits')                ; create a FITS HTTP object
;               a->open,'orpheus.nascom.nasa.gov' ; open a URL socket 
;               a->hread,f,header                 ; read header
;               print,header                      ; print header
;               a->read,file,data             ; read into data array
;               a->close                          ; close socket
;
;               This works too:
;
; a->read,'orpheus.nascom.nasa.gov/~zarro/synop/mdi_mag_fd_20001126_0136.fits'
;
; Category    : objects sockets fits
;               
; Syntax      : IDL> a=obj_new('hfits')
;
; History     : Written 11 Oct 2001, D. Zarro (EITI/GSFC)
;               Modified 10 Oct 2005, Zarro (L-3Com/GSFC) 
;                 - added _ref_extra
;               Modified 11 Nov 2006, Zarro (ADNET/GSFC)
;                 - fixed bug parsing URL's without http prefix
;               Modified 30 Sept 2009, Zarro (ADNET/GSFC)
;                 - added capability to read multiple extensions
;               Modified 27 March 2011, Zarro (ADNET)
;                 - added /swap_if_little_endian per Landsman
;                   suggestion
;               1-Mar-2013, Zarro (ADNET)
;                 - updated with read methods from modified HTTP
;                   object
;               8-July-2013, Zarro (ADNET)
;                 - renamed ::READFITS to ::READ 
;
; Contact     : dzarro@solar.stanford.edu
;-

;-- init HTTP socket

function hfits::init,_ref_extra=extra

chk=self->fits::init(_extra=extra)
if ~chk then return,chk
dprint,'% HFITS::INIT'

return,self->http::init(_extra=extra,/swap_if_little_endian)

end

;--------------------------------------------------------------------------

pro hfits::cleanup

self->http::cleanup
self->fits::cleanup

return & end

;---------------------------------------------------------------------------
;--- read FITS header from remote URL

pro hfits::hread,url,header,count=count,_ref_extra=extra

count=0 & header=''
self->readfits_url,url,data,header=header,_extra=extra,/nodata

if is_blank(header) then return
count=n_elements(header)
if (n_params() ne 2) then hprint,header

return & end


;---------------------------------------------------------------------------
;--- read FITS data from remote URL

pro hfits::readfits_url,url,data,header=header,index=index,err=err,$
                    nodata=nodata,_ref_extra=extra
err=''
header=''
delvarx,data

;-- send a GET request

self->send_request,url,_extra=extra,err=err
if is_string(err) then begin
 self->close
 return
endif

self->read_response,response,_extra=extra,err=err
if is_string(err) then begin
 self->close
 return
endif

;-- examine the response header

sock_content,response,code=code,_extra=extra
scode=strmid(trim(code),0,1)
if scode ne 2 then begin
 err='File not found.' & message,err,/info & self->close
 return
endif

nodata=keyword_set(nodata)

if nodata then self->read_header,header,err=err,_extra=extra else $
 self->read_data,data,header=header,err=err,_extra=extra

self->close

if is_string(header) and arg_present(index) then index=fitshead2struct(header)

return & end

;---------------------------------------------------------------------------
;-- read FITS header from server

pro hfits::read_header,header,err=err,_ref_extra=extra,extension=extension

err=''
header=''

status=0 & mstatus=0
if ~is_number(extension) then extension=0
if extension gt 0 then mstatus=fxmove(self.unit,extension)
if mstatus eq 0 then mrd_hread,self.unit,header,status,_extra=extra

if is_blank(header) or (status ne 0) then begin
 err='Failed to read FITS header.'
 message,err,/info
endif

return & end

;---------------------------------------------------------------------------
;-- read FITS data from server 

pro hfits::read_data,data,header=header,extension=extension,err=err,_ref_extra=extra,$
           verbose=verbose

forward_function mrdfits

err=''
status=0
if ~is_number(extension) then extension=0
verbose=keyword_set(verbose)
if verbose then t1=systime(/seconds)
data=mrdfits(self.unit,extension,header,status=status,_extra=extra,/fscale)
if verbose then t2=systime(/seconds)
if status ne 0 then begin
 err='Error reading file.'
 message,err,/info
 return
endif

if verbose then begin
 tdiff=anytim2tai(t2)-anytim2tai(t1)
 message,'Data read in '+trim(tdiff)+' seconds',/info
endif
return & end

;--------------------------------------------------------------------------
;-- FITS reader

pro hfits::read,file,data,_ref_extra=extra,err=err

err=''

if is_blank(file) then begin
 err='Blank URL filename entered.'
 message,err,/info
 return
endif

if n_elements(file) ne 1 then begin
 err='Cannot remotely read multiple files.'
 message,err,/info
 return
endif

if stregex(file,'ftp://',/bool) then begin
 err='Cannot socket read from FTP server.'
 message,err,/info
 return
endif

if is_compressed(file) then begin
 err='Cannot socket read compressed file.'
 message,err,/info
 return
endif

nodata=n_params() eq 1
self->url_parse,file,server,hfile
url_entered=is_string(server) and is_string(hfile)
if url_entered then begin
 self->readfits_url,file,data,_extra=extra,err=err,nodata=nodata
endif else begin
 self->fits::read,file,data,_extra=extra,err=err,nodata=nodata
endelse

return & end

;----------------------------------------------------------------------------

pro hfits__define                 

struct={hfits, inherits http, inherits fits}

return & end

