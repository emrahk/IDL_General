function solar_mask, index , data, ss=ss, outside=outside, $
   pad=pad, annulus=annulus, solar_r=solar_r, mask_data=mask_data
;+
;   Name: return  a solar disk mask using SSW standard keywords
;
;   Input Parameters:
;      index - structure or fits header
;      data  - optional data to mask
;
;   Keyword Parameters:
;      ss - if set, function returns SS (SubSript) vector, not array mask
;      pad - if defined, pad the limb with this (can be negative) - pixel units
;      rpad - alternative to PAD in units of R
;      annulus - if set, two element array - annulus inner and outer diam
;                Units = R
;      mask_data - if set, function returns masked data instead of boolean
;
;   Output:
;      function returns bit mask size of data array or subscripts if /ss is set
;
;   History:
;     19-Oct-1998 - S.L.Freeland - logic from ssw_limbstuff et al
;      2-Dec-1999 - S.L.Freeland - eliminate variable/function conflict(mask)
;     20-Jun-2000 - S.L.Freeland - enable ANNULUS keyword and function
;     30-Aug-2004 - R.D.Bentley - extract time with GET_FITS_TIME - more forgiving
;
;   Calling Examples:
;      IDL> diskmask=solar_mask(index,data)                   ; inside limb   
;      IDL> abovelimbmask=solar_mask(index,data,/outside)     ; outside limb
;      IDL> annulus=solar_mask(index,data,annulus=[.9,1.1])   ; annulus
;
;   Method:
;      call L.Wang 'cir_mask' using crpix et at
;
;  Restrictions:
;-

mask_data=n_params() gt 1 and keyword_set(mask_data)

case 1 of 
  required_tags(index,'crpix1,crpix2,cdelt1'): 
  else: begin
     box_message,'Not yet supported'
     return,-1
  endcase
endcase

pixx=gt_tagval(index,/crpix1)
pixy=gt_tagval(index,/crpix2)
if n_elements(solar_r) eq 0 then $
    solar_r=gt_tagval(index,/solar_r,missing=0.)     ; can get from get_sun & cdelt

solar_r=0                                               ; FORCE CALCULATION
if solar_r eq 0 then begin                              ; no solar_r, use ephemeris
   get_fits_time,index,tt 
   sunstuff=get_sun(anytim2ints(tt),sd=solar_r)
   solar_r=solar_r/gt_tagval(index,/cdelt1,missing=.5)
endif

if n_elements(annulus) eq 2 then begin 
   padout=solar_r*(max(annulus)-1.)
   padin =solar_r*(min(annulus)-1.)
   maskout=solar_mask(index,data,pad=padin,/outside)
   maskin =solar_mask(index,data,pad=padout)
   annmask=maskin and maskout
   if mask_data then annmask=data*annmask
   return,annmask  
endif

if keyword_set(pad) then solar_r=solar_r+pad

if not keyword_set(data) then data=$
   make_array(gt_tagval(index,/naxis1),gt_tagval(index,/naxis2),/byte)

ssmask=cir_mask(data,pixx,pixy,solar_r,outside=keyword_set(outside)) ; LWang routine

retval=data*0

case 1 of 
  keyword_set(ss): retval=ssmask
  else: begin 
     if ssmask(0) ne -1 then retval(ssmask)=1
     if mask_data then retval=data*retval      ; return masked data on request
  endcase
endcase

return, retval
end

