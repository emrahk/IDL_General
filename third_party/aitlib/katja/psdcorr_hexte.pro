PRO psdcorr_hexte,inplength,inpdseg, $
                  freq,noipsd, $
                  clusterrate=clusterrate,xuld=xuld, $
                  cluster_a=cluster_a,cluster_b=cluster_b, $
                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                  avgrate=avgrate,avgback=avgback, $
                  unnormalized=unnormalized,chatty=chatty
;+
; NAME:
;          psdcorr_hexte
;
; PURPOSE:
;          calculates the observational noise of the FFT-psd that is
;          caused by HEXTE dead-time, based on the expertise of Emrah
;          Kalemci CASS UCSD
;
;          IMPORTANT NOTE: THIS IS AN UNPUBLISHED RESULT AND I DO NOT 
;          GUARANTEE THAT IT WORKS CORRECTLY FOR ALL HEXTE SOURCES.
;	   PLEASE CONTACT ME BEFORE USING, ESPECIALLY IF YOU INTEND TO PUBLISH 
;	   A PAPER. -->  Emrah Kalemci emrahk@mamacass.ucsd.edu
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          psdcorr_hexte,inplength,inpdseg, $
;                  freq,noipsd, $
;                  clusterrate=clusterrate,xuld=xuld, $
;                  cluster_a=cluster_a,cluster_b=cluster_b, $
;                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;                  avgrate=avgrate,avgback=avgback, $
;                  unnormalized=unnormalized,chatty=chatty          
;           
; INPUTS:
;          inplength : Length of the time interval used to compete individual
;	               PSD
;	   inpdseg   : segment length into which the lightcurve has been
;                      divided to compute the psd (averaged over all
;                      segments)
;	   freq       : Fourier frequency array for the PSD 
;        clusterrate  : Count rate per Cluster (assumes 4 detectors in A and
;			3 detectors in B.)
;
;             xuld    : XULD event rate which cause the major dead-time effects
;                       in HEXTE PSD   
;
;          avgrate    : average count rate of the LC used for
;                          computing the PSD
;          avgback    : average background count rate to be used in the
;		        correction of normalization
;                          
;
; OPTIONAL INPUTS:
;          none 
;	
; KEYWORD PARAMETERS: 
;
;          cluster_a   : deadtime correction for HEXTE psds for
;                           cluster A;
;                           hexte_dt=1 has to be set;
;                           default: cluster_a undefined;   
;          cluster_b   : deadtime correction for HEXTE psds for
;                           cluster B  
;                           hexte_dt=1 has to be set;
;                           default: cluster_b undefined;
;          schlittgen     : if set, return power in Schlittgen
;                           normalization  
;                           (Schlittgen, H.J., Streitberg, B., 1995,
;                           Zeitreihenanalyse, R. Oldenbourg)  
;          leahy          : if set, return power in Leahy normalization 
;                           (Leahy, D.A., et al. 1983, Ap.J., 266,160) 
;          miyamoto       : if set, return power in Miyamoto normalization
;
;          unnormalized   : if set, do not do the normalization
;
;          chatty         : controls screen output 
;                           default: no screen output;
;
; OUTPUTS:
;          noipsd : Normalized and deadtime corrected output PSD
;
; OPTIONAL OUTPUTS:
;          none
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
;
;          fourierfreq.pro
;          readxuld.pro
;          psdnorm.pro
;          hexdeadpsd.pro
;
; EXAMPLE:
;          psdcorr_hexte,inplength,inpdseg, $
;                  freq,noipsd, $
;                  clusterrate=100.,xuld=85., $
;                  cluster_a=1, $
;                  miyamoto=1, $
;                  avgrate=100.,avgback=30.
;
; MODIFICATION HISTORY:
;          Version 1.0 Emrah Kalemci CASS UCSD
;          2001/10/04  Emrah Kalemci: 
;                      deadtime correction for cluster B included
;          2001/11/08  Thomas Gleissner IAAT: 
;                      basic IDL header added                      
;                      calculation of sum changed
;                      control print of cluster_a/b added
;
;
;          2001/12/20  Emrah Kalemci CASS
;		       Cluster A / Cluster B control changed to make it work
;		       correctly with rxte_fourier.pro. (dtcorr.pro changed
;	               accordingly also...) IDL Header extended   
;
;          2002/01/07  Emrah Kalemci CASS
;		       Version 1.6  The bug on cluster control fixed..
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

na=keyword_set(cluster_a)
nb=keyword_set(cluster_b)
sum=na + nb
IF (sum EQ 0) THEN BEGIN
    cluster_a=1
    print,'no cluster keyword was set, using Cluster A as default'
ENDIF
IF (sum GE 2) THEN message,'psdcorr_hexte: Only one cluster can be specified'

IF keyword_set(cluster_a) THEN BEGIN     
    IF (keyword_set(chatty)) THEN BEGIN 
      print,'psdcorr_hexte: cluster_a=1 (default)'
    ENDIF 
    ;; average rate
    navg     = clusterrate/4.
    ;; high energy particle rate (magic number 85 is the average XULD rate
    ;; for the lightcurves I used for the fitting EK)
    xf=avg(xuld)/85.
    ;; calculate HEXTE deadtime correction in Leahy normalization
    hexdeadpsd,navg,xf,freq,corr   
ENDIF ELSE BEGIN 
    IF (keyword_set(chatty)) THEN BEGIN 
      print,'psdcorr_hexte: cluster_b=1'
    ENDIF 
    ;; average rate
    navg     = clusterrate/3.
    ;; high energy particle rate
    xf=avg(xuld)*0.9/85.
    ;; calculate HEXTE deadtime correction in Leahy normalization
    hexdeadpsd,navg,xf,freq,corr   
ENDELSE 
    
hpsd=2.+corr

;; normalization of the HEXTE  psd (hpsd is Leahy normalized)
noipsd=(hpsd*dseg*dseg*avgrate)/(2.*length)
IF (NOT keyword_set(unnormalized)) THEN BEGIN 
    psdnorm,avgrate,length,dseg,noipsd, $
      schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
      avgback=avgback,chatty=chatty
ENDIF


END



