;+
; Project     :	STEREO
;
; Name        :	WCS_PLOT_CYLINDRICAL
;
; Purpose     :	Plot (e.g. heliographic) maps in cylindrical projections.
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure takes an image in a cylindrical projection, such
;               as a heliographic map, and plots it with longitude and latitude
;               marks along the axes.
;
; Syntax      :	WCS_PLOT_CYLINDRICAL, HEADER, IMAGE
;
; Examples    :	WCS_PLOT_CYLINDRICAL, HEADER, IMAGE, XTICKLEN=-0.01, $
;                       YTICKLEN=-0.005, /NOSQUARE, /POS_LONG
;
; Inputs      :	HEADER  = Either the FITS header or WCS containing the
;                         description of the coordinate system.
;
;               IMAGE   = Two dimensional image to be plotted.
;
; Opt. Inputs :	None.
;
; Outputs     :	PLOT_IMAGE is called to plot the image to the current graphics
;               device.
;
; Opt. Outputs:	None.
;
; Keywords    :	TICKINTERVAL = Interval between tick values.  Default depends
;                          on the size of the map, generally 30 degrees.
;
;               OCONTOUR = If set, then contour lines are drawn for the
;                          longitude and latitude coordinates.
;
;               OCOLOR   = Color to use for the contour lines.
;
;               NOWRAP     = If set, don't wrap the longitude values to be
;                            between +/-180 degrees.  Only used for cylindrical
;                            projections (CAR,CEA,CYP,MER).
;
;               POS_LONG   = If set, then force the output longitude to be
;                            positive, i.e. between 0 and 360 degrees.  The
;                            default is to return values between +/- 180
;                            degrees.
;
;               Any other keywords supported by PLOT_IMAGE or any of the other
;               underlying routines are also supported.
;
; Calls       :	VALID_WCS, FITSHEAD2WCS, WCS_GET_COORD, PLOT_IMAGE, CONTV
;
; Common      :	None.
;
; Restrictions:	Only the cylindrical projections CAR, CEA, CYP, and MER are
;               supported.  The longitude axis must be first, followed by the
;               latitude axis.
;
; Side effects:	Any coordinates measured off the image with the CURSOR routine
;               will be in image pixels rather than longitude and latitude.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 28-Mar-2013, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_plot_cylindrical, header_or_wcs, image, ocontour=ocontour, $
                          ocolor=ocolor, tickinterval=tickinterval, $
                          title=title, color=color, pos_long=pos_long, $
                          _extra=_extra
on_error, 2
if n_params() ne 2 then message, $
  'Syntax: WCS_PLOT_CYLINDRICAL, HEADER_OR_WCS, IMAGE'
;
;  If a header, then convert to a WCS structure.
;
if valid_wcs(header_or_wcs) then wcs = header_or_wcs else begin
    errmsg = ''
    wcs = fitshead2wcs(header_or_wcs, errmsg=errmsg, _extra=_extra)
    if errmsg ne '' then message, errmsg
endelse
;
;  Check the WCS structure.
;
if n_elements(wcs.naxis) gt 2 then message, $
  'Only two-dimensional maps supported'
if (wcs.ix ne 0) then message, 'Data must be in longitude, latitude order'
proj = wcs.projection
if (proj ne 'CAR') and (proj ne 'CEA') and (proj ne 'CYP') and $
  (proj ne 'MER') then message, 'Projection ' + proj + ' not supported'
if wcs.crval[1] ne 0 then message, /informational, $
  'Warning: Reference pixel not at equator -- results may not be optimal'
;
;  Get the coordinates.
;
sz = size(image)
coord = wcs_get_coord(wcs, pos_long=pos_long, _extra=_extra)
lonmin = min(coord[0,*,*], max=lonmax)  &  lonrange = lonmax - lonmin
latmin = min(coord[1,*,*], max=latmax)  &  latrange = latmax - latmin
;
;  Determine a good set of longitude tick marks.
;
if n_elements(tickinterval) eq 0 then begin
    if lonrange ge 240 then begin
        tickinterval = 30
    end else if lonrange ge 90 then begin
        tickinterval = 15
    end else begin
        delta = lonrange / 10
        power = floor(alog10(delta))
        delta = delta / 10.^power
        val = [10,5,2]
        value = 1
        for i=0,2 do if val[i] gt delta then value = val[i]
        tickinterval = value * 10.^power
    endelse
endif
;
mintick =  ceil(lonmin/tickinterval)
maxtick = floor(lonmax/tickinterval)
xticks = maxtick - mintick
xvalues = (mintick + indgen(xticks+1)) * tickinterval
;
;  If monotonic, then use a simpler algorithm.
;
dlon = coord[0,1:*,0] - coord[0,*,0]
w = where(dlon ge 0, count1, ncomplement=count2)
if (count1*count2) eq 0 then begin
    xtickv = (xvalues - coord[0,0,0]) / wcs.cdelt[0]
end else begin
    w = where(xvalues eq 0, count)
    if count eq 0 then begin
        xticks = xticks + 1
        xvalues = [xvalues, 0]
        s = sort(xvalues)
        xvalues = xvalues[s]
    endif
    xcoord = dblarr(2,xticks+1)
    xcoord[0,*] = xvalues
    xcoord[1,*] = coord[1,0,0]
    xtickv = reform((wcs_get_pixel(wcs, xcoord, _extra=_extra))[0,*])
endelse
xtickname = ntrim(xvalues)
;
;  Determine a good set of latitude tick marks.
;
mintick =  ceil(latmin/tickinterval)
maxtick = floor(latmax/tickinterval)
yticks = maxtick - mintick
yvalues = (mintick + indgen(yticks+1)) * tickinterval
ycoord = dblarr(2,yticks+1)
ycoord[0,*] = coord[0,0,0]
ycoord[1,*] = yvalues
ytickv = reform((wcs_get_pixel(wcs, ycoord, _extra=_extra))[1,*])
ytickname = ntrim(yvalues)
;
;  Plot the cylindrical map.
;
plot_image, image, origin=[-0.5,-0.5], scale=1, title=title, color=color, $
            xticks=xticks, xtickv=xtickv, xtickname=xtickname, $
            yticks=yticks, ytickv=ytickv, ytickname=ytickname, _extra=_extra
;
;  If requested, overplot the contour lines.
;
if keyword_set(ocontour) then begin
    if (n_elements(ocolor) eq 0) and (n_elements(color) eq 1) then $
      ocolor = color
    contv, reform(coord[0,*,*]), levels=xvalues, color=ocolor, _extra=_extra
    contv, reform(coord[1,*,*]), levels=yvalues, color=ocolor, _extra=_extra
endif
;
end
