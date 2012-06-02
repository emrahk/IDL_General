;
; Create frame for plotting spectra
; Spectrum gets plotted from emin to emax, and flux from fmin to fmax.
; if fluxtype is set, determines what is to be plotted:
;   1: f(nu)
;   2: nu f(nu)
;   3: Nph(nu)
;
; psym : Symbol with wich plots are done, can be array, 10 by default
;
pro specplot, sp, erange=erange,frange=frange,title=title, $
              nufnu=nfn,fnu=fn,loge=loge,logf=logf,nologf=nologf, $
              nologe=nologe,de=de,df=df, $
              fluxtype=flt,psym=symbol, $
              linestyle=linst,norm=norm,color=co,background=ba,$
              xstyle=xstyle,ystyle=ystyle,offset=ofs,label=lab, $
              xtitle=xtitle, ytitle=ytitle,  $
              nph=nph, symsize=symsize,factor=factor,$
              exact=exact,position=position, mec2=mec2, $
              mev=mev,charsize=charsize,noerase=noerase, $
              ytickformat=ytickformat

   common splcom,fluxtype,meme
   ;;
   ;; Type of flux to be plotted:
   ;; Either from keyword or from flt
   ;;
   if (n_elements(flt) ne 0) then begin
       IF ((flt GT 0) AND (flt LE 3)) THEN fluxtype = flt
   end else begin
       IF (keyword_set(fn))  THEN fluxtype = 1
       IF (keyword_set(nfn)) THEN fluxtype = 2
       IF (keyword_set(nph)) THEN fluxtype = 3
   ENDELSE

   IF (n_elements(fluxtype) EQ 0) THEN fluxtype=3
   IF (n_elements(charsize) EQ 0) THEN charsize=1.
   IF (n_elements(noerase) EQ 0) THEN noerase=0

   IF (n_elements(ytickformat) EQ 0) THEN ytickformat='' 

   ;;
   ;; Save sp and convert to correct type
   ;;
   IF (n_elements(sp) GT 0) THEN BEGIN 
       spe=sp
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           tmp=spe(i)
           spec2type,tmp,fluxtype
           spe(i)=tmp
       ENDFOR 
   ENDIF 

   ;;
   ;; Display Energy in keV, mec^2, or in MeV
   ;;
   meme=0
   IF (keyword_set(mec2)) THEN meme=1
   IF (keyword_set(mev)) THEN meme=2

   ;;
   ;; Energy-range
   ;;
   IF (n_elements(erange) EQ 2) THEN BEGIN 
       emin=min(erange)
       emax=max(erange)
       IF (n_elements(xstyle) EQ 0) THEN xstyle=1
   END ELSE BEGIN 
       emin=1E30
       emax=-1E30
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           ff=spe(i).f(0:spe(i).len-1)
           valid=where(ff GT 0.)
           IF (valid(0) NE -1) THEN BEGIN 
               emin=min([emin,min(spe(i).e(valid))])
               emax=max([emax,max(spe(i).e(valid))])
           ENDIF 
       END 
       IF (meme EQ 1) THEN BEGIN 
           emin=emin/511.
           emax=emax/511.
       ENDIF 
       IF (meme EQ 2) THEN BEGIN 
           emin=emin/1000.
           emax=emax/1000.
       ENDIF 
   END 

   ;;
   ;; Flux range
   ;;
   IF (n_elements(frange) EQ 2) THEN BEGIN 
       fmin=min(frange)
       fmax=max(frange)
       IF (n_elements(ystyle) EQ 0) THEN ystyle=1
   END ELSE BEGIN 
       fmin=1E30
       fmax=-1E30
       FOR i=0,n_elements(spe)-1 DO BEGIN 
           ff=spe(i).f(0:spe(i).len-1)
           ee=spe(i).e(0:spe(i).len-1)
           IF (meme EQ 1) THEN ee=ee/511.
           IF (meme EQ 2) THEN ee=ee/1000.
           valid=where((ff GT 0.) AND (ee GE emin) AND (ee LE emax))
           IF (valid(0) NE -1) THEN BEGIN 
               fmin=min([fmin,min(spe(i).f(valid))])
               fmax=max([fmax,max(spe(i).f(valid))])
           ENDIF 
       ENDFOR 
   END 

   ;;
   ;; x-axis title
   ;;
   IF (n_elements(xtitle) EQ 0) THEN BEGIN
       CASE meme OF
           0: xtitle = textoidl('E!D !N[keV]')
           1: xtitle = textoidl('E!D !N[m_ec^2]')
           2: xtitle = textoidl('E!D !N[MeV]')
           default: message, 'Error 1 in specplot'
       END 
   END

   ;;
   ;; y-axis title (LEAVE blanks in exponents!!!)
   ;;
   IF (n_elements(ytitle) EQ 0) THEN BEGIN 
       IF (meme NE 2) THEN BEGIN 
           CASE fluxtype OF
               1: ytitle =textoidl('E N(E)!D !N[keV cm^{-2 }s^{-1 }keV^{-1 }]')
               2: ytitle =textoidl('E^2 N(E)!D !N[keV^{2}cm^{-2 }s^{-1 }keV^{-1 }]')
               3: ytitle =textoidl('N(E)!D !N[photons cm^{-2 }s^{-1 }keV^{-1 }]')
               default: message, 'Error 2a in specplot'
           END 
       END ELSE BEGIN 
           CASE fluxtype OF
               1: ytitle =textoidl('E N(E)!D !N[MeV cm^{-2 }s^{-1 }MeV^{-1 }]')
               2: ytitle =textoidl('E^2 N(E)!D !N[MeV^{2}cm^{-2 }s^{-1 }MeV^{-1 }]')
               3: ytitle =textoidl('N(E)!D !N[photons cm^{-2 }s^{-1 }MeV^{-1 }]')
               default: message, 'Error 2b in specplot'
           END
       END
   END 

   ;;
   ;; Set parameters to their default values if not given
   ;;
   IF (n_elements(co) EQ 0) THEN co=!p.color
   IF (n_elements(ba) EQ 0) THEN ba=!p.background
   IF (n_elements(xstyle) EQ 0) THEN xstyle=0
   IF (n_elements(ystyle) EQ 0) THEN ystyle=0

   IF (n_elements(title) EQ 0) THEN title = ' '
   
   ;; axes  
   xlog=1
   IF (emax/emin LT 10.) THEN xlog=0 ;; no log. e-axis if less then a decade
   ;;
   IF (keyword_set(loge)) THEN xlog=1
   IF (keyword_set(nologe)) THEN xlog=0
   

   ylog=1
   IF (fmax/fmin LT 10.) THEN ylog=0 ;; no log. f-axis if less then a decade
   IF (keyword_set(logf)) THEN ylog=1
   IF (keyword_set(nologf)) THEN ylog=0

   ;;
   ;; Frame for plot
   ;;
   IF (n_elements(position) EQ 0) THEN BEGIN 
       plot, [emin,emax], [fmin, fmax], title=strtrim(title,2), $
         xtitle=xtitle,ytitle=ytitle,color=co(0),background=ba,/nodata, $
         xstyle=xstyle,ystyle=ystyle,xlog=xlog,ylog=ylog,charsize=charsize, $
         noerase=noerase,ytickformat=ytickformat
   END ELSE BEGIN 
       plot, [emin,emax], [fmin, fmax], title=strtrim(title,2), $
         xtitle=xtitle,ytitle=ytitle,color=co(0),background=ba,/nodata, $
         xstyle=xstyle,ystyle=ystyle,position=position,xlog=xlog,ylog=ylog, $
         charsize=charsize,noerase=noerase,ytickformat=ytickformat
   END
   
   ;;
   ;; Plot spectra if necessary
   ;;
   if (n_elements(spe) ne 0) then BEGIN 
       ospecplot, spe, psym=symbol, $
         linestyle=linst,norm=norm,color=co, $
         offset=ofs,label=lab,de=de, $
         df=df,symsize=symsize,factor=factor, $
         charsize=charsize
   ENDIF 
END 
