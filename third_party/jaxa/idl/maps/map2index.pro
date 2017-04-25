

pro map2index, map, index, data, err=err, debug=debug
;+
;   Name: map2index
;
;   Purpose: convert D.M.Zarro map object(s) to "standard index,data"
;
;   Input Parameters:
;      map   - an image map or map array
;      index (optional) - the original index record (will be updated) 
;      Note: if MAP includes INDEX property, that is used preferentially 
;  
;   Output Parameters:
;     index - IDL structure(s) with "standard" tags derived from map
;             If map.INDEX exists, that is starting template
;             ELSE if INDEX is INPUT, that is starting template
;             ELSE ssw standard structure template is used
;  
;     data  - 2D or 3D MAP data array(s)
; 
;   Calling Sequence:
;      IDL> map2index, map,    index     , data
;                      IN ,    IN/OUT    , OUT
;                            (opt.inp)
;   Context Sequence Example:
;      IDL> mreadfits, <files> , index, data         ; files->index,data   
;      IDL> [optional data scaling/processing]       ; whatever...
;      IDL> index2map, index, data, maps             ; index,data->maps
;      IDL> [map manip;  drot_map, sub_map...]       ; mapping SW
;      IDL> map2indx, newmaps,(new)index,newdata     ; newmaps->index,data 
;      IDL> mwritefits, newindex, newdata            ; index,data->files
;      Note: mreadfits may be replaced by 'read_xxx'
;  
;   History:
;      9-April-1998 - S.L.Freeland using struct2ssw & D.M. Zarro unpack_map 
;      3-March-2000 - S.L.Freeland - revised (made it work!)
;                     Use XCEN/YCEN centric and call to struct2ssw
;      4-March-2000 - S.L.Freeland - cont. 3-mar enhancments
;                     add CROTA and (opt CROTACEN if it exists)
;      18-Dec-2002 - Zarro (EER/GSFC), changed ROLL -> ROLL_ANGLE and
;                    converted some execute statements
;      12-Jan-2009 - Zarro (ADNET) - added CROTACN1,2
;      21-Sep-2010 - Zarro (ADNET) - added check for CROTA in INDEX
;
;   Side Effects:
;      If INDEX is defined on INPUT , it is assumed to contain
;      the original INDEX - Fields associated with the input MAP
;      will be updated (clobbered if you want to put it that way)
;      to reflect rotation, pointing, time, binning map changes.
;
;      In conjunction with 'index2map.pro', this rotuine permits:
;       index,data(original) ->  map(manipulations)   -> index,data(new)
;       -> map via index2map -> [drot_map/sub_map...] -> via map2index
;-

debug=keyword_set(debug)
err=''

if (not valid_map(map)) then begin
  pr_syntax,'map2index, map, index, data'
  return
endif

np=n_elements(map)

; expect original index saved as property-if not, use SSW standard template 
mindex=gt_tagval(map,/index,missing=0)
case 1 of
   data_chk(mindex,/struct): index=mindex     ; use MAP.INDEX (property)
   data_chk(index,/struct):                   ; use INDEX input parameter
   else: index=sswfits_struct(np,/addfits)    ; else use dummy template
endcase   
index=struct2ssw(index, /addfits)             ; assure all tags available

;------ init output DATA ; use first map.data as template ------------ 
sdata0=gt_tagval(map[0],/data)
data=make_array(data_chk(sdata0,/nx),data_chk(sdata0,/ny),np,/nozero,$
                type=data_chk(sdata0,/type))

; --------------------------------------------------------------------
; do some vector map->index structure filling (outside of per map loop)
index.ctype1= 'solar_x'
index.ctype2= 'solar_y'
units1= gt_tagval(map,/units,missing='arcsecs')
units2= gt_tagval(map,/units,missing='arcsecs')
if tag_exist(index,'cunit1') then index.cunit1 =units1 ; else add_tag?
if tag_exist(index,'cunit2') then index.cunit2 =units2 ; else add_tag?
naxis1=data_chk(gt_tagval(map,/data),/nx)
naxis2=data_chk(gt_tagval(map,/data),/ny)
if tag_exist(index,'crota') then index.crota=map.roll_angle
if tag_exist(index,'crota1') then index.crota1=map.roll_angle
if tag_exist(index,'crota2') then index.crota2=map.roll_angle
if tag_exist(index,'crotacn1') then index.crotacn1=comdim2(map.roll_center[0,*])
if tag_exist(index,'crotacn2') then index.crotacn2=comdim2(map.roll_center[1,*])
index.naxis1=naxis1
index.naxis2=naxis2
; -----------------------------------------------------------------
; -----------------------------------------------------------------
index.crval1= 0                 ; will use (X/Y)CEN & CRPIX(1/2) convention
index.crval2= 0
; -----------------------------------------------------------------
; -------- map times -> index (CCSDS) ----------------------------
index.time=0                                         ; init
index.mjd=0                                          ; init
index.day=0                                          ; init
index.date_obs=anytim(gt_tagval(map,/time),/ccsds)   ; map times -> index
index=struct2ssw(index,/nopoint,/nosolar)            ; rationalize time tags
; -----------------------------------------------------------------

if tag_exist(map,'dur') then begin
   synonyms=str2arr('exptime,expdur,shut_mdur')      ; "standards..."
   for i=0,n_elements(synonyms)-1 do begin
    if tag_exist(index,synonyms[i],index=k) then begin
     index.(k)=map.dur
     break
    endif
   endfor 
endif

if tag_exist(map,'id') then index.origin=map.id

if tag_exist(map,'soho') then index.telescop=(['','SOHO'])(map.soho)

for i=0,np-1 do begin 
;    ----------- unpack data --------
     unpack_map,map[i],mdata,xp,yp,$                 ; call D.M.Zarro routine
        dx=cdelt1,dy=cdelt2,xc=xcen,yc=ycen,err=err  ; (XCEN/YCEN/CDELTn)
     index[i].xcen=xcen
     index[i].ycen=ycen
     index[i].cdelt1=cdelt1
     index[i].cdelt2=cdelt2
     index[i].crpix1=comp_fits_crpix(xcen,cdelt1,naxis1,0.)
     index[i].crpix2=comp_fits_crpix(ycen,cdelt2,naxis2,0.)
     if tag_exist(index,'CROTACEN') then index[i].crotacen=map[i].roll_center
     data(0,0,i)=temporary(mdata)                ; insert 2D->3D
endfor

if debug then stop, 'before exit'
return
end
