PRO dtcorr,freq,psd, $
           rate=rate,length=length,dseg=dseg, $
           schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
           avg_bkg=avg_bkg,chatty=chatty,zhang_dt=zhang_dt,pca_dt=pca_dt,$
           cluster_a=cluster_a,cluster_b=cluster_b,pcuon=pcuon,$
           hexte_dt=hexte_dt,poisson=poisson, $
           _extra=extra
;+
; NAME:
;          dtcorr
;
;
; PURPOSE:
;          calculate the deadtime correction and apply it to the psd
;          array; return the frequency array and the corrected psd array
;          (for Zheng (instrument independent), PCA, HEXTE or Poisson 
;          correction)
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;         
;          dtcorr,freq,psd, $
;                rate=rate,length=length,dseg=dseg, $
;                schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;               avg_bkg=avg_bkg,chatty=chatty,zhang_dt=zhang_dt,pca_dt=pca_dt,$
;               cluster_a=cluster_a,cluster_b=cluster_b,pcuon=pcuon,$
;               hexte_dt=hexte_dt,poisson=poisson, $
;               _extra=extra
; INPUTS:
;          freq   : fourier frequency array corresponding to time
;                   and dseg 
;          psd    : normalized power spectral density array
;                   corresponding to rate and dseg, and noise subtracted 
;          rate   : corresponding count rate array
;          length : length of the time-interval used to compute the
;                   individual PSD
;          dseg   : segment length into which the lightcurve has been
;                   divided to compute the psd (averaged over all
;                   segments)
;
;
; OPTIONAL INPUTS:
;
;	
; KEYWORD PARAMETERS: 
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
;          chatty         : controls screen output 
;                           default: no screen output
;          zhang_dt       : instrument independent deadtime
;                           correction
;                           (after: Zhang, Jahoda, Swank, et al.,
;                           1995, Ap. J. 449, 930) ; 
;                           default: see below  
;          ninstr         : number of instruments that
;                           accumulated the lightcurves ;
;                           zhang_dt=1 has to be set ;
;                           default: ninstr=1;   
;          deadtime       : parameter giving the instrument
;                           deadtime in the same units as the time
;                           array of the lighcurves [sec] ;
;                           zhang_dt=1 has to be set ;   
;                           default: deadtime=0; 
;          nonparalyzable : keyword defining the type of Zhang
;                           deadtime correction that is performed ;
;                           if set, a correction for
;                           nonparalyzable deadtime is performed ; 
;                           zhang_dt=1 has to be set ;   
;                           default: nonparalyzable=0;
;          pca_dt         : deadtime correction for PCA psds
;                           (after: Jernigan, Klein, and Arons,
;                           2000, Ap. J. 530, 875);
;                           default: see below   
;          pcuon          : number of PCUs that is turned on;
;                           pca_dt=1 has to be set;    
;                           default: pcuon undefined;
;                                    if pca_dt=1 then 
;                                    pcuon=5 is the default     
;          vle            : average vle rate per PCU;
;                           pca_dt=1 has to be set;    
;                           default: vle undefined;
;          level          : (average) PCA ``deadtime level'';
;                           determining the deadtime value;      
;                           pca_dt=1 has to be set;    
;                           default: level undefined;
;          hexte_dt       : deadtime correction for HEXTE psds
;                           (after: Kalemci, 2000, priv. comm);
;                           default: see below 
;          xuld           : xuld rates for one cluster;
;                           hexte_dt=1 has to be set;    
;                           default: xuld undefined;
;          cluster_a      : deadtime correction for HEXTE psds for
;                           cluster A;
;                           hexte_dt=1 has to be set;
;                           default: cluster_a undefined;   
;          cluster_b      : deadtime correction for HEXTE psds for
;                           cluster B  
;                           hexte_dt=1 has to be set;
;                           default: cluster_b undefined;
;          poisson        : correction for Poisson noise only, without
;                           deadtime effects
;                                           
;          only one of the  keywords zhang_dt/pca_dt/hexte_dt/poisson can
;          be set;  
;          default: zhang_dt=1, pca_dt undefined, hexte_dt undefined,
;          poisson undefined  
;   
;
; OUTPUTS:
;          freq : fourier frequency array corresponding to time
;                 and dseg 
;          psd  : normalized power spectral density array
;                 corresponding to rate and dseg, and noise
;                 subtracted 
;
;
; OPTIONAL OUTPUTS:

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
;
;
; PROCEDURE:
;          psdcorr.pro
;          psdcorr_pca.pro
;          psdcorr_hexte.pro
;          psdcorr_poisson.pro
;
;
; EXAMPLE:
;          dtcorr,freq,psd, $
;                 rate=rate,length=length,dseg=dseg
;
;
; MODIFICATION HISTORY:
;          2001/11/07, Thomas Gleissner IAAT: dtcorr.pro based on
;                      foucalc.PRO by Katja Pottschmidt IAAT 
;
;          2001/12/20, Emrah Kalemci CASS: cluster_a and cluster_b keywords
;		       added to make it work correctly with
;		       psdcorr_hexte
;
;          2002/01/17, T.G.: 
;                      * keyword poisson added
;                      * 'IF (n_elements(avg_bkg) NE 0)'-Blocks in psdcorr,
;                        psdcorr_pca and psdcorr_hexte removed
;                        (with J.W. guaranty!)
;
;-
   ;;
   ;; chatty-keyword, default:
   ;; chatty=0: the procedures do not produce any comments on screen
   ;;
   IF (NOT keyword_set(chatty)) THEN BEGIN 
       chatty=0
   ENDIF 
      
   ;; 
   ;; normalization-keywords (schlittgen, leahy, miyamoto), default:
   ;; miyamoto=1: Miyamoto normalization 
   ;;
   IF ((n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)) GT 1) $
     THEN BEGIN  
       message,'dtcorr: Only one normalization-keyword can be set' 
   ENDIF
   IF ((n_elements(schlittgen)+n_elements(leahy)+n_elements(miyamoto)) EQ 0) $
     THEN BEGIN
       miyamoto=1
   ENDIF 
   IF (keyword_set(schlittgen)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'dtcorr: The Fourier quantities are Schlittgen-normalized'
   ENDIF 
   IF (keyword_set(leahy)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'dtcorr: The Fourier quantities are Leahy-normalized'
   ENDIF
   IF (keyword_set(miyamoto)) THEN BEGIN
       IF (keyword_set(chatty)) THEN print,'dtcorr: The Fourier quantities are Miyamoto-normalized'
   ENDIF
   IF (keyword_set(avg_bkg)) THEN BEGIN
     IF (NOT keyword_set(miyamoto)) THEN BEGIN 
       message,'dtcorr: Background correction can only be performed for Miyamoto normalization'
     ENDIF 
   ENDIF 

   ;;
   ;; deadtime correction keywords, default:
   ;; zhang_dt=1: Zhang deadtime correction
   ;;
   nzha = n_elements(zhang_dt)
   npca = n_elements(pca_dt)
   nhex = n_elements(hexte_dt)
   npoi = n_elements(poisson)
   IF ((nzha+npca+nhex) GT 1) THEN BEGIN  
     message,'dtcorr: Only one deadtime-type-keyword can be set' 
   ENDIF
   ; zhang_dt is default
   IF ((nzha+npca+nhex+npoi) EQ 0) THEN BEGIN
     zhang_dt=1
   ENDIF

   IF (keyword_set(pca_dt)) THEN BEGIN
     IF (n_elements(pcuon) EQ 0) THEN BEGIN
       pcuon=5
       IF (keyword_set(chatty)) THEN BEGIN 
         print,'dtcorr: pcuon=5 (default for pca_dt=1)'
       ENDIF 
     ENDIF
   ENDIF
   
;; calculate observational noise with deadtime influence for
;; the normalized psd for each channel (noinormpsd)

   noinormpsd=fltarr(n_elements(freq))

    IF (keyword_set(chatty)) THEN BEGIN 
        print,'######### dtcorr: Mean countrate       : '
        print,mean(rate)
    ENDIF 
    ;;
    ;;
    IF (keyword_set(zhang_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'dtcorr: Zhang deadtime correction is applied'
    ENDIF 
    IF (keyword_set(pca_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'dtcorr: PCA deadtime correction is applied'
    ENDIF 
    IF (keyword_set(hexte_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'dtcorr: HEXTE deadtime correction is applied'
    ENDIF 
    IF (keyword_set(poisson)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'dtcorr: Poisson noise correction is applied'
    ENDIF 
    ;;
    ;; 
    IF (keyword_set(zhang_dt)) THEN BEGIN 
      totrate=mean(rate)
      psdcorr,totrate,length,dseg, $
        cfreq,noinormpsd, $
        _extra=extra, $
        schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
        avgback=avg_bkg, $
        chatty=chatty
    ENDIF 
    ;;
    ;; 
    IF (keyword_set(pca_dt)) THEN BEGIN 
      pic=mean(rate)/float(pcuon)
      psdcorr_pca,length,dseg, $
        cfreq,noinormpsd, $
        pcurate=pic,_extra=extra, $
        schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
        avgrate=mean(rate),avgback=avg_bkg, $ 
        chatty=chatty
    ENDIF 
    ;;    
    ;;
    IF (keyword_set(hexte_dt)) THEN BEGIN 
      clus=mean(rate)
      psdcorr_hexte,length,dseg, $
        cfreq,noinormpsd,cluster_a=cluster_a,$
        clusterrate=clus,_extra=extra, cluster_b=cluster_b,$
        schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
        avgrate=mean(rate),avgback=avg_bkg, $
        chatty=chatty
    ENDIF 
    ;;
    ;;
    IF (keyword_set(poisson)) THEN BEGIN 
      psdcorr_poisson,length,dseg, $
        cfreq,noinormpsd, $
        schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
        avgrate=mean(rate),avgback=avg_bkg, $             
        unnormalized=unnormalized,chatty=chatty
    ENDIF 
    ;;
    ;;
    ;; correct PSD (normalized) with NOINORMPSD for observational noise
    ;; and deadtime
    psd=temporary(psd)-noinormpsd

END 






