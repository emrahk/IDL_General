;+
; Project     : SSW
;
; Name        : IMG_ENTROPY
;
; Purpose     : Returns a standard (but not unique) value for the entropy of an image
;				according to the construction given in Taro Sakao's thesis
;				as used for the Yohkoh HXT image reconstruction
;
;
; Category    : Image Processing
;
; Explanation : Img_entropy = - Sum( F * alog( F )) where F = Img / Avg(Img)
;
; Syntax      : IDL> result = mtotal (array, dimension)
;
; Inputs      : array - array to be summed (or multiplied)
;
; Opt. Inputs : dimension - dimension over which to sum (starting at 1)
;
; Outputs     : Returns sum(product) of elements in array, or sum(product) over dimension if dimension(s) are specified
;
; Keywords    :
;				SUM - total of input image
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     :
;				27-aug-2010, richard.schwartz@nasa.gov
;
; Contact     : richard.schwartz@nasa.gov
;-
function img_entropy, img, sum=sum

;Assume first 2 dimensions are the images, last dimensions index the image
out = img>0 ; positivity
sz  = size(/str, out)
nxny = sz.dimensions[0:1]
nxy = product(nxny)
out = reform(/over, out, nxy, sz.dimensions[2]>1)
sum = total(out, 1)
if sum eq 0 then begin
	sum = 1
	out = out + 1./ nxy
	endif
out = out/transpose(reproduce(sum,nxy))
z = where(out le 0, nz)
if nz ge 1 then out[z]=1
return, 0.0- mtotal( out*alog(out),/first)
end