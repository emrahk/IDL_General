;+
; Project     : HESSI
;
; Name        : SYNOP_SPEX__DEFINE
;
; Purpose     : Define a synop_spex data object.  Allows any data type that can be read
;               in ospex, to be plotted in show_synop.  In show_synop, spex data types are
;               associated with this object.  To plot, the get_plot_obj method is called to return
;               a xyplot or utplot object, which can be passed to plotman or plotted directly.
;
; Category    : Ancillary Synoptic Objects
;
; Syntax      : IDL> c=obj_new('synop_spex')
;
; History     : Written 24-Mar-2009, Kim Tolbert, Dominic Zarro
;               Modified 26-April-2009 (Zarro/ADNET) 
;                - added check for SPEX package in path
;               Modified 1-May-2009 (Zarro/ADNET)
;                - changed SPEX from being inherited to being a helper
;                  object. This allows SYNOP_SPEX to compile if SPEX
;                  package is not installed.
;               Modified 8-February-2010, Zarro (ADNET)
;                - replaced SOXS_FILES with call to SITE object
;               Modified 12-Feb-2010, Kim
;                - default plot units are now 'rate'
;               Modified 14-Feb-2010, Zarro (ADNET)
;                - added error checks if SPEX object undefined.
;               Modified 19-Feb-2010, Zarro (ADNET)
;                - moved SPEX init to ::READ for faster startup
;-
;-----------------------------------------------------------------------------

pro synop_spex::cleanup
obj_destroy,self.spex
self->site::cleanup
return
end

;-----------------------------------------------------------------------------
;-- check for SPEX path

function synop_spex::have_spex_xray

chk1=have_proc('spex__define')
chk2=have_proc('chianti_kev')
if chk1 and chk2 then return,1b
path1=local_name('$SSW/packages/spex/idl')
if ~is_dir(path1) then return,0b
add_path,path1,/expand,/quiet
path2=local_name('$SSW/packages/xray/idl')
if ~is_dir(path2) then return,0b
add_path,path2,/expand,/quiet

chk1=have_proc('spex__define')
chk2=have_proc('chianti_kev')
return,chk1 and chk2
end

;------------------------------------------------------------------------------

pro synop_spex::read,file,_ref_extra=extra,err=err

if ~obj_valid(self.spex) then begin
 if ~self->have_spex_xray() then begin
  err='SPEX READ method not available. Check if SPEX package is installed.'
  message,err,/info
  return
 endif
 self.spex=obj_new('spex',_extra=extra,/no_gui)
endif

;-- download if URL

if is_blank(file) then begin
 pr_syntax,'object_name->read,filename'
 return
endif
file=strtrim(file,2)
if is_url(file) then begin
 out_dir=curdir()
 if ~write_dir(out_dir,/quiet) then out_dir=get_temp_dir()
 sock_copy,file,out_dir=out_dir,local_file=ofile,_extra=extra
endif else ofile=file
if is_blank(ofile) then return

data = self.spex->getdata(spex_specfile=ofile,_extra=extra)
return
end

;------------------------------------------------------------------------------
; get_plot_obj function returns a xyplot or utplot object containing all the data to plot and
; options for plotting.  That object can be passed directly to plotman or plotted via obj->plot

function synop_spex::get_plot_obj, spectrum=spectrum, units=units, _ref_extra=extra

checkvar, units, 'rate'
if keyword_set(spectrum) then begin
  self.spex -> plot_spectrum,/tband,/allint,/no_plotman, /get_plot_obj, obj=obj, spex_units=units, _extra=extra
endif else begin 
  self.spex -> plot_time,/no_plotman, /get_plot_obj, obj=obj, spex_units=units, _extra=extra
endelse
return, obj
end

;-----------------------------------------------------------------------------
; PLOT wrapper

pro synop_spex::plot,_ref_extra=extra,err=err

if ~obj_valid(self.spex) then begin
 err='SPEX PLOT method not available. Check if SPEX package is installed.'
 message,err,/info
 return
endif

void=self->get_plot_obj(_extra=extra,get_plot_obj=0)

end

;------------------------------------------------------------------------------
;-- wrapper around SPEX GET

function synop_spex::get, filename=filename, _ref_extra=extra

if ~obj_valid(self.spex) then begin
 err='SPEX GET method not available. Check if SPEX package is installed.'
 message,err,/info
 return,''
endif

if keyword_set(filename) then return,self.spex->get(/spex_specfile)
return,self.spex->get(_extra=extra)
end

;------------------------------------------------------------------------------
;-- wrapper around SPEX SET

pro synop_spex::set,_ref_extra=extra

if ~obj_valid(self.spex) then begin
 err='SPEX SET method not available. Check if SPEX package is installed.'
 message,err,/info
 return
endif

self.spex->set,_extra=extra
return
end

;------------------------------------------------------------------------------
; has_data function returns 1 if there is data in the spec object to
; return.

function synop_spex::has_data
return,is_struct(self.spex->getdata())
end

;----------------------------------------------------------------------------
;-- search files (currently only SOXS)

function synop_spex::search,tstart,tend,_ref_extra=extra,soxs=soxs,$
                 hsi=hsi,xrs=xrs,count=count,type=type

rhost='hesperia.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='les',org='year',$
                 topdir='/soxs',/full

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('sxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/info

return,files
end

;------------------------------------------------------------------------------

pro synop_spex__define                 
self={synop_spex, spex:obj_new(), inherits site}
return & end

