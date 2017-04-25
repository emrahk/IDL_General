;+
; Project     : SOHO-CDS
;
; Name        : DROT_MAP_FAST
;
; Purpose     : fast version of DROT_MAP
;
; Category    : imaging
;
; Explanation : Just rotates central coordinates of map
;
; Syntax      : rmap=drot_map_fast(map,duration,time=time)
;
; Inputs      : MAP = map structure
;               DURATION = amount to rotate by [hours units]
;
; Outputs     : RMAP = map with rotated coordinates
;
; Keywords    : DAYS = duration units in days
;             : SECONDS = duration units in seconds
;               NO_RTIME = don't add RTIME property
;               REF_MAP = project to REF_MAP time and angles
;
; History     : Written 5 June 1998, D. Zarro, SAC/GSFC
;               Modified 22 Feb 2000, Zarro (SM&A/GSFC) 
;                - adjust for roll before drotating
;               7 December 2014, Zarro (ADNET)
;                - pass map angular information into rot_xy
;                  to allow for arbitrary positioned spacecraft
;                  (e.g. STEREO)
;               10 December 2014, Zarro (ADNET)
;                - added REF_MAP
;               24 November 2015, Zarro (ADNET)
;                - changed CENTER to RCENTER to avoid clash with image
;                  center
;
; Contact     : dzarro@solar.stanford.edu
;-

function drot_map_fast,map,duration,_extra=extra,err=err,$
                       ref_map=ref_map,no_rtime=no_rtime

err=''

;--check inputs

if ~valid_map(map,err=err) then begin
 pr_syntax,'rmap=drot_map_fast(map,duration,[time=time])'
 if exist(map) then return,map else return,-1
endif

;-- get solar rotation duration

dtime=get_drot_dur(map,duration,_extra=extra,time=ref_map)
cur_time=get_map_time(map,/tai)
ntime=n_elements(dtime)
nmap=n_elements(map)
have_rtime=tag_exist(map,'rtime')
have_roll=tag_exist(map,'roll_angle')
if valid_map(ref_map) then vend=get_map_angles(ref_map)

for i=0,nmap-1 do begin

 cdur=dtime(i < (ntime-1))
 dprint,'% duration (sec): ',cdur
 new_time=cur_time[i]+cdur
 tmap=map[i]

;-- get center of map

 xc=tmap.xc
 yc=tmap.yc
 vstart=get_map_angles(tmap)
 radius=vstart.rsun

;-- if not on disk then don't drotate

 on_disk=sqrt(xc^2+yc^2) lt radius
 
 if on_disk then begin
  corr_roll=0b
  if have_roll then corr_roll=(tmap.roll_angle mod 360.) ne 0.
  if corr_roll then roll_xy,xc,yc,-tmap.roll_angle,rcenter=tmap.roll_center,xc,yc
  rcor=rot_xy(xc,yc,tstart=cur_time[i],tend=new_time,vstart=vstart,vend=vend,/sphere)
  rcor=reform(rcor)
  xc=rcor[0] & yc=rcor[1]
  still_on_disk=sqrt(xc^2+yc^2) le radius

;-- if still on disk then update map. 

  if still_on_disk then begin
   if corr_roll then roll_xy,xc,yc,tmap.roll_angle,rcenter=tmap.roll_center,xc,yc
   tmap.xc=xc
   tmap.yc=yc
  endif
 endif

 if ~have_rtime and ~keyword_set(no_rtime) then tmap=add_tag(tmap,anytim2utc(new_time,/vms),'rtime')
 rmap=merge_struct(rmap,tmap,/no_copy)
endfor

return,rmap

end
