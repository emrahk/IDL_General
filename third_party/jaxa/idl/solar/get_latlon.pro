;+
;NAME:
;     GET_LATLON
;PURPOSE:
;     Compute latitude and longitude for a data array given the coordinates
;     of the center of the array.
;CATEGORY:
;CALLING SEQUENCE:
;     latlon = get_latlon(mag,point=point,date=date)
;INPUTS:
;OPTIONAL INPUT PARAMETERS:
;     mag = magnetic field structure containing at least the B_LONG (used to
;           derive the dimension of the array: not required if the nx and ny
;           keywords are set) and POINT fields (see below).  B_LONG is
;           used to derive the dimension of the array and is not required if 
;           the nx and ny keywords are set.  The size and pointing can be
;     specified with keywords, in which case mag is not required.
;KEYWORD INPUT PARAMETERS
;     point = pointing structure: 
;                lat(radians) = latitude of center of array, 
;                cmd(radians) = cmd of center of array, 
;                b0(radians) = solar B0 angle,               
;                p(radians) = solar P angle, 
;                pix_size(arcseconds) = size of the pixels, 
;                                       single number = x & y size
;                                       2-element vector = [xsize,ysize]
;                radius(arcseconds) = solar radius.
;
;     Note: The center of the array is defined to be (nx-1)/2.0 and 
;     (ny-1)/2.0 in pixel coordinates.
;
;     The pointing parameters can alternatively be specifield seperately 
;     with the following keywords:
;
;     lat    = latitude of center of FOV in radians
;     cmd    = CMD of center of FOV in radians
;
;     Alternatively, you can specify the pixel coordinates of the center of the
;     FOV rather than the lat/lon of the center of the FOV:
;
;     x0,y0 = coordinates of the center of the FOV relative to the center
;             of the solar disk in PIXEL units.
;
;     b0     = solar B0 angle in radians
;     pangle = solar P angle in radians
;     pixsize= Pixel size in arc seconds
;     radius = solar radius in arc seconds.  Not required if date is set or if
;              radius is set in the point structure.
;
;     date = date of data, e.g. '19-Aug-92 19:00'.  
;            Required to compute solar radius if the radius is not set in 
;            the radius keyword or in the point structure.
;     nx = x size of data array.  Required if no data is passed.
;     ny = y size of data array.  Required if no data is passed.
;KEYWORD PARAMETERS
;     /solar = x,y in array is relative to solar coordinates (so the p-angle
;              should be forced to zero).  Default is to assume that
;              x,y are relative to terrestrial coordinates.
;     /add = Add the latitude and longitude arrays to the magnetic field
;            structure (mag).
;     /quiet = work quietly.
;OUTPUTS:
;     latlon = structure with two field: latitude and cmd (arrays, same size
;              as the input array) giving the latitude and central meridian
;              distance in DEGREES.
;COMMON BLOCKS:
;SIDE EFFECTS:
;EXAMPLES:
;
;     j is a magnetic field structure
;
;     ll = get_latlon(j)
;     ll = get_latlon(point=j.point,nx=60,ny=45)
;
;RESTRICTIONS:
;     o Projects points off the limb back to the limb.
;     o Assumes pixels are uniformly spaced.
;     o Assumes the pixel grid is aligned so that the y axis is to the north
;       and the x axis is to the west (terrestrial or solar depending on the
;       state of the "solar" keyword).  This could be corrected by adjusting
;       the p angle as necessary.
;PROCEDURE:
;     Straightforward spherical trig.
;MODIFICATION HISTORY:
;     T. Metcalf 25-Apr-1994
;     1996-02-15  Allow pixel size to be a 2-element vector.
;     1996-09-04  Changed "keyword_set" to "n_elements() EQ 1" for the 
;                 various keywords so that they can be equal to 0.
;     1996-10-11  Added the x0 and y0 keywords.
;     1996-10-15  Fixed minor bug with undefined qdull_disk when x0,y0 not
;                 set.
;     20-feb-1997 S.L.Freeland - use <get_rb0p> instead of "old" pb0r
;     17-oct-2001 T. metcalf Use double precision.
;     18-Oct-2001 T. Metcalf Use atan to find longitude
;     11-Mar-2005 T. Metcalf Use lonlat2xy to get xy when a mag structure
;                            is passed in.  Not a very significant change.
;-

function get_latlon,data,point=point,date=datin,nx=nx,ny=ny,solar=solar, $
                    radius=sunr,cmd=lon,lat=lat,b0=b0,pixsize=pixsin,pangle=p, $
                    add=add,quiet=quiet,x0=x0,y0=y0,rho=outrho,theta=theta

   if n_elements(data) GT 0 then begin
      sdata = size(data)
      if sdata(n_elements(sdata)-2) NE 8 then message,'Structure required'
   endif
   if n_elements(nx) NE 1 then begin
      if n_elements(data) LE 0 then message,'X Dimension required'
      nx = n_elements(data.b_long(*,0))
   endif
   if n_elements(ny) NE 1 then begin
      if n_elements(data) LE 0 then message,'Y Dimension required'
      ny = n_elements(data.b_long(0,*))
   endif

   if NOT keyword_set(point) and keyword_set(data) then point = data.point
   if keyword_set(solar) then p=0.0 else $
   if n_elements(p) NE 1   then p=point.p
   if n_elements(b0) NE 1  then b0 = point.b0
   if n_elements(pixsin) EQ 2 then pixs = double(pixsin)
   if n_elements(pixsin) EQ 1 then pixs = double([pixsin(0),pixsin(0)])
   if n_elements(pixs) LE 0 then pixs = double(point.pix_size)

   if n_elements(sunr) NE 1 then begin
      if keyword_set(datin) then begin
         dat = anytim2ints(datin)
         sunr=get_rb0p(dat,/radius)
       endif else begin
         if tag_index(point,'RADIUS') LT 0 then message,'Date required'
         sunr=point.radius
      endelse
   endif

   ; center in solar coordinates
   if n_elements(x0) EQ 1 AND n_elements(y0) EQ 1 then begin
      xcenter = x0*pixs(0)
      ycenter = y0*pixs(1)
      center = [xcenter,ycenter]
   endif else begin
      if n_elements(lon) NE 1 then lon = point.cmd
      if n_elements(lat) NE 1 then lat = point.lat
      xy = lonlat2xy([lon,lat]*!radeg,b0=b0,radius=sunr)
      ; rotate to terrestrial coordinates
      center = xy # [[cos(p),-sin(p)], [sin(p),cos(p)]]
      ;xcenter = cos(lat)*sin(lon)*sunr
      ;ycenter = (-cos(lat)*cos(lon)*sin(b0)+sin(lat)*cos(b0))*sunr
      ;; rotate to terrestrial coordinates
      ;center = [xcenter,ycenter] # [[cos(p),-sin(p)], [sin(p),cos(p)]]
   endelse
 
   ; Assume x is west and y is north
   x=(float(lindgen(nx,ny) MOD nx)-(nx-1)/2.)*pixs(0)+center(0)
   y=(float(lindgen(nx,ny) / nx)-(ny-1)/2.)*pixs(1)+center(1)

   x = double(x)
   y = double(y)

   rho = sqrt(x^2+y^2)<sunr   ; don't let rho off the limb
   outrho = rho/sunr

   ;rho = asin(rho/sunr) - rho*4.84813681d-6  ; 4.8e-6 is arcsec to radians
   arcsec2rad = 4.84813681d-6
   rho = asin(sin(rho*arcsec2rad)/sin(sunr*arcsec2rad)) - rho*arcsec2rad
   theta = p+atan(x,y)
   srho = sin(rho)
   crho = cos(rho)
   ctheta = cos(theta)
   sb0 = sin(b0)
   cb0 = cos(b0)

   lat = asin(sb0*crho+cb0*srho*ctheta)
   lon = atan(srho*sin(theta),(crho*cb0-srho*sb0*ctheta))

   if keyword_set(add) and keyword_set(data) then begin
      if tag_index(data,'LATITUDE') GE 0 then data.latitude=lat*!radeg $
      else data=add2str(data,'LATITUDE',lat*!radeg,quiet=quiet)
      if tag_index(data,'CMD') GE 0 then data.cmd=lon*!radeg $
      else data=add2str(data,'CMD',lon*!radeg,quiet=quiet)
   endif

   return,{latitude:lat*(180.0d0/!dpi),cmd:lon*(180.0d0/!dpi)}


end
