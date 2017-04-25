;+
; Project     : STEREO
;
; Name        : GET_MAP_ANGLES
;
; Purpose     : return spacecraft-dependent coordinate transformation
;                angles for a map
;
; Category    : imaging, maps
;
; Syntax      : IDL> angles=get_map_angles(map)
;
; Inputs      : MAP = map structure or MAP ID and time
;
; Outputs     : ANGLES = {l0,b0,roll_angle,rsun}
;
; Keywords    : NO_ROLL_ANGLE = set to not include roll angle
;
; History     : Written 6 September 2008 - Zarro (ADNET)
;               Modified 21 July 2009, Zarro (ADNET)
;                - added check for whether SOHO map has already been corrected
;                  to Earth-view.
;               4 December 2014, Zarro (ADNET)
;                - added check for missing or zero RSUN field
;               24 December 2014, Zarro (ADNET)
;                - added check for COR 1 & 2
;               17 January 2015, Zarro (ADNET)
;                -added check SOHO instrument names in MAP ID
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_angles,map,time,use_ephemeris=use_ephemeris,ephemeris=ephemeris,$
                no_roll_angle=no_roll_angle,_ref_extra=extra,verbose=verbose


angles={l0:0.d0,b0:0.d0,roll_angle:0.d0,rsun:960.d0}
return_roll=~keyword_set(no_roll_angle) 
if ~return_roll then angles=rem_tag(angles,'roll_angle')

id=''
map_input=valid_map(map) 
time_input=valid_time(map)
id_input=is_string(map,/blank) && valid_time(time) 

if ~map_input && ~id_input && ~time_input then return,angles

;-- if map already has one of these angles, then use them

soho=0b
case 1 of
 map_input: begin
  id=map.id & mtime=get_map_time(map)
 end
 id_input: begin
  id=map & mtime=time
 end
 else: mtime=map
endcase

;-- check for valid RSUN field

have_angles=0b
if map_input then begin
 have_angles=have_tag(map,'l0') && have_tag(map,'b0') && have_tag(map,'rsun')
 if have_angles && have_tag(map,'rsun') then have_angles=map.rsun gt 0.
endif

;-- if SOHO, have to check whether image was previously remapped to Earth-view.

use_ephemeris=keyword_set(use_ephemeris) || keyword_set(ephemeris)
soho_id=stregex(id,'(SOHO|CDS|SUMER|EIT|LASCO)',/bool,/fold) 
if map_input then begin
 struct_assign,map,angles
 if have_tag(map,'soho') then soho=map.soho else soho=0b
 if soho_id && ~soho then use_ephemeris=1b
endif

if ~use_ephemeris && have_angles then return,angles

;-- check if SOHO or STEREO
 
stereo=0b
stereo_a=stregex(id,'STEREO[_|-]?A',/bool,/fold)
stereo_b=stregex(id,'STEREO[_|-]?B',/bool,/fold)
if stereo_a then stereo='A'
if stereo_b then stereo='B'

if is_string(stereo) then begin
 cor1=stregex(id,' +COR1 +',/bool,/fold)
 cor2=stregex(id,' +COR2 +',/bool,/fold)
endif

verbose=keyword_set(verbose)
if verbose then begin
 if soho then message,'Checking SOHO ephemeris..',/cont else $
  message,'Checking ephemeris..',/cont 
 if is_string(stereo) then message,'Checking STEREO ephemeris..',/cont
endif

temp=pb0r(mtime,l0=l0,/arcsec,soho=soho,stereo=stereo,roll=roll,$
          _extra=extra,verbose=verbose,cor1=cor1,cor2=cor2)
angles.l0=l0
angles.b0=temp[1]
angles.rsun=temp[2]
if is_string(stereo) && return_roll then angles.roll_angle=roll

return,angles
end
