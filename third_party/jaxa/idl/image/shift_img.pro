;+

function shift_img,data,shifts,missing=missing, $
                   xscale=xscalein,yscale=yscalein, $
                   rot12=rot12in,anchor=anchorin

;NAME:
;     SHIFT_IMG
;PURPOSE:
;     Shift images in a data cube with optional scale and rotation. 
;CATEGORY:
;CALLING SEQUENCE:
;     outdata = shift_img(data,shifts)
;INPUTS:
;     data = image data cube (or a single image)
;     shifts = array of x and y pixel shifts: fltarr(2,nimages).  A
;              positive value for the shifts moves the image up and
;              right. 
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS
;     missing = value for array for areas that shift out of the FOV
;               (def = 0)
;     xscale, yscale = scale change for images: fltarr(nimages). (def = 1.0)
;     rot = rotation for images, CCW in degrees: fltarr(nimages). (def = 0.0)
;     anchor = center of rotation [x,y]: fltarr(2,nimages). 
;              (def = center of image) 
;OUTPUTS:
;     outdata = array of shifted images, same size as data
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;PROCEDURE:
;     Uses rss2pq to define the transformation and poly_2d to do the
;     shifting.
;EXAMPLE:
;     Here is an example of making a dejittered TRACE movie:
;        itref = 0
;        itrace = trace_cube_pointing(tindex,tdata,itref) ; correct pointing
;        xscale = tindex[itref].cdelt1/tindex.cdelt1
;        yscale = tindex[itref].cdelt2/tindex.cdelt2
;        xshift0 = ((tindex.naxis1-1)-(tindex[itref].naxis1-1)*xscale)/2.
;        yshift0 = ((tindex.naxis2-1)-(tindex[itref].naxis2-1)*yscale)/2.
;        xshift = -xshift0 - (tindex[itref].xcen-tindex.xcen)/tindex.cdelt1
;        yshift = -yshift0 - (tindex[itref].ycen-tindex.ycen)/tindex.cdelt2
;        shifts = transpose([[xshift],[yshift]])
;        dnew = shift_img(tdata,shifts) ; dejittered data cube
;      This example does not correct for solar rotation and the
;      pointing in the index structure will not apply to the shifted data.
;MODIFICATION HISTORY:
;     T. Metcalf 2003-07-29
;-

dsize = size(data)
if dsize[0] LT 2 OR dsize[0] GT 3 then $
   message,'ERROR: data must have 2 or 3 dimensions'
nx = dsize[1]
ny = dsize[2]
if dsize[0] EQ 3 then nimage=dsize[3] else nimage = 1L
if n_elements(missing) NE 1 then missing = 0.

xscale = fltarr(nimage)
yscale = fltarr(nimage)
rot12 = fltarr(nimage)
anchor = fltarr(2,nimage)

if keyword_set(xscalein) then begin
   if n_elements(xscalein) EQ nimage then xscale[*] = xscalein[*] $
   else if n_elements(xscalein) EQ 1 then xscale[*] = xscalein $
   else message,'ERROR: xscale must have either 1 element or '+string(nimage)+' elements'
endif else xscale[*] = 1.0
if keyword_set(yscalein) then begin
   if n_elements(yscalein) EQ nimage then yscale[*] = yscalein[*] $
   else if n_elements(yscalein) EQ 1 then yscale[*] = yscalein $
   else message,'ERROR: yscale must have either 1 element or '+string(nimage)+' elements'
endif else yscale[*] = 1.0
if keyword_set(rot12in) then begin
   if n_elements(rot12in) EQ nimage then rot12[*] = rot12in[*] $
   else if n_elements(rot12in) EQ 1 then rot12[*] = rot12in $
   else message,'ERROR: rot12 must have either 1 element or '+string(nimage)+' elements'
endif else rot12[*] = 0.0
if keyword_set(anchorin) then begin
   if n_elements(anchorin) EQ 2*nimage then begin
      anchor[0,*] = anchorin[0,*]
      anchor[1,*] = anchorin[1,*]
   endif else if n_elements(anchorin) EQ 2 then begin
      anchor[0,*] = anchorin[0]
      anchor[1,*] = anchorin[1]
   endif else  message,'ERROR: anchor must have either 2 elements or '+string(2*nimage)+' elements'
endif else begin
   anchor[0,*] = (nx-1)/2.
   anchor[1,*] = (ny-1)/2.
endelse

outdata = data

for i=0L,nimage-1L do begin
   xshift = shifts[0,i]
   yshift = shifts[1,i]
   t = rss2pq(nx,ny,xscale=xscale[i],yscale=yscale[i], $
                    xshift=xshift,yshift=yshift, $
                    rot12=rot12[i],p=p,q=q,anchor=anchor[*,i])
   outdata[*,*,i] =  poly_2d(data[*,*,i],p,q,2,nx,ny,cubic=-0.5,missing=missing)
endfor

return,outdata

end
