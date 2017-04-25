;---------------------------------------------------------------------------
; Document name: rd_image_fits.pro
; Created by:    Liyun Wang, GSFC/ARC, February 27, 1995
;
; Last Modified: Wed Jul 30 14:16:57 1997 (lwang@achilles.nascom.nasa.gov)
;---------------------------------------------------------------------------
;
PRO rd_image_fits, data_file, image, header, group=group, data_info=data_info,$
                   image_max=image_max, image_min=image_min, errmsg=errmsg, $
                   column=column, img_csi=img_csi, img_utc=img_utc, $
                   status=status
;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       RD_IMAGE_FITS
;
; PURPOSE:
;       Driver program of FXREAD and CDS_IMAGE to read any FITS file
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       rd_image_fits, data_file, image, header, min=min, max=max, $
;                      image_max=image_max, image_min=image_min $
;                      [,errmsg=errmsg]
;
; INPUTS:
;       DATA_FILE - name of FITS file
;
; OPTIONAL INPUTS:
;       COLUMN - Column number of data in FITS binary table. This parameter
;                has no effect on "plain" FITS files, and will cause CDS_IMAGE
;                to be called directly with its value if passed.
;       GROUP  - Group ID of the group leader.
;
; OUTPUTS:
;       IMAGE  - A 2-D image array
;       HEADER - Header of the image
;
; OPTIONAL OUTPUTS:
;       DATA_INFO - A structure that indicates name and column number of all
;                   images contained in one FITS file. This is generally for
;                   FITS files with a binary table. It show have the following
;                   tags:
;
;                      BINARY  - Integer scalar with value 1/0 indicating if
;                                the data_file contains binary table or not
;                      COL     - Integer vector that indicates all column
;                                numbers for the data
;                      LABEL   - String vector showing the label of data in
;                                each column
;                      CUR_COL - Current column of data being read
;
;       IMG_UTC - UTC at which the observation was made
;       IMG_CSI - Part of CSI structure, containing the following tags:
;                 XU0, YU0, X0, Y0, XV0, YV0, SRX, SRY, FLAG
;       ORIGIN - The value of the first point along each of the axes
;                of image array, in absolute coordinates (e.g., arcsec)
;       SPACING - The pixel spacing along each axis, i.e., value (in
;                 absolute system) per image data pixel. It is the
;                 scaling factor we use in CSI (srx and sry, etc).
;
; KEYWORD PARAMETERS:
;       None.
;
; CALLS:
;       XSEL_ITEM, FXREAD, CDS_IMAGE, FXPAR, FXHREAD, BELL
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
;       Extracted from IMAGE_TOOL.PRO, February 27, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, GSFC/ARC, February 27, 1995
;       Version 2, Liyun Wang, GSFC/ARC, May 11, 1995
;          Rotated loaded image if keyword CROTA or CROTA1 is found in the
;             header and its value is not zero
;       Version 3, April 1, 1996, Liyun Wang, GSFC/ARC
;          Modified so that point of view is set based on the loaded image
;       Version 4, July 30, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug occurred when dealing with compressed FITS files
;       Version 5, 10-Jul-2003, William Thompson, GSFC
;               Look for CROTA2 as well, to be more standards compliant
;
; VERSION:
;       Version 5, 10-Jul-2003
;-
;
   ON_ERROR, 2
   IF N_PARAMS() LT 3 THEN BEGIN
      MESSAGE,'Usage: rd_image_fits, file, image, header [,keyword=]',/cont
      RETURN
   ENDIF
   errmsg = ''
   status = 1
   
;----------------------------------------------------------------------
;  Adding checks to see if the file is compressed. Uncompress such files
;  (write privilege required)   
;----------------------------------------------------------------------
   sep_filename, data_file, dsk, direc, file, ext
   n_ext = N_ELEMENTS(ext)
   IF n_ext GE 2 THEN BEGIN
      IF (ext(n_ext-1) EQ "Z" OR ext(n_ext-1) EQ "gz") THEN BEGIN
         SPAWN,'/usr/local/bin/gunzip '+data_file
         d_file = concat_dir(direc,arr2str([file,ext(0:n_ext-2)],'.'))
         recomp = 1
      ENDIF ELSE d_file = data_file
   ENDIF ELSE d_file = data_file

;---------------------------------------------------------------------------
;  Open the file and read the header.  If the number of axes is non-zero, then
;  the data is assumed to be in the main part of the FITS file.  Otherwise, the
;  data will be in a FITS binary table.
;---------------------------------------------------------------------------
   OPENR, unit, d_file, /GET_LUN, /BLOCK
   fxhread, unit, header
   FREE_LUN, unit

;---------------------------------------------------------------------------
;  Determine point of view; Earth view assumed first
;---------------------------------------------------------------------------
   use_earth_view
   telescope = fxpar(header, 'TELESCOP')
   IF !err NE -1 THEN IF trim(telescope) EQ 'SOHO' THEN use_soho_view

   naxis = fxpar(header,'NAXIS')
   img_utc = get_obs_date(header)
   IF naxis EQ 2 THEN BEGIN
      fxread, d_file, image, header, errmsg = errmsg
      IF errmsg NE '' THEN BEGIN
         bell
         popup_msg, 'FXREAD: '+errmsg, title = 'FXREAD ERROR'
         status = 0
         RETURN
      ENDIF
      rot_angle = fxkvalue(header,['CROTA1','CROTA2','CROTA','CROT','SC_ROLL'])
      IF NOT num_chk(rot_angle) THEN BEGIN
;---------------------------------------------------------------------------
;        Rotate the image to make solor north pole straight up or down
;---------------------------------------------------------------------------
         IF rot_angle NE 0.0 THEN BEGIN
            crpix1 = fxpar(header,'CRPIX1')
            crpix2 = fxpar(header,'CRPIX2')
            IF NOT num_chk(crpix1) AND NOT num_chk(crpix2) THEN BEGIN
               image = rot(image, -rot_angle, 1, crpix1, crpix2, /pivot, $
                           /cubic, missing = 0)
            ENDIF ELSE BEGIN
               image = rot(image, -rot_angle, /cubic, missing = 0)
            ENDELSE
         ENDIF
      ENDIF
      itool_set_csi, header, img_csi=img_csi, date=img_utc, err=errmsg
      data_info = {binary:0, label:'', col:1, cur_col:1}
   ENDIF ELSE BEGIN
      IF naxis EQ 0 THEN BEGIN
         IF fxpar(header,'EXTEND') EQ 1 THEN BEGIN
;---------------------------------------------------------------------------
;           File contains extension. Assume that the binary table is
;           the first extension in the file
;---------------------------------------------------------------------------
            fxbopen, unit, d_file, 1, extheader
            fxbfind, extheader, 'TDETX', data_col, values, ndata
            IF ndata LT 1 THEN MESSAGE, 'No detector data found'
            fxbfind, extheader, 'TTYPE', col, ttype, ncol,''
            FOR i = 0, ndata-1 DO BEGIN
               IF N_ELEMENTS(image_list) EQ 0 THEN $
                  image_list = ttype(i) $
               ELSE $
                  image_list = [image_list, ttype(i)]
            ENDFOR
            IF N_ELEMENTS(column) EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;              Select what column to read in.  this can be either a character
;              string or an integer.
;---------------------------------------------------------------------------
               IF !d.window NE -1 THEN $
                  n_col = xsel_item(image_list, title=['Press the button',$
                                   'below to select data'], group = group)$
               ELSE BEGIN
                  OPENW, outunit, filepath(/terminal), /more, /GET_LUN
                  FOR i = 0,ndata-1 DO BEGIN
                     PRINTF,outunit,col(i),'   ',ttype(i)
                     IF !err EQ 1 THEN GOTO, done
                  ENDFOR
done:	          FREE_LUN, outunit
                  n_col = ''
                  WHILE n_col EQ '' DO READ,'Enter column to read: ',n_col
                  IF valid_num(n_col) THEN n_col = LONG(n_col)
               ENDELSE
               IF n_col EQ -1 THEN BEGIN
                  errmsg = 'Operation is canceled.'
                  RETURN
               ENDIF
               cur_col = col(n_col)
            ENDIF ELSE BEGIN
               cur_col = column
            ENDELSE
            fxbclose, unit
            column = cur_col
            cds_image, d_file, data_stc, cur_col
            data_info = {binary:1, label:image_list, col:col, cur_col:cur_col}
            image = data_stc.array
            header = data_stc.header
;---------------------------------------------------------------------------
;           In this case, the reference point is the first pixel of the image
;---------------------------------------------------------------------------
            origin = data_stc.origin
            spacing = data_stc.spacing
            angles = pb0r(img_utc)
            radius = 60.*angles(2)
            img_csi = {xu0:0, yu0:0, x0:0, y0:0, xv0:origin(0), yv0:origin(1),$
                       srx:spacing(0), sry:spacing(1), flag:1, radius:radius}
         ENDIF ELSE BEGIN
            status = 0
            errmsg = 'Keyword EXTEND not found'
         ENDELSE
      ENDIF ELSE BEGIN
         errmsg = 'NAXIS has to be either 2 or 0!'
         status = 0
      ENDELSE
   ENDELSE

   IF N_ELEMENTS(recomp) THEN BEGIN
      IF (ext(n_ext-1) EQ 'Z') THEN $
         SPAWN,'compress '+d_file $
      ELSE SPAWN,'/usr/local/bin/gzip '+d_file
   ENDIF

   image_min = MIN(image)
   image_max = MAX(image)

END

;---------------------------------------------------------------------------
; End of 'rd_image_fits.pro'.
;---------------------------------------------------------------------------
