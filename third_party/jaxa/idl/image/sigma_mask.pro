function Sigma_mask, image, box_width, n_sigma=nsigma, all_pixels=all, $
                     monitor=monitor, radius=radius, n_change=nchange, $
                     variance_image=imvar, deviation_image=imdev, $
                     outbox=outbox

;+
; NAME:
;	sigma_mask
; PURPOSE:
;	Computes the mean and standard deviation of pixels in a box
;	centered at  
;	each pixel of the image, but excluding the center pixel. If the center 
;	pixel value exceeds some # of standard deviations from the mean, it is 
;	flagged. Note option to process pixels on
;	the edges.
;	
; CALLING SEQUENCE:
;	Result = sigma_mask( image, box_width, N_sigma=(#), /ALL,/MON )
; INPUTS:
;	image = 2-D image (matrix)
;	box_width = width of square filter box, in # pixels (default = 3)
; KEYWORDS:
;	N_sigma - # standard deviations to define outliers, floating point,
;			recommend > 2, default = 3. For gaussian statistics:
;			N_sigma = 1 flags 35% of pixels, 2 = 5%, 3 = 1%.
;	RADIUS - alternative to specify box radius, so box_width = 2*radius+1.
;      /ALL_PIXELS causes computation to include edges of image,
;      /MONITOR prints information about % pixels replaced.
; Optional Outputs:
;	N_CHANGE - # of pixels flagged (mask = 0)
;	VARIANCE - image of pixel neighborhood variances * (N_sigma)^2,
;	DEVIATION - image of pixel deviations from neighborhood means,
;	squared.
;	OUTBOX - Size of box to return flagged around any marked pixel
;                (default 1)
; CALLS:
;	function filter_image( )
; PROCEDURE:
;	Compute mean over moving box-cars using smooth, subtract center values,
;	compute variance using smooth on deviations from mean,
;	check where pixel deviation from mean is within variance of
;	box.
;	Return a mask array with ones where the deviation is less than
;	the specified amount and zeros for the points outside the range.
;	
; MODIFICATION HISTORY:
;	Derived from Frank Varosi's SIGMA_FILTER routine. Mar 1996, SJT.
;-

if N_elements( radius ) EQ 1 then  box_width = 2*radius+1  else begin
    if N_elements( box_width ) NE 1 then box_width = 3
    box_width = 2*(fix( box_width )/2) + 1 ;make sure width is odd.
endelse

if (n_elements(outbox) eq 0) then outbox = 1
if (outbox mod 2 eq 0) then outbox = outbox+1

si = size(image)
if (si(0) ne 2) then message, "IMAGE must be a 2-D array."

if (box_width LT 3) then return, replicate(1b, si(1), si(2))
bw2 = box_width^2

mean = (filter_image( image, SMO = box_width, ALL = all )*bw2 - image)/ $
  (bw2-1)

if N_elements( Nsigma ) NE 1 then Nsigma = 3.
if (Nsigma LE 0) then return, replicate(0b, si(1), si(2))

imdev = (image - mean)^2
fact = float( Nsigma^2 )/(bw2-2)
imvar = fact*( filter_image( imdev, SMO = box_width, ALL = all )*bw2 - imdev )

iuse = imdev lt imvar
nok = long(total(iuse))

npix = N_elements( image )

nchange = npix - nok
if keyword_set( monitor ) then $
  print, nchange*100./npix, Nsigma, $
  FORM = "(F6.2,' % of pixels excluded, N_sigma=',F3.1)"

if (outbox ne 1) then begin
    iuse2 = replicate(1b, si(1)+(outbox-1), si(2)+(outbox-1))
    jshift = (outbox-1)/2
    iuse2(jshift, jshift) = iuse
    iuse2 = erode(iuse2, replicate(1b, outbox, outbox))
    iuse = iuse2(jshift:jshift+si(1)-1, jshift:jshift+si(2)-1)
endif

return, iuse

end
