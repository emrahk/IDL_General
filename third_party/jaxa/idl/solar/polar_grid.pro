
pro polar_grid, $
  item, data, center=center, img_siz=img_siz, $
  phi_sep=phi_sep, phi_res=phi_res, $
  r_sep=r_sep, r_res=r_res, r_max=r_max, spherical=spherical, $
  grid_color=grid_color, grid_thick=grid_thick, $
  draw_limb=draw_limb, limb_color=limb_color, limb_thick=limb_thick, $
  erase=erase, norestsys=norestsys, read_out=read_out, $
  charsize=charsize, charthick=charthick, km=km, qs=qs

;+
; NAME:
;       POLAR_GRID
; EXAMPLES:
; PURPOSE:
;       Overlay a polar grid on an image
;       Interactively display polar coodinates of the cursor
; CATEGORY:
;       Image display.
; CALLING SEQUENCE:
;	polar_grid, $
;	  item, data, center=center, img_siz=img_siz, $
;	  phi_sep=phi_sep, phi_res=phi_res, $
;	  r_sep=r_sep, r_res=r_res, r_max=r_max, $
;	  grid_color=grid_color, grid_thick=grid_thick, $
;	  draw_limb=draw_limb, limb_color=limb_color, limb_thick=limb_thick, $
;	  erase=erase, norestsys=norestsys, read_out=read_out, $
;	  charsize=charsize, charthick=charthick, km=km, qs=qs
; EXAMPLE CALLS:
;       polar_grid, index
;       polar_grid, index, data, /draw_limb, /read_out
;       polar_grid, r_pix, x, data, /draw_limb, /read_out
; REQUIRED INPUTS:
;       ITEM         May be:
;			SXT index or roadmap record
;			R_PIX, the radius of the disk in image pixels
; OPTIONAL INPUTS:
;   POSITIONAL PARAMETERS:
;       DATA         Image array.  If passed it is displayed.
;   KEYWORDS PARAMETERS:
;	CENTER	     Center of disk relative to lower left corner of
;		     image, in image pixel coordinates.
;	IMG_SIZ	     Size of image: [x_size, y_size]
;       PHI_SEP    Grid separation interval for lines of constant
;                    phi, in degrees (def = 5 deg).
;       R_SEP        Grid separation interval for lines of constant
;                    radius, in units of fractional disk radius (def = 0.2).
;	PHI_RES    Point separation interval for lines of constant
;		     radius, in degrees (def is 2 deg).
;	R_RES        Point separation interval for lines of constant
;                    radius, in units of fractional disk radius (def = 0.1).
;	R_MAX	     Outer limit of lines of constant radius, in units of
;		     fractional disk radius (def = 2.0).
;       ERASE	     If present and nonzero, window is erased prior
;                    to drawing grid (def is 0).
;       READ_OUT     If present and non-zero, the polar coordinates
;                    of the cursor are displayed in a window-let.
;       SPHERICAL  If set, then in place of a linear radial coordinate use
;		     the angle between the specified point and the axis
;                    defined by the center of the solar sphere and the center
;                    of the solar disk.
;	KM	     If present and non-zero, and if READ_OUT is also set,
;		     then the displayed value of R will be in kilometers
;		     when R greater than the disk radius.
;	GRID_COLOR   Obvious.
;	GRID_THICK   Obvious.
;       DRAW_LIMB    If present and non-zero, limb is drawn.
;	LIMB_COLOR   Obvious.
;	LIMB_THICK   Obvious.
;	CHARSIZE     Obvious.
;	CHARTHICK    Obvious.
;	NORESTSYS    If present and non-zero, do not reset plot parameters
;		     on return.
;	QS	     If present and non-zero, stop execution within POLAR_GRID
; OUTPUTS:
;   POSITIONAL PARAMETERS:
;       none.
;   KEYWORDS PARAMETERS:
;       LAST_RPHI  Last position of cursor (during /READ_OUT mode)
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;       24-Aug-94 - GLS, based on DRAW_GRID and PLOT_CLON
;	08-Apr-98 - William Thompson, GSFC
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;-

savesys,/aplot

if n_elements(item) eq 0 then item = min([!d.x_size,!d.y_size])/2
if n_elements(img_pos) eq 0 then img_pos = [0,0]
if n_elements(phi_sep) eq 0 then phi_sep = 5.
if keyword_set(spherical) and n_elements(r_sep) eq 0 then r_sep = 10.
if n_elements(r_sep) eq 0 then r_sep =  .2
if keyword_set(spherical) and n_elements(r_max) eq 0 then r_max = 90.
if n_elements(r_max) eq 0 then r_max = 2.0
if n_elements(phi_res) eq 0 then phi_res = 2.
if n_elements(r_res) eq 0 then r_res = .1
if n_elements(grid_thick) eq 0 then grid_thick = 1
if n_elements(grid_color) eq 0 then grid_color = !d.table_size-1
if n_elements(draw_limb) eq 0 then draw_limb = 0
if n_elements(limb_thick) eq 0 then limb_thick = 3
if n_elements(limb_color) eq 0 then limb_color = !d.table_size-1
if n_elements(erase) eq 0 then erase = 0
if n_elements(read_out) eq 0 then read_out = 0
if n_elements(charsize) eq 0 then charsize = 1.0
if n_elements(charthick) eq 0 then charthick = 1.5

sec_per_pix = 2.453	; Arc seconds per SXT full res pixel
r_sun = 6.9599e5	; km

sz_item = size(item)
if sz_item(n_elements(sz_item)-2) eq 8 then begin
  rb0p = makvec(get_rb0p(item))
  r_pix = rb0p(0)/sec_per_pix		; radius in pixels
  img_res = gt_res(item)
  img_siz = gt_shape(item)
  fov = img_siz*(2^img_res)/r_pix
  img_corner = gt_corner(item)  	; corner in FR pixels
  sunc = sxt_cen(item, roll=roll)
  sxt_cen = sunc(0:1,*)
; (full res pix) / r_pix:
  center = (img_corner + img_siz*(2^img_res)/2 - sxt_cen)/r_pix
endif else begin
  r_pix = item
  if n_elements(data) gt 0 then begin
    sx_data = size(data)
    img_siz = [sz_data(1),sz_data(2)]
  endif
  if n_elements(img_siz) eq 0 then img_siz = [!d.x_size,!d.y_size]
  fov = img_siz/r_pix
  fov = float(fov)
  center = [0,0]
endelse

if n_elements(data) gt 0 then tvscl,data

ymin = center(0) - fov(0)/2 & ymax = center(0) + fov(0)/2
zmin = center(1) - fov(1)/2 & zmax = center(1) + fov(1)/2

plot,[ymin,ymax],[zmin,zmax],/nodata,noerase=(1-erase), $
     xstyle = 1+4, ystyle = 1+4, $
     xrange = [ymin,ymax], yrange = [zmin,zmax], $
     position = [img_pos(0),img_pos(1), $
                 img_pos(0)+img_siz(0)-1, $
                 img_pos(1)+img_siz(1)-1],/device

n_r = 360/phi_sep
n_r_pts = r_max/r_res
r = findgen(n_r_pts)*r_res
for i = 0,n_r-1 do begin
  phi = fltarr(n_r_pts) + i*phi_sep/!radeg
  x = r*cos(phi)
  y = r*sin(phi)
  oplot,x,y,color=grid_color,thick=grid_thick
endfor

n_phi = r_max/r_sep
n_phi_pts = 360/phi_res + 1
phi = findgen(n_phi_pts)*phi_res/!radeg
for i = 1,n_phi do begin
  if keyword_set(spherical) then $
    r = fltarr(n_phi_pts) + sin(i*(r_sep/!radeg)) else $
    r = fltarr(n_phi_pts) + i*r_sep
  x = r*cos(phi)
  y = r*sin(phi)
  oplot,x,y,color=grid_color,thick=grid_thick
endfor

if keyword_set(draw_limb) then $
  oplot,cos(findgen(361)/!radeg),sin(findgen(361)/!radeg), $
        color=limb_color,thick=limb_thick

if keyword_set(read_out) ne 0 then begin
  device, get_window = win_coords
  window0 = !d.window
  wdef,window1,xpos=win_coords(0),ypos=win_coords(1),256,64
  last_r_str = '' & last_phi_str = ''
  !err = 0
  while !err ne 4 do begin
    wset,window0
    cursor,y0,z0,2,/data        ; Note wait_mode = 2
    phi_val = atan(-y0,z0)*!radeg
    if phi_val lt 0 then phi_val = phi_val + 360
    r_val = sqrt(y0*y0 + z0*z0)
    r_str     = ' R: ' + string(r_val,format='$(f5.2)')
    if (r_val le 1) and keyword_set(spherical) then $
    r_str     = ' THETA: ' + string(asin(r_val)*!radeg,format='$(f7.2)')
    if (r_val gt 1) and keyword_set(km) then $
    r_str     = ' R: ' + string((r_val-1)*r_sun,format='$(f9.2)') + $
		' km'
    phi_str   = ' PHI: ' + string(phi_val,format='$(f7.2)')
    last_rphi = [r_val,phi_val]
    wset,window1
    xyouts,10,42,last_r_str,/device,color=0, $
      charsize=charsize,charthick=charthick
    xyouts,10,10,last_phi_str,/device,color=0, $
      charsize=charsize,charthick=charthick
    xyouts,10,42,r_str,/device, $
      charsize=charsize,charthick=charthick
    xyouts,10,10,phi_str,/device, $
      charsize=charsize,charthick=charthick
    last_r_str = r_str & last_phi_str = phi_str
  endwhile
  wdelete,window1
  wset,window0
  print, 'Optional values in LAST_RPHI are: '
  print, r_str
  print, phi_str
endif

if keyword_set(qs) then stop

if keyword_set(norestsys) ne 1 then restsys,/aplot

end

