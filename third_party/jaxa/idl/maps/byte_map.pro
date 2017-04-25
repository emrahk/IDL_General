;+
; Project     : Hinode/EIS
;
; Name        : BYTE_MAP
;
; Purpose     : Bytescale a map
;
; Category    : imaging
;
; Syntax      : bmap=byte_map(map)
;
; Inputs      : MAP = map to bytescale
;
; Outputs     : BMAP = bytescaled map
;
; Keywords    : ERR = error strings
;
; History     : Written, 2 April 2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function byte_map,map,err=err,_extra=extra

err=''

if (not valid_map(map)) then begin
 pr_syntax,'bmap=byte_map(map)'
 return,-1
endif

bmap=map
bdata=cscale(map.data,_extra=extra,obottom=obottom,otop=otop)
bmap=rep_tag_value(bmap,bdata,'data')
bmap=add_tag(bmap,obottom,'bottom')
bmap=add_tag(bmap,otop,'top')

return,bmap
end


