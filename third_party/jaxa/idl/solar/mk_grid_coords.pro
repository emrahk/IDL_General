
;       (09-jul-92)
  pro mk_grid_coords,grid_sep,mgrid_sep,res,lat_vec,lon_vec,deg=deg
;+
; NAME:
;	MK_GRID_COORDS
; PURPOSE:
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
;   POSITIONAL PARAMETERS:
;   KEYWORDS PARAMETERS:
; OUTPUTS:
;   POSITIONAL PARAMETERS:
;   KEYWORDS PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
; MODIFICATION HISTORY:
;       July, 1992. - Written by GLS, LMSC.
;-

if n_elements(deg) eq 0 then deg = 0
if deg eq 0 then degrad = !dtor else degrad = 1
n_gridpts = 180./grid_sep	; Define number of grid points for each
				;   circle of latitude and longitude
n_plotpts = 360./res		; Define number of plot points for each
				;   circle of latitude and longitude
lon_phi = $
  rebin((findgen(n_gridpts)*grid_sep-90)*degrad,n_gridpts*n_plotpts,/sample)
lon_theta = repvec(findgen(n_plotpts)*res*degrad,n_gridpts)
lon_vec = transpose([[fltarr(n_plotpts*n_gridpts)+1],[lon_theta],[lon_phi]])
; LATITUDE LINE COORDINATES ARE THE SAME AS LONGITUDE LINE COORDINATES,
;   BUT WITH THETA AND PHI REVERSED:
lat_theta = $
  rebin(((findgen(n_gridpts-1)+1)*grid_sep-90)*degrad, $
  (n_gridpts-1)*n_plotpts,/sample)
lat_phi = repvec(findgen(n_plotpts)*res*degrad,(n_gridpts-1))
lat_vec = $
  transpose([[fltarr(n_plotpts*(n_gridpts-1))+1],[lat_theta],[lat_phi]])

end

