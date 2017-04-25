;----------------------------------------------------------------------
; Document name: mk_gif.pro
; Created by:    Liyun Wang, GSFC/ARC, December 7, 1994
;
; Last Modified: Tue Sep  2 15:14:43 1997 (lwang@achilles.nascom.nasa.gov)
;----------------------------------------------------------------------
;
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       MK_GIF
;
; PURPOSE:
;       Convert FITS files to GIF image files
;
; EXPLANATION:
;       Reads one or more FITS files, byte scales them, and then
;       writes them to GIF files. If a title is to be plotted, it
;       will be plotted in upper center position.
;
; CALLING SEQUENCE:
;       MK_GIF, FILE_STC
;
; INPUTS:
;       FILE_STC - A structure with three tags:
;          FILENAME -- Name of the FITS file
;          TITLE    -- Title to be attached in the GIF image
;          COLOR    -- Color table to be loaded; defaults to 0
;          FLIP     -- Flag indicating if the image should be flipped
;                      before conversion.
;          GAMMA    -- Gamma value used for changing the color table.
;                      If gamma value is negative, the image is
;                      logrithum scaled first before gamma correction
;                      is made
;          TOP      -- Portion of top color (0 to 100) to be used
;          BOTTOM   -- Portion of bottom color (0 to 100) to be used
;          MIN      -- String, minimum value to be used for byte scaling
;          MAX      -- String, maximum value to be used for byte scaling
;          REBIN    -- Factor of rebinning; defaults to 1
;          ICON     -- If positive, create "iconized" GIF image as well;
;                      its value also indicates rebinning factor for the
;                      iconized image
;          ICON_STR -- Title to be used in iconized image
;          ICON_FNAME - Full name of iconized GIF image
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
; KEYWORD PARAMETERS:
;       RED, GREEN, BLUE - optional color vectors to override COLOR
;       FRAC    - fraction by which to increase image
;                 size in Y-direction to fit title [def = 10%]
;       ROTATE  - value for rotate (see ROTATE function)
;       FLIP    - flip image to to bottom
;       RVS     - flip (reverse) image left to right
;       SIG     - select significant range of image
;
; CALLS:
;       SSW_WRITE_GIF, CONCAT_DIR, BREAK_FILE, FXREAD
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
; PREVIOUS HISTORY:
;       Written December 7, 1994, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, December 7, 1994
;          Modified from FITS2GIF by Dominic Zarro (ARC)
;       Version 2, Liyun Wang, GSFC/ARC, February 1, 1995
;          Added one tag (FLIP) to the input file structure.
;       Version 3, August 16, 1995, Liyun Wang, GSFC/ARC
;          Used the ERRMSG keyword in the call to FXREAD so that the
;             loop can last if error occurs in reading a FITS file
;       Version 4, March 8, 1996, Liyun Wang, GSFC/ARC
;          Added EIT image auto-scaling, auto-color table loading
;       Version 5, April 4, 1996, Liyun Wang, GSFC/ARC
;          Implemented making iconized GIF files
;       Version 6, December 20, 1996, Liyun Wang, NASA/GSFC
;          Modified such that iconized images will have a fix width of
;             256 pixels, as long as FILE_STC.ICON is greater than 1
;       Version 7, January 28, 1997, Liyun Wang, NASA/GSFC
;          Modified such that if FILE_STC.REBIN is greater than 1 the
;             image is rebined to 512 pixel wide (instead of treating
;             FILE_STC.REBIN as a rebin factor)
;       Version 8, July 16, 1997, Liyun Wang, NASA/GSFC
;          Made call to EIT_PREP if env variable SSW_EIT is set
;	Version 9, William Thompson, GSFC, 8 April 1998
;		Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;       Version 10, 13-Aug-2003, William Thompson
;               Use SSW_WRITE_GIF instead of WRITE_GIF
;
; VERSION:
;	Version 9, 8 April 1998
;-
;
FUNCTION rescale_image, image, minim=minim, maxim=maxim
   IF not KEYWORD_SET(minim) THEN minim = 0b
   IF KEYWORD_SET(maxim) THEN max_scale = FLOAT(maxim) ELSE max_scale = 255.
   val_min = MIN(image)
   val_max = MAX(image)
   offset = (val_min - minim) > 0b
   image = TEMPORARY(image) - val_min
   scl = (max_scale - minim)/val_max
   image = BYTE(scl*TEMPORARY(image)) + minim
   RETURN, image
END

PRO MK_GIF, ifile, red=red, green=green, blue=blue, frac=frac, $
            rvs=rvs, sig=sig, icon=icon, _extra=extra_keywords
   ON_ERROR, 2

   err=''
   IF N_ELEMENTS(ifile.filename) EQ 0 OR datatype(ifile) NE 'STC' THEN $
      MESSAGE,'Syntax --> mk_gif, file_struct'
   eit_path = trim(GETENV('SSW_EIT'))
   eit_done = 0
;   IF getenv('DISPLAY') EQ '' THEN set_plot,'z'
   xpos = .5
   sav_dev = !d.name

   FOR i = 0, N_ELEMENTS(ifile.filename)-1 DO BEGIN
     set_plot, 'z'
      break_file, ifile(i).filename, dsk, direc, file, ext

      ofile = concat_dir(direc,file+'.gif')
      err = ''
      ct_loaded = 0
      IF STRPOS(ifile(i).title(0), 'SOHO EIT') GE 0 AND eit_path NE '' THEN BEGIN
         eit_prep, ifile(i).filename, header, image, /surround
         IF STRPOS(ifile(i).filename, '00284') GE 0 THEN $
            max_val=12000 $
         ELSE IF STRPOS(ifile(i).filename, '00195') GE 0 THEN $
            max_val=8000 $
;         ELSE IF STRPOS(ifile(i).filename, '00171') GE 0 THEN $
;            max_val=6000 $
         ELSE $
            max_val=6000
         scl = FLOAT(!d.table_size - 1)/ALOG10(max_val)
         image = scl*ALOG10((image > 1.) < max_val)
         eit_done = 1
         load_eit_color, header
      ENDIF ELSE $
         fxread, ifile(i).filename, image, header, err=err
      IF err NE '' THEN BEGIN
         PRINT, 'Error occurred when reading '+ifile(i).filename
         PRINT, '   '+err
      ENDIF ELSE BEGIN
         top = !d.table_size-1
;---------------------------------------------------------------------------
;        Check to see if the image is from SOHO EIT, and if so, rescale it
;        and load EIT's color table
;---------------------------------------------------------------------------
         instrume = fxpar(header, 'INSTRUME')
         IF !err NE -1 THEN IF instrume EQ 'EIT' THEN BEGIN
            IF NOT eit_done THEN image = eit_scaling(image, header)
;---------------------------------------------------------------------------
;           EIT images generally have a size of 1024x1024 and
;           therefore have a rebin factor of 2. However, if the image
;           size is 512x512, don't do the rebin
;---------------------------------------------------------------------------
            sz = SIZE(image)
            IF sz(1) LE 512 THEN BEGIN
               ifile(i).rebin = ifile(i).rebin/2
               ifile(i).icon = ifile(i).icon/2
            ENDIF
            ct_loaded = 1
            eit_done = 0
         ENDIF ELSE BEGIN
            IF ifile(i).gamma LT 0 THEN BEGIN
               cur_max = MAX(image)
               scl = FLOAT(!d.table_size - 1)/ALOG10(cur_max)
               image = scl*ALOG10((image > 1.0) < cur_max)
               ifile(i).gamma = -ifile(i).gamma
            ENDIF
         ENDELSE

         IF KEYWORD_SET(sig) THEN image = sigrange(TEMPORARY(image))

         IF ifile(i).min NE '' THEN $
            minimum = FLOAT(ifile(i).min) ELSE $
            minimum = MIN(image)
         IF ifile(i).max NE '' THEN $
            maximum = FLOAT(ifile(i).max) ELSE $
            maximum = MAX(image)

;         IF STRPOS(ifile(i).title(0), 'SOHO EIT') GE 0 THEN $
;            image=rescale_image(image) $
;         ELSE $
         image = BYTSCL(TEMPORARY(image), MIN=minimum, MAX=maximum, top=250)
         dprint, minimum, maximum
         
         IF KEYWORD_SET(rvs) THEN image = reverse(TEMPORARY(image))
         IF ifile(i).flip EQ 1 THEN $
            image = reverse(ROTATE(TEMPORARY(image), 2))
         sz = SIZE(image)
         IF ifile(i).icon GT 1 THEN BEGIN
;            xxi = sz(1)/ifile(i).icon
;            yyi = sz(2)/ifile(i).icon
            xxi = 256
            yyi = FIX(xxi*FLOAT(sz(2))/FLOAT(sz(1)))
            image_i = congrid(image, xxi, yyi)
            szi = SIZE(image_i)
         ENDIF
         IF ifile(i).rebin GT 1 THEN BEGIN
            xxi = 512
            yyi = FIX(xxi*FLOAT(sz(2))/FLOAT(sz(1)))
;            xx = sz(1)/ifile(i).rebin
;            yy = sz(2)/ifile(i).rebin
            image = congrid(image, xxi, yyi)
            sz = SIZE(image)
         ENDIF
         IF ifile(i).title(0) NE '' THEN BEGIN
            IF N_ELEMENTS(ifile(i).title) EQ 2 THEN BEGIN
               ypos = .96
            ENDIF ELSE BEGIN
               ypos = .95
            ENDELSE
            IF N_ELEMENTS(frac) EQ 0 THEN frac = 10.
            ysize = FIX(sz(2)*(1.+frac/100.))
            image = extend_matrix(image, ysize-sz(2), /yappd)
            IF ifile(i).icon NE 0 THEN BEGIN
               ysizei = FIX(szi(2)*1.08)
               image_i = extend_matrix(image_i, ysizei-szi(2), /yappd)
            ENDIF
            DEVICE, set_resolution=[sz(1), ysize]
            TV, image
;----------------------------------------------------------------------
;           Plot the centered title
;----------------------------------------------------------------------
            xyouts, xpos, ypos, ifile(i).title(0), norm=1, SIZE=1.0, $
               charthick=1.0, font=-1, alignment=0.5, $
               _extra=extra_keywords, color=top
            IF N_ELEMENTS(ifile(i).title) EQ 2 THEN BEGIN
               xyouts, xpos, ypos-0.03, ifile(i).title(1), norm=1, SIZE=1.0, $
                  charthick=1.0, font=-1, alignment=0.5, $
                  _extra=extra_keywords, color=top
            ENDIF
            image = tvrd()
         ENDIF
         IF ct_loaded EQ 0 THEN loadct, ifile(i).color, /silent
         chg_ctable, GAMMA=ifile(i).gamma, top=ifile(i).top, $
            bottom=ifile(i).bottom
;----------------------------------------------------------------------
;        Override color table if red, green, and blue are defined
;----------------------------------------------------------------------
         IF N_ELEMENTS(red)*N_ELEMENTS(green)*N_ELEMENTS(blue) EQ 0 THEN $
            cload = 0 ELSE cload = 1
         IF cload THEN ssw_write_gif, ofile, image, red, green, blue  $
         ELSE ssw_write_gif, ofile, image
         PRINT, 'File '+ofile+' created.'
         IF ifile(i).icon NE 0 THEN BEGIN
            DEVICE, set_resolution=[szi(1), ysizei]
            TV,  image_i
            xyouts, 0.5, 0.95, ifile(i).icon_str, norm=1, SIZE=0.8, $
               charthick=1.0, font=-1, color=top, alignment=0.5
            image_i = tvrd()
            IF cload THEN $
               ssw_write_gif, ifile(i).icon_fname, image_i, red, green, blue  $
            ELSE ssw_write_gif, ifile(i).icon_fname, image_i
            PRINT, 'Icon file '+ifile(i).icon_fname+' created.'
         ENDIF
 ;        set_plot, sav_dev
      ENDELSE
   ENDFOR
   if exist(sav_dev) then set_plot,sav_dev
   RETURN
END

;----------------------------------------------------------------------
; End of 'mk_gif.pro'.
;----------------------------------------------------------------------
