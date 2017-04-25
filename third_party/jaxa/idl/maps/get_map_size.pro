;+
; Project     : RHESSI
;
; Name        : GET_MAP_SIZE
;
; Purpose     : extract map dimensions
;
; Category    : imaging
;
; Syntax      : msize=get_map_size(map)
;
; Inputs      : MAP = image map
;
; Outputs     : MSIZE = [nx,ny]
;
; Keywords    : ERR = error string
;
; History     : Written 20 April 2015, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_size,map,err=err

err=''
if ~valid_map(map,err=err) then return,-1
if n_elements(map) ne 1 then begin
 err='Cannot handle more than one input map.'
 mprint,err
 return,-1
endif

return,get_true_size(map.data,err=err)

end
