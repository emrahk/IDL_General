
;+
; NAME:
;	GIFDIR2JPG24
;
; PURPOSE:
; 	Converts all the GIFS in gif_dir to 24 bit JPEGs in another directory 
;
; CATEGORY:
;	Image Processing.
;
; CALLING SEQUENCE:
;
;		GIFDIR2JPG24,Gif_dir,Jpg_dir,Jsize_x,Jsize_y
;
; INPUTS:
; 	 	Gif_dir
;         	Jpg_dir
;		Jsize_x		horz size for JPEGS
;		Jsize_y         vert size for JPEGS
;
; OPTIONAL INPUTS:
;	
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;	Output directory contains a 24 bit color JPEG for each GIF in the input directory
;
; OPTIONAL OUTPUTS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; EXAMPLE:
;
;		GIFDIR2JPG24,'./gifs','./jpg24',1024,1024
;
; MODIFICATION HISTORY:
; 	Written by:	Dennis Wang, 18 Mar 1999
;
;	@(#)gifdir2jpg24.pro	1.1 03/19/99 LASCO IDL LIBRARY
;-


;
pro gifdir2jpg24,gif_dir,jpg_dir,jsize_x,jsize_y
cd,gif_dir
f = findfile('*.gif')
n_gif = n_elements(f)

for igif=0,n_gif-1 do begin
 read_gif,f(igif),gif_image,r,g,b
 jname = str_sep(f(igif),'.')
 gif2jpg24,gif_image,r,g,b,jsize_x,jsize_y,jpg_image
 print,'Writing '+jpg_dir+'/'+jname(0)+'.jpg'
 write_jpeg,jpg_dir+'/'+jname(0)+'.jpg',jpg_image,true=3
endfor
end
