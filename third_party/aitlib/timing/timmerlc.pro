PRO timmerlc,time,rate,nt=nt,mean=mea,sigma=sigma, $
             seed=seed,dt=dt,randomu=randomu, $
             model=model,params=params,_extra=extra
;+
; NAME:
;          timmerlc
;
;
; PURPOSE:
;          Simulate a light-curve with a general periodogram shape
;
;
; CATEGORY:
;          light curve simulation
;
;
; CALLING SEQUENCE:
;         timmerlc,time,rate,nt=nt,mean=mea,sigma=sigma, $
;             seed=seed,dt=dt,randomu=randomu, $
;             model=model,params=params,_extra=extra
;
;
; INPUTS:
;          -
;
;
; OPTIONAL INPUTS:
;          dt: time resolution of the lightcurve to be simulated
;          nt: Number of bins of the simulated lightcurve (default:65536)
;              Should be power of two for optimum performance (FFT...)
;        mean: Mean count rate of the simulated lightcurve (default: 0.)
;       sigma: Standard deviation of the lightcurve to be simulated
;              (default:1.)
;        seed: Seed for the random number generator (returned if not
;              defined -- see IDL help for randomu function)
;       model: name of a function returning the desired PSD shape
;              using the calling convention of mpfitfun
;      params: parameters of the model (argument to model)

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
;        Based on Version 1.3 of rndpwrlc by S. Benlloch, IAAT, 
;             dated 2002 January
;
;        -- start of code development of code timmerlc
;        New version 2002 July-September: cleaned earlier code, now
;        any PSD shape is in principle possible.
; $Log: timmerlc.pro,v $
; Revision 1.1  2002/09/12 08:17:45  wilms
; initial release into aitlib
;
;
;-

   ;; Time resolution of the lc
   IF (n_elements(dt) EQ 0) THEN dt=1.

   ;; Number of frequencies desired
   IF (n_elements(nt) EQ 0) THEN nt=65536L
   
   ;; Mean count rate of lc to be simulated (cps)
   IF (n_elements(mea) EQ 0) THEN mea=0.

   ;; Variance to be simulated
   IF (n_elements(sigma) EQ 0) THEN sigma=1.
   
   ;; There is NO DEFAULT MODEL, so bail out if there are problems
   ;; (do not check whether params are given, as in principle a
   ;; model with no parameters at all could be possible
   IF (n_elements(model) EQ 0) THEN BEGIN 
       message,'Need a model-name to continue'
   ENDIF 

   ;;
   ;; Real and imaginary part of periodogram with chi^2 distribution
   ;; of 2 dof (=square of gaussian random dist)
   ;;
   
   ;; Frequencies at which PSD is to be computed
   ;; 1/T,...,1/dt
   simfreq= (dindgen(nt/2)+1. ) /(dt*nt)

   ;; Compute periodogram
   IF (n_elements(extra) NE 0) THEN BEGIN 
       simpsd=call_function(model,simfreq,params,_extra=extra)
   ENDIF ELSE BEGIN 
       simpsd=call_function(model,simfreq,params)
   ENDELSE 
   fac = sqrt(simpsd)

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
   time = dt*findgen(nt)
   rate = float(FFT(complex(real,imag),-1))

   std=stddev(rate)

   rate=rate*sigma/std + mea

END 

