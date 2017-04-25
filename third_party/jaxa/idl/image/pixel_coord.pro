;+
; PROJECT:
;	HESSI
; NAME:
;	PIXEL_COORD
;
; PURPOSE:
;	This function converts image dimensions into a 2d array
;	of x and y coordinates in pixel units relative to the center of the image.
;
; CATEGORY:
;	MAP, IMAGE
;
; CALLING SEQUENCE:
;	pixel_coordinates = pixel_coord( [xdim,ydim])
;
; CALLS:
;	none
;
; INPUTS:
;       Image_dim - [number of pixels in x, number of pixels in y]
;		default is [64, 64].
;		Values may differ in x and y.
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       Pixels returned with coordinate values in a float array
;	dimensioned [ 2, Number_in_x x Number_in_y ].
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Map coordinates are built from 1-d pixel indices.
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 16-mar-99.
;	Version 1.1, richard.schwartz@gsfc.nasa.gov, 1-mar-2000.
;		Fixed pixel index error for y location.  Irrelevant for
;		image_dim[0] eq image_dim[1].  Otherwise, it's serious.
;	Version 1.2, richard.schwartz@gsfc.nasa.gov, 6-mar-2000.
;		Added assurance of integer arithmetic.
;	9-SEP-2010, richard.schwartz@nasa.gov, renamed from hsi_pixel_coord.pro
;	16-oct-2012, richard.schwartz@nasa.gov, using get_ij, it's faster
;-
function pixel_coord, image_dim

checkvar, image_dim, [64,64]

mapindex = where( fltarr( image_dim[0]>1, image_dim[1]>1 ) +1, npixel)

;xpixel= mapindex mod image_dim[0]
;;ypixel= mapindex / image_dim[1]
;ypixel= long(mapindex / image_dim[0])
;xpixel= xpixel - (image_dim[0]-1.)/2.
;ypixel= ypixel - (image_dim[1]-1.)/2.
;res   = [reform(xpixel,1,npixel), reform(ypixel,1,npixel)]

out   = float(get_ij( mapindex, image_dim[0]))
out[0,*] = out[0,*] - (image_dim[0]-1.)/2.
out[1,*] = out[1,*] - (image_dim[1]-1.)/2.

return, out
end