;+
; Project     : SOHO-CDS
;
; Name        : MEAN_MAP
;
; Purpose     : Compute mean value in vicinity of pixels
;
; Category    : imaging
;
; Explanation : Points nearest input coordinates are averaged
;
; Syntax      : mean=mean_map(map,xc,yc)
;
; Examples    :
;
; Inputs      : MAP = map structure 
;               XC,YC = coordinate arrays of pixels
;
; Opt. Inputs : None
;
; Outputs     : MEAN = mean value
;
; Opt. Outputs: 
;
; Keywords    : TAG_ID = tag name or index to use
;               AREA = if set, average over total area bounded by (xc,yc)
;               TROTATE = rotate map coords to reference time before
;                         averaging
;               SHIFT = [x,y] offsets to apply to coordinates (after rotation)
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 22 Jan 1997, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function mean_map,map,xc,yc,tag_id=tag_id,area=area,found=found,$
             trotate=trotate,keep=keep,centroid=centroid,shift=shift_val

on_error,1

if (not valid_map(map)) or (not exist(xc)) or (not exist(yc)) then begin
 pr_syntax,'mean=mean_map(map,xc,yc)'
 return,-1
endif

err=''
unpack_map,map,data,xp,yp,err=err,tag_id=tag_id,centroid=centroid
if err ne '' then return,-1

;-- rotate data coordinates?

if valid_map(trotate) then tref=get_map_time(trotate) else $
 tref=anytim2tai(trotate,err=err)
if err eq '' then begin
 tend=get_map_time(map)
 if tag_exist(map,'soho') then soho=map.soho else soho=0
 rcor=rot_xy(xc,yc,tstart=tref,tend=tend,soho=soho,keep=keep)
 xr=rcor(*,0)
 yr=rcor(*,1)
;stop,1
endif else begin
 xr=xc & yr=yc
endelse 

;-- shift coordinates?

if n_elements(shift_val) eq 2 then begin
 xr=xr+shift_val(0)
 xy=xr+shift_val(1)
endif

;-- average points within area bounded by (xr,yr)

if keyword_set(area) then begin
 ok=where( (xp ge min(xr)) and (xp le max(xr)) and (yp ge min(yr)) and $
           (yp le max(yr)),count)
 if count eq 0 then begin
  message,'no data within specified coordinates',/cont
  return,-1
 endif
 sorder=uniq([ok],sort([ok]))
 found=data(ok)

;-- otherwise average over nearest pixels

endif else begin
 delvarx,found,findex
 s=float(size(xp))
 nx=s(1) & ny=s(2)
 for j=0,n_elements(xr)-1 do begin
  diffx=abs(xp-xr(j))
  diffy=abs(yp-yr(j))
  rad=sqrt(diffx^2+diffy^2)
  nearest=where(min(rad) eq rad,cnt)
  if exist(found) then found=[found,data(nearest)] else found=data(nearest)
  if exist(findex) then findex=[findex,nearest] else findex=nearest
 endfor
 sorder=uniq([findex],sort([findex]))
 found=found(sorder)
endelse

return,total(found)/n_elements(found)

end
