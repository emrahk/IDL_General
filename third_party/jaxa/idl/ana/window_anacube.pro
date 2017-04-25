;+
; NAME:
;	WINDOW_ANACUBE
; PURPOSE:
;       Read ANA image cube opened with OPEN_ANACUBE; 
;	windowed region selectable by cursors. 
; CATEGORY:
; CALLING SEQUENCE:
;	cube = window_anacube(ref_no)
;  or
;	cube = window_anacube(ref_no,/read)
;	cube = window_anacube(ref_no,/read,/reuse,ss=ss)
; INPUTS:
;       ref_no		No. of frame to be used for windowing
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
;	ss		ss vector if only selection to be read
;	read		read images - default is to show reference image
;	reuse_window	use window that was previously selected with cursors.
;		        (default is to have user select one)
;	display         Show each frame as it is read (cut into selection frame)
;	max		max value to be used when displaying reference image
; OUTPUTS:
;	cube		3d image cube of selected window
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
;       anacube,anacube_window
; SIDE EFFECTS:
; RESTRICTIONS:
;	MUST be called after OPEN_ANACUBE
;	Images only make sense if ANA has not done any "subtle" rotations...
; PROCEDURE:
;	Allows user to select region on a reference image using the cursors.
;	Reads in selected region as a data cube. The ss vector allows 
;	selected frames to be read.
; MODIFICATION HISTORY:
;          Mar-99  RDB  Written
;	08-Dec-99  RDB  Added /display keyword to show data as being read
;			Flip images N-S; ANA reads the other way
;
;-

function	window_anacube,ref_no,max=max, $
			read=read,ss=ss,reuse_window=reuse_window, $
			display=display

common anacube
common anacube_window


img_arr = -1		;default to no return

if ana_unit eq -1 then begin
   box_message,'** NO ANA file currently open **'
   return,-1
endif

print,' '
print,'Using file: ',ana_filename
print,'No. of images:',ana_hdr_struct.naxis3
print,'Image dimensions:',ana_hdr_struct.naxis1,ana_hdr_struct.naxis2
if n_params() eq 0 then begin		;just supply file info...
   print,''
   print,'>> NO Reference image supplied'
   return,-1
endif
print,'Reference image:',ref_no
print,' '

;	create window of correct size and display reference image
;window,xsiz=ana_hdr_struct.naxis1,ysiz=ana_hdr_struct.naxis2
image = ana_img_rec(ref_no)
image = rotate(image,7)		;flip north-south
wdef,image=image
imax = max(image)		;130
if keyword_set(max) then imax=max
tvscl,bytscl(image,max=imax)

if keyword_set(read) then begin
   if not keyword_set(reuse_window) then begin
      box_message,'Use mouse to select region of interest'
      print,' '
      box_cursor,x0,y0,nx,ny
      nx = (nx+1)/2*2		;round to even. no of pixels...
      ny = (ny+1)/2*2
   endif else box_message,'* Re-using predefined window *'
   print,'Window coordinates (x0,y0,nx,ny): ',x0,y0,nx,ny,format='(a,4i6)'
;;   draw_boxcorn, x0, y0, x0+nx-1, y0+ny-1
   draw_boxcorn, x0-1, y0-1, x0+nx-1+1, y0+ny-1+1

   if keyword_set(ss) then begin
      nimg = n_elements(ss)
      ssj = ss
      box_message,'No. of SS vector images:'+string(nimg)
   endif else begin
      nimg = ana_hdr_struct.naxis3
      ssj = indgen(nimg)
   endelse

   print,''
   print,'Number of Images to be Read:',nimg
   print,'Total memory requirements (Mbytes):', float(nimg)*nx*ny/1.e6,format='(a,f6.1)'
   print,''
   yesnox,'Okay to read',ansr
   if ansr then begin
      img_arr = bytarr(nx,ny,nimg)
      if not keyword_set(display) then $
;;         for j=0,nimg-1 do img_arr(*,*,j) = (ana_img_rec(ssj(j)))(x0:x0+nx-1,y0:y0+ny-1) $
         for j=0,nimg-1 do img_arr(*,*,j) = (ana_img_rec(ssj(j)))(x0:x0+nx-1,(sz(1)-1)-(y0+ny-1):(sz(1)-1)-y0) $
      else begin
         wshow		;push the window to the front
         sz = size(image,/dimensions)
         print,sz
         for j=0,nimg-1 do begin
;		better to rotate after the extraction - less pixels, less memory...
            image = (ana_img_rec(ssj(j)))(x0:x0+nx-1,(sz(1)-1)-(y0+ny-1):(sz(1)-1)-y0)
            image = rotate(image,7)			;flip north-south
            img_arr(*,*,j) = image
            tvscl,bytscl(image,max=imax),x0,y0
         endfor
      endelse
      help,img_arr
      print,''
   endif

endif

return,img_arr
end      
