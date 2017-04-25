;+
; PROJECT:
;       SOHO
;
; NAME:
;       CNVT_COORD()
;
; PURPOSE:
;       Conversion between any 2 of 4 coord systems for solar images
;
; EXPLANATION:
;       For image displaying, especially for the solar images, there
;       can be at least four coordinate systems involved, and they are:
;
;           1. Device coordinate system, in device pixels
;           2. Data (image) coordinate system, in data pixels (base 1)
;           3. Solar disk coordinate system, in arc seconds
;           4. Heliographic coordinate system, in degrees
;
;       This routine can do the conversion between any two of
;       them. For the solar disk system (with origin at the disk
;       center), the positive directions of the X and Y axes point to
;       the west limb and north limb, respectively.
;
; CALLING SEQUENCE:
;       Result = CNVT_COORD(xx [, yy], csi=csi, from=from, to=to)
;
; INPUTS:
;       XX  -- X coordinates of points to be converted. Scalar or
;              vector if YY is passed; if YY is not passed,
;              XX must be either 2-element vector or Nx2 array.
;              Depending on the coordinate system, values of XX can be
;              pixel number in X direction for device system (1) or
;              data (image) system (2), or Solar X in arcsec in solar
;              disk system (3), or latitude in degrees for
;              heliographic system (4).  
;
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems
;              involved. For more information about CSI, take a look
;              at itool_new_csi.pro
;
;              Note: Units used for CRVAL1 and CRVAL2 are arc seconds in
;                    case of solar images. If the reference point is
;                    the solar disk center, CRVAL1 = CRVAL2 = 0.0. The
;                    reference point can also be the first pixel of
;                    the image (i.e., the pixel on the lower-left
;                    corner of the image).
;
;       FROM -- Code for the original coordinate system (see explanation)
;       TO   -- Code for the new coordinate system to be converted
;               to. Possible values are the same as those of FROM
;
; OPTIONAL INPUTS:
;       YY  -- Y coordinates of points to be converted. Scalar or
;              vector; must have the same number of elements as XX
;              Depending on the coordinate system, values of YY can be
;              pixel number in Y direction for device system (1) or
;              data (image) system (2), or Solar Y in arcsec in solar
;              disk system (3), or longitude in degrees for
;              heliographic system (4). 
;
; OUTPUTS:
;       RESULT -- A Nx2 array, containing new coordinates;
;                 refer to the input description of XX (and YY) for returned
;                 values for different coordinate systems. A scalar
;                 value of -1 will be returned for a non-valid
;                 conversion or wrong type of data.
;
; OPTIONAL OUTPUTS:
;       OFF_LIMB -- Flag which is true if the coordinates are beyond
;                   the solar limb. Only used for converting to the
;                   heliographic system
;
; KEYWORD PARAMETERS:
;       DATE -- date in CCSDS or ECS time format; required for
;               conversion between heliographic coordinate system to
;               or from other system. If not passed, CSI.DATE_OBS
;               will be used.
;
; CALLS:
;       ARCMIN2HEL, HEL2ARCMIN
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;
; HISTORY:
;       Version 1, November 16, 1994, Liyun Wang, GSFC/ARC, Written.
;       Version 2, August 28, 1996, Liyun Wang, NASA/GSFC
;          Used ROUND (instead of FIX) to get coordinates for device
;             and data systems
;       Version 3, August 13, 1997, Liyun Wang, NASA/GSFC
;          Made conversion from 1 to 3 more accurate especially when
;             showing images with less pixels
;          Made DATE as optional keyword.
;       Version 4, September 2, 1997, Liyun Wang, NASA/GSFC
;          Modified to use column major array for I/O.
;
; VERSION:
;       Version 4, September 2, 1997
;-
FUNCTION cnvt_2to3, aa, csi
   ix = FLOAT(csi.cdelt1*(aa(*, 0)-csi.crpix1)+csi.crval1)
   iy = FLOAT(csi.cdelt2*(aa(*, 1)-csi.crpix2)+csi.crval2)
   RETURN, [[ix], [iy]]
END

FUNCTION cnvt_1to3, aa, csi
;---------------------------------------------------------------------------
;  detl1 and delt2 are scaling factor in units of arcsec/(device
;  pixel), val1 and val2 are solar coordinates at lower
;  left edge (corner) of the 1st image pixel in device system, or 
;  center of the device pixel at the lower-left corner of display area
;---------------------------------------------------------------------------
   delt1 = DOUBLE(csi.cdelt1*csi.ddelt1)
   delt2 = DOUBLE(csi.cdelt2*csi.ddelt2)
   temp = cnvt_coord(1, 1, from=2, to=3, csi=csi)
   val1 = (temp(0, 0)-0.5*csi.cdelt1)+0.5*csi.ddelt1
   val2 = (temp(0, 1)-0.5*csi.cdelt2)+0.5*csi.ddelt2
;   val1 = csi.crval1-(csi.crpix1-0.5)*csi.cdelt1
;   val2 = csi.crval2-(csi.crpix2-0.5)*csi.cdelt2
   ix = val1+delt1*(aa(*, 0)-csi.drpix1)
   iy = val2+delt2*(aa(*, 1)-csi.drpix2)
   RETURN, [[ix], [iy]]
END

FUNCTION CNVT_COORD, xx, yy, csi=csi, from=from, to=to, date=date, $
                     off_limb=off_limb
   ON_ERROR, 2
   IF N_ELEMENTS(from)*N_ELEMENTS(to) EQ 0 THEN BEGIN
      MESSAGE, 'Must specify FROM and TO keywords.', /cont
      RETURN, -1
   ENDIF
   IF from EQ to THEN BEGIN
      MESSAGE, 'No need to make a conversion.', /cont
      RETURN, -1
   ENDIF
   mess = 'Input parameter must be a 2-element vector or Nx2-element array.'
   code = from*10+to
   IF N_ELEMENTS(yy) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;     Only one argument passed in
;---------------------------------------------------------------------------
      sz = SIZE(xx)
      IF sz(0) EQ 1 THEN BEGIN
         IF sz(1) NE 2 THEN BEGIN
            MESSAGE, mess, /cont
            RETURN, -1
         ENDIF
         xa = xx(0)
         ya = xx(1)
      ENDIF ELSE BEGIN
         IF sz(2) NE 2 THEN BEGIN
            MESSAGE, mess, /cont
            RETURN, -1
         ENDIF
         xa = xx(*, 0)
         ya = xx(*, 1)
      ENDELSE
   ENDIF ELSE BEGIN
      xa = xx
      ya = yy
   ENDELSE
   n_pts = N_ELEMENTS(xa)

   IF N_ELEMENTS(date) EQ 0 THEN date = csi.date_obs
   off_limb = INTARR(n_pts)
   aa = FLOAT([[xa], [ya]])
   CASE (code) OF
      12: BEGIN
         ix = (ROUND(csi.ddelt1*(aa(*, 0)-csi.drpix1)+1.0) > 1) ;< csi.naxis1
         iy = (ROUND(csi.ddelt2*(aa(*, 1)-csi.drpix2)+1.0) > 1) ;< csi.naxis2
         RETURN, [[ix], [iy]]
      END
      13: BEGIN
         RETURN, cnvt_1to3(aa, csi)
      END
      14: BEGIN
         temp = cnvt_1to3(aa, csi)/60.0
         temp = arcmin2hel(temp(*, 0), temp(*, 1), date=date, $
                           off_limb=off_limb)
         RETURN, TRANSPOSE(temp)
      END
      21: BEGIN
         ix = (csi.drpix1+ROUND(0.5/csi.ddelt1)+(aa(*, 0)-1)/csi.ddelt1) ; > 0
         iy = (csi.drpix2+ROUND(0.5/csi.ddelt2)+(aa(*, 1)-1)/csi.ddelt2) ; > 0
         RETURN, [[ROUND(ix)], [ROUND(iy)]]
      END
      23: BEGIN
         RETURN, cnvt_2to3(aa, csi)
      END
      24: BEGIN
         temp = cnvt_2to3(aa, csi)/60.0
         temp = arcmin2hel(temp(*, 0), temp(*, 1),  date=date, $
                           off_limb=off_limb)
         RETURN, TRANSPOSE(temp)
      END
      32: BEGIN
         ix = csi.crpix1+FLOAT((aa(*, 0)-csi.crval1)/csi.cdelt1)
         iy = csi.crpix2+FLOAT((aa(*, 1)-csi.crval2)/csi.cdelt2)
         RETURN, [[ROUND(ix)], [ROUND(iy)]]
      END
      31: BEGIN
         aa(*, 0) = csi.crpix1+FLOAT((aa(*, 0)-csi.crval1)/csi.cdelt1)
         aa(*, 1) = csi.crpix2+FLOAT((aa(*, 1)-csi.crval2)/csi.cdelt2)
         ix = (csi.drpix1+(aa(*, 0)-1)/csi.ddelt1) ; > 0
         iy = (csi.drpix2+(aa(*, 1)-1)/csi.ddelt2) ; > 0
         RETURN, [[ROUND(ix)], [ROUND(iy)]]
      END
      34: BEGIN
         temp = arcmin2hel(aa(*, 0)/60.0, aa(*, 1)/60.0, date=date, $
                           off_limb=off_limb)
         RETURN, TRANSPOSE(temp)
      END
      42: BEGIN
         temp = 60.0*TRANSPOSE(hel2arcmin(aa(*, 0), aa(*, 1), date=date))
         ix = csi.crpix1+FLOAT((temp(*, 0)-csi.crval1)/csi.cdelt1)
         iy = csi.crpix2+FLOAT((temp(*, 1)-csi.crval2)/csi.cdelt2)
         RETURN, [[ROUND(ix)], [ROUND(iy)]]
      END
      43: BEGIN
         temp = 60.0*TRANSPOSE(hel2arcmin(aa(*, 0), aa(*, 1), date=date))
         RETURN, temp
      END
      41: BEGIN
         aa = 60.0*TRANSPOSE(hel2arcmin(aa(*, 0), aa(*, 1), date=date))
         aa(*, 0) = csi.crpix1+FLOAT((aa(*, 0)-csi.crval1)/csi.cdelt1)
         aa(*, 1) = csi.crpix2+FLOAT((aa(*, 1)-csi.crval2)/csi.cdelt2)
         ix = (csi.drpix1+(aa(*, 0)-1)/csi.ddelt1) ; > 0
         iy = (csi.drpix2+(aa(*, 1)-1)/csi.ddelt2) ; > 0
         RETURN, [[ROUND(ix)], [ROUND(iy)]]
      END
      ELSE: RETURN, -1
   ENDCASE
END
