
pro ssw_find_transit, index, data, centx, centy, boolean=boolean, $
		      display=display, ponly=ponly, pixpad=pixpad, $
		      xcen=xcen, ycen=ycen, _extra=_extra, sfactor=sfactor
;+
;   Name: ssw_find_transit
;
;   Purpose: find planet against solar disk
;
;   Input Parameters:
;      index, data - standard 'ssw' index,data 2D/3D (read_eit, read_trace..)
;
;   Output Parameters:
;      centx,centy - the weighted centroid position (planet location)
;
;   Keyword Parameters:
;     ponly   - output array of 'planet only'  (same size as data)
;     boolean - if set, use boolean array instead of data array for centroid
;     display - if set, show results
;     sfactor - expected signal difference; default = .1 (10%)
;     pixpad  - optional pixel padding (only consider this distance above limb)
;               default=20 pix, increase for EUV & XRAY 
;     xcen_limit - (input) optional xcen limits (restrict search to this reg)
;     ycen_limit - (input) optional ycen limits (restrict search to this region)
;     xpix_limit - (input) optional x pixel range restrict search to this reg)
;     ypix_limit - (input) optional x pixel range restrict search to this reg)
;  
;     xcen,ycen - (output) centx and centy in arcsecs from sun center (ssw std)
;     
;   History:
;      2-December-1999 - S.L.Freeland - orig for TRACE/Mercury transit
;      3-December-1999 - S.L.Freeland - add call to ssw_mask_image
;                        (enable xcen/ycen search limit)
;   Restrictions:
;      ~ on disk only - assumes planet signal low compared to solar disk 
;-  
if n_elements(pixpad) eq 0 then pixpad=20           ; above limb padding  
display=keyword_set(display)

nimages=data_chk(data,/nimage)                      ; number images
if nimages lt 1 or 1-data_chk(index,/struct)  then begin
   box_message,'Need 2D or 3D "index,data" input
   return
endif  

ponly=make_array(data_chk(data,/nx),data_chk(data,/ny),nimages,$
		 type=data_chk(data,/type))
ptemp=ponly(*,*,0)
centx=fltarr(nimages) & centy=fltarr(nimages)
if n_elements(sfactor) eq 0 then sfactor=.1

for i=0, nimages-1 do begin
   smask=solar_mask(index(i),data(*,*,i),pad=pixpad)          ; ~on-disk mask
   xymask=ssw_mask_image(index(i),data(*,*,i), _extra=_extra) ; XY restrict?
   amask=float(smask and xymask)
   if display and (i eq 0) then begin
      wdef,im=amask
      tvscl,amask and data(*,*,i)
      align_label,/uc,size=2,'Data Mask'
      wait,2
   endif
   pmask=(data(*,*,i) lt sfactor*average(data(where(amask)))) and amask
   ssplanet=where(pmask gt 0,mmcnt)                       ; subscripts of planet

   if mmcnt eq 0 then begin
      box_message,'Could not find anything in image# ' + strtrim(i,2)
      ssplanet=0
   endif

   temp=ptemp                                      ; template
   temp(ssplanet)=data(ssplanet)                   ; planet data pixels->empty
   ponly(0,0,i)=temp                               ; -> output array     
   if keyword_set(boolean) then $                  ; boolean requested?
       ponly(0,0,i)=ponly(*,*,i) ne 0              ;    make them 1's instead
   centroidw, ponly(*,*,i), xcentx, xcenty         ; calculate weighted centroid
   centx(i)=xcentx & centy(i)=xcenty               ; scalar->vector output

   if keyword_set(display) then begin              ; display on request
      wdef,im=data
      tvscl,data(*,*,i)
      plots,replicate(xcentx,2),[0,!d.y_size-1],/device   
      plots,[0,!d.x_size-1],   replicate(xcenty,2),/device
      wait,([0,2])(i lt (nimages-1))   
   endif
endfor

; -------- return XCEN and YCEN keywords ---------
xcen=(centx-index.crpix1)*index.cdelt1
ycen=(centy-index.crpix2)*index.cdelt2

return
end
  
  
