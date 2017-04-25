;+
; Project     : HESSI
;
; Name        : SKIN_MAP
;
; Purpose     : Skin a map so that data pixels falling on lines of 
;               constant specified heliographic latitude/longitude 
;               are set to 1, and 0 otherwise.
;
; Category    : maps
;
; Syntax      : IDL> skip_map,map,smap
;
; Inputs      : MAP = map structure
;
; Outputs     : SMAP = skinned map
;
; Keywords    : GRID = grid spacing (degrees) [ def = 30]
;               TOLERANCE = tolerance (degrees) to decide if pixel
;               falls on latitude/longitude line [def = .5]
; 
; History     : 29-Jan-2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-


pro skin_map,map,smap,grid=grid,_extra=extra,tolerance=tolerance

if ~valid_map(map) then return

if is_number(grid) then grid=float(grid) else grid=30.

;-- extract heliocentric coordinates

xp=get_map_xp(map)
yp=get_map_yp(map)

;-- convert to heliographic

latlon=arcmin2hel(xp[*]/60.,yp[*]/60.,date=map.time,_extra=extra,off=off)

lat=latlon[0,*]
lon=latlon[1,*]
smap=map
smap.data=0.
data=smap.data

;-- search for data points closest to lat/lon grid

if is_number(tolerance) then tol=float(tolerance) else tol=.5
arc=-90.+grid*findgen(180./grid+1)
for i=0,n_elements(arc)-1 do begin
 diff1=abs(arc[i]-lon)
 diff2=abs(arc[i]-lat)
 find=where( (diff1 le tol),count)
 if count gt 0 then (data)[find]=1.0
 find=where( (diff2 le tol),count)
 if count gt 0 then (data)[find]=1.0
endfor

;-- remove offlimb points

chk=where(off eq 1,ocount)
if ocount gt 0 then (data)[chk]=0.

smap.data=temporary(data)
return & end
