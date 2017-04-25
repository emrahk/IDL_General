
function dij, a, i, j

;+
; NAME:
;	DIJ
; PURPOSE:
;	Calculate the 'distance' of each pixel within an image,
;	or each index within an array, from a given pixel,
;	specified by indices i and j (x and y).
; CALL:
;	distance_array = dij(input_array, i, j)
; INPUTS:
;	A   - Input array
;	i,j - xy indices of pixel relative to which distances are calculated
; OPTIONAL INPUT:
; OUTPUTS:
;	Array of distances
; OPTIONAL OUTPUT:
; METHOD:
;	Define x and y coordinate arrays corresponding to input matrix,
;	then use these to calculate matrix of distances relative to
;	reference coordinates by means of Theorem of Pythagoras.
; HISTORY:
;	10-Aug-2001 - Written by GLS.
;        4-Sep-2001 - S.L.Freeland - common block to avoid recalculation
;                                    if last = current
;-
common dij_blk, last_params, last_d

if n_params() lt 3 then begin 
   box_message,'need array and desired center'
   return,-1
endif

if n_elements(lj) eq 0 then last_params=fltarr(4)-1

dim = size(a,/dim)
nx = dim(0)
ny = dim(1)
nelem = nx*ny
xarr = findgen(nelem) mod nx
yarr = findgen(nelem)  /  nx

curr_params=[nx,ny,i,j]

chk_params=where(curr_params ne last_params,cnt)

if cnt gt 0 then begin
   d = sqrt((xarr-i)*(xarr-i) + (yarr-j)*(yarr-j))
   last_params=curr_params
   last_d=d
endif else d=last_d
 
return,d
end

