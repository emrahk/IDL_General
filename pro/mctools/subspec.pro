;
; Create the difference of two spectra, the energy-binning and type
; are that of the first spectrum
;
FUNCTION subspec, sp1, spe2
;  sp2 = spe2
;  tmp = where(sp1.e NE sp2.e)
;  IF (tmp(0) ne -1) THEN BEGIN 
      sp2 = rebinspec(spe2, sp1)
;  ENDIF 
  IF (sp2.flux NE sp1.flux) THEN spec2type, sp2, sp1.flux
  sum = replicate(sp1,1)
  sum.f(*) = sp1.f(*)-sp2.f(*)
  sum.sat = -1.
  ;;
  ;; Check for saturated values in both spectra, set to 0
  ;;
  IF (sp1.sat GT 0.) THEN BEGIN
      tmp = where(sp1.f GT sp1.sat)
      IF (tmp(0) NE -1) THEN sum.f(tmp)=sp2.f(tmp)
  ENDIF 
  IF (sp2.sat GT 0.) THEN BEGIN
      tmp = where(sp2.f GT sp2.sat)
      IF (tmp(0) NE -1) THEN sum.f(tmp)=sp1.f(tmp)
  ENDIF
  ;;
  ;; Case of both spectra being saturated: saturate resulting
  ;; spectrum
  ;;
  IF ((sp2.sat GT 0.) AND (sp1.sat GT 0.)) THEN BEGIN
      tmp = where((sp1.f GT sp1.sat) AND (sp2.f GT sp2.sat))
      sum.sat = max(sum.f)*100.
      IF (tmp(0) NE -1) THEN sum.f(tmp)=sum.sat
  ENDIF 

  sum.desc = '('+sp1.desc + ')+(' + sp2.desc + ')'

  return, sum
END 
