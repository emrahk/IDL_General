;+
; Project     : STEREO
;
; Name        : mk_secchi_map
;
; Purpose     : make a SECCHI image map
;
; Category    : imaging, maps
;
; Syntax      : IDL> map=mk_secchi_map(file,omap)
;
; Inputs      : FILE = SECCHI FITS file
;               INDEX/DATA = index/data arrays from previous read 
;
; Outputs     : MAP = SECCHI map structure
;
; Keywords    : OMAP = optional object containing map
;
; History     : Written 4 October 2007, Zarro (ADNET)
;               Modified 29 March 2008, Zarro (ADNET)
;                - return array of maps with size equal to first map
;               Modified 26 March 2009, Zarro (ADNET)
;                - renamed index2map method call to mk_map
;               Modified 19 April 2009, Zarro (ADNET)
;                - removed vectorization from mk_map
;               Modified 23 May 2014, Zarro (ADNET)
;                - used MERGE_STRUCT to merge maps with different
;                  tag type. Return INDEX as keyword.
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_secchi_map,file,data,omap=omap,_ref_extra=extra,err=err,index=index

err=''
index_data=is_struct(file) and exist(data)
file_in=is_string(file)

if ~file_in and ~index_data then begin
 pr_syntax,'map = mk_secchi_map(fits_file_name)'
 pr_syntax,'map = mk_secchi_map(index,data)'
 return,-1
endif

;-- create a SECCHI object 

return_obj=arg_present(omap) 
no_copy=~return_obj

if ~obj_valid(omap) then omap=obj_new('secchi',_extra=extra) else begin
 if obj_class(omap) ne 'SECCHI' then obj_destroy,omap
endelse

if ~obj_valid(omap) then return,-1

;-- read and/or process

if file_in then begin
 omap->read,file,data,_extra=extra,err=err
endif else begin
 for i=0,n_elements(file)-1 do omap->mk_secchi_map,i,file[i],data[*,*,i],_extra=extra
endelse
 
if is_string(err) then begin
 obj_destroy,omap
 return,-1
endif

;-- extract similar sized map structures from object

count=omap->get(/count)
if count gt 0 then begin
 for i=0,count-1 do begin
  imap=omap->get(i,/map,no_copy=no_copy,_extra=extra)
  rindex=omap->get(i,/index)
  sz=size(imap.data) 
  if i eq 0 then begin
   nx=sz[1] & ny=sz[2]
   map=temporary(imap)
   index=rindex
  endif else begin
   n1=sz[1] & n2=sz[2]
   if (n1 eq nx) and (n2 eq ny) then begin
    map=merge_struct(map,imap,/no_copy)
    index=merge_struct(index,rindex)
   endif
  endelse  
 endfor
endif

if ~return_obj or count eq 0 then obj_destroy,omap

if ~valid_map(map) then map=-1

return,map

end



