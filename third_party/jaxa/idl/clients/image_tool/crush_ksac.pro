;--------------------------------------------------------------------------
; Document name: crush_ksac.pro
; Created by:    Liyun Wang, GSFC/ARC, May 2, 1995
;
; Last Modified: Thu Dec 21 14:28:25 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;       Version 1, May 2, 1995, Liyun Wang, GSFC/ARC, written
;       Version 2, December 21, 1995, Liyun Wang, GSFC/ARC
;          Modified to reflect the change in DATE_OBS format made at KSAC
;
PRO crush_ksac, fits_file
;---------------------------------------------------------------------------
;  A program to rewrite FITS files from the Sacreamental Peak
;
;  FITS image files from National Obs. at Sacreamental Peak contain images
;  with 2200x2200 pixels, and do not necessarily have correct information
;  or format on scaling factors, date and time of observation, and they
;  are just too big (nearly 10 MB for each file). This program reads in
;  such a FITS file at a step size of 4 (to reduce the image into a
;  550x550 array) and adds in necessary FITS keywords in the header so
;  that the processed FITS file can be readily used by IMAGE_TOOL.
;
;  The input file name must conform the SOHO synoptic filenaming convention
;  (e.g., ksac_caiik_fd_19950811_1524.fts)
;
;  The assumption is that the following conditions always hold in the
;  original FITS file:
;
;     The solar image is centered in the image; solar N top, E left; the
;     disk diameter is 2000 pixels
;
;  The side effect of this routine is that the original FITS file is
;  modified; this is the intention of running this program.
;---------------------------------------------------------------------------
   step = 4
   err=''
   fxread, fits_file, data, header_orig, step, /average,err=err
   if err ne '' then begin
    message,err,/cont
    return
   endif

;---------------------------------------------------------------------------
;  If the original NAXIS1 or NAXIS2 is less than 800, no need to crush
;---------------------------------------------------------------------------
   IF fxpar(header_orig,'NAXIS1') LE 800 OR $
      fxpar(header_orig,'NAXIS2') LE 800 THEN RETURN

   lambda = fxpar(header_orig,'LAMBDA')
   old_name = fxpar(header_orig,'FILENAME')

   fxhmake, header_new, data
   new_file = fits_file
   err = ''
   fxwrite, new_file, header_new, data, /NOUPDATE, err=err
   IF err NE '' THEN BEGIN
;---------------------------------------------------------------------------
;     If error occurs, write the original file back
;---------------------------------------------------------------------------
      PRINT, err
      err = ''
      fxwrite, fits_file, header_orig, data, err=err
      RETURN
   ENDIF
   break_file, fits_file, disk_log, dir, filnam, ext, fversion, node

   date = fxpar(header_orig, 'DATE_OBS')
   IF date EQ '' THEN BEGIN
;---------------------------------------------------------------------------
;     Get obs. date from filename
;---------------------------------------------------------------------------
      year = STRMID(filnam,14,2)
      month = STRMID(filnam,18,2)
      day = STRMID(filnam,20,2)
      date = day+'/'+month+'/'+year
      fxhmodify, new_file, 'DATE-OBS', date
   ENDIF

   time = fxpar(header_orig, 'TIME_OBS')
   IF time EQ '' THEN BEGIN
;---------------------------------------------------------------------------
;     Get obs. time from filename
;---------------------------------------------------------------------------
      hour = STRMID(filnam,23,2)
      minute = STRMID(filnam,25,2)
      time = hour+':'+minute+':00'
      fxhmodify, new_file, 'TIME-OBS', time
   ENDIF

;---------------------------------------------------------------------------
;  Fix values for CRPIX1 and CRPIX2
;---------------------------------------------------------------------------
   crpix1 = FLOAT(fxpar(header_new, 'NAXIS1')-1)/2.0
   crpix2 = FLOAT(fxpar(header_new, 'NAXIS2')-1)/2.0
   fxhmodify, new_file, 'CRPIX1', crpix1
   fxhmodify, new_file, 'CRPIX2', crpix2

   OPENU, unit, new_file, /block, /get_lun
   fxhread, unit, header_tmp, status
   FREE_LUN, unit
   IF status EQ 0 THEN header_new = header_tmp ELSE BEGIN
      MESSAGE, 'Error occurred in FXHREAD.', /cont
      RETURN
   ENDELSE

   err=''
   fxread, new_file, data, header_new,err=err
   if err ne '' then begin
    message,err,/cont
    return
   endif 
   img_utc = get_obs_date(header_new)
   angles = pb0r(img_utc)
   sradius = 60.*angles(2)

;---------------------------------------------------------------------------
;  Suppose the solar disk diameter is originally 2000 pixels, then
;  current one will be 2000.0/4 = 500.0 pixels
;---------------------------------------------------------------------------
   radius = fxpar(header_orig,'CRRADIUS')
   IF radius EQ '' THEN radius = 2000./step/2.0
   fxhmodify, new_file, 'CRRADIUS', radius
   cdelt1 = sradius/radius
   fxhmodify, new_file, 'CDELT1', cdelt1
   fxhmodify, new_file, 'CDELT2', cdelt1

   fxhmodify, new_file, 'ORIGIN', 'KSAC'

   type_str = STRMID(filnam,5,5)
   IF type_str EQ 'halph' THEN type = 'HALPHA' ELSE type = 'K'

   fxhmodify, new_file, 'TYPE-OBS', type
   IF lambda NE '' THEN fxhmodify, new_file, 'LAMBDA', lambda
   IF old_name NE '' THEN fxhmodify, new_file, 'FILENAME', old_name

   RETURN
END

;---------------------------------------------------------------------------
; End of 'crush_ksac.pro'.
;---------------------------------------------------------------------------
