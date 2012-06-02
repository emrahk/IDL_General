;
; Return photon-number of spectrum sp in interval [emin,emax],
; not fast enough for rebinning, but can use it nevertheless
;
FUNCTION photflux, spe, emin, emax
   on_error, 1
   fl = 0.
   ;;
   ;; Return 0 if emin>=emax
   ;;
   IF (emin GE emax) THEN BEGIN
       IF (emin EQ emax) THEN return, fl
       print, 'Warning: photflux: emin > emax'
       print, '    returning 0'
       print, '    emin: ',emin
       print, '    emax: ',emax
       return, fl
   ENDIF
   ;;
   ;; Return 0 if [emin,emax] not within interval
   ;;
   IF NOT ((spe.e(0) LT emin) AND (spe.e(spe.len-2) GT emax)) THEN return,fl
;   IF (spe.e(0) GT emax) THEN return, fl
;   IF (spe.e(spe.len-2) LE emin) THEN return, fl
;   IF (spe.e(0) GT emin) THEN return, fl
;   IF (spe.e(spe.len-2) LE emax) THEN return, fl

   sp = spe
   IF (sp.flux NE 0) THEN spec2phot, sp
   ;;
   ;; Search for lowest index
   ;;
   imin=min(where(sp.e GT emin))-1
   imax=min(where(sp.e GT emax))-1
   ;;
   ;; Deal with case of spectrum lying in one bin in its entirety
   ;;
   IF (imin EQ imax) THEN BEGIN
       fl = sp.f(imin)*(emax-emin)/(sp.e(imin+1)-sp.e(imin))
       return, fl
   ENDIF 
   ;;
   ;; Now integrate over inner parts of spectrum
   ;;
   FOR i=imin+1, imax-1 DO BEGIN
       val = sp.f(i)
       IF ((sp.sat GT 0) AND (val GT sp.sat)) THEN val=0. 
       fl= fl + val
   ENDFOR
   ;;
   ;; Deal with edges of interval
   ;;
   fl = fl+sp.f(imin)*(sp.e(imin+1)-emin)/(sp.e(imin+1)-sp.e(imin))
   fl = fl+sp.f(imax)*(emax-sp.e(imax))/(sp.e(imax+1)-sp.e(imax))
   ;;
   return, fl
END 
