;+
; Project     : VSO
;
; Name        : arcsec2helio
;
; Purpose     : Convert heliocentric (arcsecs) coordinates to heliographic (degrees)
;
; Inputs      : XP, YP = array of heliocentric coordinates
;
; Outputs     : LAT, LON = array of heliographic latitude and longitude coordinates
;
; Keywords    : DATE = UT date for conversion [def = current]
;
; History     : 26-Oct-2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

pro arcsec2helio,xp,yp,lat,lon,_ref_extra=extra

lat=-1. & lon=-1.
if (n_elements(xp) eq 0) or (n_elements(yp) eq 0) then return
ndimx=size(xp,/n_dim)
ndimy=size(yp,/n_dim)
if (ndimx ne ndimy) then return
if ndimx gt 2 then return
if ndimx eq 2 then begin
 xdim=size(xp,/dimensions)
 ydim=size(yp,/dimensions)
 if (xdim[0] ne ydim[0]) or (xdim[1] ne ydim[1]) then return
 nx=xdim[0] & ny=xdim[1]
endif

latlon=arcmin2hel(xp[*]/60.,yp[*]/60.,_extra=extra)
if ndimx eq 2 then begin
 lat=reform(latlon[0,*],nx,ny)
 lon=reform(latlon[1,*],nx,ny)
endif else begin
 lat=comdim2(latlon[0,*])
 lon=comdim2(latlon[1,*])
endelse

return & end
