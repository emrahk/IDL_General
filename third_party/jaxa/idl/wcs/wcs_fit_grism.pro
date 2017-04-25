;+
; Project     :	STEREO
;
; Name        :	WCS_FIT_GRISM
;
; Purpose     :	Fit GRISM parameters to spectral dispersion
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	This procedure takes a series of pixel vs. spectral coordinate
;               measurements, and fits the World Coordinate GRISM function,
;               which combines grating and prism parameters to characterize
;               spectral dispersion.  Besides the usual FITS keywords CRPIX,
;               CRVAL, and CDELT, the GRISM projection uses the following
;               parameters:
;
;                   PVk_0a  G        Grating ruling density         [m^-1]
;                   PVk_1a  m        Grating order
;                   PVk_2a  alpha    Angle of incidence             [deg]
;                   PVk_3a  nr       Zeroth order refractive term
;                   PVk_4a  nrprime  First order refractive term    [m^-1]
;                   PVk_5a  epsilon  Out-of-plane angle             [deg]
;                   PVk_6a  theta    Angle to camera axis           [deg]
;
;               However, these terms are not completely independent of each
;               other.  The fitted array PARAM contains the following elements:
;
;                       CRVAL           Reference value
;                       CDELT           Pixel spacing
;                       GME             G * m / cos(epsilon)
;                       NRA             nr * sin(alpha)
;                       NRAPRIME        nrprime * sin(alpha)
;                       THETA           theta
;
;               Once these parameters have been fitted, it's left up to the
;               user to decompose them into the seven GRISM parameters above,
;               in whatever manner seems most suitable.
;
; Syntax      :	WCS_FIT_GRISM, PIXREL, COORD,  [... keywords ...]
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
;               COORD   = Array of spectral coordinate positions associated
;                         with PIXREL.  The type of coordinate is given by the
;                         keyword COORD_TYPE, and the units are given by the
;                         keyword CUNIT.  Both are needed to properly evaluate
;                         the GRISM function.
;
; Opt. Inputs :	PARAM   = The array of first guesses for the fitted parameters,
;                         as described above.  If not passed, then the software
;                         generates a first guess.
;
; Outputs     :	PARAM   = The array of fitted parameters, as described above.
;                         One should always examine the result of the fit, to
;                         see if additional iterations are required.  It may
;                         take several calls before converging to a solution.
;                         Setting MAX_ITER=1000 will also help.
;
; Opt. Outputs:	None.
;
; Keywords    :	COORD_TYPE = String containing the four-letter codes used in
;                            the CTYPE keyword.  For example, if the spectral
;                            axis is wavelength, the FITS header would contain
;                            a line like "CTYPE1 = 'WAVE-GRI'.  Can be one of
;                            the following:
;
;                               WAVE    Vacuum wavelength (default)
;                               AWAV    Air wavelength (def. if /AIR_GRISM)
;                               FREQ    Frequency
;                               ENER    Energy
;                               WAVN    Wave number
;                               VELO    Velocity
;                               VRAD    Radio velocity
;                               VOPT    Optical velocity
;                               ZOPT    Redshift
;                               BETA    Beta factor (v/c)
;
;               CUNIT      = The units string to be stored in the FITS header,
;                            e.g. 'Angstrom', 'Hz', 'm/s', etc.  The default
;                            depends on COORD_TYPE, and the units must be
;                            consistent with COORD_TYPE.  See WCS_PARSE_UNITS
;                            for more information on the types of strings
;                            allowed.  It's very important to get the units
;                            correct, because the GRISM parameters are in MKS
;                            units, as are the constants used to support the
;                            non-wavelength coordinate types.
;
;               RESTWAV    = The rest wavelength.
;               RESTFRQ    = The rest frequency.  One or the other of these
;                            keywords is needed for calculations involving
;                            velocity.  Only one needs to be passed--the other
;                            will be calculated automatically.
;
;               AIR_GRISM  = If set, then the grism-in-air (GRA) projection is
;                            fitted, instead of the normal GRI projection.
;
;               NORESET    = If set, then the information stored in the common
;                            block, based on the above keywords, is not reset.
;                            This simplifies the process of recalling the
;                            procedure to reiterate the solution.
;
;               INITIALIZE = If set, then the parameter array is initialized to
;                            a first guess, based on answers to questions posed
;                            by the program.
;
;               LAMBDA     = Step sizes to use in fitting the parameters.  The
;                            default is 1% of the values, which means that any
;                            value set to 0 is not fitted.  Ignored if doesn't
;                            have six elements.
;
;               FIT_GRATING= If FIT_GRATING=0 is passed, then the GME parameter
;                            is held constant.  The default is to fit GME.
;
;               FIT_ALPHA  = If FIT_ALPHA=0 is passed, then the two parameters
;                            involving the angle alpha, i.e. NRA and NRAPRIME,
;                            are held constant.  The default is to fit NRA, and
;                            to fit NRAPRIME unless the initial guess is 0.
;
;               FIT_THETA  = If set, then fit the THETA parameter, even if the
;                            initial guess is zero.
;
;               FIT_ONLY_THETA = Equivalent to the combination of /FIT_THETA,
;                                FIT_GRATING=0, and FIT_ALPHA=0.  This is
;                                probably a good starting point if all the
;                                other parameters are known.
;
;               NOFIT      = Don't actually fit the data.  Useful for
;                            setting up the common block shared with
;                            WCS_FIT_GRISM_FUNCT.
;
;               NOPRINT    = If set, then information about the fit is not
;                            printed to the screen.
;
;               In addition, any keyword to the AMOEBA_C procedure can be
;               passed, such as MAX_ITER or ERROR.
;
; Calls       :	WCS_FIT_GRISM_FUNCT, WCS_PARSE_UNITS, READ_DEFAULT, AMOEBA_C
;
; Common      :	The common block wcs_fit_grism is used to pass information to
;               the associated routine WCS_FIT_GRISM_FUNCT.
;
; Restrictions:	Not all combinations of the grism parameters are valid.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 28 June 2005, William Thompson, GSFC 
;               Version 2, 29 June 2005, William Thompson, GSFC
;                       Added keywords FIT_ALPHA, FIT_ONLY_THETA
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_fit_grism, pixrel, coord, param, coord_type=k_coord_type, $
                   cunit=cunit, restwav=k_restwav, restfrq=k_restfrq, $
                   air_grism=air_grism, fit_grating=fit_grating, $
                   fit_theta=fit_theta, fit_alpha=fit_alpha, noreset=noreset, $
                   fit_only_theta=fit_only_theta, lambda=lambda, $
                   initialize=initialize, nofit=nofit, noprint=noprint, $
                   n_iter=n_iter, chisqr=chisqr, _extra=_extra
on_error, 2
common wcs_fit_grism, base_units, factor, coord_type, restfrq, restwav, gra
;
;  Check the input parameters.
;
if n_params() lt 3 then message, 'Syntax: WCS_FIT_GRISM, PIXREL, COORD, PARAM'
if n_elements(pixrel) ne n_elements(coord) then message, $
  'Arrays PIXREL and COORD must have the same number of elements'
;
;  If passed, parse the units specification.
;
if n_elements(cunit) eq 0 then begin
    if (not keyword_set(noreset)) or (n_elements(base_units) eq 0) or $
      (n_elements(factor) eq 0) then begin
        base_units = 'DEF'
        factor = 1
    endif
end else wcs_parse_units, cunit, base_units, factor
;
;  Check the air grism setting.
;
if keyword_set(air_grism) then gra = 1 else $
  if (not keyword_set(noreset)) or (n_elements(gra) eq 0) then gra = 0
;
;  Check the coordinate type.
;
if n_elements(k_coord_type) eq 1 then begin
    coord_type = strupcase(k_coord_type)  
end else if (not keyword_set(noreset)) or (n_elements(coord_type) eq 0) then $
  begin
    if gra then coord_type = 'AWAV' else coord_type = 'WAVE'
endif
;
;  Check to see if the rest frequency and/or wavelength were passed.
;
c = 2.99792458D8        ;Speed of light
if n_elements(k_restwav) ne 0 then restwav = k_restwav else $
  if (not keyword_set(noreset)) or (n_elements(restwav) eq 0) then restwav = 0
if n_elements(k_restfrq) ne 0 then restfrq = k_restfrq else $
  if (not keyword_set(noreset)) or (n_elements(restfrq) eq 0) then restfrq = 0
if (restfrq ne 0) and (restwav eq 0) then restwav = c / restfrq
if (restwav ne 0) and (restfrq eq 0) then restfrq = c / restwav
;
;  Depending on the coordinate type, see if the necessary parameters were
;  passed.
;
case coord_type of
    'FREQ': if (base_units ne 's^-1') and (base_units ne 'DEF') then $
      message, 'Illegal units specification ' + cunit
    'ENER': if (base_units ne 'kg.m^2.s^-2') and (base_units ne 'DEF') then $
      message, 'Illegal units specification ' + cunit
    'WAVN': if (base_units ne 'm^-1') and (base_units ne 'DEF') then $
      message, 'Illegal units specification ' + cunit
    'VRAD': begin
        if (base_units ne 'm.s^-1') and (base_units ne 'DEF') then $
          message, 'Illegal units specification ' + cunit
        if restfrq eq 0 then message, 'Rest frequency not available'
    endcase
    'WAVE': if (base_units ne 'm') and (base_units ne 'DEF') then $
      message, 'Illegal units specification ' + cunit
    'VOPT': begin
        if (base_units ne 'm.s^-1') and (base_units ne 'DEF') then $
          message, 'Illegal units specification ' + cunit
        if restwav eq 0 then message, 'Rest wavelength not available'
    endcase
    'ZOPT': begin
        if (base_units ne '') and (base_units ne 'DEF') then $
          message, 'Illegal units specification ' + cunit
        if restwav eq 0 then message, 'Rest wavelength not available'
    endcase
    'AWAV': if (base_units ne 'm') and (base_units ne 'DEF') then $
      message, 'Illegal units specification ' + cunit
    'VELO': begin
        if (base_units ne 'm.s^-1') and (base_units ne 'DEF') then $
          message, 'Illegal units specification ' + cunit
        if restwav eq 0 then message, 'Rest wavelength not available'
    endcase
    'BETA': begin
        if (base_units ne '') and (base_units ne 'DEF') then $
          message, 'Illegal units specification ' + cunit
        if restwav eq 0 then message, 'Rest wavelength not available'
    endcase
    else: message, 'Invalid coordinate type ' + coord_type
endcase
;
;  Set up the initial guess.
;
if keyword_set(initialize) or (n_elements(param) ne 6) then begin
    par1 = poly_fit(pixrel,coord,1)
    param = [poly(0.d0, par1), par1[1], 0, 1, 0, 0]
    print, 'A ruling must be entered to fit the grating term.'
    read_default, 'Grating ruling (m^-1)', g, 0.d0
    if g ne 0 then begin
        read_default, 'Grating order', m, 1
        read_default, 'Out-of-plane angle (deg)', epsilon, 0.d0
        param[2] = g * m / cos(epsilon * !dpi / 180.d0)
    endif
    read_default, 'Angle of incidence (deg)', alpha, 10.d0
    sin_alpha = sin(alpha * !dpi / 180.d0)
    print,'Leave the refractive terms at the default for grating-only case'
    read_default, 'Zeroth order refractive term', nr, 1.d0
    param[3] = nr * sin_alpha
    read_default, 'First order refractive term', nrprime, 0.d0
    param[4] = nrprime * sin_alpha
    read_default, 'Angle to camera axis (deg)', theta, 0.d0
    param[5] = theta
endif
;
;  Make sure that the parameter list includes some dispersive terms.
;
if (param[2] eq 0) and (param[4] eq 0) then message, $
  'Parameter list contains neither a grating nor a prism term'
;
;  Set up the step sizes.
;
if n_elements(lambda) eq 6 then lambda0 = lambda else lambda0 = 0.01 * param
if n_elements(fit_grating) eq 1 then $
  lambda0[2] = lambda0[2] * keyword_set(fit_grating)
if n_elements(fit_alpha) eq 1 then $
  lambda0[3:4] = lambda0[3:4] * keyword_set(fit_alpha)
if keyword_set(fit_theta) then lambda0[5] = 1
if keyword_set(fit_only_theta) then lambda0[2:5] = [0,0,0,1]
;
;  Do the fit, and return.
;
if keyword_set(nofit) then return
if not keyword_set(noprint) then begin
    print, ''
    print, 'Coordinate type: ', coord_type
    print, 'Conversion factor: ', factor
    if restwav ne 0 then begin
        print, 'Rest wavelength [m]:', restwav
        print, 'Rest frequency [Hz]:', restfrq
    endif
    print, ''
endif
amoeba_c, pixrel, coord, 'wcs_fit_grism_funct', param, lambda=lambda0, $
  noprint=noprint, n_iter=n_iter, chisqr=chisqr, _extra=_extra
;
end
