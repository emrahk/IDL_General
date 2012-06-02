PRO pcadeadpsd,pcurate,vle,level,freq,corr
;+
; NAME:
;          pcadeadpsd
;
;
; PURPOSE:
;          compute deadtime correction for the PCA after
;          Jernigan, Klein, and Arons, 2000, Ap.J. 530, 875.
;
; CATEGORY: 
;          timing tools
;
;
;
; CALLING SEQUENCE: 
;          pcadeadpsd,pcurate,vle,level,freq,corr
;
;
;
; INPUTS:
;          pcurate: average deadtime-causing counting rate, PER PCU
;          vle    : average VLE rate, per PCU
;          level  : PCA VLE discriminator setting
;          freq   : frequencies for which the correction is to be computed
;
; OUTPUTS:
;          corr   : noise with Jernigan et al. PSD correction, 
;                   in LEAHY normalization!
;
; MODIFICATION HISTORY:
;          Version 1.2, 2000/12/22 Katja Pottschmidt, 
;                                  Doc header added and
;                                  discriminator levels 0 and 3 
;          Version 1.3, 2000/12/29 Katja Pottschmidt,
;                                  bug in both sinx/x expressions corrected
;                                  (deadtime variable had been missing)
;          Version 1.4, 2001/01/10 Katja Pottschmidt,   
;                                  the output is the corrected noise
;                                  now, not only the value to correct
;                                  the noise with,       
;                                  minor changes in the formulae
;                                  (i.e., !DPI instead of !PI)
;-
   
   IF (level EQ 0) THEN dt_vle=12D-6  ;; from RXTE cook book
   IF (level EQ 1) THEN dt_vle=61D-6  ;; measured (see Jernigan) 
   IF (level EQ 2) THEN dt_vle=142D-6 ;; measured (see Jernigan) 
   IF (level EQ 3) THEN dt_vle=500D-6 ;; from RXTE cook book
   
   IF (n_elements(dt_vle) EQ 0) THEN BEGIN 
       message,'VLE discriminator setting wrong.'
   END 
   
   dt_zha=1D-5
   
   f_vle=!DPI*freq
   f_zha=2*f_vle
   
   a=4*dt_zha*pcurate ;; approximation after Jernigan et al.
   b=2*pcurate*vle*dt_vle^2.
   
   corr_zha=a*sin(f_zha*dt_zha)/(f_zha*dt_zha)
   corr_vle=b*(sin(f_vle*dt_vle)/(f_vle*dt_vle))^2
   
   corr=2.-corr_zha+corr_vle
   
END








