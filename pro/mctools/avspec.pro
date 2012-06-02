;
; avspec.pro: Average spectra in spec, return spectrum
;    Average is done from emin to emax on grid of size npts
;
FUNCTION avspec, spec, emin, emax, npts
   on_error, 1
   ;;
   avspec = replicate({spectrum},1)
   avspec.flux = 3
   avspec.len = npts
   avspec.sat = -1.
   ;;
   ;; Energy array in kev
   avspec.e = 10.^(alog10(emin)+(indgen(npts+1)/float(npts))* $
                   (alog10(emax/emin)))
   ;;
   ;;
   num = n_elements(spec)-1
   IF (num EQ -1) THEN return, avspec
   ;;
   ;; Now average the spectra
   ;;
   FOR i=0,avspec.len-1 DO BEGIN 
       anz=0
       fl = 0.
       FOR j=0,num DO BEGIN
           ff = specflux(spec(j),avspec.e(i))
           IF (ff NE 0.) THEN BEGIN
               anz = anz+1
               fl = fl+ff
           ENDIF
       ENDFOR 
       avspec.f(i)=0.
       IF (anz NE 0) THEN avspec.f(i)=fl/anz
   ENDFOR
   ;;
   return, avspec
END 
