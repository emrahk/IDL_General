PRO tcpeak,data,bg=bg,erange=erange,peak=peak,sigma=sigma,chisq=chisq,$
            plotfit=plotfit,plotpos=plotpos
;+
; NAME:            tcpeak
;
;
;
; PURPOSE:
;		   Fit peak to data
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  tcpeak,data,bg=2.0,erange=100
;
; 
; INPUTS:
;                  data   : the data struct array to be fitted
;
;
; OPTIONAL INPUTS:
;
;                  bg     : binsize
;                  erange : if erange is specified, the peak is fitted
;                           twice, the second time in the energy
;                           interval peak+-erange    
;
; KEYWORD PARAMETERS:
;                  plot : plot spectrum and fit in current window
;
;
; OUTPUTS:
;                  peak : position of the fitted peak
;                  sigma : the stanard deviation of the peakposition
;                  chisq : the reduced chi^2 of the fit (?) as
;                          returned by curvefit
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
; V1.0 04.01.00 T. Clauss, first version derived from mkspectrum
; V2.0 03.04.00 T. Clauss, changed fitting procedure: use IDL-gaussfit
;                   instead of mkgaussfit, added keyword ERANGE
; V2.1 18.04.00 T.Clauss, use tcgaussfit, added keyowrds SIGMA and CHISQ
; V2.2 29.08.00 T.Clauss, added keyword plotpos, changed keyword plot
;                   to plotfit
;-

   peak=0.

   IF (NOT keyword_set(bg)) THEN bg=1.d
   
   IF (n_elements(data) GT 1) THEN BEGIN 
       
     energy=data.energy  
     emin=min(energy)
     emax=max(energy)
     gspek = HISTOGRAM(energy, MIN=emin, MAX=emax, BINSIZE=bg)
     
     IF (emax-emin+bg)/bg GT 8 THEN BEGIN
         xxx = INDGEN(N_ELEMENTS(gspek))*bg+emin
         ;; do gaussfit on data
         gauss=gaussfit(xxx,gspek,f1,nterms=3)
         peak=f1(1)
     ENDIF ELSE BEGIN
         print,'% TCPEAK: Gauss Fit not possible - Not enough data points !'
         peak=-1    
     ENDELSE
     
     IF keyword_set(erange) THEN BEGIN  
         IF (peak-erange LT emin) THEN $
             print,'% TCPEAK: energy interval for fit bigger than energy range of data !'
         emin=peak-erange
         IF (peak+erange GT emax) THEN $
             print,'% TCPEAK: energy interval for fit bigger than energy range of data !'
         emax=peak+erange
         
         indp=where((data.energy GE emin) AND (data.energy LE emax))
         
         IF (n_elements(indp) GT 1) THEN BEGIN
             energy=data(indp).energy
         
             gspek = HISTOGRAM(energy, MIN=emin, MAX=emax, BINSIZE=bg)
             n_gspek=n_elements(gspek)
                         
             IF (emax-emin+bg)/bg GT 8 THEN BEGIN
                 xxx = INDGEN(n_gspek)*bg+emin
                 ;; do gaussfit on data
                 gauss=tcgaussfit(xxx,gspek,f,nterms=3,estimates=f1,sigmaa=sigma,chisq=chisq)
                  peak=f(1)
                 sigma=sigma(1)
             ENDIF ELSE BEGIN
                 print,'% TCPEAK: 2. Gauss Fit not possible - Not enough data points !'
                 peak=-1 
                 sigma=0
                 chisq=0
             ENDELSE         
         ENDIF ELSE BEGIN
             print,'% TCPEAK: 2. Gauss Fit not possible - Not enough data points !'
             peak=-1 
             sigma=0
             chisq=0
         ENDELSE
                  
     ENDIF 
         
   ENDIF ELSE BEGIN 
     print,'% TCPEAK: Gauss Fit not possible - Not enough data points !'
     peak=-1
     sigma=0
     chisq=0
   ENDELSE
   
   IF (keyword_set(plotfit)) THEN BEGIN
       IF (peak NE -1) THEN BEGIN
           spectrum = HISTOGRAM(energy, BINSIZE=bg)
           xindex = INDGEN(N_ELEMENTS(spectrum))*bg+min(energy)
           IF keyword_set(plotpos) THEN BEGIN 
               noticks=[' ',' ',' ',' ',' ',' ',' ',' ']
               PLOT, xindex, spectrum, position=plotpos,$
                 XRANGE=[emin,emax], title='Col '+strtrim(min(data.column),2),/noerase,$
                 xtickname=noticks,ytickname=noticks
               OPLOT, xxx, gauss, COLOR=42, THICK=2
           ENDIF ELSE BEGIN
               PLOT, xindex, spectrum, XRANGE=[emin,emax], title='Col '+strtrim(min(data.column),2)
               OPLOT, xxx, gauss, COLOR=42, THICK=2
           ENDELSE 
       ENDIF   
   ENDIF

END 
































































































