
pro zbuff2file, filename, r, g, b, gif=gif, jpeg=jpeg, tiff=tiff, $
   png=png, outdir=outdir, quality=quality, $
   xwin=xwin
;
;+
;   Name: zbuff2file
;
;   Purpose:
;      write the image current Z-buffer image to an image file
;      (gif,tiff,jpeg and png supported formats)
;
;   Input Parameters:
;      filename - filename for (output) image file
;      r,g,b - optional color table (gif, png, and tiff only)
;              - default is current
;
;   Keyword Parameters:
;      gif -  switch, if set, use write_gif (file gets .gif extension)
;      png -  switch, if set, use write_png (file gets .png extension)
;      tiff - switch, if set, use tiff_write (file gets .tiff extention)
;      jpeg - switch, if set, use write_jpeg (file gets .jpg extentsion)
;      outdir - output directory (may also be supplied as part of FILENAME)
;      quality - passed to write_jpeg
;	xwin - switch, if set, read the current window and transfer to zbuff
;
;   Calling Sequence:
;      zbuff2file, filename [,r,g,b, /gif, /png, /jpeg, /tiff, outdir=outdir]
;
;   Restrictions:
;      image must currently reside in Z-buffer
;
;   History:
;      17-jul-1995 (S.L.Freeland)
;       9-jun-1996 (S.L.Freeland) default quality
;      10-feb-1997 (S.L.Freeland) fix problem when outfile contained "."
;      19-Nov-1998 (M.D.Morrison) Added /xwin
;	8-Jun-1999 (M.D.Morrison) Reapplied 5-Aug-1998 patch to merge two
;				  diverging versions
;      5-Aug-1998>> (M.D.Morrison) Don't do SET_PLOT if device was zbuff
;                                 (since it resets !p parameters like
;                                 !p.color and !p.background)
;     13-Sep-1999 (S.L.Freeland) - merge SLF  11-aug-1999  change
;                                  WARN/dont abort on null images
;     11-Apr-2000 (S.L.Freeland) - fix the endif/endcase (V5.3 requirement)
;     19-Nov-2000 (B.N.Handy) - Add PNG support
;     21-Nov-2000 (B.N.Handy) - Document PNG support
;     13-Aug-2003, William Thompson, Use SSW_WRITE_GIF instead of WRITE_GIF
;-
;   Purpose: read image from zbuffer
;
tempdev=!d.name						; save device
if (keyword_set(xwin)) then begin	;MDM 19-Nov-98
    img = tvrd()
    set_plot,'z'
    wdef, image=img
    tv, img
end
;
if not data_chk(filename,/string) then begin
   message,/info,"Please supply file name..."
   message,/info,"   IDL> zbuff2file, filname [r,g,b, /gif, /jpeg, /tiff, /png]"
   return
endif

tempdev=!d.name                                         ; save device
if (!d.name ne 'Z') then set_plot,'z'
; readimage and (optionally) color table from Z-buffer
image=tvrd()
if n_params() lt 4 then tvlct,r,g,b,/get		; read color table
if (!d.name ne strupcase(tempdev)) then set_plot,tempdev


if max(image) eq min(image) then begin
   box_message,'Warning: ZBuffer image is NULL'
endif

break_file,filename,log,path,file,extension,version
fname=file+extension

tiff=keyword_set(tiff) or (strpos(fname,'.tiff') ne -1)
jpeg=keyword_set(jpeg) or (strpos(fname,'.jpg')  ne -1)
gif =keyword_set(gif)  or (strpos(fname,'.gif')  ne -1)
png =keyword_set(png)  or (strpos(fname,'.png')  ne -1)

; select output path
case 1 of
   path ne '': outdir=path				; part of file name
   data_chk(outdir,/string): 		; keyword
   else: outdir=curdir()			; none - use current
endcase

case 1 of
   gif: begin
      ext='gif'
      exe='ssw_write_gif,outfile,image,r,g,b'
   endcase
   tiff: begin
      ext='tiff'
      exe='write_tiff,outfile,image,red=r,green=g,blue=b'
   endcase
   jpeg: begin
      if n_elements(quality) eq 0 then quality=25
      ext='jpg'
      exe='write_jpeg,outfile,image,quality=quality'
      if not since_version('3.6') then begin
         tbeep
         message,/info,"Sorry,JPEG not availble until IDL Version 3.6..."
         if (!d.name ne strupcase(tempdev)) then set_plot, tempdev
         return		;********* unstructured exit ***********
      endif
   endcase
   png: begin
      ext='png'
      exe='write_png,outfile,rotate(image,7),r,g,b'  ; write_png upside down
   endcase

   else: message,"unexpected file extension..."
endcase

pieces=str2arr(fname,'.',/nomult)
if pieces(n_elements(pieces)-1) ne ext then pieces=[pieces,ext]
outfile=concat_dir(outdir,arr2str(pieces,'.'))
message,/info,"Writing file: " + outfile
box_message,exe
exestat=execute(exe)

if not file_exist(outfile) then $
   message,/info,"Had some problem writing file..."

if (!d.name ne strupcase(tempdev)) then set_plot,tempdev
return
end

