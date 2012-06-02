;
; Normalize Spectrum sp. to...
;    ... maximum flux of flux
;    ... maximum flux of 1 in energy-range flux(0),flux(1)
;    ... maximum flux of flux(2) in energy-range flux(0),flux(1)
; if nph is set: normalize to photon-flux
pro specnorm, spec, flux,nph=nph,factor=factor
;   on_error, 1
   IF (n_elements(flux) eq 1) THEN BEGIN 
       fma=flux(0)
       IF (fma EQ 0.) THEN return
       IF (spec.sat GE 0.) THEN spec.sat = spec.sat/fma
       spec.f(*) = spec.f(*)/fma
       factor=1./fma
       return
   ENDIF 
   IF (n_elements(flux) GT 1) THEN BEGIN 
       emin=flux(0)
       emax=flux(1)
       res=1.
       IF (n_elements(flux) EQ 3) THEN res=flux(2)
       IF (keyword_set(nph)) THEN BEGIN 
           spec2nph,spec
       END ELSE BEGIN 
           spec2fnu,spec
       END
       flu=specflux(spec,emin,emax)
       IF (flu NE 0) THEN BEGIN 
           spec.f(*)=spec.f(*)*res/flu
           factor=res/flu
           IF (spec.sat GE 0.) THEN spec.sat=spec.sat*res/flu
       END
       return
   ENDIF
   message, 'Wrong Parameters!'
end
