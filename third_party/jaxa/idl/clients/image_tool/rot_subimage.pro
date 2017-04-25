;----------------------------------------------------------------------
; Document name: rot_subimage.pro
; Created by:    Liyun Wang, NASA/GSFC, December 13, 1994
;
; Last Modified: Thu Sep  4 15:16:54 1997 (lwang@achilles.nascom.nasa.gov)
;----------------------------------------------------------------------
;
PRO ROT_SUBIMAGE, image, new_image, time_gap, date, xx, yy, csi=csi, $
       status=status
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ROT_SUBIMAGE
;
; PURPOSE:
;       Modify an image array with a rotated region
;
; EXPLANATION:
;       Given a region specified by two 2-element array xx, and yy, this
;       routine returns a new image array in which value of all pixels is set
;       to the minimum value of the image array except those in the region
;       which are rotated to a new place based on the solar rotation.
;
; CALLING SEQUENCE:
;       ROT_SUBIMAGE, image, new_image, time_gap, date, xx, yy, csi=csi
;
; INPUTS:
;       IMAGE    - 2D image array
;       TIME_GAP - Time interval (in days) over which the image is rotated
;       DATE     - Current time and date in CCSDS or ECS format
;       XX       - [x1, x2], in data pixels, starting and ending pixels of the
;                  subimage in X direction
;       YY       - [y1, y2], in data pixels, starting and ending pixels of the
;                  subimage in Y direction
;       CSI -- Coordinate system information structure that contains some
;              basic information of the coordinate systems involved. 
;              For more information about CSI, take a look
;              at itool_new_csi.pro
;
;              Note: Units used for CRVAL1 ans CRVAL2 are arc senconds in
;                    case of solar images. If the reference point is
;                    the solar disk center, CRVAL1 = CRVAL2 = 0.0. The
;                    reference point can also be the first pixel of
;                    the image (i.e., the pixcel on the lower-left
;                    coner of the image).
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       NEW_IMAGE - Modified image array. Only those pixels in the subimage
;                   are rotated, the rest of pixcels are set to the minimum
;                   value of the original image array
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       STATUS    - Status flag indicating success (1) or failure/cancel (0)
;
; CALLS:
;       DIFF_ROT, CNVT_COORD, ANYTIM2UTC
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
;       Planing/Image_tool
;
; HISTORY:
;       Version 1, December 13, 1994, Liyun Wang, NASA/GSFC. Written
;       Version 2, May 9, 1997, Liyun Wang, NASA/GSFC
;          Added progress meter
;          Added the STATUS keyword   
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   status = 1
;----------------------------------------------------------------------
;  Check the validity of input parameters
;----------------------------------------------------------------------
   IF N_ELEMENTS(image) EQ 0 OR N_ELEMENTS(xx) EQ 0 OR N_ELEMENTS(yy) EQ 0 OR $
      N_ELEMENTS(csi) EQ 0 THEN BEGIN 
      MESSAGE, /cont, $
         'Syntax: ROT_SUBIMAGE, image, new_image, time_gap, date, xx,yy, csi=csi'
      status = 0
   ENDIF
   IF N_ELEMENTS(xx) NE 2 OR N_ELEMENTS(yy) NE 2 THEN BEGIN
      MESSAGE, 'XX (and YY) must be 2-element array.', /cont
      status = 0
   ENDIF      
   IF datatype(csi) NE 'STC' THEN BEGIN
      MESSAGE, 'CSI must be a 14-tag structure.', /cont
      status = 0
   ENDIF      
   
   sz = SIZE(image)
   IF sz(0) NE 2 THEN BEGIN
      MESSAGE, 'Input image array must be 2-dimensional.', /cont
      status = 0
   ENDIF
   IF status EQ 0 THEN RETURN
   
   new_image = image 
;----------------------------------------------------------------------
;  When converting rotated point(s) back, new time should be used
;----------------------------------------------------------------------
   msec = LONG(time_gap*8640000.0) ; in milliseconds
   new_date = anytim2utc(date)
   new_date.time = new_date.time+msec(0)
   x1 = xx(0) & x2 = xx(1)
   y1 = yy(0) & y2 = yy(1)
   IF (x2-x1) LE 0 OR (y2-y1) LE 0 THEN BEGIN 
      MESSAGE, 'Invalid subimage index.'
      status = 0
      RETURN
   ENDIF

;----------------------------------------------------------------------
;  Start doing differential rotation for each row/column in sumimage
;----------------------------------------------------------------------
   pid = progmeter(/init, label='Calculating...', button='Cancel')
   step = 2.0
   IF (x2-x1) GE (y2-y2) THEN BEGIN
      xx = x1+INDGEN(x2-x1+1)
      yy = xx
      last_val = 0.0
      nt = y2-y1+1
      FOR i = y1, y2 DO BEGIN
         yy(*) = i
         val = FLOAT(i-y1+1.0)/nt
         IF ABS((val-last_val))*100.0 GT step THEN BEGIN
            IF (progmeter(pid, val) EQ 'Cancel') THEN BEGIN
               xkill, pid
               status = 0
               RETURN
            ENDIF
            last_val = val
         ENDIF
         helio = cnvt_coord([[xx], [yy]], csi=csi, from=2, to=4, date=date)
         helio(*, 1) = helio(*, 1)+diff_rot(time_gap, helio(*, 0), /synodic)
         helio = cnvt_coord(helio, csi=csi, from=4, to=2, date=new_date)
         new_image(helio(*, 0), helio(*, 1)) = image(x1:x2, i)
      ENDFOR
   ENDIF ELSE BEGIN
      yy = y1+INDGEN(y2-y1+1)
      xx = yy 
      nt = x2-x1+1
      FOR i = x1, x2 DO BEGIN
         xx(*) = i
         val = FLOAT(i-x1+1.0)/nt
         IF ABS((val-last_val))*100.0 GT step THEN BEGIN
            IF (progmeter(pid, val) EQ 'Cencel') THEN BEGIN
               xkill, pid
               status = 0
               RETURN
            ENDIF
            last_val = val
         ENDIF
         helio = cnvt_coord([[xx], [yy]], csi=csi, from=2, to=4, date=date)
         helio(*, 1) = helio(*, 1)+diff_rot(time_gap, helio(*, 0), /synodic)
         helio = cnvt_coord(helio, csi=csi, from=4, to=2, date=new_date)
         new_image(helio(*, 0), helio(*, 1)) = image(i, y1:y2)
      ENDFOR
   ENDELSE
   xkill, pid
END

;----------------------------------------------------------------------
; End of 'rot_subimage.pro'.
;----------------------------------------------------------------------
