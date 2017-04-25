;+
; NAME:
;	GIF2JPG24
;
; PURPOSE:
;	Change GIF format to 24 bit color JPEG
;
; CATEGORY:
;	Image Processing
;
; CALLING SEQUENCE:
;
;	GIF2JPG24, Gif_image,R,G,B,Jpg_image, JSIZE=[naxis1,naxis2]
;
; 
; INPUTS:
;        Gif_image 
;        R           red color table
;        G           green color table
;        B           blue color table
;
; OPTIONAL INPUTS:
;	
; KEYWORD PARAMETERS:
;	JSIZE	ARRAY(2)	[horiz,vert] size of output image
;
; OUTPUTS:
;        Jpg_image   byte array (JSIZE(0),JSIZE(1),3) in 24 bit color with color info in 3rd dim
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
; 	To change a GIF to a 1024x1024 JPEG
;
;	GIF2JPG24, Gif_image,R,G,B,Jpg_image,JSIZE=[1024,1024]
;
; MODIFICATION HISTORY:
; 	Written by:	Dennis Wang, 18 Mar 1999
;	99/07/12  N. Rich	Make jsize_x & _y optional keyword JSIZE
;	01/09/13  N. Rich	Add messages
;
;	@(#)gif2jpg24.pro	1.3 09/13/01 LASCO IDL LIBRARY
;-

pro gif2jpg24,gif_image,r,g,b,jpg_image,JSIZE=jsize
;tvlct,r,g,b,/GET
message,'',/INFO
t1=systime(1)
sz = size(gif_image)
IF not(keyword_set(JSIZE)) THEN BEGIN
	jsize_x = sz(1)
	jsize_y = sz(2)
ENDIF ELSE BEGIN
	jsize_x = jsize(0)
	jsize_y = jsize(1)
ENDELSE

if (sz(1) ne jsize_x or sz(2) ne jsize_y) then begin
 image = congrid(gif_image,jsize_x,jsize_y)
endif else begin
 image = gif_image
endelse
jpg_image = bytarr(jsize_x,jsize_y,3)

horz = jsize_x - 1
vert = jsize_y - 1

for ivert = 0,vert do begin
 for ihorz = 0,horz do begin
  jpg_image(ihorz,ivert,*) = [r(image(ihorz,ivert)),g(image(ihorz,ivert)),b(image(ihorz,ivert))]
 endfor
endfor

print,' took',systime(1)-t1,' seconds'
end
