;
; Compute energy index alpha and estimate for cutoff-energy ecut.
;
; That is, alphacut fits to a model
;
; f(e; e0,alpha,ecut)=e^(-alpha) * exp( -(e-1)/ecut )
; 

PRO plexp, x, a, f,pder,verbose=verbose
   COMMON testcom,ee,fl

   IF (a(0) LT 0.) THEN a(0)=0.
   IF (a(1) LT 0.) THEN a(1)=1.

   xx=x/x(0)
   f = xx^(-a(0))*exp(-(xx-1.)/a(1))

   IF (n_elements(pder) NE 0) THEN BEGIN
       pder(*,0)=-a(0)*f/xx
       pder(*,1)=(xx-1.)/(a(1)*a(1))*f
   ENDIF 

   IF (keyword_set(verbose)) THEN BEGIN 
       plot_oo, ee, fl
       oplot, x,f
       print, a
       aa=' '
       read, aa
   ENDIF 
END 

PRO alphacut, sp, e0,alpha, ecut,emin=emin,emax=emax,chi2=chi2,verbose=verbose
   COMMON testcom,ee,fl

   IF (n_elements(emin) EQ 0) THEN emin=5.
   IF (n_elements(emax) EQ 0) THEN emax=50.
   ;;
   ;; Generate arrays for curvefit
   ;;
   imin=1
   imax=1
   while (sp.e(imin) lt emin) do imin=imin+1
   while (emax gt sp.e(imax)) do imax=imax+1
   emin=sp.e(imin)
   emax=sp.e(imax)
   ee=sp.e(imin:imax)
   fl=sp.f(imin:imax)

   mm=min(where(fl EQ 0.))
   IF (mm GT 0) THEN BEGIN
       ee=ee(0:mm-1)
       fl=fl(0:mm-1)
   ENDIF 
   fl=fl/fl(0)
   ;;
   ;; Fit power-law with exp. cutoff to data
   ;;
   w=1./fl(*)
   a=fltarr(2)
   a(0)=0.7 ;; PL-Index
   a(1)=10. ;; Cut-off
   iter=0
   chi2=0.
   itmax=40
   res=curvefit(ee,fl,w,a,function_name='plexp',iter=iter, itmax=itmax, $
                chi2=chi2)

   alpha=a(0)
   ecut=a(1)*ee(0)
   e0 = ee(0)
   IF (keyword_set(verbose)) THEN plexp, ee, a, f, /verbose
END 


;
; Like alphacut, but old version (not recommended)
;
PRO oldalphacut
   alpha=0.
   ecut=0.
   
   ;; Rebin spectrum to 100 bins (thus smoothing the spectrum)
   n = fix(sp.len/50)
   gr = groupspec(sp,n,null)
   
   ;; look only at spectrum above 1 keV
   istart = min(where(gr.e(0:gr.len) GT 1.))
   IF (istart EQ -1) THEN return
   
   ;; max. point in spectrum
   IF (gr.sat EQ 0.) THEN BEGIN
       iend = max(where(gr.f(0:gr.len) GT 0.))
   END ELSE BEGIN
       iend = max(where((gr.f(0:gr.len) GT 0.) AND (gr.f(0:len) LT gr.sat)))
   END 
   IF (iend EQ -1) THEN return
   IF (iend EQ istart) THEN return 
   
   ;; Generate array with valid fluxes above 1keV
   valid = istart+indgen(iend-istart)
   tmp=intarr(iend-istart)
   nd=0
   FOR i=0,iend-istart-1 DO BEGIN
       IF (gr.sat EQ 0.) THEN BEGIN
           IF (gr.f(valid(i)) GT 0.) THEN BEGIN
               tmp(nd)=valid(i)
               nd=nd+1
           ENDIF
       END ELSE BEGIN 
           IF ((gr.f(valid(i)) GT 0.) AND (gr.f(valid(i)) LT gr.sat))THEN BEGIN
               tmp(nd)=valid(i)
               nd=nd+1
           ENDIF
       END
   ENDFOR
   IF (nd EQ 0) THEN return
   valid=tmp(0:nd-1)

   fl=alog10(gr.f(valid))
   en=alog10(gr.e(valid))
   npt=n_elements(fl)
   
   ;; Now differentiate
   dfl=fltarr(npt-1)
   me=dfl
   for i=0,npt-2 DO BEGIN
       dfl(i)=(fl(i+1)-fl(i))/(en(i+1)-en(i))
   ENDFOR
   
   ;; Gliding average and sigma of the first n points
   sum=0.
   sum2=0.
   alpha=0.
   ecut=-1.
   FOR i=0,npt-2 DO BEGIN 
       sum=sum+dfl(i)
       sum2=sum2+dfl(i)*dfl(i)
       me=sum/(i+1)
       si=sum2/(i+1) - me*me
       IF (abs(si/me) LE 0.04) THEN BEGIN 
           alpha=me
           ecut=en(i+1)
       ENDIF
   ENDFOR
   alpha=-alpha
   ecut=10.^ecut
END
