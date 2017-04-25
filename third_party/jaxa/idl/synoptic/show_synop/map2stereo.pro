;+
; Project     : STEREO
;
; Name        : map2stereo
;
; Purpose     : Project an image map to STEREO view
;
; Category    : imaging, maps
;
; Syntax      : IDL> smap=map2stereo(map)
;
; Inputs      : MAP = image map structure
;               TIME = UT time of STEREO image to project map to, 
;                      or a STEREO map structure
;
; Outputs     : SMAP = map projected to STEREO view
;
; Keywords    : /AHEAD for STEREO A, /BEHIND for STEREO B
;
; History     : Written 4 October 2007 - Zarro (ADNET)
;               Modified 12 November 2014 - Zarro (ADNET)
;               - ensured that map center mapped correctly.
;
; Contact     : dzarro@solar.stanford.edu
;-

function map2stereo,map,time,ahead=ahead,behind=behind,_extra=extra,err=err

err=''

;-- validate inputs

if ~valid_map(map,err=err) then begin
 pr_syntax,'smap=map2stereo(map,time)'
 return,-1
endif

;-- sort out times

mtime=get_map_time(map,/tai)
case 1 of
 valid_time(time): proj_time=anytim2tai(time)
 valid_map(time) : proj_time=get_map_time(time,/tai)
 else: proj_time=mtime
endcase

;-- check if STEREO map entered

if valid_map(time) then begin
 spacecraft=''
 if stregex(time.id,'STEREO[-|_]A',/bool,/fold) then spacecraft='A'
 if stregex(time.id,'STEREO[-|_]B',/bool,/fold) then spacecraft='B'
 if is_blank(spacecraft) then begin
  err='Input map not a STEREO map'
  message,err,/cont
  return,map
 endif
 angles=get_map_angles(time)
 b0=angles.b0
 l0=angles.l0
 rsun=angles.rsun
 roll=time.roll_angle
 rcenter=time.roll_center
 center=[time.xc,time.yc]
endif else begin
 spacecraft='A'
 if keyword_set(behind) then spacecraft='B' 
 temp=pb0r_stereo(proj_time,stereo=spacecraft,roll=roll,l0=l0,err=err,/arcsec)
 if is_string(err) then return,map
 b0=temp[1] & rsun=temp[2]
endelse

;-- do the reprojecting

interval=proj_time-mtime
smap=drot_map(map,interval,b0=b0,l0=l0,rsun=rsun,roll=roll,$
              center=center,rcenter=rcenter,_extra=extra,err=err,/sec)

return,smap
end

