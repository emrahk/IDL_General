;+
; Project     : SOHO - CDS     
;                   
; Name        : FIT_SPEC
;               
; Purpose     : fit spectra
;               
; Category    : Analysis
;               
; Explanation : 
;               
; Syntax      : IDL> fit_spec,x,y
;    
; Examples    : 
;
; Inputs      : y = data to fit
;               x = independent array
;               
; Opt. Inputs : None
;               
; Outputs     : fx,fz = fitted results array
;               a = fitted parameters
;               e = error in a
;
; Opt. Outputs: None
;               
; Keywords    : fit_funct = string name of fit_function to fit
;                           limited to 'GAUSS','FBLUE','VOIGT', and 'DVOIGT'
;               fixp = parameter indicies to fix (e.g. [0,1] to fix first and second)
;               flabels = string array of fit characteristics
;               damp  = damping width (A) for Voigt fit
;               disp  = dispersion (dw/dx) 
;               weights = weights for fitting
;               include = range of additional region to include in fit (e.g. background)
;               err = 1 (fail) / 0 (success)
;               fxrange = range within which to restrict fit
;               chi2 = reduced chi squared 
;               /wave = flags 'x' array as wavelength units (A)
;               /flux = flags 'y' array as flux units (photons s-1 cm-2 A-1)
;               /last = use latest 'a' values as input to new iteration
;               /instrumental = use instrumental weighting
;               
;
; Common      : None.
;               
; Restrictions: Limited to Gaussians and Voigt functions.
;               
; Side effects: None.
;               
; History     : Version 1,  17-July-1996,  D M Zarro.  Written
;               Version 2, 13-Sept-1999, Zarro (SM&A/GSFC), added BGAUSS
;               20-Sept-1999, Zarro (SM&A/GSFC), added /INSTRUMENTAL
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-            

pro fit_spec,x,y,fx,fz,a,e,flabels=flabels,fxrange=fxrange,fit_funct=fit_funct,$
     wave=wave,last=last,damp=damp,disp=disp,flux=flux,chi2=chi2,weights=weights,$
     include=include,err=err,fixp=fixp,corr=corr,con=con,plot=plot,$
     instrumental=instrumental

on_error,1
err=0
cv=2*sqrt(alog(2.))

np=n_elements(x)
if np eq 0 then message,'usage --> FIT_SPEC,X,Y,FX,FZ,A,[FIT_FUNCT=FUNCT,WEIGHT=W]'

if n_elements(disp) eq 0 then disp=1.
if n_elements(weights) eq 0 then begin
 weights=replicate(1.,np)
 if keyword_set(instrumental) then begin
  ok=where(y ne 0.,count)
  if count gt 0 then weights(ok)=1./y(ok)
 endif
endif

;--  Choose points that are in specified ranges
;    If FXRANGE undefined, then start with whole range;
;    Choose wavelength ranges in pairs.

if n_elements(fxrange) lt 2 then lrange=[min(x),max(x)] else lrange=fxrange

nrange=n_elements(lrange)
if (nrange mod 2) ne 0 then lrange=lrange(0:nrange-2)
for jj=0,n_elements(lrange)-1,2 do begin
 wrange=[lrange(jj),lrange(jj+1)]
 wok=(x ge min(wrange) and (x le max(wrange)))
 wsubs=where(wok,count)
 if (count gt 0) then begin
  if jj eq 0 then good=wsubs else good=[good,wsubs]
 endif
endfor

if (n_elements(include) eq 2) then begin
 chk=where( (x ge min(include)) and (x le max(include)), count)
 if count gt 0 then good=[good,chk]
endif

;-- remove duplicates

good=good(uniq(good,sort(good)))

if n_elements(good) lt 2 then begin
 flabels='TOO FEW POINTS FOR FITTING' & message,flabels,/info & return
endif

fx=x(good) & fy=y(good) & fw=weights(good)

;-- valid fit functions

flabels=''
fit_functs=['GAUSS','FBLUE','VOIGT','DVOIGT','MGAUSS','BGAUSS']
if n_elements(fit_funct) eq 0 then fit_funct=''
fun=strupcase(strtrim (fit_funct,2))

find=where(fun eq fit_functs,count)
if count eq 0 then begin
 flabels='UNSUPPORTED FIT FIT_FUNCTION' & print,flabels & return
endif

;-- units?

if keyword_set(wave) then wave=1 else wave=0
if wave then aunit='(ANG)' else aunit='(BIN)' 

if keyword_set(flux) then flux=1 else flux=0
if flux then funit='(PH CM-2 S-1)' else funit='(CTS S-1)'

;-- fit_function?

if fun ne 'FBLUE' then begin
 
;-- gaussian

 if (fun eq 'GAUSS') or (fun eq 'MGAUSS') or (fun eq 'BGAUSS') then begin
  fz=gauss_fit(fx,fy,a,e,chi2=chi2,weights=fw,nfree=nfree,last=last,$
               fixp=fixp,broad=fun eq 'BGAUSS',err=err)
  if err eq 1 then return
  stren=a(3)*sqrt(!pi)*a(5)
  dstren=stren*(abs(e(3))/a(3) + abs(e(5))/a(5))
 endif

;-- single voigt fit

 if (fun eq 'VOIGT') then begin  
  if n_elements(damp) eq 0 then damp=0     
  if n_elements(fixp) eq 0 then fixpp=[2,6] else fixpp=fixp
  fz=voigt_fit(fx,fy,a,e,damp=damp,fixp=fixpp,chi2=chi2,weights=fw,$
               nfree=nfree,last=last)
  stren=a(3)
  dstren=e(3)
 endif

;-- double voigt function

 if (fun eq 'DVOIGT') then begin
  if n_elements(damp) eq 0 then damp=0
  if n_elements(fixp) eq 0 then fixpp=[2,6,10] else fixpp=fixp
  corr=intarr(11,11)
  corr(5,9)=1
  fz=dvoigt_fit(fx,fy,a,e,damp=damp,fixp=fixpp,chi2=chi2,weights=fw,$
               nfree=nfree,last=last,corr=corr)
  stren=a(3)
  stren2=a(7)
  dstren=e(3)
  dstren2=e(7)
  sep=abs(a(4)-a(8))
  dsep=sqrt(e(4)^2 + e(8)^2)
  slabel='SEPA '+aunit+' : '+strtrim(string(sep,'(g10.5)'),2)+$
                         '+/-'+strtrim(string(dsep,'(g10.5)'),2)
  width2=a(9)
  fwhm2=width2*cv
  dwidth2=e(9)
  dfwhm2=dwidth2*cv
  cent2=a(8)
  dcent2=e(8)
  wlabel2='FWHM_2 '+aunit+' : '+strtrim(string(fwhm2,'(g10.5)'),2)+$
                         '+/-'+strtrim(string(dfwhm2,'(g10.5)'),2)

  clabel2='CENTROID_2 '+aunit+' : '+strtrim(string(cent2,'(f11.5)'),2)+$
                     ' +/- '+strtrim (string(dcent2,'(f11.5)'),2)

 endif
  
;-- widths

 cent=a(4) & width=a(5) 
 dwidth=e(5) & dcent=e(4)
 fwhm=width*cv
 dfwhm=dwidth*cv
 wlabel='FWHM '+aunit+' : '+strtrim(string(fwhm,'(g10.5)'),2)+$
                         '+/-'+strtrim(string(dfwhm,'(g10.5)'),2)
                           
endif

;-- blueshift model

if (fun eq 'FBLUE') then begin
 fac=1.
 if n_elements(fixp) eq 0 then fixpp=[2] else fixpp=fixp
 fz=fblue_fit(fx,fy,a,e,fac=fac,chi2=chi2,weights=fw,$
              nfree=nfree,last=last,fixp=fixpp)
 bkg=a(0)+fx*a(1)+fx^2*a(2)
 bshift=a(7) & dshift=e(7)
 bw=abs((fx-a(4)+a(7))/fac/a(7)) < 5.d & ew=exp(-bw^2)
 bluec=bkg+a(6)*ew
 cent=a(4) & dcent=e(4)
 width=a(5) & dwidth=e(5)
 if wave then begin
  units='(KM/S)'
  bshift=3.e5*bshift/cent
  dshift=3.e5*dshift/cent
 endif else units='(BIN)'
 fx=[fx,reverse(fx),fx] & fz=[bluec,reverse(bluec),fz]
 bstren=fac*a(7)*a(6)/a(3)/a(5)
 stren=sqrt(!pi)*a(3)*a(5)
 dstren=stren*(abs(e(3))/a(3) + abs(e(5))/a(5))
 blabel='BLUESHIFT '+units+': '+strtrim(string(bshift,'(f8.0)'),2)+$
                         '+/-'+strtrim (string(dshift,'(f8.0)'),2)

 rlabel='REL. STRENGTH: '+string(bstren,'(f4.2)')
endif

;-- Doppler velocity width

if wave then begin 
 vwidth=3.e5*width/cent & dvwidth=3.e5*dwidth/cent  
 vlabel='DOPP WIDTH (KM/S) : '+strtrim(string(vwidth,'(g10.5)'),2)+$
                         '+/-'+strtrim (string(dvwidth,'(g10.5)'),2)

 if n_elements(width2) ne 0 then begin
  vwidth2=3.e5*width2/cent2 & dvwidth2=3.e5*dwidth2/cent2
  vlabel2='DOPP WIDTH_2 (KM/S) : '+strtrim(string(vwidth2,'(g10.5)'),2)+$
                         '+/-'+strtrim (string(dvwidth,'(g10.5)'),2)
  vlabel=[vlabel,vlabel2]
 endif
endif


;-- line strength
 
if flux and (not wave) then begin 
 stren=stren*disp & dstren=dstren*disp
 if n_elements(stren2) ne 0 then begin
  stren2=stren2*disp & dstren2=dstren2*disp
 endif
endif

if (not flux) and wave then begin
 stren=stren/disp
 dstren=dstren/disp
 if n_elements(stren2) ne 0 then begin
  stren2=stren2/disp & dstren2=dstren2/disp
 endif
endif

ilabel='INTEN '+funit+' : '+strtrim(string(stren,'(g10.5)'),2)+ $
                         '+/-'+strtrim (string(dstren,'(g10.5)'),2)

if n_elements(stren2) ne 0 then begin
 ilabel=[ilabel,'INTEN_2 '+funit+' : '+strtrim(string(stren2,'(g10.5)'),2)+ $
                         '+/-'+strtrim (string(dstren2,'(g10.5)'),2)]
endif

clabel='CENTROID '+aunit+' : '+strtrim(string(cent,'(f11.5)'),2)+$
                     ' +/- '+strtrim (string(dcent,'(f11.5)'),2)


;-- organize plot labels

flabels=[ilabel,clabel]
if n_elements(clabel2) ne  0 then flabels=[flabels,clabel2]
if n_elements(wlabel) ne  0 then flabels=[flabels,wlabel]
if n_elements(wlabel2) ne  0 then flabels=[flabels,wlabel2]
if n_elements(vlabel) ne  0 then flabels=[flabels,vlabel]
if n_elements(slabel) ne  0 then flabels=[flabels,slabel]
if n_elements(blabel) ne  0 then flabels=[flabels,blabel]
if n_elements(rlabel) ne  0 then flabels=[flabels,rlabel]

chi='CHISQ: '+string(chi2/nfree,'(f8.1)')
flabels=[flabels,chi]

if keyword_set(plot) then oplot,fx,fz

err=0
return & end

