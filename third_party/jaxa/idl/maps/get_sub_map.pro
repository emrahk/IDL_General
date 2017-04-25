;+
; Project     : SOHO-CDS
;
; Name        : GET_SUB_MAP
;
; Purpose     : function wrapper around SUB_MAP
;
; Category    : imaging
;
; Syntax      : smap=get_sub_map(map)
;
; Inputs      : MAP = map structure created by MAKE_MAP
;
; Outputs     : SMAP = subimage of map
;
; Keywords    : see SUB_MAP
;
; History     : Written 8 November 2002, Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_sub_map,map,_ref_extra=extra

sub_map,map,smap,_extra=extra

return,smap

end


