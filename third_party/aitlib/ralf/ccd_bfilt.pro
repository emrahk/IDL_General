PRO CCD_BFILT, image, flux, area, sigma, N_SIGMA=n_sigma, SILENT=silent
;
;+
; NAME:
;	CCD_BFILT
;	
; PURPOSE:   
;	Use filtering algorithm before determination of total flux in a
;	background aperture, to exclude cosmics or dead columns.
;       Before adding the pixel values, SIGMA_FILTER is applied :
;       Computes the mean and standard deviation of pixels in a box
;	centered at each pixel of the image, but excluding the center
;	pixel. If the center pixel value exceeds some N_SIGMA standard
;	deviations from the mean, it is replaced by the mean in box.
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_BFILT, image, [ flux, area, sigma, $
;                  N_SIGMA=n_sigma, SILENT=silent ]
;
; INPUTS:
;	IMAGE    : 2D image array.
;
; OPTIONAL INPUTS:
;	NONE.
;
; KEYWORDS:
;	NONE.
;
; OPTIONAL KEYWORDS:
;	N_SIGMA : Filter limit in sigma, see above.
;	SILENT  : No screen output of number of rejected pixels.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS
;       FLUX  : Integrated flux in the image array.
;       AREA  : Area used for flux integration [pixel].
;       SIGMA : Sigma for the INTEGRATED flux.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;	NONE.
;	
; RESTRICTIONS:
;	NONE.
;
; REVISION HISTORY:
;	Ralf D. Geckeler - %CCD% package for IDL - written Sept.96.
;-


on_error,2                      ;Return to caller if an error occurs

if not EXIST(image) then message,'Image file missing' else begin $
si=size(image)
if si(0) ne 2 then $
message,'Image array must be 2 dimensional'
endelse

if not EXIST(n_sigma) then n_sigma=3

ima_filt=SIGMA_FILTER(image,n_sigma=n_sigma,/all_pixels, $
                      /iterate,n_change=n_change)

flux=total(ima_filt)
area=double(n_elements(ima_filt))
rms=sqrt(total((ima_filt-flux/area)^2)/(area-1.0d0)) ;per pixel
rms_flux=sqrt(area)*rms	;sigma error of integrated flux

if not EXIST(silent) then message, $
'Changed pixel [%] : '+strtrim(string(double(n_change)*100.0d0/area),2),/inf

RETURN
END
