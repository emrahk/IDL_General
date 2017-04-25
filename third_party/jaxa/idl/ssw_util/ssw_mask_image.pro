function ssw_mask_image, index , data, $
        xcen_limits=xcen_limits, ycen_limits=ycen_limits, $
	xpix_limits=xpix_limits, ypix_limits=ypix_limits, $
        ss=ss, pad=pad, solar_r=solar_r, outside=outside
;+
;   Name: return solar disk mask constrained by XY limits using SSW standards 
;
;   Input Parameters:
;      index - structure or fits header (read_trace, read_eit, read_sxt...)
;      data  - optional data to mask 
;
;   Keyword Parameters:
;      ss - if set, function returns SS (SubSript) vector, not array mask
;      pad - if defined, pad the limb with this - in pixel units
;      xcen_limits - [xcen0,xcen1] - (EW) limits in arcsec from sun center
;      xpix_limits - [x0,x1]       - limits in pixels
;      ycen_limits - [ycen0,ycen1] - (NS) limits in arcsec from sun center
;      ypix_limits - [y0,y1]       - limits in pixels
;
;   Output:
;      function returns bit mask size of data array or subscripts if /ss is set
;
;   History:
;     19-Oct-1998 - S.L.Freeland - logic from ssw_limbstuff et al
;      2-Dec-1999 - S.L.Freeland - eliminate variable/function conflict(mask)
;      3-Dec-1999 - S.L.Freeland - extension of 'solar_mask.pro' to XY
;  
;   Method:
;
;  Restrictions:
;    input requires ssw compliant pointing tags (crpix,cdelt...)
;-
outside=keyword_set(outside)

case 1 of 
  required_tags(index,'crpix1,crpix2,cdelt1,naxis1,naxis2'): 
  else: begin
     box_message,'Not yet supported'
     return,-1
  endcase
endcase

pixx=gt_tagval(index,/crpix1)
pixy=gt_tagval(index,/crpix2)
nx=gt_tagval(index,/naxis1)
ny=gt_tagval(index,/naxis2)
delt1=gt_tagval(index,/cdelt1)
delt2=gt_tagval(index,/cdelt2,missing=delt1)

if not keyword_set(solar_r) then $
    solar_r=gt_tagval(index,/solar_r,missing=0.)     ; can get from get_sun & cdelt

if solar_r eq 0 then begin
   sunstuff=get_sun(index,sd=solar_r)
   solar_r=solar_r/gt_tagval(index,/cdelt1,missing=.5)
endif

if keyword_set(pad) then solar_r=solar_r+pad

if not keyword_set(data) then data=$
   make_array(gt_tagval(index,/naxis1),gt_tagval(index,/naxis2),/byte)

retval=(data*0)+outside

; convert xcen/ycen limits -> pix limits
case n_elements(xcen_limits) of
   0:
   1: begin
        xcen_limitx=[xcen_limits(0),((nx+1)/2)+pixx]
        xpix_limits=(xcen_limits(0:1)/delt1)+pixx
   endcase
   else: xpix_limits=(xcen_limits(0:1)/delt1)+pixx
endcase

case n_elements(ycen_limits) of
   0:
   1: begin
       ycen_limitx=[ycen_limits(0),((ny+1)/2)+pixy]
       ypix_limits=(ycen_limits(0:1)/delt2)+pixy
   endcase
   else: ypix_limits=(ycen_limits(0:1)/delt2)+pixy
endcase

case n_elements(xpix_limits) of
   0: xpix_limits=[0,nx-1]
   1: xpix_limits=[xpix_limits(0),nx-1]
   else: xpix_limits=xpix_limits(0:1)>0<(nx-1)
endcase
case n_elements(ypix_limits) of
   0: ypix_limits=[0,ny-1]
   1: ypix_limits=[ypix_limits(0),ny-1]
   else: ypix_limits=ypix_limits(0:1)>0<(ny-1)
endcase

retval(xpix_limits(0):xpix_limits(1),  $
       ypix_limits(0):ypix_limits(1) ) = ([1,0])(outside)

ssmask=where(retval)
if keyword_set(ss) then retval=where(ssmask)

return, retval
end


