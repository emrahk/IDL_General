;---------------------------------------------------------------------------
; Document name: rd_image_gif.pro
; Created by:    Liyun Wang, GSFC/ARC, May 8, 1995
;
; Last Modified: Thu Nov  2 11:15:23 1995 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO rd_image_gif, file, data, minimum=minimum, maximum=maximum, $
                  obs_time=obs_time, color_table=color_table, status=status,$
                  error=error, group=group
;+
; PROJECT:
;       SOHO
;
; NAME:	
;       RD_IMAGE_GIF
;
; PURPOSE:
;       To read a GIF file and to get related obs time 
;
; EXPLANATION:
;       
; CALLING SEQUENCE: 
;       rd_image_gif, file, data, obs_time=obs_time
;
; INPUTS:
;       FILE - GIF file name
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       DATA   - 2-Dim Image data being read
;
; OPTIONAL OUTPUTS:
;       OBS_TIME - Observation time associated with the image
;       MINIMUM  - Minimum value in the image aaary
;       MAXIMUM  - Maximum value in the image aaary
;       COLOR_TABLE - Nx3 array for color table in RGB system
;       STATUS  - Status of loading the GIF file. 1 for success and 0 
;                 for failure
;       ERROR   - Named variable containing error message. If no error
;                 occurs, a null string is returned
; KEYWORD PARAMETERS: 
;       None.
;
; CALLS:
;       XINPUT, XANSWER, GET_UTC
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
;       Written May 8, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, May 8, 1995
;       Version 2, October 27, 1995, Liyun Wang, GSFC/ARC
;          Made the starting search directory to be current working directory
;       Version 3, November 2, 1995, Liyun Wang, GSFC/ARC
;          Changed to a procedure to be consistant with RD_IMAGE_FITS
;          Modified so that filename needs to be supplied
;
; VERSION:
;       Version 3, November 2, 1995
;-
;
   ON_ERROR, 2
   error = ''
   status = 0
;    COMMON rd_gif_aaa, load_path
;    IF N_ELEMENTS(load_path) NE 0 THEN path = load_path ELSE BEGIN
;       cd, current=curr_dir
;       path = curr_dir
;    ENDELSE
;    file = pickfile(filter = '*.gif *.GIF', title = 'Select GIF Image File', $
;                    /must_exist, path = path, get_path = load_path) 
   IF NOT file_exist(file) THEN BEGIN
      error = 'File "'+file+'" does not exist!'
      MESSAGE, error, /cont
   ENDIF
   
;---------------------------------------------------------------------------
;  Get image observation time
;---------------------------------------------------------------------------
   get_utc, obs_time, /ecs
   loop = 1
   WHILE loop DO BEGIN
      xinput,obs_time, 'Enter observation time of the image:', $
         status=status, group=group
      IF status EQ 0 THEN BEGIN
         IF xanswer(['You did not select a required observation time.',$
                     'Do you wish to quit this operation?'], /beep, $
                    group=group) THEN BEGIN
            error = 'Operation aborted.'
            RETURN
         ENDIF
      ENDIF
      IF valid_time(obs_time, err) THEN BEGIN
         loop = 0
         read_gif, file, data, r, g, b
         IF N_ELEMENTS(r) NE 0 THEN BEGIN 
            minimum = MIN(data)
            maximum = FIX(MAX(data))
;          IF (SIZE(r))(1) GT !d.n_colors THEN BEGIN
;             r = r(0:!d.n_colors-1)
;             g = g(0:!d.n_colors-1)
;             b = b(0:!d.n_colors-1)
;             IF maximum LT !d.n_colors-1 THEN BEGIN
;                r(maximum:!d.n_colors-1) = 255
;                g(maximum:!d.n_colors-1) = 255
;                b(maximum:!d.n_colors-1) = 255
;             ENDIF
;          ENDIF
            color_table = [[r], [g], [b]]
         ENDIF
         status = 1
      ENDIF ELSE BEGIN
       if trim(err) ne '' then begin
        xack, err
        error = err
       endif
      ENDELSE
   END
   RETURN
END

;---------------------------------------------------------------------------
; End of 'rd_image_gif.pro'.
;---------------------------------------------------------------------------
