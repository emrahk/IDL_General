function ssw_flare_locator, index, datax, oindex,odata , $
   limb_pad=limb_pad, smooth_width=smooth_width, nosmooth=nosmooth , $
   dark_flare=dark_flare, helio=helio, flare_helio=flare_helio, ldata=ldata, $
   despikes=despikes, nospikes=nospikes, nofill=nofill,xyp=xyp, $
   reg_minutes=reg_minutes
    
;
;+
;   ssw_flare_locator
;
;   Purpose: locate flares from input data (3D or 2D)
;
;   Input Paramters:
;      index,data - ssw compliant 'index,data'; usually  
;                   one "before" and another during or shortly after peak
;   Output:
;      function returns xcen/ycen of flare 
;
;   Keyword Parameters:
;      limb_pad - size of above limb region to consider  ( -> solar_disk.pro )
;      smooth_width - width of box in boxcar smooth  
;      nosmooth - switch, if set, don't apply the smoothing algorithm
;      dark_flare - if set, look for dark, not bright "flare" (dimming?)
;      helio - if set, function return heliographic (arcmin2hel convention)
;      ldata - (output) - data array used in the location
;      flare_helio (output) - flare coordinates in heliographic
;      nofill - if set, dont fill missing pixels from neighbors 
;           (default is to fill via ssw_fill_cube which results in zeroing out the  
;            missing pixels in the differenence image, probably a reasonable thing)
;      nospikes/despikes (input, synonyms) - if set, despike both images prior to
;               applying flare algorithm (suggested if not done prior to call)
;               Current algorithm is via ssw/gen nospike.pro (/FLARE set)
;      reg_minutes - if set, number of minutes seperation when image
;               registration w/differential rotation will kick in
;               (default is no registration)

;   History:
;      Circa Jan 1 2002 - written
;
;      16-Mar-2004 - allow one image (make it look like 2)
;                    protect against 2 image input of identical images
;      12-may-2005 - add REG_MINUTES keyword and function
;-

; 
;-
if n_elements(smooth_width) eq 0 then smooth_width=5
if keyword_set(nosmooth) then smooth_width=0
dark_flare=keyword_set(dark_flare)
despikes=keyword_set(despikes) or keyword_set(nospikes)
nofill=keyword_set(nofill)

if data_chk(datax,/nimage) eq 1  then begin
   data=rebin(datax,data_chk(datax,/nx),data_chk(datax,/ny),2, $
               type=data_chk(datax,/type))
   data(*,*,0)=0
   nofill=1                   
endif else begin
   if data_chk(datax,/nimage) eq 2  then begin
      data=datax
      ss=where(data(*,*,0) ne data(*,*,1),dcnt)
      if dcnt eq 0 then begin 
         box_message,'Two identical images input! - zeroing first'
         data(*,*,0)=0
         nofill=1
      endif
   endif

endelse

if keyword_set(reg_minutes) then begin 
    if max(abs(ssw_deltat(index,/min))) ge reg_minutes then begin 
       box_message,'Applying registration/derotation
       ssw_register,index,data,oindex,odata,/derotate,$
          ref_index=n_elements(index)-1
       index=temporary(oindex)
       data=temporary(odata)
    endif else box_message,'Close enough dT; not registering'
endif
       


case data_chk(data,/nimages) of 
   0: begin 
         box_message,"need at least one image..."
         return,-1
      endcase
   1: begin 
         box_message,'single not yet supported
      endcase
   2: begin
        box_message,'2 image case'
        if despikes then $
           for i=0,1 do data(0,0,i)=nospike(data(*,*,i),/flare)
        nofill=nofill or max(data(*,*,0)) lt 1
        if not keyword_set(nofill) then begin 
            ssm=where(data le 0,mcnt)
            if mcnt gt 0 then begin 
               data(ssm)=0
               ssw_fill_cube,data
            endif
        endif
        difference_movie,index,data,oindex,odata
        ldata=bytscl(smooth(odata,smooth_width)) * $
             solar_mask(oindex,odata,pad=limb_pad)
        if dark_flare then begin 
           ss0=where(ldata eq 0,sscnt)
           if sscnt gt 0 then ldata(ss0)=max(ldata)
        endif
        ss=where(ldata eq call_function((['max','min'])(dark_flare),ldata))
        xyp=coord_l2v(ss,size(ldata))
        oindex=struct2ssw(oindex)
        flrx=comp_fits_crval(oindex.xcen,oindex.cdelt1,oindex.naxis1,xyp(0))
        flry=comp_fits_crval(oindex.ycen,oindex.cdelt2,oindex.naxis2,xyp(1))
help,flrx,flry
      endcase
   else: begin
      box_message,'more than 2 image case...
   endcase
endcase 

retval=-1
if n_elements(flrx) gt 0 then begin 
   retval=[flrx,flry]
   flare_helio=arcmin2hel(flrx/60.,flry/60.,$
          date=anytim(oindex.date_obs,/utc_int),$
          soho=strupcase(gt_tagval(oindex,/TELESCOP)) eq 'SOHO')
   chkfin=where(1-finite(flare_helio),icnt)
   if icnt gt 0 then $
      flare_helio=reverse(conv_a2h([flrx,flry],anytim(oindex.date_obs,/int)))
   if keyword_set(helio) then retval=flare_helio
endif

return,retval
end
