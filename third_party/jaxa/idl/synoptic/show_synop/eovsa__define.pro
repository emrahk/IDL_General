;+
; Project     : VSO
;
; Name        : EOVSA__DEFINE
;
; Purpose     : Class definition for EOVSA data object
;
; Category    : Objects
;
; History     : Written 23 September 2013, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-
;---------------------------------------------------

function eovsa::init,_ref_extra=extra

if ~self->have_path(_extra=extra) then return,0

;-- load helper objects instead of using inheritence to avoid property 
;   name collisions

edb=obj_new('eovsa_db',_extra=extra)
if ~obj_valid(edb) then return,0
self.database=edb
self.image=obj_new('fits')
self.spectrum=obj_new('eovsa_tpwr')

return,1

end

;-------------------------------------------------

pro eovsa::cleanup

obj_destroy,self.database
obj_destroy,self.image
obj_destroy,self.spectrum

return & end

;--------------------------------------------------
function eovsa::search,tstart,tend,_ref_extra=extra

return,self.database->search(tstart,tend,_extra=extra)

end

;---------------------------------------------------

function eovsa::get,_ref_extra=extra

case self.data_type of
'image': return,self.image->get(_extra=extra)
'spectrum': return,self.spectrum->get(_extra=extra)
 else: return,undefined
endcase

end

;---------------------------------------------------

pro eovsa::set,_ref_extra=extra

case self.data_type of
'image': self.image->set,_extra=extra
'spectrum': self.spectrum->set,_extra=extra
 else: return
endcase

end

;------------------------------------------------------
;-- get data type

function eovsa::type,file,err=err

types=[0,1,2]
ptypes=['image','spectrum','lightcurve']

err=''
mrd_head,file,header,err=err
if is_string(err) then return,'Undefined'

;-- check header for type

tvalue=fits_keyword_value(header,'type')
if is_number(tvalue) then begin
 chk=where(fix(tvalue) eq types,count)
 if count ne 0 then return,ptypes[chk[0]]
endif

;-- try filename

tfile=file_basename(file)
case 1 of
 stregex(tfile,'_sp',/bool): return,'spectrum'
 stregex(tfile,'_im',/bool): return,'image'
 else: return,'Undefined'
endcase

end

;--------------------------------------------------------

pro eovsa::read,file,_ref_extra=extra,out=eovsa_rd,err=err

err=''

if ~self->is_valid(file,err=err) then return

self.image->getfile,file,local_file=cfile,err=err,_extra=extra
if is_blank(cfile) or is_string(err) then return

type=self->type(cfile)

error=0
catch, error
if (error ne 0) then begin
 err=err_state()
 message,err,/info
 catch,/cancel
 return
endif

case type of
'image' : self.image->read,cfile,_extra=extra
'spectrum': self.spectrum->read,file=cfile,_extra=extra
else: begin
       err='No read method for type - '+type
       message,err,/info
       return
      end
endcase

self.data_type=type
self.filename=file_basename(cfile)

return & end

;-----------------------------------------------

function eovsa::is_valid,file,err=err,_ref_extra=extra

err=''
if is_blank(file) then begin
 err='Missing input file.'
 message,err,/info
 return,0b
endif

chk=get_fits_det(file,err=err,_extra=extra)
if is_string(err) then return,0b

if chk ne 'EOVSA' then begin
 err='Input file is not an EOVSA FITS file.'
 message,err,/info
 return,0b
endif

return,1b

end
;------------------------------------------------

function eovsa::has_data

if self.data_type eq 'image' then begin
 if ~obj_valid(self.image) then return,0b
 if have_method(self.image,'has_data') then return,self.image->has_data()
endif
 
if self.data_type eq 'spectrum' then return,obj_valid(self.spectrum) 
return,0b

end

;-------------------------------------------------

pro eovsa::plot_spectrum,_ref_extra=extra,err=err

err=''
if have_method(self.spectrum,'allplot') then $
 self.spectrum->allplot,/no_copy,/noclone,/nodup,filename=self.filename,_extra=extra else begin
  err='Missing ALLPLOT method.'
  message,err,/info
endelse

return & end
;---------------------------------------------------

pro eovsa::plotman,_ref_extra=extra

case self.data_type of
'image': self.image->plotman,_extra=extra,/use_colors
'spectrum': self->plot_spectrum,_extra=extra
else: message,'No plot method for type - '+type
endcase

return & end

;-----------------------------------------------------------------------------
;-- check for EOVSA branch in !path

function eovsa::have_path,err=err,verbose=verbose

err=''
if ~have_proc('eovsa_read_pwrfits') then begin
 epath=local_name('$SSW/radio/eovsa/idl')
 if is_dir(epath) then add_path,epath,/append,/quiet,/expand
 if ~have_proc('eovsa_read_pwrfits.pro') then begin
  err='EOVSA branch of SSW not installed.'
  if keyword_set(verbose) then message,err,/info
  return,0b
 endif
endif

return,1b
end

;------------------------------------------------------
pro eovsa__define,void                 

void={eovsa, filename:'', data_type:'', database:obj_new(), spectrum:obj_new(), $
             image:obj_new()}

return & end
