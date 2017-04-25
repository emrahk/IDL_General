PRO load_eit_color, header
;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       LOAD_EIT_COLOR
;
; PURPOSE: 
;       Load EIT color table based on the wavelength (in FITS header)
;
; CATEGORY:
;       Utility
; 
; SYNTAX: 
;       load_eit_color, header
;
; INPUTS:
;       HEADER - FITS header, string array
;
; HISTORY:
;       Version 1, July 15, 1997, Liyun Wang, NASA/GSFC. Written
;       Version 2, Sept 8, 2001, changed to call EIT_COLORS
;
; CONTACT:
;       Liyun Wang, NASA/GSFC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;
   ON_ERROR, 2
   
   IF N_ELEMENTS(header) NE 0 THEN BEGIN
      wavelength = fxpar(header, 'WAVELNTH')
      IF !err EQ -1 THEN wavelength = 304
   ENDIF ELSE wavelength = 304
   
   color_ok = 0
;---------------------------------------------------------------------------
;  Load different color table for different wavelengths. If something
;  goes wrong, load the default red temparature color table
;---------------------------------------------------------------------------

   mk_eit_env
   have_eit_colors=have_proc('eit_colors')
   if not have_eit_colors then begin
    have_eit_dir=is_dir('$SSW/soho/eit/idl')
    if have_eit_dir then add_path,'$SSW/soho/eit/idl',/append,/expand
    have_eit_colors=have_proc('eit_colors')
   endif

   if have_eit_colors then begin
    eit_colors,wavelength
    color_ok = 1
   endif

   IF NOT color_ok THEN BEGIN
      MESSAGE, 'No EIT color table found. Default color table loaded.', $
         /cont
      loadct, 3
   ENDIF
END

