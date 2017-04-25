;+
; Project:
;     SDAC
; Name:
;     GOES_CHIANTI_TEM
;
; Usage:
;     goes_chianti_tem, fl, fs, temperature, emission_meas, satellite=goes
;                       [, /photospheric, date=date_if_GOES_6 ]
;
;Purpose:
;     This procedures computes the temperature and emission measure of the
;     solar soft X-ray plasma measured with the GOES ionization chambers
;     using CHIANTI spectral models with coronal or photospheric abundances
;
;     Intended as a drop-in replacement for GOES_TEM that uses mewe_spec
;
;Category:
;     GOES, SPECTRA
;
;Method:
;     From the ratio of the two channels the temperature is computed
;     from a spline fit from a lookup table for 101 temperatures
;     then the emission measure is derived from the temperature and b8.
;     All the hard work is done in two other routines containing the
;     coefficients for the responses.
;
;Inputs:
;     FL - GOES long wavelength flux in Watts/meter^2
;     FS - GOES short wavelength flux
;
;Keywords:
;     satellite  - GOES satellite number, needed to get the correct response
;     photospheric - use photospheric abundances rather than the default
;              coronal abundnaces
;     DATE   - ANYTIM format, eg 91/11/5 or 5-Nov-91,
;              used for GOES6 where the constant used to scale the reported
;              long-wavelength channel flux was changed on 28-Jun-1993 from
;              4.43e-6 to 5.32e-6, all the algorithms assume 5.32 so FL prior
;              to that date must be rescaled as FL = FL*(4.43/5.32)
;
;Outputs:
;     Temperature   - Plasma temperature in units of 1e6 Kelvin
;     Emission_meas - Emission measure in units of 1e49 cm-3
;
;Common Blocks:
;     None.
;
;Needed Files:
;     goes_get_chianti_temp, goes_get_chianti_em contain the coefficients.
;     also calls anytim, fcheck
;
; MODIFICATION HISTORY:
;     Stephen White, 04/03/24
;     Stephen White, 05/08/15: added the scl89 correction for GOES 8-12
;		Based on Chianti
;		(See goes_get_chianti_tem for Version. 5.2 at last revision)
;	  Richard Schwartz, 2010-dec-02, change GOES6 FL conversion date to 28-jun-1983 from
;		28-jun-1993
;
; Contact     : Richard.Schwartz@gsfc.nasa.gov
;
;-
;-------------------------------------------------------------------------

 pro goes_chianti_tem, fl_in, fs_in, temp, em, satellite=satellite,$
                      photospheric=photospheric, date=date

;--------------------------- PREPARE THE DATA ----------------------------

 if keyword_set(satellite) then goes=fix(satellite) else goes=8
 ; convert long channel flux if needed - GOES 6 data before 28-Jun-83 (not '93 as in old version)
 datechk = anytim('28-jun-1983',/sec)
 if anytim(fcheck(date, datechk),/sec) lt datechk $
      and goes eq 6 then b8=fl_in*(4.43/5.32) else b8=fl_in

 ; Recent fluxes released to the public are scaled to be consistent
 ; with GOES-7: in fact recent fluxes are correct and so we need to
 ; remove this correction before proceeding to use transfer functions
 ; old version from Bornmann et al 1989 used until 2005 July in goes_tem
 ; if (goes lt 8) then scl89= fltarr(2)+1. else scl89 = [0.790, 0.920]
 ; new version from Rodney Viereck (NOAA), e-mail to SW, 2004 June 09
 if (goes lt 8) then scl89= fltarr(2)+1. else scl89 = [0.700, 0.850]
 b8 = b8 / scl89[0]
 ; don't change input arrays
 fs = fs_in / scl89[1]

 ; now calculate ratio where data are good
 index=where((fs lt 1.e-10) or (b8 lt 3.e-8))
 bratio=(fs>1.e-10)/(b8>3.e-8)
 if (index[0] ne -1) then bratio[index]=0.003

;--------------------------- EXACT FITS ----------------------------------

 if not keyword_set(photospheric) then photospheric=0

 ; hard work is done in these routines
 goes_get_chianti_temp,bratio,temp,sat=goes,photospheric=photospheric
 goes_get_chianti_em,b8,temp,em,sat=goes,photospheric=photospheric

 ; goes_get_chianti_em returns em in cm^-3, SOLARSOFT expects units of 10^49

 em=em/1.d49

 return

end
