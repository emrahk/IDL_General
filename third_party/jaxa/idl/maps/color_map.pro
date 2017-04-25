;+
; Project     : RHESSI
;
; Name        : COLOR_MAP
;
; Purpose     : check if input image map has valid color table vectors
;
; Category    : imaging
;
; Syntax      : valid=color_map(map)
;
; Inputs      : MAP = image map structure
;
; Outputs     : VALID = 1/0 if valid/invalid
;
; Keywords    : TRUE_COLOR = 1,2,3 if map has interleaved color images (0 if not)
;
; History     : 30 August 2015 - written, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function color_map,map,true_index=true_index,err=err

err=''
true_index=0
if ~valid_map(map,err=err) then return,0b
have_colors=tag_exist(map,'red')*tag_exist(map,'green')*tag_exist(map,'blue')

if have_colors then return,valid_colors(map.red,map.green,map.blue)
return,is_truecolor(map.data,true_index=true_index,err=err)

end
