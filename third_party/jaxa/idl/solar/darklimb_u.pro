FUNCTION darklimb_u,ll

;----------------------------------------------------------------------------

;NAME:
;	darklimb_u
;PURPOSE:
;	Returns the constant, u, for a given wavelength for input into the limb 
;	darkening function (see LIMBDARK_COR and LIMBDARK_PLOT)
;CALLING SEQUENCE:
;	u = darklimb_u(lambda)
;INPUT:
;	ll - wavelength of interest in Angstroms
;OPTIONAL INPUT:
;OUTPUT:
;	constant, u, in Allen's limb darkening expression
;OPTIONAL OUTPUT:
;RESTRICTIONS:
;	Only applies to wavelengths in the range 4000<lambda<15000
;HISTORY:
;	14-oct-96 - D. Alexander, written
;        5-feb-97 - S.L.Freeland - names - SSW Compatibility 
;----------------------------------------------------------------------------

ll=1.*ll  ; make sure wavelength is floating point

pll=[1.,ll,ll^2,ll^3,ll^4,ll^5] ; set up 5th order polynomial

; coefficients for 5th order poly fit to limb darkening
; constant u.  Fit was done on data from Astrophysical
; Quantities by Allen.

au = -8.9829751
bu = 0.0069093916
cu = -1.8144591e-6
du = 2.2540875e-10
eu = -1.3389747e-14
fu = 3.0453572e-19
a=[au,bu,cu,du,eu,fu]
 
ul = total(a*pll)

return,ul
end

