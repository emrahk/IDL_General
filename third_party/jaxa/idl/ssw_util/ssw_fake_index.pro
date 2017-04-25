pro ssw_fake_index, date_obs, index, data, indata=indata, $ 
;           date_obs=date_obs,                            $  
            ns_helio=ns_helio, ew_helio=ew_helio,         $
            xcen=xcen, ycen=ycen,                         $
            cdelt1=cdelt1,  cdelt2=cdelt2, nx=nx, ny=ny,  $
            soho=soho, l1=l1   , helio=helio, fov_as=fov_as, $
            gui_ref=gui_ref, _extra=_extra
;
;+
;   Name: ssw_fake_index
;
;   Purpose: generate 'fake' index,data from coords + time + FOV info   
;
;   Input Parameters:
;      date_obs - vector of desired index times, any SSW format 
;
;   Output Parameters: 
;      index, [data], - derived index,data with fields filled in
;
;   Keyword Parameters:
;      ns_helio - desired NS heliographic coords (hel2arcmin convention)
;      ew_helio - desired EW heliographic coords (hel2arcmin convention)
;      xamin    - EW heliocentric (arcmin2hel convention)
;      yamin    - NS heliocentric (arcmin2hel convention)
;      xcen     - EW heliocentric per www.lmsal.com/ssw_standards.html conven
;      ycen     - NS heliocentric per www.lmsal.com/ssw_standards.html conven
;      cdelt1   - arcsec/EW pixel 
;      cdelt2   - arcsec/NS pixel (default to cdelt1)
;      nx, naxis1 - (synonyms) #EW pixels
;      ny, naxis2 - (synonyms) #NS pixels 
;      indata (IN) - if supplied, use this data instead of dummy data
;                    (naxis1/nx & naxis2/ny are inherited from this if supplied)
;      soho,l1 (synonyms) - use L1/SoHO perspective for coordinate conversions
;      fov_as - desired field of view in arcseconds (synonym for cdelt&NX,NY) 
;      gui_ref - (from plot_map WWW gui javascript)
;      extra - inheritance -> struct2ssw
;      
;    Method:
;       fill in a few fundamental fields, then call struct2ssw

if data_chk(gui_ref,/string,/scalar) then begin 
   box_message,'Assuming input from www plot_map gui service...'
   fields=ssw_strsplit(str2arr(gui_ref),'=',/tail)
   if n_elements(fields) lt 5 then begin 
     box_message,'Unexpected value of GUI_REF, returing...
     return
   endif
   xycorn=float(fields(0:3)) ; x1,y1,x2,y2
   fov_as=[ xycorn(2)-xycorn(0), xycorn(1) - xycorn(3)]
   xcen=xycorn(0) + (.5*fov_as(0))
   ycen=xycorn(3) + (.5*fov_as(1))
   imgtime=last_nelem(fields)
   if strlen(imgtime) eq 18 then $
      imgtime=strmid(imgtime,0,10) + ' ' + strmid(imgtime,10,8)
   date_obs=anytim(imgtime,/ccsds)
   cdelt1=1
endif 
if n_elements(date_obs) eq 0 then begin 
   box_message,'You need at least a vector of desired times...'
   return
endif
nout=n_elements(date_obs)
case 1 of 
   required_tags(date_obs,'date_obs,naxis1,cdelt1,xcen,ycen'): index=date_obs
   else: index=sswfits_struct(nout,/addfits)
endcase

index.date_obs=anytim(date_obs,/ccsds)        ;  anything->CCSDS
index.naxis=2                                 ; only images for now 
case n_elements(fov_as) of
   0:
   else: begin 
      if n_elements(fov_as) eq 1 then xyfov=replicate(fov_as,2) else $
         xyfov=fov_as(0:1)
      if n_elements(cdelt1) eq 0 then cdelt1=.5
      if n_elements(cdelt2) eq 0 then cdelt2=cdelt1 
      nx=xyfov(0)/cdelt1
      ny=xyfov(1)/cdelt2
   endcase
endcase 

; check for pixel size
case 1 of 
   n_elements(cdelt1) eq 1 or n_elements(cdelt1) eq nout: $
      index.cdelt1=cdelt1
   index.cdelt1 ne 0:                                       ; supplied
   else: begin 
      box_message,'You must supply CDELT1   
      return
   endcase
endcase

case 1 of 
   n_elements(cdelt2) ne 0: index.cdelt2=cdelt1
   else: index.cdelt2=cdelt1
endcase
 

if data_chk(indata,/nimage) eq nout then data=indata  else begin 
   case 1 of 
      n_elements(nx) ne 0:
      n_elements(naxis1): nx=naxis1(0)
      else: begin 
         box_message,'You must supply at least NX/NAXIS1
         return
      endcase
   endcase
   case 1 of
      n_elements(ny) ne 0:
      n_elements(naxis2) ne 0: ny=naxis2(0)
      else:ny=nx(0)                             ; default to square
   endcase
   data=make_array(nx(0),ny(0),nout,/byte)
endelse

index.naxis1=data_chk(data,/nx)               ; fill naxis1/naxis2
index.naxis2=data_chk(data,/ny)

if data_chk(helio,/string) then begin         ; expect string  N05E90 ...
   fhelio=ssw_helio2string(helio,/string2)
   ns_helio=fhelio(0)
   ew_helio=fhelio(1) 
endif     
 
case 1 of 
   n_elements(xcen) eq 1 or n_elements(xcen) eq nout:
   n_elements(xamin) eq 1 or n_elements(xamin) eq nout: xcen=xamin/60.
   n_elements(ew_helio) eq nout and n_elements(ns_helio) eq nout: begin 
      xcen=fltarr(nout)
      ycen=fltarr(nout)
      for i=0,nout-1 do begin 
         xy=hel2arcmin(ns_helio(i),ew_helio(i),date=anytim(index(i).date_obs,/utc_int),$
           soho=keyword_set(l1) or keyword_set(soho))
         xcen(i)=xy(0)*60.
         ycen(i)=xy(1)*60.
      endfor
    endcase
    else: begin 
       box_message,'Need XCEN/YCEN -or- XAMIN/YAMIN -or- EW_HELIO/NS_HELIO'
       return
    endcase
endcase

index.xcen=xcen
index.ycen=ycen 

index=struct2ssw(index,_extra=_extra)           ; populate missing fields

return
end
 
