
function mk_mdi_map_earth,mindex,mdata,degree=degreein,verbose=verbose, $
                          use_warp_tri=use_warp_tri,_extra=_extra

;+
;NAME:
;     MK_MDI_MAP_EARTH
;PURPOSE:
;     Make an MDI map structure with the image as it would have
;     been seen from the Earth perspective.  The pointing is 
;     updated and the image is warped to the Earth view.
;CATEGORY:
;CALLING SEQUENCE:
;     mdi_map = mk_mdi_map_earth(mdi_index,mdi_data)
;INPUTS:
;     mdi_index = MDI index structure(s)
;     mdi_data = MDI image(s)
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
;     mdi_map = MDI map structure for plot_map etc. with the
;               correct information to plot Earth data on
;               top of it.  
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
;-

     if NOT keyword_set(degreein) then degree=2 else degree=fix(degreein)>1

     nimage = n_elements(mdata[0,0,*])
     nx_image = n_elements(mdata[*,0,0])
     ny_image = n_elements(mdata[0,*,0])
     
     for i=0L,nimage-1L do begin

        if keyword_set(verbose) then message,/info,'Image '+string(i)

        earth_L0 = mindex[i].earth_L0
        obs_L0  = mindex[i].obs_L0
        earth_B0 = mindex[i].earth_B0
        obs_B0 = mindex[i].obs_B0
        obs_R0 = mindex[i].obs_R0

        ; compute the parallax in longitude: mindex.obs_L0-mindex.earth_L0
        value = (obs_L0-earth_L0+180.) MOD 360.
        neg = where(value LT 0.,count)
        if count GT 0 then value(neg) = value(neg) + 360.
        plon = value - 180. ; this is mindex.obs_L0-mindex.earth_L0 in [-180,+180]

        ; Get lat and cmd of the image from the SOHO viewpoint
        latlon = get_latlon(nx=nx_image, $
                            ny=ny_image, $
                            x0=(nx_image-1.)/2.0-mindex[i].x0, $
                            y0=(ny_image-1.)/2.0-mindex[i].y0, $
                            b0=obs_b0*!dtor, $
                            pang=mindex[i].solar_p*!dtor, $  ; should be zero
                            pixs=mindex[i].im_scale, $
                            rad=obs_r0)
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

        if ngood LE 0 then message,'Data is too far off the limb'
        delvarx,behind,behinde,r

        ; Warp the image to the earth view

        ; Take out the overall shift before warping.  This shift is accounted
        ; for by adjusting the coordinates of the center of the image, not
        ; by warping the image.

        ;xcen = bilinear(reform(xy[0,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)
        ;ycen = bilinear(reform(xy[1,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)
        xcene = bilinear(reform(xye[0,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)-xshift
        ycene = bilinear(reform(xye[1,*],nx_image,ny_image),(nx_image-1)/2.,(ny_image-1)/2.)-yshift

        xe = reform((xye[0,good]-xcene)/mindex[i].im_scale + (nx_image-1)/2.)
        ye = reform((xye[1,good]-ycene)/mindex[i].im_scale + (ny_image-1)/2.)
        ; Make uniform grid to warp onto
        ;x = reform((xy[0,good]-xcen)/mindex[i].im_scale + (nx_image-1)/2.)
        ;y = reform((xy[1,good]-ycen)/mindex[i].im_scale + (ny_image-1)/2.)
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
        scale = mindex[i].EARTH_R0/mindex[i].OBS_R0
        mmapi.dx = (mmapi.dx)*scale
        mmapi.dy = (mmapi.dy)*scale
        mmapi.xc = (xcene)*scale
        mmapi.yc = (ycene)*scale
        mmapi.soho = 0

        if n_elements(mmap) LE 0 then mmap = mmapi else mmap=[mmap,mmapi]
      endfor

   return,mmap

end
