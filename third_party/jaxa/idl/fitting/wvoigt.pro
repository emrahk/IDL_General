function wvoigt,wave,wave0,TDOPPW,ROCKW
;+
; NAME:
;   WVOIGT
; PURPOSE:
;   Call the IDL Voigt routine to calculate a Voigt Profile.
;   The input parameters are in terms of FWHM.
; CALLING SEQUENCE:
;   Profile = wvoigt(wave,wave0,TDOPPW,ROCKW)
; INPUTS:
;   wave   =  Vector of wavelengths at which the profile is to be calculated
;   wave0  =  The central wavelength of the profile
;   TDOPPW = Total Gaussian Doppler broadening (FWHM) -- must be a scalar
;   ROCKW  = Lorenztian Rocking Curve (FWHM)          -- must be a scalar
; RETURNED:
;   The normalized Voigt profile is returned
; OPTIONAL INPUT KEYWORDS:
; HISTORY:
;   6-oct-93, J. R. Lemen (LPARL), Written.
; -

;if n_params() le 4 then message,'Profile = wvoigt(wave,wave0,TDOPPW,ROCKW)'

nspec = n_elements(wave0)
nwave = n_elements(wave)
out = fltarr(nwave,nspec)
sq2 = 2.*sqrt(alog(2.))

xnorm = float(sq2 / TDOPPW / sqrt(!pi))		; Normalization factor
YY    = float(sq2 / 2. * ROCKW / TDOPPW)
qq = float(sq2/TDOPPW)

; wvl = the wavelength difference vector:

wvl = transpose(rebin([wave0],nspec,nwave,/sample)) - rebin([wave],nwave,nspec,/sample)
XX  = abs(qq*wvl)				; * (wave0(i)/(wave0(i)+wvl)))
ii = where(XX lt 9.)				; Only calculate for when XX < 9.

; This code assumes the Voigt function is symmetric in Wavelength space
; The Voigt function is computed for 180 values equally spaced between XX = 0 and xx = 9
; Then the resulting arrays (xxx and zz) are linearly interpolated.
; This approach was used to speed up the program by about a factor of 3.

if ii(0) ne -1 then begin			; Were there any wavelengths in range?
   XX = XX(ii) 					; Only compute for cases were XX < 9

   xxx = findgen(180)*.05			; Calculate for 180 values of XX
   zz = voigt(YY,xxx)
   out(ii) = interpolate(zz,XX*20.) * xnorm
endif

return,reform(out)
end
