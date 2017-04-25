PRO itool_rd_gif, file, data, minimum=minimum, maximum=maximum, $
                  color_table=color_table, status=status,$
                  error=error, group=group, csi=csi
;+
; PROJECT:
;       SOHO
;
; NAME:
;       ITOOL_RD_GIF
;
; PURPOSE:
;       To read a GIF file and to get related obs time
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       itool_rd_gif, file, data, obs_time=obs_time
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
; CATEGORY:
;
; PREVIOUS HISTORY:
;       Written May 8, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, May 8, 1995
;       Version 2, October 27, 1995, Liyun Wang, NASA/GSFC
;          Made the starting search directory to be current working directory
;       Version 3, November 2, 1995, Liyun Wang, NASA/GSFC
;          Changed to a procedure to be consistant with RD_IMAGE_FITS
;          Modified so that filename needs to be supplied
;       Version 4, September 9, 1997, Liyun Wang, NASA/GSFC
;          Took out DATE_OBS keyword
;          Added CSI keyword
;       Version 5, 1998 June 7, Zarro (SAC/GSFC) - added FILE2TIME call
;	Version 6, 1998 Sep 2, DeForest (Stanford/GSFC) - Added CLEAN_GIF call
;	Version 7, 2000 Mar 31, Zarro (SM&A/GSFC) - Added READ_JPEG call
;-
;
   ON_ERROR, 2
   error = ''
   status = 0

   IF NOT file_exist(file) THEN BEGIN
      error = 'File "'+file+'" does not exist!'
      MESSAGE, error, /cont
   ENDIF

   obs_time =file2time(file, /ecs)
   
   break_file, file, dlog, dir, filnam, ext
   
   itype = ''
   src_code = itool_img_type(/stc)
   str = STRUPCASE(STRMID(filnam, 5, 5))
   temp = grep(str, src_code.code, /exact)
   IF temp(0) NE '' THEN itype = temp(0)
   
   src = ''
   src_code = itool_img_src(/stc)
   str = STRUPCASE(STRMID(filnam, 0, 4))
   temp = grep(str, src_code.code, /exact)
   IF temp(0) NE '' THEN src = temp(0)
   
   IF obs_time EQ '' THEN BEGIN 
;---------------------------------------------------------------------------
;     Get image observation time from the user
;---------------------------------------------------------------------------
      get_utc, obs_time, /ecs
      loop = 1
      WHILE loop DO BEGIN
         xinput, obs_time, 'Enter observation time of the image:', $
            status=status, group=group
         IF status EQ 0 THEN BEGIN
            IF xanswer(['You did not select a required observation time.', $
                        'Do you wish to quit this operation?'], /beep, $
                       group=group) THEN BEGIN
               error = 'Operation aborted.'
               RETURN
            ENDIF
         ENDIF
         IF valid_time(obs_time, err) THEN loop = 0
         if trim(err) ne '' then xack, err
         error = err
      ENDWHILE
   ENDIF
;   read_gif, file, data, r, g, b
   case 1 of
    valid_gif(file) : begin
     clean_gif,data,r,g,b,file                                                                  
     if n_elements(r) ne 0 then begin
      color_table = [[r], [g], [b]]
     endif
     src='Unknown' & itype='Unknown'
    end                                                         
    valid_jpeg(file): begin
     message,'reading JPEG file',/cont
     read_jpeg,file,data,color_table,color=!d.table_size-1
     src='Unknown' & itype='Unknown'
    end
    else: begin
     error='Unsupported image type'
     message,error,/cont
     return
    end
   endcase 

   minimum = min(data)
   maximum = fix(max(data))
   
   if datatype(data) ne 'BYT' then data = BYTE(data)
   sz = SIZE(data)
   csi = itool_new_csi(/basic)
   csi.date_obs = anytim2utc(obs_time, /ecs, /trunc)
   csi.naxis1 = sz(1)
   csi.naxis2 = sz(2)
   csi.bitpix = 8
   csi.origin = src
   csi.imagtype = itype
   status = 1
   RETURN
END

