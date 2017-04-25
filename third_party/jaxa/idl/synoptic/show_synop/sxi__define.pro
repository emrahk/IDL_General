; Project     : SXI
;
; Name        : SXI__DEFINE
;
; Purpose     : Define an SXI data object
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : IDL> c=obj_new('sxi')
;
; History     : Written 16 Feb 2003, D. Zarro, (EER/GSFC)
;               Modified 22 Dec 2004, Zarro (L-3Com/GSFC) - added /level2
;               Modified 22 Apr 2005, Zarro (L-3Com/GSFC) - improved NGDC checking
;               Modified 7  Aug 2005, Zarro (L-3Com/GSFC) 
;               - fixed use of level2 reader
;               Modified 3 Jan 2006, Zarro (L-3Com/GSFC)
;               - renamed LIST procedure to SEARCH
;               Modified 3 Feb 2006, Zarro (L-3Com/GSFC)
;               - fixed bug in searching over multiple days
;               Modified 28 July 2006, Zarro (ADNET/GSFC)
;               - incorporated GOES13 and future satellites
;               1-Jan-2015, Zarro (ADNET)
;               - updated for GOES 15
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function sxi::init,_ref_extra=extra

if ~self->site::init(_extra=extra) then return,0
if ~self->fits::init(_extra=extra) then return,0

return,1

end

;----------------------------------------------------------------------------

pro sxi::cleanup

self->site::cleanup
self->fits::cleanup

return & end

;----------------------------------------------------------------------------
; SXI front-end FITS reader

pro sxi::read,file,data,_ref_extra=extra,err=err

err=''
self->fits::read,file,data,err=err,_extra=extra,extension=0
if is_string(err) then return
self->set,/log_scale,grid=30,/limb
return
end

;----------------------------------------------------------------------------
; SXI low-level FITS reader (not currently used)

pro sxi::mreadfits,file,data,header=header,index=index,_ref_extra=extra,$
                   nodata=nodata,err=err,dscale=dscale

forward_function sxig12_read,sxig12_read_one

installed=self->hget(/installed)

dscale=keyword_set(dscale)
noscale=1b-dscale

;-- if SXI branch not installed, use standard FITS reader

err=''

if keyword_set(nodata) then begin
 mrd_head,file,header,err=err,_extra=extra
 if err eq '' then index=fitshead2struct(header)
 return
endif

level1=stregex(file,'_B',/bool) eq 1b
level2=stregex(file,'_C',/bool) eq 1b

if (not installed) then begin
 self->fits::mreadfits,file,data,header=header,index=index,$
             _extra=extra,err=err,dscale=dscale
 return
endif

if level1 then data=sxig12_read_one(file,header,noscale=noscale,_extra=extra) else $
 data=sxig12_read(file,header,_extra=extra,noscale=noscale)
if is_string(header) then index=fitshead2struct(header)

return & end

;-----------------------------------------------------------------------
function sxi::search,tstart,tend,_ref_extra=extra,count=count,type=type

type=''
count=0
dstart=get_def_times(tstart,tend,dend=dend,/ext)

ystart=dstart.year
yend=dend.year
goes12=(ystart ge 2003) && (ystart le 2007) && $
        (yend ge 2003) && (yend le 2007)
goes15=(ystart ge 2010) && (yend ge 2010)

if goes12 then sat=12
if goes15 then sat=15
if is_number(sat) then begin
 rhost=sxi_server(path=path,sat=sat)
 self->setprop,rhost=rhost,ext='FTS',org='day',$
                 topdir=path,/full,$
                 delim='/',ftype='SXI'

 files=self->site::search(tstart,tend,_extra=extra,count=count)
endif
if count gt 0 then type=replicate('sxr/images',count) else files=''
if count eq 0 then message,'No SXI files found.',/info

return,files
end

;------------------------------------------------------------------------------

pro sxi__define,void                 

void={sxi, inherits fits, inherits site}

return & end



