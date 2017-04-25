
FUNCTION darklimb_v,ll

;----------------------------------------------------------------------------

;NAME:
;	darklimb_v
;PURPOSE:
;	Returns the constant, v, for a given wavelength for input into the limb 
;	darkening function (see LIMBDARK_COR and LIMBDARK_PLOT)
;CALLING SEQUENCE:
;	v = darklimb_v(lambda)
;INPUT:
;	ll - wavelength of interest in Angstroms
;OPTIONAL INPUT:
;OUTPUT:
;	constant, v, in Allen's limb darkening expression
;OPTIONAL OUTPUT:
;RESTRICTIONS:
;	Only applies to wavelengths in the range 4000<lambda<15000
;HISTORY:
;	14-oct-96 - D. Alexander, written
;        5-feb-97 - S.L.Freeland - names, SSW compatibility
;----------------------------------------------------------------------------

ll=1.*ll  ; make sure wavelength is floating point

pll=[1.,ll,ll^2,ll^3,ll^4,ll^5] ; set up 5th order polynomial

; coefficients for 5th order poly fit to limb darkening
; constant u.  Fit was done on data from Astrophysical
; Quantities by Allan.

; coefficients for 5th order poly fit to limb darkening
; constant v.  Fit was done on data from Astrophysical
; Quantities by Allen.

av = 9.2891180
bv = -0.0062212632
cv = 1.5788029e-6
dv = -1.9359644e-10
ev = 1.1444469e-14
fv = -2.599494e-19

a=[av,bv,cv,dv,ev,fv]

vl = total(a*pll)

return,vl
end
