;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_COORD
;
; Purpose     : extract map coordinates
;
; Category    : imaging
;
; Syntax      : IDL> get_map_coord,map,xp,yp
;
; Inputs      : MAP = image map
;
; Outputs     : XP, YP = coordinate arrays
;
; Keywords    : ERR = error string
;               ORIGINAL = original coordinates (if map is rotated)
;
; History     : Written 12 November 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro get_map_coord,map,xp,yp,err=err,original=original,_ref_extra=extra

err=''
if ~valid_map(map,err=err) then begin
 message,err,/cont
 return
endif

if ~keyword_set(original) then begin
 if arg_present(xp) then xp=get_map_xp(map)
 if arg_present(yp) then yp=get_map_yp(map)
 return
endif

if ~have_tag(map,'rtime') then begin
 message,'input map does not seem to be differentially rotated',/cont
 return
endif

otime=get_map_time(map,/original)
void=drot_map(map,time=otime,xp=xp,yp=yp,/no_data,err=err,_extra=extra)
return
end

