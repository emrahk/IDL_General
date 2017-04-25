FUNCTION darklimb_r,ll,bandpass,func

;----------------------------------------------------------------------------
;NAME:
;	darklimb_r
;PURPOSE:
;	Returns the constants, u or v, for a given central wavelength and  
;	wavelength range (bandpass) for input into the limb darkening function  
;	(see LIMBDARK_COR and LIMBDARK_PLOT)
;CALLING SEQUENCE:
;	u = darklimb_r(lambda,bandpass,'darklimb_u')
;	v = darklimb_r(lambda,bandpass,'darklimb_v')
;INPUT:
;	ll - central wavelength of interest in Angstroms
;	bandpass - wavelength range required, centred on ll
;	func - string specifying the function which returns the appropriate constant
;OPTIONAL INPUT:
;OUTPUT:
;	required constant in Allen's limb darkening expression
;OPTIONAL OUTPUT:
;RESTRICTIONS:
;	Only applies to wavelengths in the range 4000<lambda<15000
;HISTORY:
;	14-oct-96 - D. Alexander, written
;        5-feb-97 - S.L.Freeland - names/SSW compatibility
;----------------------------------------------------------------------------

ll=1.*ll  ; make sure wavelength is floating point

; set up limits for integral

   llmax = ll + bandpass/2.
   llmin = ll - bandpass/2.


; do spectral averaging over bandpass

   ul = qsimp(func,llmin,llmax)/bandpass

return,ul

end


