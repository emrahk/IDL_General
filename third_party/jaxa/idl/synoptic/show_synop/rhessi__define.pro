;+
; Project     : HESSI
;
; Name        : RHESSI__DEFINE
;
; Purpose     : Define a light RHESSI data object that has the same methods as the other
;               synoptic data types.  This has two purposes:
;               1. Can read and plot a RHESSI image fits file using the standard calls
;                  (read, plot) without having the RHESSI ssw software installed
;               2. If the rhessi software is installed, and a blank filename is passed
;                  to read method, will make a real rhessi image object, set the parameters 
;                  passed via extra, and the write method will write an output FITS file. The
;                  advantage is that this object has generic read, write methods (unlike
;                  the rhessi image object's set, getdata, fitswrite methods). This
;                  mode is used in the prepserver on the server side, which calls all of the
;                  different data objects with the same calls (read and write).  On the
;                  server, we have the RHESSI software is installed so we can create an
;                  image fits file through this more generic interface.
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('rhessi')
;
; History     : Written 1-Dec-2008, Kim Tolbert
;               2-Apr-2009. Kim.  Add functionality to make a RHESSI
;               image and write a FITS file.
;               14-Oct-2009, Zarro (ADNET) 
;                 - renamed ::mreadfits to ::readfits
;                 - added call to mk_map since mreadfits usd to do
;                   this
;               3-Nov-2009, Zarro (ADNET) 
;               - removed explicit nodata keyword since it conflicted
;                 with extra
;               26-Nov-2011, Kim. Call al_legend instead of legend (IDL V8 conflict) and make
;                legend_color byte
;
;-
;-- RHESSI init

function rhessi::init,_ref_extra=extra

mklog,'SEARCH_NETWORK','1'
return,self->fits::init(_extra=extra)

end

;---------------------------------------------------------------------------
;-- set color table 5

pro rhessi::colors,k

dsave=!d.name
set_plot,'Z'
tvlct,r0,g0,b0,/get
loadct,5,/silent
tvlct,red,green,blue,/get
tvlct,r0,g0,b0
set_plot,dsave
self->set,k,red=red,green=green,blue=blue,/has_colors

return & end


;--------------------------------------------------------------------------
;-- FITS reader.  If not input file is passed (file = '') that means we want to use the 
; RHESSI-specific sofware if available to reconstruct an image.  In that case, make a rhessi
; object and set parameters from extra into it in the read method.  When we call the write 
; method, the image will be generated and a FITS file written.

pro rhessi::read,file,data,_ref_extra=extra
forward_function hsi_image

if file eq '' then begin
  if have_proc('hsi_image') then begin
    self.hsi_image_obj = hsi_image()
    self.hsi_image_obj ->set, _extra=extra
    self.hsi_image_obj -> set_no_screen_output
  endif
return
endif
    
;-- download if URL

self->getfile,file,local_file=ofile,_extra=extra
if is_blank(ofile) then return

self->readfits,ofile,data,_extra=extra

count=self->get(/count)
if count eq 0 then return

for i=0,count-1 do begin
 self->set,i,/limb
 self->colors,i
endfor

return & end

;---------------------------------------------------------------------------

pro rhessi::write, outfile
if is_class(self.hsi_image_obj, 'HSI_IMAGE') then self.hsi_image_obj -> fitswrite, im_out=outfile
end

;---------------------------------------------------------------------------

pro rhessi::readfits,file,data,index=index,_ref_extra=extra,err=err

 err=''

 self->fits::readfits,file,data,_extra=extra,index=index,err=err
 if is_string(err) or (size(data,/n_dim) ne 2) then return
 self->fits::readfits,file,ext1,_extra=extra,extension=1,index=index1,err=err
 if is_string(err) or ~is_struct(ext1) then return

 index = add_tag(index, ext1.image_algorithm, 'image_algorithm')

 case 1 of
    tag_exist(ext1,'ebands_arr'): enb = ext1.ebands_arr
    tag_exist(ext1,'energy_axis'): enb = ext1.energy_axis
    else: enb = [0.,0.]
 endcase
 index = add_tag(index, enb, 'energy_range')

 det = ext1.det_index_mask
 front = ext1.front_segment
 rear = ext1.rear_segment
 used = where(det) + 9* rear
 ids = [ strtrim(indgen(9)+1,2)+'F', strtrim(indgen(9)+1,2)+'R', strtrim(indgen(9)+1,2)+'T']
 det_string = arr2str(ids( used>0<26 ) + strarr(n_elements( ids )),' ')
 index = add_tag(index, det_string, 'subcolls')

 self->mk_map,index,data,filename=file_basename(file),err=err,_extra=extra

 end


;-----------------------------------------------------------------------------

pro rhessi::plot, legend_loc=legend_loc, legend_color=legend_color, charsize=charsize, _ref_extra=extra
self -> map::plot, _extra=extra

index = self -> get(/index)
enb = index.energy_range

legend = [format_intervals([index.date_obs,index.date_end],/ut), $
   'Detectors: ' + index.subcolls, $
   'Energy Range: ' + trim(enb[0],'(f6.1)') + ' - ' + trim(enb[1],'(f6.1)'), $
   index.image_algorithm]

checkvar, legend_loc, 1
if legend_loc ne 0 then begin
   top = legend_loc lt 3
   bottom = legend_loc ge 3
   right = (legend_loc mod 2) eq 0
   left = legend_loc mod 2
endif

checkvar, legend_color, 255
; Note: don't pass extra to legend.  There are conflicts.
if legend_loc ne 0 then $
  al_legend, legend, box=0, $
    top_legend=top, bottom_legend=bottom, right_legend=right, left_legend=left,$
    textcolor=byte(legend_color), charsize=charsize

end




;-----------------------------------------------------------------------------
;-- RHESSI help

pro rhessi::help

print,''
print,"IDL> rhessi=obj_new('rhessi')                        ;-- create rhessi object
print,'IDL> rhessi->read,file_name                          ;-- read FITS file
print,'IDL> rhessi->plot                                    ;-- plot
print,"IDL> p = plotman(input=rhessi,plot_type='image', desc='RHESSI image')     ; plot in interactive PLOTMAN" 
print,"IDL> p->new_panel,input=rhessi,plot_type='image', desc='RHESSI image'     ; add to existing PLOTMAN GUI" 
print,'IDL> map=rhessi->get(/map)                           ;-- extract map structure
print,'IDL> data=rhessi->get(/data)                         ;-- extract data array
print,'IDL> obj_destroy,rhessi                              ;-- destroy rhessi object


return & end

;------------------------------------------------------------------------------
;-- rhessi data structure

pro rhessi__define,void

void={rhessi, hsi_image_obj: obj_new(), inherits fits}

return & end
