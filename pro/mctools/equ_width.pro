;
; Compute equivalent width of a line using the continuum defined as a
; straight line from emin and emax.
;
; emin: min. energy (approximate)
; emax: max. energy (approximate)
;
; The correct values used for emin, emax get returned in these variables.
; The width is returned in eV!
;
pro equ_width, spe, emin, emax, width, title=title, plot=plot,cont=cont, $
               fmin=fmin, fmax=fmax, verbose=verbose
;   on_error, 1
   ;;
   ;; Convert to flux
   ;;
   sp=spe
   spec2fnu, sp
   ;;
   ;; Find low and high energy bins
   ;;
   if ( (sp.e(sp.len-1) le emin) or (sp.e(0) gt emax)) then begin
       printf, 'Energy range not part of spectrum'
       width=0.
       return
   endif
   imin=1
   imax=1
   while (sp.e(imin) lt emin) do imin=imin+1
   while (emax gt sp.e(imax)) do imax=imax+1
   emin=sp.e(imin)
   emax=sp.e(imax)
   ;;
   ;; Define Continuum; if undefinable or zero: return 0.
   ;;
   IF (n_elements(cont) EQ 0) THEN BEGIN 
       f1 = sp.f(imin)
       f2 = sp.f(imax)
       df = (f2-f1)/(emax-emin)
       width=0.
       IF (sp.sat GT 0) THEN BEGIN
           IF ((f1 GE sp.sat) OR (f2 GE sp.sat)) THEN return
       ENDIF
       IF ((df EQ 0.) AND (f1 EQ 0.)) THEN return
       ;;
       ;; Now integrate over spectrum
       ;;
       FOR i=imin, imax DO BEGIN
           fl = f1 + df*(sp.e(i)-emin)
           val = sp.f(i)
           IF ((sp.sat GT 0) AND (val GT sp.sat)) THEN BEGIN
               val=0. 
           END 
           width= width + (val-fl)/fl * (sp.e(i+1)-sp.e(i))
       ENDFOR
   END ELSE BEGIN 
       ;; should take care of saturation here (but don't yet)...
       IF (n_elements(cont) EQ 1) THEN BEGIN 
           fl=alog10([sp.f(imin:imin+cont),sp.f(imax-cont:imax)])
           en=alog10([sp.e(imin:imin+cont),sp.e(imax-cont:imax)])
       END ELSE BEGIN 
           fl=alog10([sp.f(imin:imin+cont(0)),sp.f(imax-cont(1):imax)])
           en=alog10([sp.e(imin:imin+cont(0)),sp.e(imax-cont(1):imax)])
       END 
       ;; now flux(e) = 10^b  * energy^a
       linreg, en, fl, a, b
       f0 = 10.^b
       IF (keyword_set(verbose)) THEN BEGIN
           print, 'continuum is ', strtrim(f0,2), '* E^', strtrim(a,2)
       ENDIF 
       ;;
       ;; Now integrate over spectrum
       ;;
       width=0.
       FOR i=imin, imax DO BEGIN
           fl = f0 * sp.e(i)^a
           val = sp.f(i)
           IF ((sp.sat GT 0) AND (val GT sp.sat)) THEN val=0. 
           width= width + (val-fl)/fl * (sp.e(i+1)-sp.e(i))
       ENDFOR
   END
   width=width*1000.
   IF keyword_set(verbose) THEN print, 'EW = ', strtrim(width,2), ' eV'
   ;;
   ;; Plot spectrum and energy range
   ;;
   IF (keyword_set(plot) NE 0) THEN BEGIN 
       spec2fnu,sp
       IF (n_elements(title) NE 0) THEN BEGIN 
           atitle = title
       END ELSE BEGIN 
           atitle = sp.desc
       ENDELSE 
       IF (n_elements(fmin) EQ 0) THEN fmin=0.7*min(sp.f(imin:imax))
       IF (n_elements(fmax) EQ 0) THEN fmax=1.5*max(sp.f(imin:imax))
       noco=0.
       specplot, emin*0.95, emax*1.05, fmin, fmax, sp, title=atitle, $
         normalized=0, normconst=noco, yst=1,/fnu
       IF (n_elements(cont) EQ 0) THEN BEGIN 
           ee = fltarr(2*(imax-imin+1)+1) & ff = fltarr(2*(imax-imin+1)+1)
           j=0
           FOR i=imin-1,imax-1 DO BEGIN
               ee(j)   = (sp.e(i)+sp.e(i+1))/2 & ff(j)   = sp.f(i)
               ee(j+1) = ee(j) &                 ff(j+1) = sp.f(i+1)
               j=j+2
           ENDFOR
           ee(j)=ee(0) & ff(j)=ff(0)
           ff = ff/noco
           polyfill, ee,ff,/line_fill,orientation= 45
           polyfill, ee,ff,/line_fill,orientation=-45
           oplot, ee,ff,linestyle=2
       END ELSE BEGIN 
           ee = fltarr(3*(imax-imin+1)+1) & ff = fltarr(3*(imax-imin+1)+1)
           j=0
           FOR i=imin-1,imax-1 DO BEGIN
               ee(j)   = (sp.e(i)+sp.e(i+1))/2 & ff(j)   = sp.f(i)
               ee(j+1) = ee(j) &                 ff(j+1) = sp.f(i+1)
               j=j+2
           ENDFOR
           FOR i=imax-1,imin-1,-1 DO BEGIN 
               ee(j)=(sp.e(i)+sp.e(i+1))/2.
               ff(j)=f0 *ee(j)^a
               j=j+1
           ENDFOR
           ee(j)=ee(0) & ff(j)=ff(0)
           ff = ff/noco
           polyfill, ee,ff,/line_fill,orientation= 45
           polyfill, ee,ff,/line_fill,orientation=-45
           oplot, ee,ff,linestyle=2
           IF (n_elements(cont) EQ 1) THEN BEGIN 
               oplot, sp.e(imin:imin+cont),sp.f(imin:imin+cont)/noco,color=200
               oplot, sp.e(imax-cont:imax),sp.f(imax-cont:imax)/noco,color=200
           END ELSE BEGIN 
               oplot, sp.e(imin:imin+cont(0)),sp.f(imin:imin+cont(0))/noco, $
                 color=200,psym=10
               oplot, sp.e(imax-cont(1):imax),sp.f(imax-cont(1):imax)/noco, $
                 color=200,psym=10
           END 
       END 
   ENDIF 
END 
