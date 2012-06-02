PRO rndpwrlc,time,rate,nt=nt,beta=beta,sigma=sigma,mean=mea, $
             seed=seed,dt=dt,randomu=randomu
;+
; NAME:
;          rndpwrlc
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
;          rndpwrlc,time,rate,nt=nt,beta=beta,sigma=sigma,mean=mea
;
;
; INPUTS:
;          -
;
;
; OPTIONAL INPUTS:
;          nt: Number of bins of the simulated lightcurve (default:65536)
;              Should be power of two for optimum performance (FFT...)
;        beta: Power law index of the periodogram (default: 1.5)
;        mean: Mean count rate of the simulated lightcurve (default: 0.)
;       sigma: Standard deviation of the lightcurve to be simulated
;              (default:1.)
;        seed: Seed for the random number generator (returned if not
;              defined -- see IDL help for randomu function)
;   
; KEYWORD PARAMETERS:
;        randomu: if set, the IDL random number generator is used. If
;                not set, ran2 (from aitlib) procedure is used. 
;           
; OUTPUTS:
;        time: Time array (trivial :-) )
;        rate: Array of countrates of length n
;
;
; OPTIONAL OUTPUTS:
;        seed: see above
;
; RESTRICTIONS:
;        There are rumors that the IDL random number generator is not
;        absolutely perfect -- in fact, we have seen this in our
;        simulations of deadtime noise. So the periodogram has not
;        perfectly independent bins. For high precision work use one
;        of the rngs implemented by Sara Benlloch, ran2_normal, and
;        part of aitlib. 
;
;
; PROCEDURE:
;        Simulation of the fourier transform of the light curve, and
;        inverse Fourier transform. See 
;        J. Timmer & M. Koenig, On generating power law noise, A&A,
;        300, 707-710, 1995
;        for details
;        RAN2_NORMAL (aitlib)   
;
; EXAMPLE:
;        rndpwrlc,ti,lc,mean=80.,sigma=10.,seed=seed
;        psd,ti,lc,freq,psd
;        plot,freq,psd,/xlog,/ylog
;
;
; MODIFICATION HISTORY:
;        Based on code by M. Koenig and J. Timmer, dated 1996 April 17
;        Version 1.0: J. Wilms, K. Pottschmidt, IAAT, 2000 October 26
;        Version 1.1; S. Benlloch, IAAT, 2000 November 28   
;                 keyword randomu added   
;                 ran2_normal implemented   
;        Version 1.2; S. Benlloch, IAAT, 2001 June
;                 corrected error in beta and treatment of fourier transform
;        Version 1.3; S. Benlloch, IAAT 2002 January
;                 corrected error by odd nt
;
; $Log: rndpwrlc.pro,v $
; Revision 1.6  2002/09/12 09:59:22  wilms
; added automatic CVS logging
;
;-
   
   ;; PL index of the PSD
   IF (n_elements(beta) EQ 0) THEN beta=1.5

   ;; Number of frequencies desired
   IF (n_elements(nt) EQ 0) THEN nt=65536L
   
   ;; Mean count rate of lc to be simulated (cps)
   IF (n_elements(mea) EQ 0) THEN mea=0.
   
   ;; Desired standard deviation of the lc
   IF (n_elements(sigma) EQ 0) THEN sigma=1.
   
   ;; Time resolution of the lc
   IF (n_elements(dt) EQ 0) THEN dt=1.
   
   ;;
   ;; Real and imaginary part of periodogram with chi^2 distribution
   ;; of 2 dof (=square of gaussian random dist)
   ;;
   
   fac = ((dindgen(nt/2)+1.)/(dt*nt))^(-(beta/2.)) ;; 1/T,...,1/dt

   IF keyword_set(randomu) THEN BEGIN 
       pos_real=randomu(seed,nt,/normal)*fac
       pos_imag=randomu(seed,nt,/normal)*fac
   ENDIF ELSE BEGIN 
       pos_real=ran2_normal(seed,dim=nt)*fac
       pos_imag=ran2_normal(seed,dim=nt)*fac
   ENDELSE 
   
   pos_imag[nt/2-1] = 0

   IF float(nt)/2. GT nt/2 THEN BEGIN 
     neg_real = (pos_real[0:(NT/2)-1])
     neg_imag = -(pos_imag[0:(NT/2)-1])
   ENDIF ELSE BEGIN 
     neg_real = (pos_real[0:(NT/2)-2])
     neg_imag = -(pos_imag[0:(NT/2)-2])
   ENDELSE 

   real = [0.,(pos_real),reverse(neg_real)]
   imag = [0.,(pos_imag),reverse(neg_imag)]

   ;; 
   ;; Simulate lc from its Fourier transform
   ;;
   rate = float(FFT(complex(real,imag),1))

   ;;
   ;; Normalize to desired mean count rate and variance
   ;;
   avg = mean(rate)
   sig = sqrt(variance(rate))

   time = dt*findgen(nt)
   rate = (rate-avg)/sig*sigma+mea
   
END 






