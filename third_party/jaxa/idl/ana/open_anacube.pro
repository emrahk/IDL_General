;+
; NAME:
;       OPEN_ANACUBE
; PURPOSE:
;       Opens ANA data cube for reading with WINDOW_ANACUBE
; CATEGORY:
; CALLING SEQUENCE:
;       open_anacube,filename
;	open_anacube,filename,hdr_struct,image,/read_all
; INPUTS:
;       filename	name of ANA cube to be opened
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
;	new		if set, close any open cube and open new one
;	read_all	if set, read all the data in the cube
; OUTPUTS:
; OPTIONAL OUTPUT PARAMETERS:
;	hdr_struct	structure cointaining ANA cube FITS header
;	image		3d image cube
; COMMON BLOCKS:
;       anacube,anacube_window
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;	Opens cube for read. Can read all the images in, but selective
;	read using window_anacube is recommended.
; MODIFICATION HISTORY:
;          Mar-99  RDB  Written
;
;-

pro	open_anacube,filename,hdr_struct,img,new=new, $
		read_all=read_all,debug=debug

common anacube,ana_unit,ana_filename,ana_hdr_struct,ana_img_rec
common anacube_window,x0,y0,nx,ny

if keyword_set(new) then close_anacube

if n_elements(ana_unit) gt 0 then begin
   if ana_unit gt 0 then begin
      box_message,['ANA file already open: '+string(ana_unit), $
         'Use CLOSE_ANACUBE to close it']
      return
   endif
endif

;	open file for i/o
OPENR,ana_unit,filename,/GET_LUN

;	first lets get the header
;	?? should we make this a lot bigger??
rf = ASSOC(ana_unit,BYTARR(2880))
header = string(reform(rf(0),80,36))
nrec = where(strpos(header,'END') ge 0) & nrec=nrec(0)
header = header(0:nrec-1)
hdr_struct = fitshead2struct(header)
if keyword_set(debug) then begin
   help,header
   print,strtrim(header,2),format='(x,a)'
   help,hdr_struct,/st
endif

;	exit if not a suitable file
must_exit = 1
if tag_exist(hdr_struct,'simple') then $
      if hdr_struct.simple then must_exit = 0
if must_exit then begin
   box_message,'This is NOT a SIMPLE FITS file'
   print,strtrim(header,2),format='(x,a)'
   free_lun,ana_unit
   ana_unit = -1
   return
endif

;	now read the data records
ana_filename = filename
ana_hdr_struct = hdr_struct
hdr_offset = 2880		;assumes only 1 block!!

if keyword_set(read_all) then begin
;	Read all images and close file
   print,''
   print,'Using file: ',ana_filename
   print,'Total memory requirements (Mbytes):', $
         float(hdr_struct.naxis1)*hdr_struct.naxis2*hdr_struct.naxis3/1.e6, $
         format='(a,f6.1)'
   print,''
   yesnox,'Okay to read',ansr
   if ansr then begin
      if n_params() eq 3 then begin
         img_array = ASSOC(ana_unit,bytarr(hdr_struct.naxis1,hdr_struct.naxis2,hdr_struct.naxis3),hdr_offset)
         img = img_array(0)
         box_message,'ANA file '+ana_filename+' has been read'
         help,img
      endif else box_message,'NO return array provided' 
   endif
   free_lun,ana_unit
   ana_unit = -1		;flag closed

endif else begin
;	Read first image only and leave the file open. 
;	May need to do this with very large ANA cubes
   ana_img_rec = ASSOC(ana_unit,bytarr(hdr_struct.naxis1,hdr_struct.naxis2),hdr_offset)
   img = ana_img_rec(0)
   box_message,['ANA file '+ana_filename+' has been opened', $
      'Use WINDOW_ANACUBE to select the ROI and read the data', $
      'Use CLOSE_ANACUBE to close the file', $
      'Cube dimensions: '+string(hdr_struct.naxis1,hdr_struct.naxis2,hdr_struct.naxis3,format='(3i5)')]
   if n_params() eq 3 then help,img else box_message,'NO return array provided'

endelse


end
