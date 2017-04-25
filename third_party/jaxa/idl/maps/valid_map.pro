;+
; Project     : SOHO-CDS
;
; Name        : VALID_MAP
;
; Purpose     : check if input image map is of valid type
;
; Category    : imaging
;
; Syntax      : valid=valid_map(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : VALID = 1/0 if valid/invalid
;
; Keywords    : OLD_FORMAT = 1/0 if using old .xp, .yp format or not
;
; History     : Written 22 October 1997, D. Zarro, SAC/GSFC
;               13 July 2009, Zarro (ADNET)
;                - added checks for minimum required map tags
;               23 December 2010, Zarro (ADNET)
;                - added HAVE_COLORS output keyword
;               20 April 2015, Zarro (ADNET)
;                - add TRUE_COLOR keyword
;               30 August 2015, Zarro (ADNET)
;                - Removed COLOR keywords
;
; Contact     : dzarro@solar.stanford.edu
;-

function valid_map,map,err=err,old_format=old_format,_extra=extra

err='Missing or invalid input map.'

error=0
catch,error
if error ne 0 then begin
 message,err,/cont
 return,0b
endif

;-- check if true MAP object (IDL > 5)

sz=size(map)
dtype=sz[n_elements(sz)-2]
if dtype eq 11 then begin
 if ~call_function('obj_valid',map[0]) then return,0b
 valid=valid_map(map[0]->get(/map),old_format=old_format)
 return,valid
endif

;-- otherwise check for required tags

if dtype ne 8 then return,0b
if ~tag_exist(map,'DATA') then return,0b
if ~tag_exist(map,'TIME') then return,0b
if ~tag_exist(map,'ID') then return,0b
;if ~tag_exist(map,'ROLL_ANGLE') then return,0b
;if ~tag_exist(map,'ROLL_CENTER') then return,0b

old_format=tag_exist(map,'xp') and tag_exist(map,'yp')
if ~old_format then begin
 if ~tag_exist(map,'XC') then return,0b
 if ~tag_exist(map,'YC') then return,0b
 if ~tag_exist(map,'DX') then return,0b
 if ~tag_exist(map,'DY') then return,0b
endif

;-- if we made it here then we're ok

err=''
return,1b & end

