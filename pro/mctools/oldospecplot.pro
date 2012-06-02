;
; Overplot spectra spec with symbol psym, linestyle linestyle
; over existing plot.
;
; psym      : Symbol to plot data-points, can be array, contrary to
;             normal idl psym=0 won't draw a line, but will prevent
;             drawing of symbols
; linestyle : Linestyle of lines, can be array
; normalized: 0: Do not normalize plot
;             1: Normalize to total maximum
;             2: Normalize to individual maximum
;             3: Normalize to normconst
;             2D-array: normalize to same flux in energy-bin given by
;                normalized=[emin,emax]. If normconst is set, the flux
;                is given by normconst, if not it is set to one
; color     : Color of Plot
; offset    : Relative Offset of plots vs. Normal, can be array 
; label     : Label of each plot, can be array
; normconst : Value of constant for normalization, returned if normalized != 0
;             and normconst set, used if set and normalized=3
; erange    : if set, draw range of energy-bin (only if psym!=10)
; frange    : if set, include flux-error (only if psym!=10)
;
pro oldospecplot, spec, psym=symbol, linestyle=linst, normalized=norm, $
               color=co,offset=ofs,label=lab, $
               normconst=normconst,erange=erange,frange=frange, $
               symsize=symsize

   common splcom, fluxtype, meme

   on_error, 1

   ns = n_elements(spec)

   IF (n_elements(meme) EQ 0) THEN meme=0

   if (ns eq 0) then return
   IF (n_elements(co) EQ 0) THEN co=!p.color
   IF (n_elements(xst) EQ 0) THEN xst=0
   IF (n_elements(yst) EQ 0) THEN yst=0
   IF (n_elements(norm) EQ 0) THEN norm=0
   IF (n_elements(symsize) EQ 0) THEN symsize=1.
   IF (n_elements(symbol) EQ 0) THEN symbol=10
   IF (n_elements(linst) EQ 0) THEN linst=0
   IF (n_elements(ofs) EQ 0) THEN ofs=1.
   IF (n_elements(fluxtype) EQ 0) THEN fluxtype=1 
   ;;
   ;; Normalize spectrum and convert to correct type
   ;;
   ma= -1E30
   mi=  1E30
   fmi=0.
   fma=0.
   ;;
   spe=spec
   ;;
   IF (n_elements(norm) EQ 1) THEN BEGIN 
       ;;
       ;; Normalize individually
       ;;
       FOR sp=0,ns-1 DO BEGIN
           tmp=spe(sp)
           spec2type,tmp,fluxtype
           specinfo, spe(sp), fmi, fma
           IF (fma GT ma) THEN ma=fma
           IF (fmi LT mi) THEN mi=fmi
           ;;
           ;; Normalize to maximum
           ;;
           IF (norm EQ 2) THEN BEGIN
               specnorm, tmp, fma
               saturate, tmp, fmi/fma
           ENDIF
           ;;
           ;; Normalize to normconst
           ;;
           IF (norm EQ 3) THEN BEGIN
               IF (normconst EQ 0.) THEN normconst = 1.
               specnorm, tmp, normconst
               saturate, tmp, fmi/normconst
           ENDIF
           ;;
           spe(sp)=tmp
       ENDFOR
       ;;
       ;; Normalize together and return normalizing constant
       ;;
       IF (norm EQ 1) THEN BEGIN
           minval = mi/ma
           FOR sp=0, ns-1 DO BEGIN
               tmp=spe(sp)
               specnorm, tmp, ma
               saturate, tmp, minval
               spe(sp)=tmp
           ENDFOR
           ;;
           ;; if wanted: return normconst
           ;;
           IF (n_elements(normconst) NE 0) THEN normconst=ma
       ENDIF 
       IF ((norm EQ 0) AND (n_elements(normconst) NE 0)) THEN BEGIN 
           normconst = 1.
       ENDIF 
   END 

   ;;
   ;; Normalize to same flux in bin
   ;;
   IF (n_elements(norm) EQ 2) THEN BEGIN 
       IF (n_elements(normconst) EQ 0) THEN BEGIN 
           normconst=1.
       END ELSE BEGIN 
           IF (normconst EQ 0) THEN normconst=1.
       END 
       FOR sp=0,ns-1 DO BEGIN 
           tmp=spe(sp)
           CASE meme OF 
               0: specnorm,tmp,[norm(0),norm(1),normconst]
               1: specnorm,tmp,[511.*norm(0),511.*norm(1),normconst]
               2: specnorm,tmp,[norm(0)/1000.,norm(1)/1000.,normconst]
               default: message, 'Error 1 in ospecplot'
           END
           spec2type,tmp,fluxtype
           spe(sp)=tmp
       ENDFOR 
   ENDIF 
   
   ;;
   ;; Loop over spectra and plot
   ;;    (excluding saturated bins)
   ;;
   for sp=0,ns-1 do BEGIN
       symb=symbol(n_elements(symbol)-1)
       IF (n_elements(symbol) GT sp) THEN symb=symbol(sp)
       lin = linst(n_elements(linst)-1)
       IF (n_elements(linst) GT sp) THEN lin = linst(sp)
       offs = ofs(n_elements(ofs)-1)
       IF (n_elements(ofs) GT sp) THEN offs = ofs(sp)
       col = co(n_elements(co)-1)
       IF (n_elements(co) GT sp) THEN col=co(sp)

       tmp = spe(sp)
       nel = tmp.len-1
       ener = tmp.e(0:nel+1)
       IF (meme EQ 1) THEN ener = ener/510.9990645047279
       IF (meme EQ 2) THEN ener = ener/1000.
       flux = tmp.f(0:nel)
       max_value = 1E30
       if (tmp.sat gt 0.) then max_value = tmp.sat
       IF (meme EQ 2) THEN BEGIN 
           flux=flux/1000.
           max_value=max_value/1000.
       ENDIF 

       min_value=0.
       ndx=where(flux GT 0.)
       IF (ndx(0) NE -1) THEN min_value = min(flux(ndx))

       IF (symb EQ 10) THEN BEGIN
           ;;
           ;; Line-Plot
           ;;
           oplot,ener,flux*offs,psym=symb,linestyle=lin,color=col, $
             min_value=min_value*offs,max_value=max_value*offs
       END ELSE BEGIN
           ;;
           ;; Symbol Plot
           ;;
           ;; geometrical mean gives "middle" of energy-bin in log e-space
           en2 = sqrt(ener(*)*shift(ener(*),-1))
           valid = where(flux LT max_value)
           IF (valid(0) NE -1) THEN BEGIN
               ;;
               ;; Plot symbols at valid points
               ;;
               IF (symb NE 0) THEN BEGIN 
                   oplot,en2(valid),flux(valid)*offs,psym=symb, $
                     symsize=symsize,color=col
               ENDIF 
               ;;
               ;; Plot energy-ranges if desired
               ;;
               IF (keyword_set(erange)) THEN BEGIN
                   FOR jj=0, n_elements(valid)-1 DO BEGIN
                       oplot, [ener(valid(jj)),ener(valid(jj)+1)], $
                         [flux(valid(jj)),flux(valid(jj))]*offs,color=col
                   ENDFOR
               ENDIF
               ;;
               ;; Plot flux error if desired
               ;;
               IF (keyword_set(frange)) THEN BEGIN
                   FOR jj=0, n_elements(valid)-1 DO BEGIN
                       te=convert_coord([ener(valid(jj)),ener(valid(jj)+1)],$
                         [flux(valid(jj)),flux(valid(jj))]*offs,/to_normal)
                       emean=(te(0,0)+te(0,1))/2.
                       emean=convert_coord([emean],[te(1,0)],/normal,/to_data)
                       emean=emean(0)
                       IF (tmp.err(valid(jj)) GE 0.) THEN BEGIN 
                           fl = ([-tmp.err(valid(jj)),+tmp.err(valid(jj))]+ $
                                 flux(valid(jj)))*offs
                           oplot, [emean,emean], fl,color=col
                       END ELSE BEGIN 
                           ;;
                           ;; Arrow for upper limit
                           ;;
                           ee1 = emean/1.05
                           ee2 = emean*1.05
                           ff1 = flux(valid(jj))*offs/1.5
                           ff2 = flux(valid(jj))*offs/2.
                           oplot, [emean,emean],[flux(valid(jj))*offs,ff2], $
                             color=col
                           oplot, [ee1,emean,ee2],[ff1,ff2,ff1],color=col
                       ENDELSE 
                   ENDFOR
               ENDIF 
           ENDIF
       END
       ;;
       ;; Plot label
       ;;
       if (n_elements(lab) ne 0) then begin
           if (lab(sp).text ne "") then begin
               ndx = where((ener lt lab(sp).ener) and $
                           (shift(ener,-1) ge lab(sp).ener))
               if (n_elements(ndx) gt 0) then begin
                   ndx=ndx(0)
               end else begin
                   if (ener(0) gt lab(sp).ener) then ndx=0
                   if (ener(nel) lt lab(sp).ener) then ndx=nel
               endelse
               if (ndx eq -1) then ndx=0

               txt = lab(sp).text
               if (offs ne 1.) then txt = txt+" x 10!E"+ $ 
                 strtrim(string(alog10(offs),format='(G0.2)'),2)+"!N"
               xyouts, lab(sp).ener, flux(ndx)*offs, strtrim(txt,2), $
                 color=col,alignment=lab(sp).align, charsize=lab(sp).size
           endif
       endif
   endfor
end

