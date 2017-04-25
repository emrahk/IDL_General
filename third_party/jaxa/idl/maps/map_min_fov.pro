
;+
; PROJECT:
;   SSW
; NAME:
;   Map_Min_Fov
;
; PURPOSE:
;   This function takes a map structure and returns a map_str only covering the
;	minimum rectangle or square containing the pixels above the threshold fraction
;	with the same center as the original map
; CATEGORY:
;   HESSI, UTIL, MAP
;
; CALLING SEQUENCE:
;   new_min_map = map_min_fov( map_str, threshold, square=square, odd=odd, nomapstr=nomapstr)
;
; CALLS:
;   none
;
; INPUTS:
;        map_str - original map structure, see def_map.pro
; OUTPUTS;
;       Returns a new map_str covering a rectangle or square FOV including all
;		pixles ge to the threshold x max( map_str.data)
;
;
; OPTIONAL INPUTS:
;		 Threshold - include pixels to this fraction of the peak value, default is 0.001
;
; OPTIONAL OUTPUTS:
;   none
;
; KEYWORDS:
;	NOMAPSTR - If set, map structure not returned, just the map array
; COMMON BLOCKS:
;   none
;
; SIDE EFFECTS:
;   none
;
; RESTRICTIONS:
;
; PROCEDURE:
;   Identifies the maximum distance from map center with pixels above threshold and
;	constructs the map to that size in both the positive and negative directions for
;	both x and y
; MODIFICATION HISTORY:
;   Version 1, richard.schwartz@gsfc.nasa.gov
;	22-feb-2010
;	9-SEP-2010, richard.schwartz@nasa.gov, revised to use pixel_coord
;
;-
function map_min_fov, map_str, threshold, square=square, $
	odd=odd, nomapstr=nomapstr

default, square, 0
default, odd, 0 ;if set, number of pixels used is odd
default, threshold, 1e-3
eps =1.e-3
default, nomapstr, ~valid_map(map_str)
map = valid_map(map_str) ? map_str.data : map_str
dim = size(map, /dim)
if dim[0] ne dim[1] then square = 0
ix = where( map ge (threshold*max(map)), nix)
xy = (pixel_coord(dim))
lrange = lonarr(2)
for i=0, 1 do begin
	lrange[i] = long(max(abs( xy[i,ix]))*2 +eps)
	lrange[i] = ( ((dim[i] mod 2) eq (lrange[i] mod 2))? lrange[i] : lrange[i]+1)<dim[i]
	endfor


if keyword_set(square) then begin
	range = max( lrange)
	lrange[*] = range

	endif

map = map[lindgen(lrange[0]) + (dim[0]-lrange[0])/2,*]

map = map[*,lindgen(lrange[1]) + (dim[1]-lrange[1])/2]
if keyword_set(nomapstr) then return, map

nmap = make_map( map,_extra=map_str)
return, nmap
end