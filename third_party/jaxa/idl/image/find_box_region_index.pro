;-------------------------------------------------------------------------------
;+
; find_box_region_index
;
; Purpose: given image x and y coordinates, and x and y coordinates of a polygon box 
;    (arbitrary shape), return the indexs of the pixels enclosed inside the box
;
; Calling sequence:
;   index_1d = find_box_region_index(x, y, box_xy)
; 
; Input: 
;   x: x-coordinates of a 2D image array
;   y: y-''''
;   box_xy: [2,n] array of x and y coordinates for n vertices of a polygon
;
; Return:
;   index_1d: 1D index (1D array) of all the pixels inside the box. 
; 
; Note: for a 2D image array, say, image=fltarr[nx, ny], the corresponding area
;   inside the box can be used as image[index_1d] -- it's like the index array returned
;   by where()
;
; History: 
;  2007/03/21: written, Wei Liu, Kim Tolbert, GSFC  This was extracted from plotman__image_flux.pro
; Modified:
;  4-Oct-2010, Kim Tolbert, Add .5 pixel size to boundary locations when converting to
;   pixel element number, so pixels passed to POLYFILLV will be shifted, and now if center of pixel is within 
;   boundary, it will be included.  Previously did some rounding on or off because polyfillv doesn't activate a 
;   box unless center lies to right of boundary.
;-
;===============================================================================

function find_box_region_index, x, y, box_xy

nx = N_elements(x)
ny = N_elements(y)

dx = x[1]-x[0]
dy = y[1]-y[0]

;--- use value_locate() to find the nearest index in the x, y grids for box vertices ------
; ADD .5 pixel size in either dimension to boundary locations to take care of peculiarity with POLYFILLV.  
; POLYFILLV interprets the pixel elements as the bottom, left of the pixel, so if you say (to simplify, 
; think in 1-D) you want the elements in pixels 2,3,4 it returns, elements 2,3 and not 4.  So adding 
; .5 of a pixel width to boundary x,y positions will have a rounding effect, and pixels will be included by 
; pollyfillv if the boundary includes the center of the pixel.
box_ind= box_xy	; 2D indexes of the box vertices
box_ind[0,*]= value_locate(x, box_xy[0,*] + .5*dx)	> 0
box_ind[1,*]= value_locate(y, box_xy[1,*] + .5*dy)  > 0

;--- find the 1D indexes of the region enclosed by the box --------
index_1d = polyfillv(box_ind(0,*),box_ind(1,*),nx, ny)


return, index_1d

end
