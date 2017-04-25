;+
; Project     : HESSI
;
; Name        : WHERE_MAP
;
; Purpose     : find nearest map in time to a set of maps 
;
; Category    : imaging maps
;
; Syntax      : index=where_map(map,map_set)
;
; Inputs      : MAP = image map
;               MAP_SET = array of maps to check
;
; Outputs     : INDEX = index of nearest map
;
; Keywords    : None
;
; History     : Written 22 March 2000, D. Zarro (SM&A/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function where_map,map,map_set

index=-1
if (not valid_map(map)) or (not valid_map(map_set)) then return,-1
if n_elements(map_set) eq 1 then return,0
t1=anytim2tai(map.time)
tset=anytim2tai(map_set.time)
diff=abs(t1-tset)
index=where(diff eq min(diff))
return,index
end

