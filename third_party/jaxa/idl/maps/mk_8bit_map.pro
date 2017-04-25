;+
; Project     : RHESSI
;
; Name        : MK_8BIT_MAP
;
; Purpose     : Convert TrueColor map to 8-bit map
;
; Category    : imaging
;
; Syntax      : omap=mk_8bit_map
;
; Inputs      : MAP = TrueColor map
;
; Outputs     : OMAP= map with RGB color arrays appended as fields
;
; Keywords    : NO_COPY = throw away original map.
;
; Written     : 19-January-2016, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_8bit_map,map,err=err,_extra=extra,no_copy=no_copy

err=''
if ~valid_map(map,err=err) then return,null()
if ~color_map(map,true_index=true_index,err=err) then return,null()
if true_index lt 1 then begin
 err='Input map not a TrueColor map.'
 mprint,err
 return,null()
endif

if keyword_set(no_copy) then omap=temporary(map) else omap=map
eight_bit=mk_8bit(omap.data,red,green,blue,_extra=extra,err=err)
if is_string(err) then return,null()
omap=rep_tag_value(omap,eight_bit,'data',/no_copy)
omap=rep_tag_value(omap,red,'red',/no_copy)
omap=rep_tag_value(omap,green,'green',/no_copy)
omap=rep_tag_value(omap,blue,'blue',/no_copy)

return,omap
end
