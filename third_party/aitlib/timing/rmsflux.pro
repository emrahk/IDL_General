PRO rmsflux,time,rate,rms,errms, $
            nseg=nseg,dseg=dseg,avgback=avgback, $
            newfreq=newfreq,length=length, $
            meanflux=meanflux,chatty=chatty
;+
; NAME: 
;          rmsflux
;
;
; PURPOSE: 
;          To test the rms-flux correlation (according to Uttley, Ph. and
;          McHardy, I.M., MNRAS 2001, 323, L26-L30), rmsflux.pro
;          calculates the mean PSD and its error of a number of given
;          equally spaced lightcurve segments, that all contain a
;          mean flux within a given range (flux bins). The Miyamoto
;          normalization is used and the PSD is Poisson noise and
;          deadtime corrected. 
;
;
; FEATURES: 
;          rmsflux.pro can conveniently be called by cygx1_rmsflux.pro in
;          the case of Cyg X-1 (IAAT).
;          
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;          time         : one, usually the first, of the equally
;                         segmented time arrays of the lightcurve
;                         (needed to calculate the Fourier frequencies)
;          rate         : array, containing the rates of the chosen
;                         lightcurve segments, e.g.array(nseg,dseg)
;      
;   
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;          nseg         : number of lightcurve segments, out of which
;                         the mean PSD is to be calculated
;          dseg         : the number of time elements contained in a lightcurve
;                         segment. The time length of a lightcurve
;                         segment with time resolution bt (e.g. bt=2^(-8)
;                         s) is then calculated by: dseg * bt,
;                         cf. keyword length
;          avgback      : in the case of dim sources (NOT Cyg X-1!) it
;                         is recommended to use an average background.
;                         default: no background
;          newfreq      : array with the lower and upper limits of the
;                         chosen frequency range. Can contain only one
;                         frequency range or a whole bunch number of
;                         adjoining ranges, e.g. for
;                         [0.1,10.,32.,100.] the rms is calculated for
;                         three ranges.
;          length       : length of lc segment; length = dseg * bt
;          meanflux     : the average rate of the nseg lightcurve
;                         segments
;          chatty       : controls screen output ; 
;                         default: no output;  
;
;
; OUTPUTS:
;          rms          : in the Miyamoto normalization, the
;                         integrated PSD, i.e., the area under the PSD
;                         estimated by the periodogramm in a given
;                         frequency range, defines the square of the
;                         total rms variability, i.e. the fractional
;                         amount by which the lightcurve is
;                         sinusoidally modulated in the given
;                         frequency range. The given rms is the square
;                         root of the integrated PSD, mutiplied by the
;                         mean flux of the corresponding lightcurve segments.
;          errms        : error of rms, according to propagation of
;                         error. The error of the periodogramm is
;                         given by errnormpsd.
;
;   
; OPTIONAL OUTPUTS:
;
;
; COMMON BLOCKS:
;
;
; SIDE EFFECTS:
;
;
; RESTRICTIONS:
;
;
; PROCEDURES USED: 
;          fourierfreq.pro
;          fastftrans.pro
;          freqrebin.pro
;          psdnorm.pro
;          psdcorr_poisson.pro
;
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;          CVS Version 1.0, 2001/02/21  TG,JW (IAAT)
;
;
;-

 ;;
 ;; Default: no background
 IF (n_elements(avgback) EQ 0) THEN avgback=0.
  
  avgrate=mean(rate)
  meanflux=avgrate

;; calculate Fourier frequencies 
;; corresponding to the segment length
  
  startbin=0L                   ; startindex of first segment
  endbin=dseg-1L                ; endindex of first segment
  fourierfreq,time(startbin:endbin),freq

;; calculate psd for each segment (ppsd) and
;; average ppsd's over nseg individual segments,
;; obtaining the mean psd
  
  ppsd=fltarr(n_elements(freq))
  normpsd=fltarr(n_elements(freq))
  
  FOR seg=0,nseg-1 DO BEGIN 
    fastftrans,rate[seg,*],ddft
    ppsd(*)=ppsd(*)+abs(ddft)^2.
    ddft=0.
  ENDFOR 
  ppsd=ppsd/nseg    ;; mean psd

;; PSD, ERROR

;; average the mean psd over frequency range 'newfreq' 
;; and obtain freq-averaged psd and uncertainty errpsd
;;
;; PSD, ERRPSD
;;
  freqrebin,freq,ppsd,nu,rebpsd,errebpsd, $
    newfreq=newfreq,chatty=chatty
  psd=temporary(rebpsd)
;; calculate mean uncertainty errpsd
  errpsd=temporary(errebpsd)/sqrt(nseg)
  
;; normalize psd and errpsd to obtain
;; NORMPSD, ERRNORMPSD
;;
  pd=psd
  psdnorm,avgrate,length,dseg,pd, $
    /miyamoto,avgback=avgback,chatty=chatty
  normpsd=temporary(pd)
  errnormpsd=errpsd*normpsd(0)/psd(0)

;; NOISE
  
;; calculate observational noise with deadtime influence for
;; the normalized psd (noinormppsd)
  noinormppsd=fltarr(n_elements(freq))
  ;;
  ;; Poissondeadtime correction
  ;;
  psdcorr_poisson,length,dseg,freq,noinormpd, $
    avgrate=avgrate,avgback=avgback, $             
    /miyamoto,chatty=chatty
  noinormppsd=temporary(noinormpd)

;; average noise over frequency range 'newfreq'
;; to obtain NOINORMPSD
;;
  freqrebin,freq,noinormppsd,nu,rebnoinormpsd,errebnoinormpsd, $
    newfreq=newfreq,nof=nof,chatty=chatty       
  noinormpsd=temporary(rebnoinormpsd)
  
;; correct NORMPSD with NOINORMPSD for observational noise
;; and deadtime (SIGNORMPSD) 
  signormpsd=normpsd-noinormpsd
  
  rms=fltarr(n_elements(newfreq)-1)
  errms=fltarr(n_elements(newfreq)-1)
  
;; calculate the rms and the error of rms 
;; for each frequency segment of newfreq
;;
;; Propagation of errors
;; errnormpsd = error of PSD
;; errms = error of rms
;; rms = (PSD)^0.5  
;; errms = 0.5 * errnormpsd/PSD * rms 
;;
  FOR freqseg=0,n_elements(newfreq)-2 DO BEGIN 
    rms2=signormpsd[freqseg]*(newfreq[freqseg+1]-newfreq[freqseg])                         
    rms[freqseg]=sqrt(rms2) * avgrate
    IF FINITE(rms[freqseg],/nan) EQ 1 THEN rms[freqseg]=0.
    errms[freqseg]=0.5 * ERRNORMPSD[freqseg]/signormpsd[freqseg] * rms[freqseg]
  ENDFOR 

END 





























