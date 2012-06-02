pro image_info, file, info, mids=mids, mom=mom, imn=imn

if NOT keyword_set(imn) then imn=0 ; do for all images

if (NOT KEYWORD_SET(file)) THEN begin
   print,"Please provide a sky image filename"
   print,"Usage: image_info,'xxx_sky_image.fits.gz',info"
   print,"info is the output structure with the required information"
endif

if (NOT KEYWORD_SET(mids)) THEN mids=50

;read the main meader to determine the number of images
hd=headfits(file,ext=1)
num_im=fxpar(hd,'NAXIS2')

print,"There are ",strtrim(string(num_im),1)," images in this file"
if imn eq 0 then print,'acquiring info on all images' else begin
   print,'only acquiring image number ',imn
   num_im=1
endelse


;read the image header to get image size

hd2=headfits(file,ext=2)
;any image present?

if hd2[0] eq -1 then begin
   print,'WARNING, no image inside!'
   info=create_struct('id',' ','exposure',0.d,'type',' ','ra',0.d,'dec',0.d,'erng',strarr(2),'image',dblarr(1,1))
   info.id=file
   mom=[0,0,0,0]

endif else begin

im_size=lonarr(2)
im_size[0]=fxpar(hd2,'NAXIS1')
im_size[1]=fxpar(hd2,'NAXIS2')

;create the structure to hold the image and other necessary info

info1=create_struct('id',' ','exposure',0.d,'type',' ','ra',0.d,'dec',0.d,'erng',strarr(2),'image',dblarr(im_size[0],im_size[1]))

if imn eq 0 then info=replicate(info1,num_im) else info=info1

;now read the info from each extension. This assumes the extensions
;are consequtive, may need to fix later

for i=0,num_im-1 do begin
if imn eq 0 then j=i else j=imn
  hdn=headfits(file,ext=j+2)
  info[i].id=file+"["+strtrim(string(j+2),1)+"]"
  info[i].exposure=fxpar(hdn,'EXPOSURE')
  if info[i].exposure eq 0. then info[i].exposure=fxpar(hdn,'TELAPSE')
  info[i].type=fxpar(hdn,'IMATYPE')
  info[i].ra=fxpar(hdn,'CRVAL1')
  info[i].dec=fxpar(hdn,'CRVAL2')
  info[i].erng[0]=fxpar(hdn,'E_MIN')
  info[i].erng[1]=fxpar(hdn,'E_MAX')
  fits_read,file,image,hdn,exten_no=j+2
  info[i].image=image
endfor

;take the middle quarter
mid=info[0].image[(im_size[0]/2.)-(mids/2.):(im_size[0]/2.)+(mids/2.),$
(im_size[1]/2.)-(mids/2.):(im_size[1]/2.)+(mids/2.)]
mom=moment(mid)

print,'exp: ',strtrim(string(info[0].exposure),1),',  coord: ',$
strtrim(string(info[0].ra),1),' ',strtrim(string(info[0].dec),1),$
',  mid_var:',strtrim(string(mom(1)),1)

endelse

end
