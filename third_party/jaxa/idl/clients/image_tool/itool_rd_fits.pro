;+
; PROJECT:
;       SOHO - CDS
;
; NAME:
;       ITOOL_RD_FITS
;
; PURPOSE:
;       Driver program of FXREAD and CDS_IMAGE to read any FITS file
;
; EXPLANATION:
;
; CALLING SEQUENCE:
;       itool_rd_fits, data_file, image, header, min=min, max=max, $
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
;       CSI     - Part of CSI structure. It's important to get this structure
;
; KEYWORD PARAMETERS:
;       IMAGE_MIN - Minimum value of the image array
;       IMAGE_MAX - Maximum value of the image array
;       ERRMSG    - Error message returned (null string if no error)
;       STATUS    - Flag (0/1) of failure/success
;
; CALLS:
;       XSEL_ITEM, FXREAD, CDS_IMAGE, FXPAR, FXHREAD, BELL
;
; PREVIOUS HISTORY:
;       Extracted from IMAGE_TOOL.PRO, February 27, 1995, Liyun Wang, NASA/GSFC
;
; MODIFICATION HISTORY:
;       Version 1, created, Liyun Wang, NASA/GSFC, February 27, 1995
;       Version 2, Liyun Wang, NASA/GSFC, May 11, 1995
;          Rotated loaded image if keyword CROTA or CROTA1 is found in the
;             header and its value is not zero
;       Version 3, April 1, 1996, Liyun Wang, NASA/GSFC
;          Modified so that point of view is set based on the loaded image
;       Version 4, July 30, 1996, Liyun Wang, NASA/GSFC
;          Fixed a bug occurred when dealing with compressed FITS files
;       Version 5, August 13, 1997, Liyun Wang, NASA/GSFC
;          Took out IMG_UTC keyword (now in CSI.DATE_OBS)
;          Uncompress compressed file to /tmp directory
;       Version 6, April 28, 1998, Zarro, SAC/GSFC
;          Added patch for getting updated EIT pointing information
;       Version 7, Oct 28, 1998, Zarro, SAC/GSFC
;          Added check for pre-uncompressed file in /tmp
;       Version 8, March 12, 1999, Zarro, SM&A/GSFC
;          Corrected call to READ_EIT
;       Version 9, 20-Nov-2001, Zarro (EITI/GSFC)
;          Added check for READ_EIT in !path
;       Version 10, 3-Jul-2003, Zarro (EER/GSFC)
;          Added check for flipped (rolled 180 deg) SOHO image
;       Version 11, 1-Oct-2003, Zarro (GSI/GSFC)
;          Fixed incorrect call to get_soho_roll for non-SOHO images
;       Version 12, 12-Jan-2006, Zarro (L-3Com/GSFC)
;          Added check for roll-corrected images
;-
;-------------------------------------------------------------------------

pro itool_read_eit,d_file,data,header,csi=csi,index=index,status=status

status=0
if (datatype(d_file) ne 'STR') or datatype(csi) ne 'STC' then return

if tag_exist(csi,'ORIGIN') then begin
 org=strupcase(csi.origin)
 is_eit=strpos(org,'EIT') gt -1
 if is_eit then begin

  mk_eit_env
  have_read_eit=have_proc('read_eit')
  if not have_read_eit then begin
   have_eit_dir=is_dir('$SSW/soho/eit/idl')
   if have_eit_dir then add_path,'$SSW/soho/eit/idl',/append,/expand
   have_read_eit=have_proc('read_eit')
  endif

  if have_read_eit then begin
   message,'using READ_EIT...',/cont
   call_procedure,'read_eit',d_file,index,data,header=header
   if datatype(index) eq 'STC' then begin
    csi.crpix1=index.crpix1
    csi.crpix2=index.crpix2
    csi.crval1=index.crval1
    csi.crval2=index.crval2
    csi.cdelt1=index.cdelt1
    csi.cdelt2=index.cdelt2
    status=1
   endif
  endif
 endif
endif

return & end

;-------------------------------------------------------------------------

PRO itool_rd_fits, data_file, image, header, group=group, data_info=data_info,$
                   image_max=image_max, image_min=image_min, errmsg=errmsg, $
                   column=column, csi=csi, status=status,index=index

   status=0
   IF N_PARAMS() LT 3 THEN BEGIN
      MESSAGE,'Usage: itool_rd_fits, file, image, header [,keyword=]',/cont
      RETURN
   ENDIF
   errmsg = ''

;----------------------------------------------------------------------
;  Adding checks to see if the file is compressed. Uncompress such files
;  to /tmp directory (write privilege required)
;----------------------------------------------------------------------
   sep_filename, data_file, dsk, direc, file, ext
   n_ext = N_ELEMENTS(ext)
   d_file=find_compressed(data_file,status=compressed)

;---------------------------------------------------------------------------
;  Open the file and read the header.  If the number of axes is non-zero, then
;  the data is assumed to be in the main part of the FITS file.  Otherwise, the
;  data will be in a FITS binary table.
;---------------------------------------------------------------------------

   if not valid_fits(d_file) then begin
    errmsg='Invalid or non-existent FITS file input.'
    message,errmsg,/cont
    return
   endif

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
   csi = itool_set_csi(header, err=errmsg, file=d_file)

;-- use READ_EIT to read EIT

   itool_read_eit,d_file,image,header,csi=csi,index=index,status=status

   IF (naxis EQ 2) THEN BEGIN

      if not status then begin
       message,'using FXREAD...',/cont
       fxread, d_file, image, header, errmsg = errmsg
       IF errmsg NE '' THEN BEGIN
        bell
        popup_msg, 'FXREAD: '+errmsg, title = 'FXREAD ERROR'
        if compressed then rm_file,d_file
        RETURN
       ENDIF
       status=1
      endif

;-- check if SOHO image is flipped

      crota=abs(csi.crota)
      dprint,'% CROTA: ',crota

     chk=where(strpos(strup(header),'ROLL CORRECTION APPLIED') gt -1,count)
     if count eq 0 then begin

      if (crota eq 180.) then begin
       csi.crota=0 & csi.reflect=2
      endif else begin
       s=fitshead2struct(header)
       chk=have_tag(s,'TELES',/start,index)
       if index gt -1 then begin
        tel=s.(index)
        if strup(tel) eq 'SOHO' then begin
         dprint,'% checking roll state for SOHO image...'
         soho_roll=abs(get_soho_roll(csi.date_obs))
         if soho_roll ne 0. then begin
          if (crota eq 0.) and (soho_roll eq 180) then csi.reflect=2
         endif
        endif
       endif
      endelse

;-- skip rotation correction if within 10 degrees of Solar N


      if (crota lt 90.) and (crota lt 10.) then csi.crota=0.0
      if (crota gt 90.) and (abs(crota-360) lt 10.) then csi.crota=0.0
;help,csi.crota,csi.reflect
;csi.reflect=2
      IF csi.crota NE 0.0  THEN BEGIN

;---------------------------------------------------------------------------
;        Rotate the image to make solar north pole straight up or down
;---------------------------------------------------------------------------
         MESSAGE, 'Rotating image to make solar poles straight up/down...',$
            /cont
         crpix1 = fxpar(header, 'CRPIX1')
         crpix2 = fxpar(header, 'CRPIX2')
print,'JAR was here.....'
         IF NOT num_chk(crpix1) AND NOT num_chk(crpix2) THEN BEGIN
            image = rot(temporary(image), csi.crota, 1, crpix1, crpix2, /pivot, $
                        /cubic, missing=0)
         ENDIF ELSE BEGIN
            image = rot(temporary(image), csi.crota, /cubic, missing=0)
         ENDELSE
         csi.crota = 0.0
      ENDIF
     endif

      IF csi.reflect gt 0 THEN BEGIN
;---------------------------------------------------------------------------
;        The image is upside down. Flip it
;---------------------------------------------------------------------------
         image=ROTATE(TEMPORARY(image),2)
         if csi.reflect eq 1 then begin
          message, 'Image upside down. Flipping it...', /cont
          image=reverse(temporary(image))
         endif else message,'correcting image for 180 degree roll...',/cont
         csi.crpix2 = csi.naxis2-1-csi.crpix2
         if csi.reflect eq 2 then csi.crpix1 = csi.naxis1-1-csi.crpix1
         csi.reflect = 0
         header=[header,"COMMENT  CORRECTED FLIP"]
      ENDIF

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
                  n_col = xsel_item(image_list, $
                                    title=['Press the button', $
                                           'below to select data'], $
                                    group=group)$
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
                  if compressed then rm_file,d_file
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
            sz = SIZE(image)
            csi.naxis1 = sz(1)
            csi.naxis2 = sz(2)
            csi.crpix1 = 1
            csi.crpix2 = 1
            csi.imagtype = data_stc.label(cur_col)
            header = data_stc.header
;---------------------------------------------------------------------------
;           In this case, the reference point is the first pixel of the image
;---------------------------------------------------------------------------
            angles = pb0r(csi.date_obs)
            csi.crval1 = data_stc.origin(0)
            csi.crval2 = data_stc.origin(1)
            csi.cdelt1 = data_stc.spacing(0)
            csi.cdelt2 = data_stc.spacing(1)
            csi.radius = 60.*angles(2)
            csi.flag = 1
         ENDIF ELSE BEGIN
            errmsg = 'Keyword EXTEND not found'
         ENDELSE
      ENDIF ELSE BEGIN
         errmsg = 'NAXIS has to be either 2 or 0!'
      ENDELSE
   ENDELSE

   image_min = MIN(image,max=image_max)
   if compressed then rm_file,d_file


END

