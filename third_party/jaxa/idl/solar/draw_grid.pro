;
pro draw_grid,center,fov,item,img_siz=img_siz,img_pos=img_pos, 	$
  roll=roll,tilt=tilt,gridsep=gridsep,mgridsep=mgridsep, 	$
  res=res,noerase=noerase,latlon=latlon,symsize=symsize,	$
  nogrid=nogrid,draw_limb=draw_limb,draw_eq=draw_eq,		$
  color=color,thick=thick,gridtype=gridtype,qstop=qstop,tv2=tv2, $
  nosavrest=nosavrest
;+
; NAME:
;       DRAW_GRID
; PURPOSE:
;	Draw a Stonyhurst grid
;	(Also can draw Carrington grid).
; CATEGORY:
; CALLING SEQUENCE:
;	draw_grid
;	draw_grid, center, fov
;	draw_grid, center, fov, /tv2
; INPUTS:
;   center	- [x,y] Center of the Stonyhurst plot in units 
;			of solar radius (default = [0,0]).
;   fov		- [x,y] Size of Stonyhurst plot in units of
;			solar radius (default = [2.5,2.5]).
;   item	- Time parameter for Carrington grid
; INPUT KEYWORDS PARAMETERS:
;   TV2		- If set, does scaling needed for PS plotting
;   img_siz	- [x,y] Size of the image (default=window size)
;   img_pos	- [x,y] Location of lower left corner of Stonyhurst
;			grid (default = [0,0]).
;   roll	- To specify a non-zero roll angle degrees). Positive
;		  will roll result grid counter clockwise.
;   tilt	- To specify the B-angle (degrees).
;   gridsep	- Grid separation (degrees).  Default = 15 degrees.
;   nogrid	- To suppress grid (usually used in combination with 
;		  the /draw_limb keyword).
;   draw_limb	- Draw the limb (usually used in combination with the
;		  /nogrid keyword).
;   draw_eq	- Draw the equator (usually used in combination with the
;		  /nogrid keyword).
;   noerase	- If set, do not erase before plotting.
;   color	- Specify the color of the grid.
;   thick	- Specify the line thickness of the grid.
;   latlon	- Array of size [2,N] giving coordinates of latitude 
;		  longitude.  Circles will be drawn at the specified
;		  coordinates.
;   symsize	- Define (arbitrary) size of latlon circles (default = 1.)
;   gridtype	- =1 for Stonyhurst (default) and =2 for Carrington grid.
;   res		- ????
;   mgridsize	- ????
;   nosavrest	- If set then DO NOT execute save/restore commands.
; OUTPUTS:
;   None.
; COMMON BLOCKS:
;	draw_grid_blk, tv2_blk
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; EXAMPLE:
; MODIFICATION HISTORY:
;       July, 1992. - Written by GLS, LMSC.
;	14-Jul-93 (MDM) - Added common block to save the xrange, yrange, and
;			  position information (to be used by other routines
;			  like PLOT_NAR, SXT_GRID, ...
;	21-Jan-93 (GLS) - Added ITEM as positional parameter.  This is
;			  an index or time parameter, used for Carrington
;			  longitude calculation (see next item).
;			  Added GRIDTYPE as a keyword parameter.  If it
;			  is 1 (default), a heliographic grid is plotted.
;			  If 2, Carrington grid is plotted.
;	23-Feb-95 (RDB) - Added TV2 keyword and stuff associated with PS
;			  plotted (see also ocontour, etc.)
;	26-Jan-96 (JRL) - Added save/restore of system plot variables.
;	29-Mar-96 (GLS)	- Added nosavrest keyword
;-

common draw_grid_blk, x_sys, y_sys, p_sys	;MDM added 14-Jul-93
common tv2_blk, xsiz_pix, ysiz_pix, xsiz_inch, ysiz_inch, ppinch

if keyword_set(nosavrest) eq 0 then $
  savesys,/aplot				; save !x,!y,!z,!p

;-----------------------------------------------------
; Set up defaults for the values of the input keywords
;-----------------------------------------------------
if n_elements(center) eq 0 then center = [0.,0.]
if n_elements(fov) eq 0 then fov = [2.5,2.5]
fov = float(fov)
if n_elements(img_siz) eq 0 then img_siz = [1,1]*(!d.x_size < !d.y_size)
if n_elements(img_pos) eq 0 then img_pos = [0,0]
if n_elements(roll) eq 0 then roll = 0
if n_elements(tilt) eq 0 then tilt = 0
if n_elements(gridsep) eq 0 then gridsep = 15
if n_elements(mgridsep) eq 0 then mgridsep = 5
if n_elements(thick) eq 0 then thick = 1
if n_elements(res) eq 0 then res = 1
if n_elements(gridtype) eq 0 then gridtype = 1
if n_elements(noerase) eq 0 then noerase = 0
if n_elements(color) eq 0 then color = 255

ymin = center(0) - fov(0)/2 & ymax = center(0) + fov(0)/2
zmin = center(1) - fov(1)/2 & zmax = center(1) + fov(1)/2

if noerase eq 0 then erase & noerase = 1

;	position and dev set depending on what plotting to...
dev=1
position = [img_pos(0),img_pos(1), $
	img_pos(0)+img_siz(0)-1, $
        img_pos(1)+img_siz(1)-1]

if (keyword_set(tv2) and (!d.name eq 'PS')) then begin
    bin=1
    x0 = img_pos(0) & y0 = img_pos(1)
    nx = img_siz(0) & ny = img_siz(1)
;;    print,img_siz,img_pos,fov
;;    print,x0,y0,nx,ny

;		this code taken from ocontour
    xn0 = x0 / float(xsiz_pix)
    yn0 = y0 / float(ysiz_pix)
    xn1 = xn0 + (nx*bin) / float(xsiz_pix)
    yn1 = yn0 + (ny*bin) / float(ysiz_pix)
    position = [xn0, yn0, xn1, yn1]
    dev=0			;don't use device coords.
endif

; Set up the coordinate systems with a /nodata plot call:

plot,[ymin,ymax],[zmin,zmax],/nodata,noerase=noerase, $
	 color=color,thick=thick, $
	 xstyle = 1+4, ystyle = 1+4, $
	 xrange = [ymin,ymax], yrange = [zmin,zmax], $
	 position = position, device = dev


;--------------
; Draw the limb
;--------------
if keyword_set(draw_limb) then $
  oplot,cos(findgen(361)/!radeg),sin(findgen(361)/!radeg), $
           color=color,thick=thick

;-----------------
; Draw the equator
;-----------------
if keyword_set(draw_eq) then begin
  eq_vec = transpose([[fltarr(361)+1],[fltarr(361)],[findgen(361)]])
  latc = s2c(eq_vec,roll=roll,b0=-tilt)
    
  goodeq = where((latc(0,*) ge 0) and $
		 (latc(1,*) ge ymin) and (latc(1,*) le ymax) and $
		 (latc(2,*) ge zmin) and (latc(2,*) le zmax),count_eq)

  good_segment0 = where(goodeq lt 180, count_segment0)
  good_segment1 = where(goodeq ge 180, count_segment1)

  if count_segment0 gt 0 then $
      oplot,(latc(1,*))(goodeq(good_segment0)), $
	    (latc(2,*))(goodeq(good_segment0)),color=color,thick=thick
  if count_segment1 gt 0 then $
      oplot,(latc(1,*))(goodeq(good_segment1)), $
	    (latc(2,*))(goodeq(good_segment1)),color=color,thick=thick
endif

;--------------
; Draw the grid
;--------------
if not keyword_set(nogrid) then begin
  mk_grid_coords,gridsep,mgridsep,res,lat,lon,/deg
  if gridtype eq 2 then begin
    clon0 = tim2clon(item)
    clon0 = (1.-(clon0 - fix(clon0)))*360.
    lon(2,*) = lon(2,*) - clon0
  endif
  n_plotpts = 360./res
  latc = reform(s2c(lat,roll=roll,b0=-tilt),3,n_plotpts,180/gridsep-1)
  lonc = reform(s2c(lon,roll=roll,b0=-tilt),3,n_plotpts,180/gridsep)
  oplot,cos(findgen(361)/!radeg),sin(findgen(361)/!radeg), $
           color=color,thick=thick
  for i = 0,180/gridsep-2 do begin
    xlat0 = reform(latc(0,0:n_plotpts/2,i))
    xlat1 = reform(latc(0,n_plotpts/2+1:*,i))
    ylat0 = reform(latc(1,0:n_plotpts/2,i))
    ylat1 = reform(latc(1,n_plotpts/2+1:*,i))
    zlat0 = reform(latc(2,0:n_plotpts/2,i))
    zlat1 = reform(latc(2,n_plotpts/2+1:*,i))
    goodlat0 = where((xlat0 ge 0) and (ylat0 ge ymin) and $
		     (ylat0 le ymax) and (zlat0 ge zmin) and $
		     (zlat0 le zmax),count_lat0)
    goodlat1 = where((xlat1 ge 0) and (ylat1 ge ymin) and $
		     (ylat1 le ymax) and (zlat1 ge zmin) and $
		     (zlat1 le zmax),count_lat1)
    if count_lat0 gt 0 then $
      oplot,ylat0(goodlat0),zlat0(goodlat0),color=color,thick=thick
    if count_lat1 gt 0 then $
      oplot,ylat1(goodlat1),zlat1(goodlat1),color=color,thick=thick
  endfor

  for i = 0,180/gridsep-1 do begin
    xlon0 = reform(lonc(0,0:n_plotpts/2,i))
    xlon1 = reform(lonc(0,n_plotpts/2+1:*,i))
    ylon0 = reform(lonc(1,0:n_plotpts/2,i))
    ylon1 = reform(lonc(1,n_plotpts/2+1:*,i))
    zlon0 = reform(lonc(2,0:n_plotpts/2,i))
    zlon1 = reform(lonc(2,n_plotpts/2+1:*,i))
    goodlon0 = where((xlon0 ge 0) and (ylon0 ge ymin) and $
		     (ylon0 le ymax) and (zlon0 ge zmin) and $
		     (zlon0 le zmax),count_lon0)
    goodlon1 = where((xlon1 ge 0) and (ylon1 ge ymin) and $
		     (ylon1 le ymax) and (zlon1 ge zmin) and $
		     (zlon1 le zmax),count_lon1)
    if count_lon0 gt 0 then $
      oplot,ylon0(goodlon0),zlon0(goodlon0),color=color,thick=thick
    if count_lon1 gt 0 then $
      oplot,ylon1(goodlon1),zlon1(goodlon1),color=color,thick=thick
  endfor
endif

;---------------------------------------------
; Optionally plot circles at latlong positions
;---------------------------------------------
if keyword_set(latlon) eq 1 then begin
  dum = findgen(33)*(!pi*2/32.)
  usersym,2*cos(dum),2*sin(dum)		; Define psym=8 to be a circle
  if n_elements(symsize) eq 0 then qsymsize = 1. else qsymsize = symsize

  sz_latlon = size(latlon)
  npts_latlon = n_elements(latlon(0,*))
  rtp = transpose([[[fltarr(npts_latlon)+1]],[transpose(latlon)]])
  rtpc = s2c(rtp,roll=roll,b0=-tilt)
  for i=0,npts_latlon-1 do oplot,[rtpc(1,i),rtpc(1,i)], $
				 [rtpc(2,i),rtpc(2,i)],psym=8, $
				 color=color,thick=thick,symsize=qsymsize
endif

;--------------------------------------------------
; Set system variables to device coordinate systems 
;--------------------------------------------------
!X.STYLE = 1+4
!Y.STYLE = 1+4
!X.RANGE = [YMIN,YMAX]
!Y.RANGE = [ZMIN,ZMAX]
POS_NORM = CONVERT_COORD([IMG_POS(0),IMG_POS(0)+IMG_SIZ(0)-1], $
                         [IMG_POS(1),IMG_POS(1)+IMG_SIZ(1)-1], $
			 /DEV, /TO_NORM)
!P.POSITION = POS_NORM(0:1,*)
;!P.POSITION = [IMG_POS(0),IMG_POS(1), $
;	       IMG_POS(0)+IMG_SIZ(0)-1, $
;	       IMG_POS(1)+IMG_SIZ(1)-1],/DEVICE

if keyword_set(qstop) then stop

x_sys = !x		;MDM added 14-Jul-93
y_sys = !y
p_sys = !p
if keyword_set(nosavrest) eq 0 then $
  restsys,/aplot				; restore !x,!y,!z,!p

return
end

