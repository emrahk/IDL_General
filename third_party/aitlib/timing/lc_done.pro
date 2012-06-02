
PRO lc_done,time,rate,nt=nt,beta=beta,sigma=sigma,mean=mea, $
             seed=seed,dt=dt,fact=fact
;+
; NAME:
;          lc_done
;
;
; PURPOSE:
;          Simulate a light-curve with a power-law distributed
;          periodogram
;
;
; CATEGORY:
;          light curve simulation
;
;
; CALLING SEQUENCE:
;          lc_done,time,rate,nt=nt,beta=beta,sigma=sigma,mean=mea, $
;            seed=seed,dt=dt
;
;
; INPUTS:
;          -
;
;
; OPTIONAL INPUTS:
;          nt: Number of bins of the simulated lightcurve (default:65536)
;        beta: Power law index of the periodogram (default: 1.5)
;        mean: Mean count rate of the simulated lightcurve (default: 0.)
;       sigma: Standard deviation of the lightcurve to be simulated
;              (default:1.)
;        seed: Seed for the random number generator (returned if not
;              defined -- see IDL help for randomu function)
;        fact: Factor introduced by Merrifield & McHardy 1994, MNRS
;              271, 899 for the Fourier freq. array dimension to
;              explore the effects of the low-freq. component in the
;              PSD. They used fact = 10. If not set, then fact = 1.
;          dt: time resolution of the lightcurve 
;   
; KEYWORD PARAMETERS:
;           
; OUTPUTS:
;        time: Time array (trivial :-) )
;        rate: Array of countrates of length nt
;
;
; OPTIONAL OUTPUTS:
;        seed: see above
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        Version 1.0, 2002/01/10, Sara Benlloch, IAAT
;-

  ;; PL index of the PSD
  IF (n_elements(beta) EQ 0) THEN beta=1.5
  
  ;; Number of bins desired
  IF (n_elements(nt) EQ 0) THEN nt=65536L
  
  ;; Mean count rate of lc to be simulated (cps)
  IF (n_elements(mea) EQ 0) THEN mea=0.
   
  ;; Desired standard deviation of the lc
  IF (n_elements(sigma) EQ 0) THEN sigma=1.   
  
  ;; Time resolution of the lc
  IF (n_elements(dt) EQ 0) THEN dt=1.
  
  ;; Frequency array
  IF (n_elements(fact) EQ 0) THEN fact = 1.                  


  freq = (dindgen(fact*nt/2.)+1.)/(fact*dt*nt) ; Fourier frequencies 

  om = 2.D*!dpi*freq
    
  ;; red noise power spectrum ; S(f) = 1/f^beta
  spectrum = freq^(-beta)  
  
  ;; random distribution
  ph = ran2_normal(seed,dim=n_elements(freq))
  phase =  2.D*!dpi*ph

  ;;
  ;; time and rate array
  ;;
  time = dt*dindgen(nt)  
  rate = dblarr(nt)
  
  ;; Eq. B1 (p. 151) in Done et al. 1992, Apj 400, 138 
  fraq = (sin(om*dt/2.D) / (om*dt/2.D)) * sqrt(spectrum)
  FOR i=0L,nt-1 DO BEGIN 
    rate[i] = total( fraq  * cos(om*time[i] - phase) )
  ENDFOR

  ;;
  ;; Normalize to desired mean count rate and variance
  ;;
  avg=mean(rate)
  sig=sqrt(variance(rate))
  
  rate=(rate-avg)/sig*sigma+mea
END 


