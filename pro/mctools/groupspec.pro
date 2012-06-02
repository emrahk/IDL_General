;
; Rebin Spectrum sp1 by adding n bins together
; if e is also set, this is only done for energies lower than
; 
; if e and n are arrays, then:
;   0--e(0)    group with n(0)
;   e(0)--e(1) group with n(1)
; etc.
; it is assumed that e is sorted.
FUNCTION groupspec, sp, n, e
   on_error, 1

   sp1 = sp
   spec2fnu, sp1
   ;;
   numstp=n_elements(n)
   numen=n_elements(e)
   IF (numen EQ 0) THEN BEGIN 
       e=sp.e(sp.len)
       numen=1
   ENDIF
   IF (numstp GT numen+1) THEN numstp=numen+1
   ;;
   reb = sp1
   reb.f(*) = 0.
   reb.e(*) = 0.
   reb.err(*)=0.
   reb.sat = sp1.sat
   IF (numstp EQ 1) THEN BEGIN 
       reb.desc= sp.desc + ' rebinned by factor '+string(n)
   END ELSE BEGIN 
       reb.desc=sp.desc + 'rebinned: '
       FOR k=0,numstp-1 DO BEGIN 
           IF (k GE numen) THEN BEGIN
               ee=sp1.e(sp1.len)
           END ELSE BEGIN 
               ee=e(k)
           END 
           reb.desc=reb.desc+'('+string(k)+','+string(ee)+') '
       ENDFOR 
   END
   ;;
   ;; The rebinning step
   ;;
   j=0
   i=0
   FOR k=0, numstp-1 DO BEGIN 
       IF (k GE numen) THEN BEGIN
           ee=sp1.e(sp1.len)
       END ELSE BEGIN 
           ee=e(k)
       END 
       WHILE ((i LT sp1.len) AND (sp1.e(i) LT ee)) DO BEGIN
           reb.e(j)=sp1.e(i)
           ;; 
           ;; Average flux
           ;;
           num=0
           fl = 0.
           FOR ll=1,n(k) DO BEGIN
               IF ((sp1.sat LE 0.) OR (sp1.f(i) LT sp1.sat)) THEN BEGIN
                   IF (i LT sp1.len) THEN BEGIN 
                       num=num+1
                       fl=fl+sp1.f(i)
                   ENDIF 
               ENDIF
               i=i+1
           ENDFOR
           IF (num GT 0) THEN BEGIN
               reb.f(j)=fl/num
           END ELSE BEGIN 
               reb.f(j)=0.
               IF (reb.sat GT 0) THEN reb.f(j)=reb.sat
           END
           j=j+1
       ENDWHILE 
       reb.e(j+1)=sp.e(i)
   ENDFOR  
   reb.len=j
   ;;
   ;; Change spectrum back to initial type
   ;;
   spec2type, reb, sp.flux
   return, reb
END 
