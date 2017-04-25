;+
; Project     :	SOHO - CDS
;
; Name        :	FIT2GIF
;
; Purpose     :	convert FITS file to a GIF image file
;
; Explanation :	Reads a FITS file, byte scales it, and
;               then writes it to a GIF file.
;
; Use         :	FITS2GIF,INFILE
;
; Inputs      :	INFILE = fits file name
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	HEADER = fits file header
;
; Keywords    :	OFILE = output GIF file name [def = INFILE with .GIF extension]
;               TITLE = title for image
;               COLOR = color table to load [def= 0 , B/W]
;               RED, GREEN, BLUE = optional color vectors to override COLOR
;               FRAC  = fraction by which to increase image
;                       size in Y-direction to fit title [def = 15%]
;               XPOS, YPOS = normalized coordinates for title [def=.1,.9]
;               ROTATE = value for rotate (see ROTATE function)
;               FLIP = flip image to to bottom
;               REVERSE = flip image left to right
;               PREVIEW = preview image before writing
;               SIG  = select significant range of image
;
; Calls       :	SSW_WRITE_GIF
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Plotting.
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC)
;
; Modified    : Version 2, William Thompson, GSFC, 8 April 1998
;			Changed !D.N_COLORS to !D.TABLE_SIZE for 24-bit displays
;               Version 3, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;
; Version     : Version 3, 13-Aug-2003
;-


pro fits2gif,ifile,data,header,ofile=ofile,color=color,red=red,green=green,blue=blue,$
             title=title,xpos=xpos,ypos=ypos,frac=frac,$
             _extra=extra_keywords,flip=flip,reverse=reverse,preview=preview,$
             sig=sig,err=err

on_error,1

err=''
if datatype(ifile) ne 'STR' then begin
 err='Syntax --> fits2gif,fits_file_name'
 message,err,/cont
 return
endif

if datatype(ofile) ne 'STR' then begin
 break_file,ifile,dsk,direc,file,ext
 ofile=file+'.gif'
endif

if not test_open(ofile,/write) then begin
 err='cannot write '+ofile
 message,err,/cont
 return
endif

;-- read the fits file

err=''
fxread,ifile,data,header,err=err
if err ne '' then begin
 message,err,/cont
 return
endif

;-- process image

image=data
if keyword_set(sig) then image=sigrange(temporary(image))
image=bytscl(temporary(image))
if keyword_set(reverse) then image=reverse(temporary(image))
if keyword_set(flip) then image=reverse(rotate(temporary(image),2))

sav_dev=!d.name
sav_white=!d.table_size-1

;-- use Z-buffer to adjoin title

sz=size(image)
if datatype(title) eq 'STR' then begin
 if n_elements(frac) eq 0 then frac=15.
 fac=(1.+frac/100.)
 new=bytarr(sz(1),sz(2)*fac)
 new(0:sz(1)-1,0:sz(2)-1)=temporary(image)
 image=new & delvarx,new
 if n_elements(xpos) eq 0 then xpos=.1
 if n_elements(ypos) eq 0 then ypos=.9
 set_plot,'z'
 device,/close,set_resolution=[sz(1),sz(2)*fac],set_colors=!d.table_size
 tv,image
 xyouts,xpos,ypos,title,norm=1,size=1.5,charthick=1.5,font=-1,$
         _extra=extra_keywords,color=sav_white
 image=tvrd()
 set_plot,sav_dev
endif

;-- use X-windows mode to load color table

preview=keyword_set(preview)
if preview then select_windows
if n_elements(color) eq 0 then color=0
loadct,color

;-- override color table

if n_elements(red)*n_elements(green)*n_elements(blue) eq 0 then cload=0 else cload=1

if preview then begin
 sz=size(image)
 window,xsize=sz(1),ysize=sz(2)
 tv,image
 if cload then tvlct,red,green,blue 
 wshow
 message,'hit return to continue or q to quit',/contin
 ans='' & read,ans
 if strupcase(strmid(ans,0,1)) eq 'Q' then return
endif

if cload then ssw_write_gif,ofile,image,red,green,blue else ssw_write_gif,ofile,image 

set_plot,sav_dev
message,'output to '+ofile,/contin

return & end
