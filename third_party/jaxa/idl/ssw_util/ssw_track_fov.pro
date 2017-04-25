pro ssw_track_fov, index, data, 		$
                     iout, dout, 		$
                     ref_helio=ref_helio, 	$
                     ref_date=ref_date, 	$
                     outsize=outsize, 		$
                     debug=debug,arcsec=arcsec, $
                     ref_map=ref_map,           $
                     ref_image=ref_image,       $
                     interactive=interactive,soho=soho
;+
; NAME:
;    ssw_track_fov
;
; PURPOSE:
;    Extract a sub-field from the SSW-compliant (2D) image data
;    based on the reference time and reference coordinates.
; CALLING SEQUENCE:
;     ssw_track_fov, index, data, outindex, outdata,/interactive 
;-OR- ssw_track_fov, index, data, outindex, outdata,ref_map=ref_map
;-OR- ssw_track_fov, index, data, outindex, outdata, ref_image=NN
;-OR- ssw_track_fov, index, data, outindex, outdata, ref_image=index(NN)
;-OR- ssw_track_fov, index, data, outindex, outdata, $ 
;        helio=[LAT, LON], date_helio=ssw_std_time, outsize=[nx , ny]
;
; INPUTS:
;    index      - SSW-compliant index structure.
;    data       - 2 or 3D data cube.
;
; Keyword Parameters:
;    ref_helio  - Reference latitude and longitude for the alignment.
;    ref_date   - Reference date/time for the heliocentric input.
;                 (This can be an index structure.)
;    outsize    - Dimension of output image in pixels.
;    arcsec     - set for reference in arsecs instead of lon/lat.
;    ref_map    -  a sub field map from the DMZ package
;    ref_image  - index of index subscript of image to use for helio reference
;    interactive - if set, box select from 
;
; OUTPUTS:
;    indexout     - modified index header.
;    datatout     - extracted/aligned data array.  Will be same resolution
;                   as input data.
;
; RESTRICTIONS:
;    This routine relies on getting a SSW standard index vector  
;
; METHOD:
;    Calculates sub-region from ref_helio and ref_date and then 
;    passes the correct sub-region to <extract_arr.pro>.
;
; HISTORY:
;       10-sep-96 G.L.Slater MDI_TRACK_FOV Written 
;       22-Oct-96 B.N.Handy - Shamelessly stolen and butchered from GLS
;       16-jan-97 S.L.Freeland (eit/mdi compliant->online SSW)
;       16-sep-97 J. Newmark - added arcsec keyword, handle if off_limb
;        9-Apr-98 S.L.Freeland - bullet proof, add /interactive (DMZ map)
;                                add REF_MAP input, move some stuff outsie
;                                of the loop for vectorization
;        8-Nov-98 S.L.Freeland - add REF_IMAGE (use if /INTERACTIVE)
;        9-March-1999 - S.L.Freeland - derive SOLAR_R if not present
;       29-April-1999 - S.L.Freeland - modify output index coords using
;                                      newer technology 
;       18-May-1999 - S.L.Freeland - minor mods, REF_IMAGE
;                     protect pb0r time input (force utc_int via anytim call)
;       10-Jun-1999 - S.L.Freeland - protect against no ref_image or ref_map
;                     add call to struct2ssw if missing tags  
;	29-Jul-1999 - R.D.Bentley - changed name of derived image size when ref_map 
;                     keyword used, used to overwrite dimensions supplied by outsize
;        3-aug-1999 - S.L.Freeland - if referenc supplied and no explicit
;                     OUTSIZE, use outsize(reference)
;        4-aug-1999 - N.Nitta/S.L.Freeland - fix hel2arcmin call 
;                     (DATE is keyword, not positional)
;-
debug=keyword_set(debug)
  
if not data_chk(index,/struct) or n_params() lt 4then begin 
  box_message,'IDL> ssw_track_fov,index,data,outindex,outdata[options]
  return
endif

num_images = n_elements(index)

if num_images ne data_chk(data,/nimages) then begin 
   box_message,'Mismatch between INDEX,DATA elements'
   return
endif  

iout = index
if not required_tags(iout,'xcen,ycen,cdelt1,cdelt2,day,time') then $
    iout=struct2ssw(iout)                                    ; add required

case 1 of 
   keyword_set(interactive):begin 
      if not keyword_set(ref_image) then ref_image=n_elements(index)/2
      box_message,'Calling Mapping Software for sub-region select' 
      ref_data=data(*,*,ref_image)
      mdata=max(ref_data)
      if data_chk(ref_data,/type) gt 1 and mdata gt 256 then begin
         ref_data=sobel_scale(index(ref_image),ref_data,minper=5,hi=.9*mdata)
      endif
      index2map,index(ref_image),ref_data, ref_map, /sub
   endcase
   data_chk(ref_image,/struct): begin
     ss=tim2dset(index,ref_image)
     index2map,index(ss),data(*,*,ss), ref_map
   endcase
   data_chk(ref_image,/type) ge 1: begin
     index2map,index(ref_image(0)),data(*,*,ref_image(0)), ref_map
   endcase
   else:
endcase   

if keyword_set(ref_map) then begin 
   if not valid_map(ref_map) then begin 
      box_message,'invalid REF_MAP'
      return
   endif
   ref_date=gt_tagval(ref_map,/time)
   ref_helio=reverse(arcmin2hel((ref_map.xc)/60.,$
                                (ref_map.yc)/60.,date=ref_date))
   outs=(size(ref_map.data))(1:2)	;!!!
   if n_elements(outsize) eq 0 then outsize=outs           ; slf.
endif

case 1 of 
   n_elements(outsize) eq 0: outs=[data_chk(data,/nx)*.25,data_chk(data,/ny)*.25]
   n_elements(outsize) eq 1: outs=replicate(outsize(0),2)
   else: outs=outsize(0:1)
endcase

dout = fltarr(outs(0), outs(1), num_images)

; Get the reference time
case 1 of 
   data_chk(ref_date, /struct): ref_time = anytim(ref_date,/yohkoh)
   data_chk(ref_date,/string):  ref_time = anytim(ref_date,/yohkoh)
   data_chk(ref_image,/struct): ref_time = anytim(ref_image,/yohkoh)
   else: begin 
      box_message,'supply reference image, map , time or use /INTERACTIVE'
      return
   endcase
endcase
      
off_limb = 0

if keyword_set(arcsec) then begin
    helio = shift(arcmin2hel(ref_helio(0)/60.,ref_helio(1)/60.,$
               date=ref_date,off_limb=off_limb,/soho),1)
    if not off_limb(0) then ref_helio = helio
endif

if tag_exist(iout,'object') then iout.object = 'partial FOV'
time_img = fmt_tim(index)

; derive radius if not included in .solar_r
radius=gt_tagval(index,/solar_r,missing=0)      ; "standard" radius in pixels
noradss=where(radius eq 0,sscnt)
sscnt=1                                         ; FORCING recalculation...

if sscnt gt 0 then begin 
   pb0rx=pb0r(anytim(ref_time,/utc_int), soho=soho, /arcsec)
   radius=pb0rx(2)/gt_tagval(index,/cdelt1,miss=2.5)  ; radius in pixels
endif

for i=0, num_images-1 do begin
  del_t = int2secarr(time_img(i),ref_time)/86400d
  suncenter = [index(i).crpix1, index(i).crpix2]
  xsiz_pix = outs(0)
  ysiz_pix = outs(1)

  if not off_limb(0) then begin
       helio = [ref_helio(0)+diff_rot(del_t(0),ref_helio(1),/synodic), $
          ref_helio(1)]

     fov_cen = conv_h2p(helio, time_img(i), behind=0, suncenter=suncenter, $
                     pix_size=index.cdelt1, radius=radius(i))

   endif else fov_cen = suncenter + ref_helio/index.cdelt1            

  dout(*,*,i) = extract_arr(data(*,*,i), xcen=fov_cen(0), ycen=fov_cen(1), $
                            xsiz=xsiz_pix, ysiz=ysiz_pix)
  if debug then stop
;
; update the relevant tags.
  iout(i).naxis1 = xsiz_pix
  iout(i).naxis2 = ysiz_pix
  arcmin=hel2arcmin(helio(1),helio(0),date=anytim(index(i),/utc_int),soho=soho)
  iout(i).xcen = arcmin(0)*60.
  iout(i).ycen = arcmin(1)*60.
  iout(i).crpix1 = comp_fits_crpix(iout(i).xcen,index(i).cdelt1,xsiz_pix)
  iout(i).crpix2 = comp_fits_crpix(iout(i).ycen,index(i).cdelt2,ysiz_pix)

; remember subfield values are physical postions on array, need to add 1 in 
; x-direction and 20 in y-direction?

  if tag_exist(iout,'p1_x') then begin    ; special update for nonstandard EIT
     sz_data=size(data)
     iout(i).p1_x = (fov_cen(0)-0.5*xsiz_pix+1) + 1 > 0
     iout(i).p2_x = (fov_cen(0)+0.5*xsiz_pix) + 1 < (sz_data(1)-1) + 1
     iout(i).p1_y = (fov_cen(1)-0.5*xsiz_pix+1) + 20 > 0
     iout(i).p2_y = (fov_cen(1)+0.5*xsiz_pix) + 20 < (sz_data(2)-1) + 20
  endif

endfor

if debug then stop
end
