PRO colacal,freq, $
            cpd,noicpd, $
            sigspd,sighpd, $
            noispd,noihpd, $
            spd,hpd, $
            alln, $
            cof,errcof, $
            lag,errlag, $
            rawcof

;+
; NAME:
;          colacal
;
;
; PURPOSE: 
;          calculate the noise-corrected coherence and its
;          noise-corrected uncertainty, the non-noise-corrected
;          coherence, the time lags and their uncertainties (all
;          frequency dependent) from the input frequencies, cross
;          power density, cross power density noise, the two
;          associated power spectra (noise-corrected and
;          non-noise-corrected) and their noise
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          colacal,freq, $
;            cpd,noicpd, $
;            sigspd,sighpd, $
;            noispd,noihpd, $
;            spd,hpd, $
;            alln, $
;            cof,errcof, $
;            lag,errlag, $
;            rawcof
;
;
; INPUTS:
;          freq    : Fourier frequency array  
;          cpd     : corresponding cross power density array;
;          noicpd  : array giving the Poisson noise contribution to cpd; 
;                    "n" in first part of eq. 8 of Vaughan & Nowak, 1997, ApJ, 474, L43  
;                    (this is the approximation for high coherence and
;                    high powers calculated in foucalc.pro)  
;          sigspd  : array giving the first noise-corrected PSD
;                    (e.g., from soft spectral band)
;          sighpd  : array giving the second  noise-corrected PSD
;                    (e.g., from hard spectral band)
;          noispd  : array giving the Poisson noise contribution to first PSD
;          noihpd  : array giving the Poisson noise contribution to second PSD
;          spd     : array giving the first PSD (non-noise-corrected)
;          hpd     : array giving the second PSD (non-noise-corrected)
;          alln    : number of averaged segments x number of averaged
;                    frequencies that contribute to each bin
;                    ("independent samples") 
;
;
; OPTIONAL INPUTS:
;          none
;
;
; KEYWORD PARAMETERS:
;          none 
;
;
; OUTPUTS:
;          cof      : frequency dependent coherence function array,
;                     noise-corrected;
;                     see first part of eq. 8 of Vaughan & Nowak,
;                     1997, ApJ, 474, L43  
;          errcof   : array giving the noise-corrected one sigma uncertainty
;                     of the noise-corrected coherence function; 
;                     see second part of eq. 8 of Vaughan & Nowak,
;                     1997, ApJ, 474, L43
;          lag      : frequency dependent time lag array;
;                     see page 10 of Nowak, Vaughan, Wilms, Dove,
;                     Begelman, 1999, ApJ, 510, 874 
;          errlag   : array giving the one sigma uncertainty of the time lag; 
;                     see eq. 16 of Nowak, Vaughan, Wilms, Dove,
;                     Begelman, 1999, ApJ, 510, 874
;          rawcof   : frequency dependent coherence function array,
;                     non-noise-corrected;
;                     see eq. 2 of Vaughan & Nowak, 1997, ApJ, 474, L43
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
;          none
;
;
; RESTRICTIONS:
;          none  
;
;
; PROCEDURES USED:
;          none
;
;
; EXAMPLE:
;          see foucalc.pro
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/06/29 Katja Pottschmidt, 
;                                  atan definition range changed
;          Version 1.3, 2000/06/29 Katja Pottschmidt,
;                                  brackets corrected
;          Version 1.4, 2001/12/21 Katja Pottschmidt,
;                                  idl-header added,
;                                  not yet complete
;          Version 1.5, 2001/12/28 Katja Pottschmidt,
;                                  idl-header completed
;
;-

      
ccpd   = dcomplex(cpd)

sigcpd = abs(ccpd)^2D0-noicpd

cof    = sigcpd/(sigspd*sighpd)

rawcof = (sigcpd+noicpd)/(spd*hpd)

dcof   = ((1D0-cof)/sqrt(abs(cof)))*sqrt(2D0/alln)

errcof = alln*((dcof/cof)^2D0+2D0*(noicpd/sigcpd)^2D0)
errcof = temporary(errcof)+(noispd/sigspd)^2D0+(noihpd/sighpd)^2D0
errcof = sqrt(temporary(errcof)/alln)

;lag    = atan((imaginary(ccpd)/float(ccpd)),1.)/(2D0*!dpi*freq)
lag    = (atan(imaginary(ccpd),float(ccpd)))/(2D0*!dpi*freq)

;dlag   = abs(ccpd)^2D0/(spd*hpd)
errlag = (1D0-rawcof)/(2D0*rawcof)
errlag = sqrt(temporary(errlag)/alln)/(2D0*!dpi*freq)

   
END 



















