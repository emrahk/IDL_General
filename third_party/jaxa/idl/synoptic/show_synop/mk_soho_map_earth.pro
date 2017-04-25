
function mk_soho_map_earth,mindex,mdata,degree=degreein,verbose=verbose, $
                          use_warp_tri=use_warp_tri,_extra=_extra

;+
;NAME:
;     MK_SOHO_MAP_EARTH
;PURPOSE:
;     Make a SOHO map structure with the image as it would have
;     been seen from the Earth perspective.  The pointing is 
;     updated and the image is warped to the Earth view.
;CATEGORY:
;CALLING SEQUENCE:
;     map = mk_soho_map_earth(index,data)
;INPUTS:
;     index = SOHO index structure(s)
;     data = SOHO image(s)
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS:
;     /use_warp_tri = Use warp_tri instead of polywarp to do the
;                     image warping.  This is much more robust,
;                     particularly near the limb, but also much 
;                     slower.  The default is to use polywarp since
;                     it is faster.
;     /quintic,/extrapolate = Passed to warp_tri if use_warp_tri is set.
;     degree = integer degree of warping passed to polywarp.  
;              The default is 2.  The best value is about 3 or 4,
;              but that takes longer.   Higher than 5 will fail 
;              rather dramatically.  Ignored if use_warp_tri is set.
;     /verbose = print some diagnostics
;OUTPUTS:
;     map = map structure for plot_map etc. with the
;           correct information to plot Earth data on
;           top of it.  
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;     This routine is like map2earth.pro, but it accounts for the
;     parallax between L1 and Earth.  map2earth only corrects the 
;     pixel scale.
;MODIFICATION HISTORY:
;     T. Metcalf 2002-Apr-04
;     T. Metcalf 2002-Apr-09 Fixed index problem in call to polywarp.
;                            Added nowarp keyword.
;     T. Metcalf 2002-Apr-11 Fixed small bug in map center.  Added 
;                            degree keyword.
;     T. Metcalf 2002-Apr-12 Added warp_tri option which is very slow
;                            but also very robust.
;     T. Metcalf 2002-Apr-23 Fixed a bug that caused the warping to fail
;                            near the limb.
;     T. Metcalf 2002-Oct-21 Upgraded mk_mdi_map_earth to mk_soho_map_earth
;     T. Metcalf 2003-Jan-29 Cleaned up code and did some more testing.
;     T. Metcalf 2005-Jan-25 Force the roll angle in the output map to
;                            be zero since the roll angle is correctd
;                            in the warping process.
;-

     if NOT keyword_set(degreein) then degree=2 else degree=fix(degreein)>1

     nimage = n_elements(mdata[0,0,*])
     nx_image = n_elements(mdata[*,0,0])
     ny_image = n_elements(mdata[0,*,0])
     
     for i=0L,nimage-1L do begin

        if keyword_set(verbose) then message,/info,'Image '+string(i)

        ; Get SOHO orbital parameters
        get_fits_time,mindex[i],sohotime
        orbit = get_orbit(sohotime)
        earth_L0 = orbit.hel_lon_earth*!radeg
        obs_L0 = orbit.hel_lon_soho*!radeg
        earth_B0 = orbit.hel_lat_earth*!radeg
        obs_B0 = orbit.hel_lat_soho*!radeg
        earth_R0 =get_rb0p(sohotime,/rad)
        obs_R0 = soho_fac(sohotime)*earth_R0

        get_fits_par,mindex[i],xcen,ycen,dx,dy

        ; The location of disk center in pixels
        ; with 0,0 defined as the LL corner pixel
        x0 = (nx_image+1)/2. - xcen/dx - 1.0  
        y0 = (ny_image+1)/2. - ycen/dy - 1.0 
 
        im_scale = dx
        if dx NE dy then message,'ERROR: cant handle non-square pixels'

        ; compute the parallax in longitude: mindex.obs_L0-mindex.earth_L0
        ; plon is mindex.obs_L0-mindex.earth_L0 in range [-180,+180]
        value = (obs_L0-earth_L0+180.) MOD 360.
        neg = where(value LT 0.,count)
        if count GT 0 then value(neg) = value(neg) + 360.
        plon = value - 180. 

        ; Get roll angle.  
        if tag_index(mindex[i],'SOLAR_P') GE 0  then solar_p = mindex.solar_p $
        else if tag_index(mindex[i],'SC_ROLL') then solar_p = mindex.sc_roll $
        else solar_p = 0.0

        ; Get lat and cmd of the image from the SOHO viewpoint
        latlon = get_latlon(nx=nx_image, $
                            ny=ny_image, $
                            x0=(nx_image-1.)/2.0-x0, $
                            y0=(ny_image-1.)/2.0-y0, $
                            b0=obs_b0*!dtor, $
                            pang=solar_p*!dtor, $  ; should be zero
                            pixs=im_scale, $
                            rad=obs_r0)
        if keyword_set(verbose) then begin
           if !d.x_size LT nx_image OR !d.y_size LT ny_image then wdef,nx_image,ny_image
           tvscl,mdata[*,*,i]
           lllevel = [-90,-75,-60,-45,-30,-15,0,15,30,45,60,75,90]
           lllabel = [  1,  1,  1,  1,  1,  1,1, 1, 1, 1, 1, 1, 1]
           ocontour2,latlon.latitude,level=lllevel,c_label=lllabel
           ocontour2,latlon.cmd,level=lllevel,c_label=lllabel
        endif
        lonlat = transpose([[reform(latlon.cmd,nx_image*ny_image)], $
                            [reform(latlon.latitude,nx_image*ny_image)]])
        delvarx,latlon
        ; Get x and y from the SOHO viewpoint
        xy = lonlat2xy(lonlat,b0=obs_b0*!dtor,radius=obs_r0)
        r = reform(sqrt(xy[0,*]^2+xy[1,*]^2),nx_image*ny_image)

        ; The point mindex[i].x0,mindex[i].y0 has latitude obs_b0
        ; and CMD 0.0 in the SOHO frame.  The same point has
        ; CMD of plon and latitude of obs_b0 in the 
        ; Earth frame.

        lonlate = lonlat
        lonlate[0,*] = lonlate[0,*] + plon
        xye = lonlat2xy(lonlate,b0=earth_b0*!dtor,radius=obs_r0,behind=behinde)

        ; Get the shift at disk center between the two views.  We'll
        ; lock this in place later.
        shift = lonlat2xy([plon,obs_b0],b0=earth_b0*!dtor,radius=obs_r0) ; [0,0] at L1
        xshift = shift[0] & yshift = shift[1]

        ; Now figure out which pixels came from behind the limb
        lonlat = xy2lonlat(xy,b0=earth_b0*!dtor,radius=obs_r0)
        lonlat[0,*] = lonlat[0,*] - plon
        junk = lonlat2xy(lonlat,b0=obs_b0*!dtor,radius=obs_r0,behind=behind)
        delvarx,lonlat,lonlate,junk

        ; Only use points in the warping that are not behind the limb in
        ; either view.
        good = where(r LT obs_r0 AND $
                     behinde EQ 0 AND $
                     behind EQ 0,ngood)

        if ngood LE 0 then message,'ERROR: all data is too far off the limb'
        delvarx,behind,behinde,r

        ; Warp the image to the earth view

        ; Take out the overall shift before warping.  This shift is accounted
        ; for by adjusting the coordinates of the center of the image, not
        ; by warping the image.

        xcene = bilinear(reform(xye[0,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)-xshift
        ycene = bilinear(reform(xye[1,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)-yshift

        xe = reform((xye[0,good]-xcene)/im_scale + (nx_image-1)/2.)
        ye = reform((xye[1,good]-ycene)/im_scale + (ny_image-1)/2.)
        ; Make uniform grid to warp onto
        x  = float((lindgen(nx_image,ny_image) MOD nx_image)[good])
        y  = float((lindgen(nx_image,ny_image) / nx_image)[good])

        delvarx,xy,xye,good
     
        if NOT keyword_set(use_warp_tri) then begin
           polywarp,x,y,xe,ye,degree,p,q
           if keyword_set(verbose) then begin
              pq2xy,xe,ye,p,q,xp,yp
              print,strcompress('Max Error (pixels): '+ $
                                string(max(xp-x))+ ' ' + $
                                string(min(xp-x))+ ' ' + $
                                string(max(yp-y))+ ' ' + $
                                string(min(yp-y)))
           endif
           delvarx,xe,ye,x,y
           newimage = poly_2d(mdata[*,*,i],p,q,2,nx_image,ny_image,cubic=-0.5, $
                              missing=0.0)
        endif else begin
           newimage = warp_tri(xe,ye,x,y,mdata[*,*,i],_extra=_extra)
           delvarx,xe,ye,x,y
        endelse

        ; Put the warped image into a map and fix the pixel scale

        index2map,mindex[i],newimage,mmapi
        scale = EARTH_R0/OBS_R0
        mmapi.dx = (mmapi.dx)*scale
        mmapi.dy = (mmapi.dy)*scale
        mmapi.xc = (xcene)*scale
        mmapi.yc = (ycene)*scale
        mmapi.soho = 0
        mmapi.roll_angle = 0.0  ; Any roll angle was removed above

        if n_elements(mmap) LE 0 then mmap = mmapi else mmap=[mmap,mmapi]
      endfor

   return,mmap

end
