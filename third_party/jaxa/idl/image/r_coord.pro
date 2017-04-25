;+
;  NAME: r_coord
;
;  PURPOSE: Given a linear array index and a centroid this will
;           return the radial distance in pixels. This will work
;	    on individual indices, but is more effectively used on
;	    a whole array at once. A linear index can be generated 
;	    using LINDGEN(xdim,ydim).
;
;  CALLING SEQUENCE:  radius=r_coord(linind,imgwdth,cent)
;
;  PARAMETERS:   linind   is the linear index into an array, FLOAT
;                imgwdth  is the image width
;                cent     is a two component vector with the centroid
;
;  NOTES: Use on an image array returns a negative intensity image.
;
;  RETURN TYPE: FLOAT
;
;  CALLS: MODD
;
;  HISTORY: Drafted by A. McAllister, 2-dec-92.
;
;-
FUNCTION r_coord,linind,imgwdth,cent

   x = modd(linind,imgwdth) + 0.5		;correct to center of pixel
   y = fix(linind/imgwdth) + 0.5

   cent=float(cent)

   return, sqrt((x-cent(0))*(x-cent(0)) + (y-cent(1))*(y-cent(1)))

end