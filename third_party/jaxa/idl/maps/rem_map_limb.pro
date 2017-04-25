;+
; Project     : SOHO-CDS
;
; Name        : REM_MAP_LIMB
;
; Purpose     : remove above limb pixels from a map
;
; Category    : imaging
;
; Explanation : 
;
; Syntax      : rmap=rem_map_limb(map)
;
; Examples    :
;
; Inputs      : MAP = image map
;
; Opt. Inputs : None
;
; Outputs     : RMAP = MAP with above limb points set to zero
;
; Opt. Outputs: None
;
; Keywords    : ERR = error string
;               MISSING = values to set deleted data
;               DISK = remove on disk pixels instead
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Written 26 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function rem_map_limb,map,disk=disk,missing=missing

on_error,1

if not valid_map(map) then begin
 pr_syntax,'nmap=remove_limb(map)'
 if exist(map) then return,map else return,-1
endif

rmap=map
if not exist(missing) then missing=0.
if tag_exist(map,'soho') then soho=map.soho else soho=0
val =pb0r(get_map_time(map), soho=soho, error=error,/arcsec)
radius = val(2)

xp=get_map_xp(map)
yp=get_map_yp(map)
if keyword_set(disk) then oper='le' else oper='gt'
s=execute('off_limb=where(xp^2+yp^2 '+oper+' radius^2,count)')
if count gt 0 then rmap.data(off_limb)=missing

return,rmap & end
