;
; Overplot spectra spec with symbol psym, linestyle linestyle
; over existing plot.
;
; psym      : Symbol to plot data-points, can be array, contrary to
;             normal idl psym=0 won't draw a line, but will prevent
;             drawing of symbols
; linestyle : Linestyle of lines, can be array
; norm      : If a number: normalize max. to this number
;             If an array, then norm=[emin,emax,flux]; i.e. normalize
;               such that photon-flux in energy-range [emin,emax] is given by
;               flux.
; color     : Color of Plot
; offset    : Relative Offset of plots vs. Normal, can be array 
; label     : Label of each plot, can be array
; de        : if set, draw range of energy-bin (only if psym!=10)
; df        : if set, include flux-error (only if psym!=10)
;
pro ospecplot, spec,psym=symbol,linestyle=linst,norm=norm, $
               color=co,offset=ofs,label=lab, $
               de=de,df=df,fn=fn,nfn=nfn,nph=nph,factor=factor, $
               symsize=symsize,fluxtype=flt,mec2=mec2,mev=mev, $
               charsize=charsize

   common splcom, fluxtype, meme

;   on_error, 1

   ns = n_elements(spec)

   ;;
   ;; Type of flux to be plotted:
   ;; Either from keyword or from flt
   ;; WARNING: overrides common-block!
   ;;
   IF (n_elements(flt) NE 0) THEN BEGIN 
       IF ((flt GT 0) AND (flt LE 3)) THEN fluxtype = flt
   END ELSE BEGIN 
       IF (keyword_set(fn))  THEN fluxtype = 1
       IF (keyword_set(nfn)) THEN fluxtype = 2
       IF (keyword_set(nph)) THEN fluxtype = 3
   ENDELSE

   ;;
   ;; Display Energy in keV, mec^2, or in MeV
   ;;
   IF (keyword_set(mec2)) THEN meme=1
   IF (keyword_set(mev)) THEN meme=2
   IF (n_elements(meme) EQ 0) THEN meme=0

   if (ns eq 0) then return
   IF (n_elements(co) EQ 0) THEN co=!p.color
   IF (n_elements(xst) EQ 0) THEN xst=0
   IF (n_elements(yst) EQ 0) THEN yst=0
   IF (n_elements(symsize) EQ 0) THEN symsize=1.
   IF (n_elements(symbol) EQ 0) THEN symbol=10
   IF (n_elements(linst) EQ 0) THEN linst=0
   IF (n_elements(ofs) EQ 0) THEN ofs=1.
   IF (n_elements(fluxtype) EQ 0) THEN fluxtype=1 
   IF (n_elements(charsize) EQ 0) THEN charsize=1.

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
   ;; Convert spectra to correct type
   ;;
   FOR i=0,n_elements(spe)-1 DO BEGIN 
       tmp=spe(i)
       spec2type,tmp,fluxtype
       spe(i)=tmp
   ENDFOR 

   ;;
   ;; Normalize spectra such that their max. flux is given by norm
   ;;
   IF (n_elements(norm) EQ 1) THEN BEGIN 
       factor=fltarr(n_elements(spe))
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           tmp=spe(i)
           specinfo,tmp,fmi,fma
           spe(i).f=tmp.f*norm/fma
           factor(i)=norm/fma
       ENDFOR
   ENDIF 

   ;;
   ;; Normalize spectra such that the photon-flux in [norm(0),norm(1)] is
   ;; given by norm(2)
   ;;
   IF (n_elements(norm) EQ 3) THEN BEGIN 
       factor=fltarr(n_elements(spe))
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           tmp=spe(i)
           ttt=0.
           CASE meme OF
               0: specnorm,tmp,[norm(0),norm(1),norm(2)],/nph,factor=ttt
               1: specnorm,tmp,[511.*norm(0),511.*norm(1),norm(2)],/nph,factor=ttt
               2: specnorm,tmp,[norm(0)/1000.,norm(1)/1000.,norm(2)],/nph,factor=ttt
           END 
           spe(i)=tmp
           factor(i)=ttt
       ENDFOR 
   ENDIF 

   IF (n_elements(norm) EQ 0 AND n_elements(factor) NE 0) THEN BEGIN 
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           fac=factor(n_elements(factor)-1)
           IF (n_elements(factor) GT i) THEN fac=factor(i)
           spe(i).f(*)=fac*spe(i).f(*)
           spe(i).sat=fac*spe(i).sat
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
               IF (keyword_set(de)) THEN BEGIN
                   FOR jj=0, n_elements(valid)-1 DO BEGIN
                       oplot, [ener(valid(jj)),ener(valid(jj)+1)], $
                         [flux(valid(jj)),flux(valid(jj))]*offs,color=col
                   ENDFOR
               ENDIF
               ;;
               ;; Plot flux error if desired
               ;;
               IF (keyword_set(df)) THEN BEGIN
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
       IF (n_elements(lab) NE 0) THEN BEGIN
           IF (lab(sp).text NE "") THEN BEGIN
               ndx = where((ener LT lab(sp).ener) AND $
                           (shift(ener,-1) ge lab(sp).ener))
               IF (n_elements(ndx) GT 0) THEN BEGIN
                   ndx=ndx(0)
               END ELSE BEGIN
                   IF (ener(0) GT lab(sp).ener) THEN ndx=0
                   IF (ener(nel) LT lab(sp).ener) THEN ndx=nel
               ENDELSE
               IF (ndx EQ -1) THEN ndx=0

               txt = lab(sp).text
               IF (offs NE 1.) THEN txt = txt+" x 10!E"+ $ 
                 strtrim(string(alog10(offs),format='(G0.2)'),2)+"!N"
               xyouts, lab(sp).ener, flux(ndx)*offs, strtrim(txt,2), $
                 color=col,alignment=lab(sp).align, charsize=lab(sp).size
           ENDIF
       ENDIF
   ENDFOR
END

