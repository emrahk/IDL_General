PRO psdcorr_poisson,inplength,inpdseg, $
                freq,noipsd, $
                schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                avgrate=avgrate,avgback=avgback, $             
                unnormalized=unnormalized,chatty=chatty
;+
; NAME:
;          psdcorr_poisson
;
;
; PURPOSE: calculates the Poisson noise to be subtracted from the psd:
;          "... it can be assumed that the total measured
;          periodogram is the sum of the signal and the noise
;          powers Pj = Pj,signal + Pj,noise. If the noise contribution
;          Pj,noise were known therefore, it could be subtracted from
;          the measured periodogram to obtain the true signal
;          periodogram. Often it is assumed that the measurement
;          process is dominated by pure photon statistics, i.e. a
;          Poisson process. If this is the case, then Pj,noise = 2 in
;          the Leahy normalization." (Wilms, PhD thesis, 1998)
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          psdcorr_poisson,inplength,inpdseg, $
;                freq,noipsd, $
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
;
;
; OPTIONAL INPUTS:
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
;          noipsd : array of observational noise of the psd
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
;          psdnorm.pro
;
;
; EXAMPLE:
;          see foucalc.pro, dtcorr.pro
;
;
; MODIFICATION HISTORY:
;          Version 1.0: 2002/01/17  Thomas Gleissner IAAT
;          CVS Version 1.2 2002/03/06 TG
;                          Provide noipsd as an array of same length
;                          as frequency array. So far it was provided
;                          as a scalar.  
;          CVS Version 1.3 2002/03/06 TG
;                          Remove stupid test printout
;
;-

;; lightcurve parameters
dseg     = long(inpdseg)
length   = double(inplength)
bt       = double(length/dseg)
time     = double(bt*findgen(dseg))

;; Fourier frequency array
fourierfreq,time,freq
time=0.

;; Poisson noise correction in Leahy normalization
pois=2

;; normalization of the psd (pois is Leahy normalized)
noipsd=(pois*dseg*dseg*avgrate)/(2.*length)
noipsd=replicate(noipsd,n_elements(freq))
IF (NOT keyword_set(unnormalized)) THEN BEGIN 
    psdnorm,avgrate,length,dseg,noipsd, $
      schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
      avgback=avgback,chatty=chatty
ENDIF


END


