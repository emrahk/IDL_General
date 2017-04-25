FUNCTION confac, image, fac, INTERPOLATE=interpolate, CUBIC=cubic
;+
;   Name: confac
;
;   Purpose: simplify interface to congrid
;
;   Input Parameters:
;      image  - image to congrid (2D or 3D ok)
;      factor - congrid factor (arbitrary default=.25)
;
;   Keyword Parameters:
;       interpolate - bilinear interp - (see congrid)
;       cubic       - cubic spline inter (see congrid)
; 
;   History:
;      Written by Tom Berger, LMSAL
;      12-Nov-1998 - S.L.Freeland - added a little doc -> SSW
;      10-Dec-1999 - S.L.Freeland - protect against no FAC (supply default=.25)
;                                   allow "image" to be 3D ("cube")
;                                   Got rid of unstructured exit...
;      24-Sep-2010 - William Thompson, use [] indexing
;-
ON_ERROR,2

if n_elements(fac) eq 0 then fac=.25  ; arbitrary, but wont crash... (slf)

nx = data_chk(image,/nx)
ny = data_chk(image,/ny)
nz = data_chk(image,/nimages)   ; SLF, added 10-Dec-1999

if nz eq 0 then begin 
    box_message,['Need 2D or 3D input...',$
    'IDL> facdata=confac(data,fact [,/interpolate]  [,/cubic])']
    return, -1
endif
 
tx=nx*fac
ty=ny*fac

retval=make_array(tx,ty,nz, type=data_chk(image,/type))

for i=0,nz-1 do retval[0,0,i]=$        ; insert 2D->3D
  CONGRID(image[*,*,i], tx, ty,  interp=interpolate, cubic=cubic)
                 
return, retval

END
