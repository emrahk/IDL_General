;+
; Project     :	STEREO
;
; Name        :	WCS_FIT_GRISM_FUNCT()
;
; Purpose     :	Function used by WCS_FIT_GRISM
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This function is used by the WCS_FIT_GRISM procedure to fit
;               grism parameters to spectral coordinates.  See WCS_FIT_GRISM
;               for more information.
;
; Syntax      :	Result = WCS_FIT_GRISM( PIXREL, PARAM )
;
; Examples    :	If PIXEL contains the array of pixel locations, and WAVE
;               contains the array of measured wavelengths, in Angstroms, and
;               CRPIX is the desired value of the FITS keyword, then
;
;                       PIXREL = PIXEL - (CRPIX - 1)
;                       WCS_FIT_GRISM, PIXREL, WAVE, PARAM, COORD='WAVE', $
;                               CUNIT='Angstrom', /INIT, MAX_ITER=1000
;
;               will do an initial fit of up to 1000 iterations, and
;
;                       OPLOT, PIXEL, WAVE-WCS_FIT_GRISM_FUNCT(PIXREL, PARAM)
;
;               will display the residuals.
;
; Inputs      :	PIXREL  = Array of pixel locations, relative to the reference
;                         pixel.  The FITS keyword CRPIXia must be consistent
;                         with the reference pixel used in calculating PIXREL.
;                         Note that FITS pixels start with 1, while IDL pixels
;                         start with 0--that distinction must be taken into
;                         account.
;
;               PARAM   = The parameter array, with the following elements:
;
;                               CRVAL           Reference value
;                               CDELT           Pixel spacing
;                               GME             G * m / cos(epsilon)
;                               NRA             nr * sin(alpha)
;                               NRAPRIME        nrprime * sin(alpha)
;                               THETA           theta
;
;                         See WCS_FIT_GRISM for more information.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the spectral coordinate, as a
;               function of pixel position.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	Only native IDL statements.
;
; Common      :	The common block wcs_fit_grism is used to pass information from
;               the calling routine WCS_FIT_GRISM.
;
; Restrictions:	Not all combinations of the grism parameters are valid.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 28 June 2005, William Thompson, GSFC 
;
; Contact     :	WTHOMPSON
;-
;
function wcs_fit_grism_funct, pixrel, param
;
on_error, 2
common wcs_fit_grism, base_units, factor, coord_type, restfrq, restwav, gra
;
;  Define various constants, including those for calculating the refractive
;  index of air.
;
c = 2.99792458d8        ;Speed of light
h = 6.6260693d-34       ;Planck constant
apar = [287.6155d0,  1.62887d-12,  0.01360d-24]
pder = [287.6155d0, -1.62887d-12, -0.04080d-24]
;
;  Parse the parameter array
;
crval    = param[0]
cdelt    = param[1]
gme      = param[2]
nra      = param[3]
nraprime = param[4]
theta    = param[5] * !dpi / 180.
;
case coord_type of
    'FREQ': begin
        nu0 = factor * crval
        lambda0 = c / nu0
        deriv = -c / nu0^2
    endcase
    'ENER': begin
        nu0 = factor * crval / h
        lambda0 = c / nu0
        deriv = -c * h / nu0^2
    endcase
    'WAVN': begin
        kappa0 = factor * crval
        lambda0 = 1.d0 / kappa0
        deriv = -1.d0 / (c * kappa0)^2
    endcase
    'VRAD': begin
        v0 = factor * crval
        nu0 = restfrq * (1.d0 - v0 / c)
        lambda0 = c / nu0
        deriv = restfrq / nu0^2
    endcase
    'WAVE': begin
        lambda0 = factor * crval
        deriv = 1.d0
    endcase
    'VOPT': begin
        z0 = factor * crval
        lambda0 = restwav * (1.d0 + z0 / c)
        deriv = restwav / c
    endcase
    'ZOPT': begin
        z0 = factor * crval
        lambda0 = restwav * (1.d0 + z0)
        deriv = restwav
    endcase
    'AWAV': begin
        x = factor * crval
        if keyword_set(gra) then begin
            lambda0 = x
            deriv = 1.d0
        end else begin
            lambda0 = x*(1.d0 + 1.d-6*(apar[0] + apar[1]/x^2 + apar[2]/x^4))
            deriv = (1.d0 + 1.d-6 * (pder[0] + pder[1]/x^2 + pder[2]/x^4))
        endelse
    endcase
    'VELO': begin
        v0 = factor * crval
        lambda0 = restwav * (c + v0) / sqrt(c^2 - v0^2)
        deriv = c * restwav / ((c - v0) * sqrt(c^2 - v0^2))
    end
    'BETA': begin
        v0 = factor * crval * c
        lambda0 = restwav * (c + v0) / sqrt(c^2 - v0^2)
        deriv = c^2 * restwav / ((c - v0) * sqrt(c^2 - v0^2))
    endcase
endcase
;
;  For grisms-in-air, unless the coordinate type is AWAV, correct for the
;  distinction between vacuum and air wavelengths.
;
if keyword_set(gra) and (coord_type ne 'AWAV') then begin
    lambda0 = lambda0 / $
      (1.d0 + 1.d-6 * (apar[0] + apar[1]/lambda0^2 + apar[2]/lambda0^4))
    deriv = deriv * $
      (1.d0 + 1.d-6 * (pder[0] + pder[1]/lambda0^2 + pder[2]/lambda0^4))
endif
;
;  Calculate the reference angle gamma_r, and the derivative dGamma/dw.
;
gamma0 = gme * lambda0 - nra
if abs(gamma0) le 1 then gamma0 = asin(gamma0) else message, $
  'Incompatible grism parameters'
denom = cos(gamma0) * cos(theta)^2
if denom eq 0 then message, 'Incompatible grism parameters'
dgdw = deriv * (gme - nraprime) / denom
;
;  Calculate the grism parameter, and use it to calculate the wavelength.
;
intermediate = cdelt*pixrel
gamma = -tan(theta) + dgdw * factor * intermediate
gamma = atan(gamma) + gamma0 + theta
denom = gme - nraprime
if denom eq 0 then message, 'Incompatible grism parameters'
lambda = (nra - nraprime * lambda0 + sin(gamma)) / denom
;
;  Unless the coordinate type is AWAV, correct for the distinction between
;  vacuum and air wavelengths.
;
if keyword_set(gra) and (coord_type ne 'AWAV') then lambda = lambda * $
  (1.d0 + 1.d-6 * (apar[0] + apar[1]/lambda^2 + apar[2]/lambda^4))
;
;  Convert into the final spectral coordinate variable.
;
case coord_type of
    'FREQ': s = c / lambda
    'ENER': s = h * c / lambda
    'WAVN': s = 1.d0 / lambda
    'VRAD': begin
        freq = c / lambda
        s = c * (restfrq - freq) / restfrq
    endcase
    'WAVE': s = lambda
    'VOPT': s = c * (lambda - restwav) / restwav
    'ZOPT': s = (lambda - restwav) / restwav
    'AWAV': if keyword_set(gra) then s = lambda else s = lambda * $
      (1.d0 + 1.d-6 * (apar[0] + apar[1]/lambda^2 + apar[2]/lambda^4))
    'VELO': s = c * (lambda^2 - restwav^2) / (lambda^2 + restwav^2)
    'BETA': s = (lambda^2 - restwav^2) / (lambda^2 + restwav^2)
endcase
;
;  Apply the appropriate units conversion, and return.
;
return, s / factor
end
