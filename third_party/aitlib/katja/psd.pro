PRO psd,time,rate,freq,psd, $
        dseg=dseg,schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
        avg_bkg=avg_bkg,normindiv=normindiv, $
        chatty=chatty,countrate=countrate,length=length,seg=seg,sigma=sigma
;+
; NAME:
;          psd
;
;
; PURPOSE:
;          calculate the fourier frequency array and the average power
;          spectral density array for segments with dimension dseg of
;          one evenly binned lightcurve (given by a time array and a
;          count rate array); return the frequency array and the
;          average power spectral density array 
;          (in Schlittgen, Leahy or Miyamoto (default) normalization)
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          psd,time,rate,freq,psd, $
;              dseg=dseg,schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $ 
;              avg_bkg=avg_bkg,normindiv=normindiv, $
;              chatty=chatty,countrate=countrate,length=length,seg=seg,sigma=sigma 
; 
; INPUTS:
;          time : time array of evenly binned lightcurve
;          rate : corresponding count rate array
;
;
; OPTIONAL INPUTS:
;          countrate : value of the count rate to be assumed for the
;                      PSD normalization (e.g., for the case of a
;                      background subtracted countrate, where the
;                      TOTAL measured countrate should be used for the
;                      normalization)
;
;	
; KEYWORD PARAMETERS: 
;          dseg           : if set, average over segments with a
;                           dimension of dseg; if not set compute the
;                           psd for the whole lightcurve (which should
;                           contain NO gap!) 
;          schlittgen     : if set, return power in Schlittgen
;                           normalization  
;                           (Schlittgen, H.J., Streitberg, B., 1995,
;                           Zeitreihenanalyse, R. Oldenbourg)  
;          leahy          : if set, return power in Leahy normalization 
;                           (Leahy, D.A., et al. 1983, Ap.J., 266,160) 
;          miyamoto       : if set, return power in Miyamoto normalization
;                           (Miyamoto, S., et al. 1991, Ap.J., 383, 784)
;          avg_bkg        : average background rate;
;                           used for correcting the psd normalization
;                           in case of Miyamoto normalization 
;                           default: avg_bkg undefined 
;          normindiv      : average AFTER normalizing individual psds
;                           default: average raw psds, then normalize
;                                    using the count rate of the total
;                                    light-curve 
;          chatty         : controls screen output 
;                           default: no screen output
;   
;
; OUTPUTS:
;          freq : fourier frequency array corresponding to time
;                 and dseg 
;          psd  : normalized power spectral density array
;                 corresponding to rate and dseg, and - if dead-time
;                 and background correction applied - also noise
;                 subtracted 
;
;
; OPTIONAL OUTPUTS:
;          length: length of the time-interval used to compute the
;                  individual PSD (may be used in 'dtcorr.pro')
;          seg   : value of dseg (may be used in 'dtcorr.pro')
;          sigma : In this keyword the standard deviation of the
;                  averaged psds is returned. This can be used
;                  to check the chi^2 property of the individual
;                  PSDs (in leahy normalization: sigmaindiv=psd IF the
;                  individual noise powers are chi^2 distributed,
;                  see van der Klis, 1989, in: Timing Neutron Stars
;                  (Oegelman/van der Heuvel, eds.), 27
;
;
; COMMON BLOCKS:
;          none 
;
;
; SIDE EFFECTS:
;          none
;
;
; RESTRICTIONS:
;          the input lightcurve has to be equally binned and has to be
;          given in count rates (not in photon numbers). We do not
;          check explicitely for gaps.
;
;
; PROCEDURE:
;          fourierfreq.pro
;          fastftrans.pro
;          psdnorm.pro
;
;
; EXAMPLE:
;          psd,findgen(1000),sin(2*!pi*0.1*findgen(1000)),freq,psd, $
;              dseg=100,schlittgen=schlittgen
;
;
;
; MODIFICATION HISTORY:
;          Version 1.0, 1998/03/06, Katja Pottschmidt
;          Version 2.0, 1998/05/12, J.W., K.P.
;          Version 3.0, 1999/29/96, long type for nseg   
;          Version 3.1, 1999/08/25, JW/SB: added countrate keyword
;          Version 4.0, 2001/08/02, Thomas Gleissner IAAT: dead-time and 
;                                   background correction added
;      CVS Version 1.4, 2001/08/13, Joern Wilms
;           Changed deadtime-default back to "no deadtime" to obtain
;             backward compatibility
;           Removed several test-printouts
;           Give informational messages only if chatty is set
;          2001/11/07  Thomas Gleissner:
;                      Outsource deadtime correction to a separate module
;                      'dtcorr.pro' 
;                      Add optional outputs: length, seg to be
;                      used in 'dtcorr.pro'
;-

   ;;
   ;; chatty-keyword, default:
   ;; chatty=0: the procedures do not produce any comments on screen
   ;;
   IF (NOT keyword_set(chatty)) THEN BEGIN 
       chatty=0
   ENDIF 
   
   ;;
   ;; normindiv-keyword, default: 
   ;; normindiv=0: normalize the average Fourier quantities
   ;;
   IF (NOT keyword_set(normindiv)) THEN BEGIN
       normindiv=0
   ENDIF 
   
   ;; 
   ;; normalization-keywords (schlittgen, leahy, miyamoto), default:
   ;; miyamoto=1: Miyamoto normalization 
   ;;
   IF ((n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)) GT 1) $
     THEN BEGIN  
       message,'psd: Only one normalization-keyword can be set' 
   ENDIF
   IF ((n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)) EQ 0) $
     THEN BEGIN
       miyamoto=1
   ENDIF 
   IF (keyword_set(schlittgen)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'psd: The Fourier quantities are Schlittgen-normalized'
   ENDIF 
   IF (keyword_set(leahy)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'psd: The Fourier quantities are Leahy-normalized'
   ENDIF
   IF (keyword_set(miyamoto)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'psd: The Fourier quantities are Miyamoto-normalized'
   ENDIF
   IF (keyword_set(avg_bkg)) THEN BEGIN
     IF (NOT keyword_set(miyamoto)) THEN BEGIN 
       message,'psd: Background correction can only be performed for Miyamoto normalization'
     ENDIF 
   ENDIF 

   ;;
   ;; check if the keyword giving the dimension of the lightcurve (lc)
   ;; segments is set; if it is not set, compute the psd of the total
   ;; lightcurve
   ;;
   dall=n_elements(time)             
   IF (n_elements(dseg) EQ 0) THEN dseg=dall
   ;; dseg is given over to seg for output of psd.pro
   seg=dseg
   nseg=long(dall/dseg)
   IF (nseg EQ 0) THEN BEGIN 
       message,'psd: Segment dseg cannot be longer than the input lightcurve'
   END 

   ;;   
   ;; calculate the Fourier frequencies (freq) and the average power spectral
   ;; density (psd) by dividing the input lightcurve into nseg
   ;; segments with dimension dseg 
   ;;
      
   psd=0.
   psd2=0.
   sigma=fltarr(nseg)
   startbin=0L
   endbin=dseg-1L
   
   fourierfreq,time(startbin:endbin),freq
   length=time(endbin)-time(startbin)

   FOR i=0L,nseg-1 DO BEGIN
       fastftrans,rate(startbin:endbin),dft
       singpsd=(abs(dft))^2.
       ;;
       ;; normindiv=1:  normalize individual psds, then average
       ;;
       IF (keyword_set(normindiv)) THEN BEGIN 
           IF (n_elements(countrate) EQ 0) THEN BEGIN 
               rr=total(rate(startbin:endbin))/dseg
           END ELSE BEGIN 
               rr=countrate
           ENDELSE
           ;; normalize individual psds
           psdnorm,rr,length,dseg,singpsd, $
             schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
             chatty=chatty
       END 
       ;; sum up individual psds
       psd=temporary(psd)+singpsd
       psd2=temporary(psd2)+singpsd*singpsd
       startbin=endbin+1
       endbin=startbin+dseg-1
   ENDFOR 

   ;; average psds
   psd=temporary(psd)/nseg
   sigma=sqrt((psd2-nseg*psd^2.)/nseg)

   ;; normindiv=0:  average raw psds, then normalize
   ;;               using the count rate of the total
   ;;               light-curve 
   IF (NOT keyword_set(normindiv)) THEN BEGIN 
       ppsd=psd
       IF (n_elements(countrate) EQ 0) THEN BEGIN 
           rr=total(rate)/n_elements(rate)
       END ELSE BEGIN 
           rr=countrate
       END 
       psdnorm,rr,length,dseg,psd,$
         schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
         chatty=chatty
       sigma=temporary(sigma)*psd(0)/ppsd(0) ;; adjust norm of sigma
   END

END 

