;+
; Project     :	STEREO
;
; Name        :	WCS_SIMPLIFY
;
; Purpose     :	Simplifies a WCS data array and structure.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure rearranges a WCS structure and associated data
;               array so that it satisfies the WCS_SIMPLE() function.  If
;               necessary, WCS_RECTIFY is called so that the WCS can be
;               decomposed into CDELT and ROLL_ANGLE values.  Also, the
;               dimensions are rearranged so that the longitude (X) dimension
;               is first, and the latitude (Y) dimension is second.
;
; Syntax      :	WCS_SIMPLIFY, DATA, WCS
;
; Inputs      :	DATA = Data array associated with the WCS structure
;               WCS  = World Coordinate System structure from FITSHEAD2WCS
;
; Opt. Inputs :	None.
;
; Outputs     :	DATA and WCS are modified.
;
; Opt. Outputs:	None.
;
; Keywords    :	Accepts keywords for WCS_DECOMP_ANGLE and WCS_RECTIFY
;
; Calls       :	VALID_WCS, WCS_SIMPLE, WCS_DECOMP_ANGLE, WCS_RECTIFY,
;               TAG_EXIST, REARRANGE
;
; Common      :	None.
;
; Restrictions:	Currently only works for WCS structures in either the
;               Helioprojective-Cartesion, or Heliocentric-Cartesian coordinate
;               systems.  The only supported projection is TAN.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 15-April-2005, William Thompson, GSFC
;               Version 2, 05-Jul-2005, William Thompson, GSFC
;                       Handle PSi_m, SPEC_INDEX, table projection
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_simplify, data, wcs, _extra=_extra
on_error, 2
;
;
;  Check the input parameters.
;
if n_params() ne 2 then message, 'Syntax: WCS_SIMPLIFY, DATA, WCS'
if not valid_wcs(wcs) then message, 'Input not recognized as WCS structure'
if n_elements(data) eq 0 then message, 'DATA array is undefined' 
;
;  Make sure that the data array matches the WCS structure.  Trailing
;  dimensions of 1 are allowed in either the DATA array or in the WCS
;  structure.
;
sz = size(data)
nn = n_elements(wcs.naxis) > sz[0]
dim1 = replicate(1L, nn)
if sz[0] gt 0 then dim1[0] = sz[1:sz[0]]
dim2 = replicate(1L, nn)
dim2[0] = wcs.naxis
w = where(dim1 ne dim2, count)
if count gt 0 then message, 'DATA array does not match WCS structure'
;
;  If the WCS is already simple, then simply return.  Make sure that the SIMPLE
;  tag is in the structure.
;
if wcs_simple(wcs, /add_tag) then return
;
;  If not already Heliocentric-Cartesian or Helioprojective-Cartesian, then
;  don't try to change coordinate systems (yet).
;
coord_type = strtrim(strupcase(wcs.coord_type),2)
if (coord_type ne 'HELIOPROJECTIVE-CARTESIAN') and $
   (coord_type ne 'HELIOCENTRIC-CARTESIAN') then begin
    message, /continue, $
      'Unable to simplify coordinate type ' + wcs.coord_type
    return
endif
;
;  If the projection is not 'TAN' or blank, don't try to change the projection
;  (yet).
;
projection = strtrim(strupcase(wcs.projection),2)
if (projection ne 'TAN') and (projection ne '') then begin
    message, /continue, 'Unable to simplify projection ' + wcs.projection
    return
endif
;
;  Determine whether or not the projection can be decomposed into CDELT and
;  ROLL_ANGLE values.  If not, then call wcs_rectify.
;
wcs_decomp_angle, wcs, roll_angle, cdelt, found, /add_tags, _extra=_extra
if not found then begin
    message = ''
    wcs_rectify, data, wcs, errmsg=message, _extra=_extra
    if message ne '' then message, message
endif
;
;  Have we already made it simple?
;
if wcs_simple(wcs, /add_tag) then return
;
;  The only remaining step is to rearrange the data so that the X coordinate is
;  first, and the Y coordinate is second.  First, determine the new order of
;  indices.
;
n_axis = n_elements(wcs.naxis)
index = lonarr(n_axis)
ix = wcs.ix
iy = wcs.iy
index[0] = ix
index[1] = iy
k = 2
for i=0,n_axis-1 do if (i ne ix) and (i ne iy) then begin
    index[k] = i
    k = k+1
endif
;
;  Rearrange the parameters in the WCS structure to fit the new index order.
;
wcs.ix = 0
wcs.iy = 1
wcs.naxis = wcs.naxis[index]
wcs.crpix = wcs.crpix[index]
wcs.crval = wcs.crval[index]
wcs.ctype = wcs.ctype[index]
wcs.cunit = wcs.cunit[index]
if tag_exist(wcs,'CDELT') then wcs.cdelt = wcs.cdelt[index]
if tag_exist(wcs,'PC') then begin
    pc = wcs.pc
    pc = pc[index,*]
    pc = pc[*,index]
    wcs.pc = pc
endif
if tag_exist(wcs,'CD') then begin
    cd = wcs.cd
    cd = cd[index,*]
    cd = cd[*,index]
    wcs.cd = cd
endif
;
;  Make sure that any PVi_m and PSi_m parameters have names reflecting the new
;  index order.
;
if tag_exist(wcs,'PROJ_NAMES') then begin
    new_names = wcs.proj_names
    for i=1,n_axis do begin
        prefix = 'PV' + ntrim(i) + '_'
        n_prefix = strlen(prefix)
        test = strmid(wcs.proj_names,0,n_prefix)
        w = where(test eq prefix, count)
        if count gt 0 then for j=0,count-1 do begin
            name = wcs.proj_names[w[j]]
            trailer = strmid(name,n_prefix,strlen(name)-n_prefix)
            new_names[w[j]] = 'PV' + ntrim(index[i]+1) + '_' + trailer
        endfor
;
        prefix = 'PS' + ntrim(i) + '_'
        n_prefix = strlen(prefix)
        test = strmid(wcs.proj_names,0,n_prefix)
        w = where(test eq prefix, count)
        if count gt 0 then for j=0,count-1 do begin
            name = wcs.proj_names[w[j]]
            trailer = strmid(name,n_prefix,strlen(name)-n_prefix)
            new_names[w[j]] = 'PS' + ntrim(index[i]+1) + '_' + trailer
        endfor
    endfor
    wcs.proj_names = new_names
endif
;
;  If the SPECTRUM tag is found, then change the spectral index to reflect the
;  new index order.
;
if tag_exist(wcs, 'spectrum', /top_level) then $
  if tag_exist(wcs.spectrum, 'spec_index', /top_level) then $
  wcs.spectrum.spec_index = index[wcs.spectrum.spec_index]
;
;  If the LOOKUP_TABLE tag is found, then change the appropriate parameters.
;
if tag_exist(wcs, 'lookup_table', /top_level) then begin
    wcs.lookup_table.coordname = wcs.lookup_table.coordname[index]
    wcs.lookup_table.indexname = wcs.lookup_table.indexname[index]
    wcs.lookup_table.axisnum   = wcs.lookup_table.axisnum[index]
endif
;
;  Rearrange the data array.
;
;;data = reform(data, dim1, /overwrite)         ;This step is not needed.
data = rearrange(data, index+1)
;
;  Run it through WCS_SIMPLE one last time before returning.
;
dummy = wcs_simple(wcs, /add_tag)
return
end
