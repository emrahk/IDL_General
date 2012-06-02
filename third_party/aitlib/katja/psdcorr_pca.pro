PRO psdcorr_pca,inplength,inpdseg, $
                freq,noipsd, $
                pcurate=pcurate,vle=vle,level=level, $    
                schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                avgrate=avgrate,avgback=avgback, $             
                unnormalized=unnormalized,chatty=chatty
;+
; NAME:
;          psdcorr_pca
;
;
; PURPOSE:
;          calculates the frequencies & observational noise of the FFT-psd,
;          the latter modified by detector dead-time, primarily based
;          on the paper by Jernigan, Klein, and Arons, 2000, Ap.J. 530, 875.
;          = RXTE/PCA specific dead-time correction
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          psdcorr_pca,inplength,inpdseg, $
;                freq,noipsd, $
;                pcurate=pcurate,vle=vle,level=level, $    
;                schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;                avgrate=avgrate,avgback=avgback, $             
;                unnormalized=unnormalized,chatty=chatty
;  
;
; INPUTS:
;          inplength : time length of the lightcurve segments for
;                      which the Fourier frequencies are calculated,
;                      to be given in seconds
;          inpdseg   : dimension of the lightcurve segments for which
;                      the Fourier frequencies are calculated,
;                      to be given in time bins
;          avgrate   : average count rate for psd normalization
;                      done by psdnorm.pro
;          pcurate   : average deadtime-causing counting rate, per PCU
;          vle       : average vle rate per PCU;
;
;
; OPTIONAL INPUTS:
;          level       : (average) PCA ``deadtime level'';
;                        determining the deadtime value;      
;                        default: level=1
;          avgback     : average background rate
;                        used for correcting the psd
;                        normalization in case of
;                        Miyamoto normalization 
;                        default: avg_bkg undefined 
;   
;
; KEYWORD PARAMETERS:
;          schlittgen     : if set, the corrected Fourier quantities
;                           are Schlittgen-normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          leahy          : if set, the corrected Fourier quantities
;                           are Leahy-normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          miyamoto       : if set, the corrected Fourier quantities
;                           are Miyamoto-normalized (=default)
;          unnormalized   : if set, the corrected Fourier quantities
;                           are not normalized
;                           (default: miyamoto=1: Miyamoto normalization) 
;          chatty         : controls screen output 
;                           (default: no screen output) 
;
;
;
; OUTPUTS:
;          freq   : Fourier frequency array
;          noipsd : array of observational noise of the psd,
;                   modified  by detector deadtime 
; 
;
; OPTIONAL OUTPUTS:
;          none  
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          setting of keyword defaults  
;
;
; RESTRICTIONS:
;          none
;
;
; PROCEDURES USED:
;
;          fourierfreq.pro
;          pcadeadpsd.pro
;          psdnorm.pro
;
;
; EXAMPLE:
;          see foucalc.pro, dtcorr.pro
;
;
; MODIFICATION HISTORY:
;          Version 1.0: 2000/12     Katja Pottschmidt IAAT
;                       2001/11/08  Thomas Gleissner IAAT,
;                                   set default for level
;                       2001/12/14  Thomas Gleissner,
;                                   delete superfluous test print-out
;          Version 1.6: 2001/12/21  Katja Pottschmidt,
;                                   idl header added
;          Version 1.7: 2001/12/21  Katja Pottschmidt,
;                                   minor change in header
; 
;
;-


IF (n_elements(level) EQ 0) THEN BEGIN
   level=1
   IF (keyword_set(chatty)) THEN BEGIN 
      print,'psdcorr_pca: level=1 (default)'
   ENDIF 
ENDIF

;; lightcurve parameters
dseg     = long(inpdseg)
length   = double(inplength)
bt       = double(length/dseg)
time     = double(bt*findgen(dseg))

;; Fourier frequency array
fourierfreq,time,freq
time=0.

;; calculate PCA deadtime correction in Leahy normalization
;;  (see Jernigan, Klein, and Arons, 2000, Ap.J. 530, 875)
pcadeadpsd,pcurate,vle,level,freq,hpsd

;; normalization of the PCA  psd (hpsd is Leahy normalized)
noipsd=(hpsd*dseg*dseg*avgrate)/(2.*length)
IF (NOT keyword_set(unnormalized)) THEN BEGIN 
    psdnorm,avgrate,length,dseg,noipsd, $
      schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
      avgback=avgback,chatty=chatty
ENDIF


END


