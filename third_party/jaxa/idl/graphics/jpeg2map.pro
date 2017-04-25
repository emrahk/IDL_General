;+
; Project     : VSO
;
; Name        : JPEG2MAP
;
; Purpose     : Convert JPEG2000 image file to a map
;
; Category    : imaging, FITS
;
; Syntax      : IDL> jpeg2map,file,map
;
; Inputs      : FILE = JPEG2000 file name
;
; Outputs     : MAP = map structure (or object in /object)
;
; Keywords    : OBJECT = set to return map object
;
; History     : 9 Oct 2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro jpeg2map,file,map,object=object,_extra=extra

;-- do usual error checks

error=0
catch,error
if error ne 0 then begin
 message,!err_string,/cont
 goto,bail
endif

if is_blank(file) then begin
 pr_syntax,'jpeg2map,file,map [,/object]'
 return
endif

file=strtrim(file,2)
chk=file_search(file,count=count)
if count eq 0 then begin
 message,file+' not found',/cont
 return 
endif

qpeg=query_jpeg2000(file,info)
if qpeg eq 0 then begin
 message,file+' is not a valid JPEG2000 file.',/cont
 return
endif

jpeg=obj_new('IDLffJPEG2000',file)
if ~obj_valid(jpeg) then begin
 message,'Error creating JPEG2000 object',/cont
 return
endif

;-- extract FITS header info from XML property

jpeg->getproperty,xml=xml
if is_blank(xml) then begin
 message,file+' does not contain valid XML header information.',/cont
 goto,bail
endif

date_obs=get_xml_value(xml,'date-obs')
if is_blank(date_obs) then begin
 date_obs=get_xml_value(xml,'date_obs')
 if ~valid_time(date_obs) then begin
  message,'XML header does not contain valid observation date/time.',/cont
  goto,bail
 endif
endif

;-- extract data

data=jpeg->getdata(_extra=extra)
dim=size(data,/dim)
ndim=n_elements(dim)
if (ndim gt 3) or (ndim lt 1) then begin
 message,' JPEG2000 file does not contain valid data.',/cont
 goto,bail
endif

naxis1=dim[0]
naxis2=dim[1]
if n_elements(dim) eq 3 then begin
 chk=where(dim eq min(dim))
 if chk[0] eq 0 then begin
  naxis1=dim[1]
  naxis2=dim[2]
 endif
endif

;-- identify data

tel=get_xml_value(xml,'teles',/partial)
inst=get_xml_value(xml,'instr',/partial)
det=get_xml_value(xml,'detec',/partial)
id=strcompress(strjoin([tel,inst,det],' '))

;-- extract coordinate information

crpix1=get_xml_value(xml,'crpix1',/float)
crpix2=get_xml_value(xml,'crpix2',/float)
crval1=get_xml_value(xml,'crval1',/float)
crval2=get_xml_value(xml,'crval2',/float)
cdelt1=get_xml_value(xml,'cdelt1',/float)
cdelt2=get_xml_value(xml,'cdelt2',/float)
roll_angle=get_xml_value(xml,'crota1',/float)
xcen=comp_fits_cen(crpix1,cdelt1,naxis1,crval1)
ycen=comp_fits_cen(crpix2,cdelt2,naxis2,crval2)
time=anytim2utc(date_obs,/vms)

;-- create map 

if obj_valid(map) then obj_destroy,map
map=make_map(data,time=time,xc=xcen,yc=ycen,dx=cdelt1,dy=cdelt2,$
             roll_angle=roll_angle,id=id,/no_copy)

;-- return as object if /object

if keyword_set(object) then begin
 omap=obj_new('fits')
 omap->set,map=map,/no_copy
 map=omap
endif

;-- cleanup

bail: if obj_valid(jpeg) then obj_destroy,jpeg


return & end
