;+
; Project     : SOHO-CDS
;
; Name        : DIFF_MAP
;
; Purpose     : Difference two maps
;
; Category    : imaging
;
; Syntax      : diff=diff_map(map1,map2)
;
; Inputs      : MAP1,MAP2 = image maps
;
; Outputs     : DIFF = MAP1-MAP2 or MAP1/MAP2
;
; Keywords    : RUNNING = if MAP2 is an array, then produce
;               a running difference (map(i)=map(i+1)-map(i), etc)
;               ROTATE  = rotate maps to common time before rotating
;               RATIO = do ratio instead
;               MISSING = value for zero divide points
;
; Restrictions: RUNNING is not yet implemented
;
; History     : Written 1 April 1998, D. Zarro, SAC/GSFC
;               Modified 13 Dec 2002, S. Hill, NOAA/SEC
;                 Corrected syntactical errors (brackets vs. parens.)
;                 and minor bug with ratio option
;
; Contact     : dzarro@solar.stanford.edu
;-


function diff_map,map1,map2,rotate=rotate,ratio=ratio,missing=missing

if (not valid_map(map1)) or (not valid_map(map2)) then begin
 pr_syntax,'map=diff_map(map1,map2,[rotate=rotate,ratio=ratio])
 return,-1
endif

if keyword_set(rotate) then dmap=drot_map(map2,ref=map1) else $
 dmap=map2

if keyword_set(ratio) then begin
 bad=where(dmap.data eq 0., count)
 if count gt 0 then dmap.data[bad]=1.  ;SMH - changed syntax
 diff=temporary(map1.data)/temporary(dmap.data)
 if exist(missing) and (count gt 0) then diff[bad]=missing 
endif else diff=temporary(map1.data)-temporary(dmap.data)                        

dmap=map1
dmap.data=temporary(diff)
if keyword_set(ratio) then $
 add_prop,dmap,ratio=get_map_time(map1)+' / '+get_map_time(map2) else $
  add_prop,dmap,difference=get_map_time(map1)+' - '+get_map_time(map2)

return,dmap
end

