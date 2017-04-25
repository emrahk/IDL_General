;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_TIME
;
; Purpose     : extract map time
;
; Category    : imaging
;
; Syntax      : time=get_map_time(map)
;
; Inputs      : MAP = image map
;
; Outputs     : TIME = map time in UTC units
;
; Keywords    : ERR = error string
;               TAI = set for TAI format
;               ORIGINAL = set to always return original time (not rotated)
;
; History     : Written 16 Aug 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_time,map,err=err,tai=tai,original=original

err=''
tai=keyword_set(tai)
original=keyword_set(original)

if ~valid_map(map,err=err) then begin
 err=''
 if tai then time=anytim2tai(map,err=err) else time=anytim2utc(map,err=err,/vms)
 if err ne '' then begin
  pr_syntax,'time=get_map_time(map)'
  return,-1
 endif else return,time
endif


have_rtime=0b
if tag_exist(map,'rtime') then have_rtime=valid_time(map[0].rtime)

if (tai) then begin
 if original or ~have_rtime then return,anytim2tai(map.time,err=err) else $
  return,anytim2tai(map.rtime,err=err)
endif

if original or ~have_rtime then return, anytim2utc(map.time,/vms,err=err) else $
 return,anytim2utc(map.rtime,/vms,err=err) 

end



