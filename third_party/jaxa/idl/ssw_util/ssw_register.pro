pro ssw_register, index, data, oindex, odata, ref_index=ref_index, $
                   ref_map=ref_map, derotate=derotate, drotate=drotate,$
                   clobber=clobber, correl=correl, roll=roll, $
                   offsets=offsets, _extra=_extra
;+
;   Name: ssw_register
;
;   Purpose: co-register 'index,data' pairs using mapping driver, opt w/drotate
;
;   Input Parameters:
;      index, data - index,data pairs containing SSW standards
;
;   Output Parameters:
;      oindex - output index of registered images (ssw tags adjusted)
;      odata  - co-registered data cube
;
;   Keyword Parameters:
;      derotate / drotate (synonyms) - if set, included solar diff rot
;      ref_index - optional reference index (structure or SS pointer)
;      ref_map   - optional reference 'map' (per D.M.Zarro et al package)
;      correl    - if set, apply correlation after keyword alignment
;      roll      - if set, roll to this angle prior to alignment
;      offsets   - (output) - dervied offsets if /CORREL is set
;      _extra - passed to coreg_map.pro  -> drot_map
; 
;   History:
;      21-August-2000 - S.L.Freeland
;       5-feb-2003 - S.L.Freeland - added /CORREL, tweaked a little
;                    track some registration & correlation in .HISTORY
;      17-oct-2008 - S.L.Freeland - restore dropped tags index->oindex
;      18-dec-2008 - S.L.Freeland - add Oxcen,Oycen,Ocrpix1,Ocrpix2 (original)
;      19-dec-2008 - S.L.Freeland - add VERSION 1.0 -> update_history
;
;   Method:
;     index,data -> maps -> coreg_map -> oindex,odata
;
;   Calling Sequence:
;      IDL> ssw_register,index,data,oindex,odata [,/correl] [,roll=0]
;
;   Calls:
;      index2map, coreg_map (via drot_map et al), map2index,$
;         drot_map, align_cube_correl, update_history
;+

version=1.0 ; slf, 19-dec-2008

nind=n_elements(index)
nimg=data_chk(data,/nim)
drotate=keyword_set(drotate) or keyword_set(derotate)     ; synonyms

if nind ne nimg or 1-data_chk(index,/struct) then begin 
   box_message,'Required "index,data" pairs
   return
endif

index2map,index,data,maps,inherit=index
if not tag_exist(maps,'index') then maps=add_tag(maps,index,'index')
if get_logenv('check_reg') then stop,'maps

case 1 of 
   data_chk(ref_map,/struct):  
   data_chk(ref_index,/struct): refss=tim2dset(index,ref_index) 
   is_number(ref_index): refss=ref_index
   else: refss=nind/2                        ; ~ midpoint 
endcase

if n_elements(refss) gt 0 then $
   index2map,index(refss), data(*,*,refss), ref_map

;if n_elements(roll) ne 0 then ref_map=drot_map(ref_map,0,roll=roll)

comaps=coreg_map(maps,ref_map,drotate=drotate,_extra=_extra)
if get_logenv('chkreg') ne '' then stop,'compas'
if n_elements(roll) gt 0 then comaps=rot_map(comaps,-1*ref_map.roll_angle)

map2index,comaps,oindex,odata


fundsub=str2arr('crpix1,crpix2,xcen,ycen,history,crota,crota1,crota2')
oii=str_subset(oindex,fundsub)
oindex=join_struct(str_subset(index,fundsub,/exclude),oii)
; update some history
update_history,oindex,'Reference Image: ' + ref_map.time
update_history,oindex,'Orig XCEN,YCEN,CROTA: ' + $
       get_infox(index,'xcen,ycen,crota'),/mode
;
; add tags for Original Ocrpix1,crpix2,xcen&ycen
wtags=str2arr('crpix1,crpix2,xcen,ycen') ; list of O(riginal) tags to add
for i=0,n_elements(wtags)-1 do begin
   oval=gt_tagval(index,wtags(i)) ; Original (unregistered) value 
   oindex=add_tag(temporary(oindex),oval,'o'+wtags(i))
endfor

if keyword_set(correl) then begin
   align_cube_correl,oindex,odata, $
      reference=tim2dset(oindex,ref_map.time), offsets=offsets
   update_history,oindex,'Correl Offsets X,Y: ' + $
      string(offsets,format='(2f10.5)'),/mode
endif

update_history,oindex,/caller,version=version

return
end

