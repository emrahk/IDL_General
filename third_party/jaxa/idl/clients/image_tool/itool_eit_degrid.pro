;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_EIT_DEGRID()
;
; PURPOSE: 
;       Degrid an EIT full-resolution, full field-of-view image
;
; CATEGORY:
;       Image_tool, misc
; 
; SYNTAX: 
;       Result = itool_eit_degrid(image, header)
;
; INPUTS:
;       IMAGE  - 2-d array, full-resolution, full field-of-view EIT image
;       HEADER - FITS header of the image file
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS: 
;       NO_COPY - set to not make dual copies of input image
;                 (only use if output image replaces input image) 
;
; COMMON:
;       None.
;
; RESTRICTIONS: 
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, March 23, 1996, D.M. Fecit. Written
;       Version 2, April 22, 1996, Liyun Wang, NASA/GSFC
;          Renamed from EIT_DEGRID and incorporated into the CDS software tree
;       Version 3, August 15, 1996, Liyun Wang, NASA/GSFC
;          Modified from July 22, 1996 version of eit_degrid.pro (in 
;             $SSW_EIT/idl/anal)
;       Version 4, June 4, 1998, Zarro (SAC/GSFC) - added /NO_COPY
;	Version 5, 30-Jul-1998, William Thompson, GSFC
;		Added check to make sure degrid data file exists.
;	Version 6, 30-Jul-1998, Zarro, SAC/GSFC
;		Added extra initial check for SSW_EIT definition
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-

FUNCTION junk_find_keyword, fits_header, keyword
;---------------------------------------------------------------------------
;  Finds the FITS header line containing the given keyword.
;---------------------------------------------------------------------------
   nh = N_ELEMENTS(fits_header) 
   ih = 0 
   match = 0
   WHILE (ih LT nh) AND (match EQ 0) DO BEGIN
      IF STRPOS(fits_header(ih), keyword) LT 0 THEN BEGIN
         ih = ih + 1
      ENDIF ELSE match = 1
   END
   IF ih EQ nh THEN ih = -1
   RETURN, ih 
END


FUNCTION itool_eit_degrid, image, fits_header, final=final,no_copy=no_copy

  have_def=trim(getenv('SSW_EIT')) ne ''
  if not have_def then return,image
 
;---------------------------------------------------------------------------
;  ITOOL_EIT_DEGRID degrids an EIT full-resolution, full field-of-view image.
;  
;  Note that it is assumed that missing blocks have been raised to the
;  detector offset, and the detector offset subtracted.
;---------------------------------------------------------------------------
;

;---------------------------------------------------------------------------
;  Let's make this easy if it's a dark or a calibration lamp image: if
;  it is, we obviously don't want to degrid the image.
;---------------------------------------------------------------------------

   object_pos = junk_find_keyword(fits_header, 'OBJECT  =')
   object = STRMID(fits_header(object_pos), 11, 16)
   IF (object EQ 'Calibration lamp') OR $
      (STRMID(object, 0, 4) EQ 'Dark') THEN RETURN, image

   if keyword_set(no_copy) then a = temporary(image) else a=image & sz_a=SIZE(a)

   IF NOT KEYWORD_SET(final) THEN final = 0

   corner_offset = [-1, -1, -20, -20]

   utc_date_19960307 = anytim2utc('1996/03/07')
   utc_date_19960321 = anytim2utc('1996/03/21')
   utc_date_19960323 = anytim2utc('1996/03/23')
   utc_date_19960327 = anytim2utc('1996/03/27')

   n_x = sz_a(1) & n_y=sz_a(2)

   IF ((n_x + n_y) LT 2048) THEN BEGIN

      corner = INTARR(4)
      ih = junk_find_keyword(fits_header, "COMMENT   P1_X")

;---------------------------------------------------------------------------
;     An entirely klugey case for the 1996 March 7 south polar plume study.
;---------------------------------------------------------------------------
      IF ih LT 0 THEN BEGIN
         ih = junk_find_keyword(fits_header, "DATE_OBS")
         a_pos = STRPOS(fits_header(ih), "'")
         date_obs = STRMID(fits_header(ih), a_pos + 1, 24)
         utc_date_obs = anytim2utc(date_obs)
         IF utc_date_obs.mjd EQ utc_date_19960307.mjd THEN BEGIN
            corner = [256, 767, 481, 800]
         ENDIF ELSE IF utc_date_obs.mjd EQ utc_date_19960321.mjd THEN BEGIN
            corner = [256, 767, 800, 1023]
         ENDIF
      ENDIF ELSE BEGIN
         FOR i_corner=0, 3 DO BEGIN
            corner(i_corner) = FIX(STRMID(fits_header(ih + i_corner), 24, 4))
         END

;---------------------------------------------------------------------------
;        fix for incorrect entry of pixel size.
;---------------------------------------------------------------------------
         IF (corner(0) MOD 2) AND (corner(1) MOD 2) THEN $
            corner_offset = [-1, -2, -20, -20]

         corner = corner + corner_offset
      END
;---------------------------------------------------------------------------
;  First case: full FOV, pixel summing
;---------------------------------------------------------------------------
   ENDIF ELSE $
      corner = [0, 1023, 0, 1023]

   x_bin = 1 & y_bin=1
   nx_grid = corner(1) - corner(0) + 1
   ny_grid = corner(3) - corner(2) + 1
   IF nx_grid GT n_x THEN x_bin = nx_grid/n_x
   IF ny_grid GT n_y THEN y_bin = ny_grid/n_y
   
   degrid = 1

   degrid_file = concat_dir(getenv('SSW_EIT'),'response', /dir)
   degrid_file = concat_dir(degrid_file, 'degrid_')

   ih = junk_find_keyword(fits_header, "WAVELNTH")
   p_pos = STRPOS(fits_header(ih), '/')
   wave = STRMID(fits_header(ih), p_pos - 4, 3)

   ih = junk_find_keyword(fits_header, "FILTER")
   a_pos = STRPOS(fits_header(ih), "'")
   filter_string = STRMID(fits_header(ih), a_pos + 1, 5)

;---------------------------------------------------------------------------
;  For now, clear means Al +1 and Al +2 means clear (clear?). For
;  anything else, punt. 
;---------------------------------------------------------------------------
   ih = junk_find_keyword(fits_header, "DATE_OBS")
   a_pos = STRPOS(fits_header(ih), "'")
   date_obs = STRMID(fits_header(ih), a_pos + 1, 24)
   utc_date_obs = anytim2utc(date_obs)

   IF (NOT final) AND (utc_date_obs.mjd LT utc_date_19960327.mjd) $
      AND (utc_date_obs.mjd NE utc_date_19960323.mjd) THEN BEGIN
      IF STRLOWCASE(filter_string) EQ 'clear' THEN BEGIN
         degrid_file = degrid_file + wave + '_' + 'al1.dat'
      ENDIF ELSE IF STRLOWCASE(filter_string) EQ 'al +2' THEN BEGIN
         degrid_file = degrid_file + wave + '_' + 'clear.dat'
      ENDIF ELSE degrid = 0
   ENDIF ELSE BEGIN
      IF STRLOWCASE(filter_string) EQ 'clear' THEN BEGIN
         degrid_file = degrid_file + wave + '_' + 'clear.dat'
      ENDIF ELSE IF STRLOWCASE(filter_string) EQ 'al +1' THEN BEGIN
         degrid_file = degrid_file + wave + '_' + 'al1.dat'
      ENDIF ELSE degrid = 0
   END

   IF NOT FILE_EXIST(degrid_file) THEN degrid = 0

   IF degrid THEN BEGIN

      IF !version.os EQ 'vms' THEN $
         OPENR, degrid_unit, degrid_file, /GET_LUN, /block $
      ELSE $
         OPENR, degrid_unit, degrid_file, /GET_LUN, /xdr

      degrid_array = FLTARR(1024, 1024)
      READU, degrid_unit, degrid_array
      CLOSE, degrid_unit 
      FREE_LUN, degrid_unit
      dg_mult = degrid_array(corner(0):corner(1), corner(2):corner(3))
      IF (x_bin EQ 1) AND (y_bin EQ 1) THEN BEGIN
         a = TEMPORARY(a)*temporary(dg_mult)
      ENDIF ELSE BEGIN
         a = TEMPORARY(a)*temporary(REBIN(dg_mult, n_x, n_y))
      END
   ENDIF ELSE $
      a = FLOAT(TEMPORARY(a))

   RETURN, a 
END

