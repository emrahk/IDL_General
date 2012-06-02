;
; Create frame for plotting spectra
; Spectrum gets plotted from emin to emax, and flux from fmin to fmax.
; if fluxtype is set, determines what is to be plotted:
;   1: f(nu)
;   2: nu f(nu)
;   3: Nph(nu)
;
; psym : Symbol with wich plots are done, can be array, 10 by default
; normalized: if 1: normalize together (default), 2: normalize indiv.
;
pro oldspecplot, eemin,eemax,ffmin,ffmax,ssp,title=title,nufnu=nfn,fnu=fn, $
              loglog=lolo,lognor=lono,fluxtype=flt,psym=symbol, $
              linestyle=linst,normalized=norm,color=co,background=ba,$
              xstyle=xst,ystyle=yst,offset=ofs,label=lab, $
              normconst=normconst, xtitle=xtitl, ytitle=ytitl,  $
              erange=erange, frange=frange, nph=nph, symsize=symsize,$
              nologf=nologf,exact=exact,position=position, mec2=mec2, $
              mev=mev

   common splcom,fluxtype,meme

;   on_error, 1

   ;;
   ;; Allow for different calling-sequences
   ;;

   ;; specplot,[emin,emax],[fmin,fmax],sp
   IF ((n_elements(eemin) EQ 2) AND (n_elements(eemax) EQ 2)) THEN BEGIN 
       emin=eemin(0)
       emax=eemin(1)
       fmin=eemax(0)
       fmax=eemax(1)
       IF (n_elements(ffmin) NE 0) THEN sp=ffmin
   ENDIF 

   ;; specplot,[emin,emax],sp
   IF ((n_elements(eemin) EQ 2) AND (n_elements(eemax) EQ 1)) THEN BEGIN 
       emin=eemin(0)
       emax=eemin(1)
       sp=eemax
       ftmp=sp(*).f
       fmax=max(ftmp)
       ndx=where(ftmp GT 0)
       fmin=min(ftmp(ndx))
   ENDIF 

   ;; specplot,emin,emax,fmin,fmax,sp
   IF (n_elements(ffmax) NE 0) THEN BEGIN 
       emin=eemin
       emax=eemax
       fmin=ffmin
       fmax=ffmax
       IF (n_elements(ssp) GT 0) THEN sp=ssp
   ENDIF 

   IF (n_elements(emin) EQ 0) THEN BEGIN 
       message,'Calling sequence: specplot,[emin,emax],[fmin,fmax],sp'
   END

   tp=2
   if (n_elements(flt) ne 0) then begin
       IF ((flt GT 0) AND (flt LE 3)) THEN tp = flt
   end else begin
       if (keyword_set(fn))  then tp = 1
       if (keyword_set(nfn)) then tp = 2
       IF (keyword_set(nph)) THEN tp = 3
   ENDELSE

   meme=0
   IF (keyword_set(mec2)) THEN meme=1
   IF (keyword_set(mev)) THEN meme=2

   ;;
   ;; Decide on x-axis title
   ;;
   IF (n_elements(xtitl) EQ 0) THEN BEGIN
       CASE meme OF
           0: xtit = 'E!D !N[keV]'
           1: xtit = 'E!D !N[m!Ie!Nc!U2!N]'
           2: xtit = 'E!D !N[MeV]'
           default: message, 'Error 1 in specplot'
       END 
   END ELSE BEGIN 
       xtit = xtitl
   END 

   ;;
   ;; Decide on y-axis title
   ;;
   IF (n_elements(ytitl) EQ 0) THEN BEGIN 
       IF (meme NE 2) THEN BEGIN 
           CASE tp OF 
               1: ytit ='E N(E)!D !N[keV cm!U-2!N s!U-1!N keV!U-1!N]'
               2: ytit ='E!U2!N N(E)!D !N[keV!U2!N cm!U-2!N s!U-1!N keV!U-1!N]'
               3: ytit ='N(E)!D !N[photons cm!U-2!N s!U-1!N keV!U-1!N]'
               default: message, 'Error 2a in specplot'
           END 
       END ELSE BEGIN 
           CASE tp OF 
               1: ytit ='E N(E)!D !N[keV cm!U-2!N s!U-1!N MeV!U-1!N]'
               2: ytit ='E!U2!N N(E)!D !N[MeV!U2!N cm!U-2!N s!U-1!N MeV!U-1!N]'
               3: ytit ='N(E)!D !N[photons cm!U-2!N s!U-1!N MeV!U-1!N]'
               default: message, 'Error 2b in specplot'
           END 
       END            
   END ELSE BEGIN 
       ytit = ytitl
   END

   fluxtype=tp
  
   ;;
   ;; Set parameters to their default values if not given
   ;;
   IF (n_elements(co) EQ 0) THEN co=!p.color
   IF (n_elements(ba) EQ 0) THEN ba=!p.background
   IF (n_elements(xst) EQ 0) THEN xst=0
   IF (n_elements(yst) EQ 0) THEN yst=0
   IF (n_elements(norm) EQ 0) THEN norm=1
   IF (n_elements(nologf) EQ 0) THEN nologf=0
   lo = 0
   if (keyword_set(lono)) then lo = 1
   if (keyword_set(lolo)) then lo = 2

   if (lo eq 0) then begin
       lo = 2
       ;; no logarithmic x-axis if less than one decade in energy
       if (emin ne 0.) then begin
           if (emax/emin lt 10.) then lo=1
       end else begin
           lo = 1
       endelse
   end 

   IF (n_elements(title) EQ 0) THEN title = ' '

   ;; axes  
   IF (lo EQ 1) THEN xlog=0
   IF (lo EQ 2) THEN xlog=1

   ylog=1
   IF (nologf EQ 1) THEN ylog=0

   ;; max. flux
   fm=fmax
   IF ((yst NE 1) AND (NOT keyword_set(exact))) THEN fm=1.1*fmax
   ;;
   ;; Frame for plot
   ;;
   IF (n_elements(position) EQ 0) THEN BEGIN 
       plot_io, [emin,emax], [fmin, fm], title=strtrim(title,2), $
       xtitle=xtit,ytitle=ytit,color=co(0),background=ba,/nodata, $
       xstyle=xst,ystyle=yst,xlog=xlog,ylog=ylog
   END ELSE BEGIN 
       plot_io, [emin,emax], [fmin, fm], title=strtrim(title,2), $
       xtitle=xtit,ytitle=ytit,color=co(0),background=ba,/nodata, $
       xstyle=xst,ystyle=yst,position=position,xlog=xlog,ylog=ylog
   END

   if (n_elements(sp) ne 0) then oldospecplot, sp, psym=symbol, $
     linestyle=linst,normalized=norm,color=co, $
     offset=ofs,label=lab,normconst=normconst,erange=erange, $
     frange = frange, symsize=symsize
end




