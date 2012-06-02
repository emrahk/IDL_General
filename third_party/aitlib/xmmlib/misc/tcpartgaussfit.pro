PRO tcpartgaussfit,xxx,spec,emin=emin,emax=emax,bg=bg,wmin=wmin,wmax=wmax,$
                   gauss=gauss,f=f,err=err,stop=stop
   
;+
; NAME:            
;                  tcpartgaussfit
;
;
; PURPOSE:
;		   fit gaussian to spec, considering only part of the
;		   spectrum 
;		   
;		   
;
;
; CATEGORY:
;                  Proton Data Analysis
;
;
; CALLING SEQUENCE:
;                  
;
; 
; INPUTS:
;                  xxx  : energies of spec
;                  spec : energy spectrum (histogram)
;
;
; OPTIONAL INPUTS:
;                  emin: the minimum energy value in ADU 
;                  emax: the maximum energy value in ADU
;                  bg     : binsize
;                  wmin, wmax: interval in which gauss is to be fitted; 
;                              if not specified, gauss is fitted
;                              between FWHM points   
;   
;
; KEYWORD PARAMETERS:
;                  err : print fit parameters and errors
;
;
; OUTPUTS:
;                  gauss : fitted gaussian
;                  f : fltarr(3) containing fit parameters
;
;
; OPTIONAL OUTPUTS:
;		   none   
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;        
;                  
;
; MODIFICATION HISTORY:
; V1.0 12.07.00 T. Clauss initial version, using part of tcpartial.pro
;-
   
   IF (NOT keyword_set(emin)) THEN BEGIN
       emin=min(xxx)
   ENDIF ELSE BEGIN
       ind=min(where(xxx GE emin))
       xxx=xxx(ind:n_elements(xxx)-1)
       spec=spec(ind:n_elements(spec)-1)
   ENDELSE
      
   IF (NOT keyword_set(emax)) THEN BEGIN
       emax=max(xxx)
   ENDIF ELSE BEGIN
       ind=max(where(xxx LE emax))
       xxx=xxx(0:ind)
       spec=spec(0:ind)
   ENDELSE
   
   IF n_elements(xxx) NE n_elements(spec) THEN BEGIN
       print,'% TCPARTGAUSSFIT: dimensions of xxx and spec different! Returning...'
       return
   ENDIF
   
   IF (NOT keyword_set(bg)) THEN bg=1.0
   
   IF (n_elements(spec) LT 10) THEN BEGIN
       print,'% TCPARTIAL: not enough data points! Returning...'
       return
   ENDIF
   
   IF ((emax-emin+bg)/bg LE 8) THEN BEGIN
       print,'% TCPARTIAL: energy interval too small! Returning...'
       return
   ENDIF
   
   ;; find starting values
   sspec=smootharr(spec,2)
   
;   stop
   
   f0=fltarr(3)
   f0(0)=max(sspec)
   find=where(sspec GE f0(0)/2)
   fa=find(0)
   fe=find(n_elements(find)-1)
   IF (fa EQ 0) THEN print,'%TCPARTIAL: hitting left boundary - check results!'
   IF (fe EQ n_elements(sspec)-1) THEN print,'%TCPARTIAL: hitting right boundary - check results!'
   f0(1)=(xxx(fa)+xxx(fe))/2
   f0(2)=(xxx(fe)-xxx(fa))/2
   
   weight=dblarr(n_elements(spec))
   weight(*)=0.0001d
   IF NOT(keyword_set(wmin)) THEN BEGIN
       wmin1=min(where(xxx GE f0(1)-f0(2)))
   ENDIF ELSE BEGIN
       wmin1=min(where(xxx GE wmin))
   ENDELSE
   IF (wmin1 LT 0) THEN wmin1=0
   IF NOT(keyword_set(wmax)) THEN BEGIN
       wmax1=max(where(xxx LE f0(1)+f0(2)))
   ENDIF ELSE BEGIN
       wmax1=max(where(xxx LE wmax))
   ENDELSE
   IF (wmax1 GE n_elements(spec)) THEN wmax1=n_elements(spec)-1
   weight(wmin1:wmax1)=1.0d   
   
   temp=tcgaussfit(xxx,spec,f1,estimates=f0,nterms=3,weights=weight)
   
   weight(*)=0.0001d
   IF NOT(keyword_set(wmin)) THEN wmin1=min(where(xxx GE f1(1)-f1(2)))
   IF (wmin1 LT 0) THEN wmin=0
   IF NOT(keyword_set(wmax)) THEN wmax1=max(where(xxx LE f0(1)+f0(2)))
   IF (wmax1 GE n_elements(spec)) THEN wmax=n_elements(spec)-1
   weight(wmin1:wmax1)=1.0d   

   ;; do better gauss fit 
   gauss=tcgaussfit(xxx,spec,f,nterms=3,weights=weight,estimates=f1,sigmaa=sigma,chisq=chisq)
   
   IF keyword_set(err) THEN BEGIN
       tcchisq,spec,gauss,min=wmin1,max=wmax1,chisq=chisq,pars=3,redchisq=redchisq
       print,'%TCPARTIAL: fit results: '
       print,'%TCPARTIAL:     height: ',strtrim(f(0),2),' ,  position: ',$
         strtrim(f(1),2),' ,  width: ',strtrim(f(2),2)
       print,'%TCPARTIAL:     chisq: ',strtrim(chisq,2),' ,  reduced chisq: ',strtrim(redchisq,2)  
       print,'%TCPARTIAL:  '
       
   ENDIF
      
   IF (keyword_set(stop)) THEN stop
   
END 































































































