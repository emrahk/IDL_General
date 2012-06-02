;
; Specflux.pro: Return photon-flux (ph/cm2 s keV) at energy E
;   of spectrum spec or in range e,e2
;
FUNCTION specflux,spec1,e,e2
;   on_error, 1
   ;;
   IF (n_elements(e2) EQ 0) THEN BEGIN 
       IF (e LT spec.e(0)) THEN return, 0.
       IF (e GE spec.e(spec.len)) THEN return, 0.
       ;;
       ;; Search for energy
       ;;
       i = min(where(spec.e GT e))-1
       ;;
       ;; Convert this energy bin to photon flux
       ;; and return
       ;;
       IF (spec.flux EQ 3) THEN return, spec.f(i)
       IF (spec.flux EQ 0) THEN return, spec.f(i)/(spec.e(i+1)-spec.e(i))
       IF (spec.flux EQ 1) THEN return, spec.f(i)/spec.e(i)
       IF (spec.flux EQ 2) THEN return, spec.f(i)/(spec.e(i)^2)
   END 
   ;;
   ;; Compute flux from e to e2 (not exactly, don't deal with
   ;; half energy-bins [yet])
   ;;
   ;;
   ;; Find low and high energy bins
   ;;
   spec=spec1
   spec2nph,spec
   emin=e
   emax=e2
   if ( (spec.e(spec.len-1) le emin) or (spec.e(0) gt emax)) then begin
       printf, 'Energy range not part of spectrum'
       return,0.
   endif
   imin=1
   imax=1
   while (spec.e(imin) lt emin) do imin=imin+1
   while (emax gt spec.e(imax) AND imax LT spec.len) do imax=imax+1
   emin=spec.e(imin)
   emax=spec.e(imax)
   ;;
   ;; Add Continuum to get flux
   ;;
   val=spec.f(imin:imax)
   IF (spec.sat GT 0.) THEN BEGIN 
       nd=where(val GT spec.sat)
       IF (nd(0) NE -1) THEN val(nd)=0.
   ENDIF
   val=val*(spec.e(imin+1:imax+1)-spec.e(imin:imax))
   return, total(val)
END 
