PRO CCD_BSIGMA, image, flux, area, rms_flux, N_SIGMA=n_sigma, SILENT=silent
;
;+
; NAME:
;	CCD_BSIGMA
;	
; PURPOSE:   
;	Use iterative algorithm to determine total flux in a background
;	aperture, excluding cosmics or dead columns.
;	Program calculates mean flux/pixel and sigma of flux,
;	rejecting all pixels deviating more than N_SIGMA*sigma from mean.
;	Procedure is repeated, until no pixels have to be rejected, then
;	total flux and sigma (of total flux) is determined. 
;
; CATEGORY:
;	Astronomical Photometry.
;
; CALLING SEQUENCE:
;	CCD_BSIGMA, image, [ flux, area, rms_flux, $
;                   N_SIGMA=n_sigma, SILENT=silent ]
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
;	N_SIGMA : Use only pixels within mean+-SIGMA_N*sigma to
;		  calculate flux, see above.
;	SILENT  : No screen output of number of rejected pixels.
;
; OUTPUTS:
;	NONE.
;
; OPTIONAL OUTPUT PARAMETERS
;       FLUX     : Integrated flux in the image array.
;       AREA     : Area used for flux integration [pixel].
;       RMS_FLUX : Sigma for the INTEGRATED flux.
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

if not EXIST(image) then  message,'Image file missing' else begin $
si=size(image)
if si(0) lt 1 then $
message,'Array dimension must >1.'
endelse

if not EXIST(n_sigma) then n_sigma=3

re=1	;rejected pixels per iteration
cc=0
rms=max(image)-min(image)
flux=total(image)
area=double(n_elements(image))
count_old=double(n_elements(image))

repeat begin

   ind=where(abs(image-flux/area) lt rms*double(n_sigma),count)

   if ind(0) ne -1 then begin
      flux=total(image(ind))
      area=double(count)
      rms=sqrt(total((image(ind)-flux/area)^2)/(area-1.0d0)) ;per pixel
      rms_flux=sqrt(area)*rms	;sigma error of integrated flux
      re=count_old-count
      cc=cc+1
      count_old=count

   endif else begin

      flux=0.0d0
      sigma=0.0d0
      area=0.0d0
      if not EXIST(silent) then $
      message,'Rejecting all pixel'
   endelse

endrep until ((area eq 0.0) or ((re eq 0) and (cc gt 1)))

if not EXIST(silent) then message, $
'Rejected pixel in background [%] : '+strtrim(string(re_t*100/area),2),/inf

RETURN
END
