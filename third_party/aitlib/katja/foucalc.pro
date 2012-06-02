PRO foucalc,time,rate,foupath, $
            dseg=inpdseg, $
            normindiv=normindiv, $
            schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $ 
            avg_bkg=avg_bkg, $
            linf=linf,logf=logf,nof=nof, $
            zhang_dt=zhang_dt, $
            ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $
            pca_dt=pca_dt, $
            pcuon=pcuon,vle=vle,level=level, $
            hexte_dt=hexte_dt, $
            xuld=xuld,cluster_a=cluster_a,cluster_b=cluster_b, $
            fmin=fmin,fmax=fmax, $
            obsid=obsid,username=username,date=date, $
            history=inphistory,chatty=chatty
;+
; NAME:
;          foucalc
;
;
; PURPOSE:
;          calculate and save Fourier quantities, their uncertainties, and
;          noise corrections from segmented, evenly spaced, 
;          multidimensional lightcurve arrays   
;
;
; FEATURES:
;          for a given segmented, evenly spaced, multidimensional (i.e.,
;          containing more than one energy band) lightcurve array
;          ``rate'' and the corresponding time array ``time'' several
;          multidimensional Fourier quantities and their uncertainties
;          are calculated:     
;          --- e.g., the normalized 
;                        (see keywords tagged ``kw1'', in case of
;                        Miyamoto normalization an additional
;                        background correction is possible), 
;                    noise and deadtime 
;                        (``kw3'', note that there is an instrument
;                        independent deadtime correction, a PCA and a
;                        HEXTE deadtime correction available, also
;                        note that the deadtime correction code cannot
;                        be switched off altogether) 
;                    corrected POWER SPECTRA; 
;                    the noise corrected COHERENCE FUNCTIONS; 
;                    and the TIME LAG SPECTRA
;          --- ;   
;          the rms value for each psd is calculated (``kw4'') if
;          Miyamoto normalization is specified;
;          the segment length ``dseg'' of the input lightcurves
;          has to be given in time bins; the Fourier quantities are
;          rebinned (``kw2''): logarithmic or linear or no rebinning can be
;          chosen; the output xdr Fourier quantities (containing a
;          history string array (``kw5'')) are stored in files with
;          names and locations that are derived from the input string
;          ``foupath'' (see RESTRICTIONS and SIDE EFFECTS)    
;                
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          foucalc,time,rate,foupath, $
;                  dseg=inpdseg, $
;                  normindiv=normindiv, $
;                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $ 
;                  avg_bkg=avg_bkg, $
;                  linf=linf,logf=logf,nof=nof, $
;                  zhang_dt=zhang_dt, $
;                  ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $
;                  pca_dt=pca_dt, $
;                  pcuon=pcuon,vle=vle,level=level, $
;                  hexte_dt=hexte_dt, $
;                  xuld=xuld,cluster_a=cluster_a,cluster_b=cluster_b, $
;                  fmin=fmin,fmax=fmax, $
;                  obsid=obsid,username=username,date=date, $
;                  history=inphistory,chatty=chatty   
;
;
; INPUTS:
;          time    : time array of the input lightcurve;
;                    has to be segmented and evenly spaced   
;          rate    : multidimensional rate array of the input
;                    lightcurve;   
;          foupath : string containing the path to a directory
;                    where the xdr output files containing the
;                    resulting multidimensional Fourier quantities are
;                    to be stored; rxte_fourier.pro also provides part
;                    of the output filenames via foupath  
;   
; 
; OPTIONAL INPUTS:
;          see KEYWORD PARAMETERS
;
;
; KEYWORD PARAMETERS:
;   
;              dseg           : dimension of the lightcurve segments
;                               for wich the Fourier frequencies and
;                               the individual transforms are
;                               calculated   
;   
;       -- for the PSD norm (kw1)
;              normindiv      : if set, average after normalizing
;                               individual psds;
;                               default: normindiv=0: average raw
;                               psds, then normalize using the count
;                               rate of the total lightcurve      
;              schlittgen     : if set, return power in Schlittgen
;                               normalization (Schlittgen, H.J.,
;                               Streitberg, B., 1995,
;                               Zeitreihenanalyse, R. Oldenbourg)
;              leahy          : if set, return power in Leahy normalization 
;                               (Leahy, D.A., et al. 1983, Ap.J.,
;                               266,160)
;              miyamoto       : if set, return power in Miyamoto normalization
;                               (Miyamoto, S., et al. 1991, Ap.J., 383, 784); 
;                               default:
;                               schlittgen undefined, leahy undefined,
;                               miyamoto=1:
;                               Miyamoto normalization 
;              avg_bkg      :   array containing the average 
;                               background rate for each energy band;
;                               used for correcting the psd
;                               normalization in case of
;                               Miyamoto normalization 
;                               default: avg_bkg undefined 
;   
;       -- for the frequency rebinning (kw2)
;              linf           : parameter giving the number of
;                               frequency bins for linear frequency
;                               rebinning
;                               default: see below   
;              logf           : parameter giving df/f for logarithmic
;                               frequency rebinning;
;                               default: see below   
;              nof            : if set, the non-frequency-rebinned
;                               Fourier quantities are saved;
;                               default: linf undefined, logf=0.15,
;                                        nof undefined 
;
;       -- for the deadtime correction of the psds (kw3)
;              zhang_dt       : instrument independent deadtime
;                               correction
;                               (after: Zhang, Jahoda, Swank, et al.,
;                               1995, Ap. J. 449, 930); 
;                               default: see below  
;              ninstr         : number of instruments that
;                               accumulated the lightcurves;
;                               zhang_dt=1 has to be set;
;                               default: ninstr is undefined;   
;                                        if zhang_dt=1 then  
;                                        ninstr=5 is the default
;              deadtime       : parameter giving the instrument
;                               deadtime in the same units as the time
;                               array of the lighcurves [sec];
;                               zhang_dt=1 has to be set;   
;                               default: deadtime is undefined; 
;                                        if zhang_dt=1 then 
;                                        deadtime=1D-5 is the default   
;              nonparalyzable : keyword defining the type of Zhang
;                               deadtime correction that is performed;
;                               if set, a correction for
;                               nonparalyzable deadtime is performed; 
;                               zhang_dt=1 has to be set;   
;                               default: nonparalyzable is undefined;
;                                        if zhang_dt=1 then
;                                        nonparalyzable=0 is the
;                                        default, i.e.: 
;                                        a correction for paralyzable
;                                        deadtime is performed
;              pca_dt         : deadtime correction for PCA psds
;                               (after: Jernigan, Klein, and Arons,
;                               2000, Ap. J. 530, 875);
;                               default: see below   
;              pcuon          : number of PCUs that is turned on;
;                               pca_dt=1 has to be set;    
;                               default: pcuon undefined;
;                                        if pca_dt=1 then 
;                                        pcuon=5 is the default     
;              vle            : average vle rate per PCU;
;                               pca_dt=1 has to be set;    
;                               default: vle undefined;
;                                        if pca_dt=1 then 
;                                        vle=100. is the default    
;              level          : (average) PCA ``deadtime level'';
;                               determining the deadtime value;      
;                               pca_dt=1 has to be set;    
;                               default: level undefined;
;                                        if pca_dt=1 then 
;                                        level=1 is the default
;              hexte_dt       : deadtime correction for HEXTE psds
;                               (after: Kalemci, 2000, priv. comm);
;                               default: see below 
;              xuld           : xuld rates for one cluster;
;                               hexte_dt=1 has to be set;    
;                               default: xuld undefined;
;                                        if hexte_dt=1 then 
;                                        xuld=[100.,100.] is the default    
;              cluster_a      : deadtime correction for HEXTE psds for
;                               cluster A;
;                               hexte_dt=1 has to be set WHY?;
;                               default: cluster_a undefined;   
;              cluster_b      : deadtime correction for HEXTE psds for
;                               cluster B;
;                               default: cluster_b undefined
;                                           
;              only one of the  keywords zhang_dt/pca_dt/hexte_dt can
;              be set;  
;              default: zhang_dt=1, pca_dt undefined, hexte_dt undefined   
;
;       -- for the determination of the rms for each psd (kw4)    
;              fmin           : minimum frequency in Hz;
;                               default (set in rmscal.pro): fmin=min(freq)  
;              fmax           : maximum frequency in Hz;
;                               default (set in rmscal.pro): fmax=max(freq)    
;   
;       -- for the history (kw5) 
;              obsid          : string giving the name of the observation;
;                               inserted in the history string array;
;                               default: 'Keyword obsid has not been set
;                                        (foucalc)'  
;              username       : string giving the name of the user; 
;                               inserted in the history string array;   
;                               default: 'Keyword username has not been set
;                                        (foucalc)'  
;              date           : string giving the production date of
;                               the Fourier quantities;
;                               inserted in the history string array;   
;                               default: 'Keyword date has not been set
;                                        (foucalc)'
;              history        : string array that is added to the
;                               history string array produced by
;                               foucalc itself; the final history
;                               string array is added to each output
;                               file; 
;                               default: history undefined   
;   
;       -- for the screen output
;              chatty         : controls screen output; 
;                               default: screen output;  
;                               to turn off screen output, set
;                               chatty=0       
;
; OUTPUTS:
;          none, but: see side effects  
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
;          the resulting Fourier quantities are written to
;          the directory specified by <foupath> 
;          in xdr format under the following file names: 
;   
;          (``_corr'' is added to the filenames of normalized psd
;          quantities when the miyamoto/avg_bkg has been set;
;          the .txt files are ASCII; 
;          the <dim[*]> part of the names is part of <foupath> as
;          delivered by rxte_fourier;
;          for nof undefined (default) only the ``*_rebin_*'' files
;          are saved) 
;   
;          <dim[*]>_cof.xdrfu               : coherence function, 
;                                             noise subtracted   
;          <dim[*]>_errcof.xdrfu            : uncertainty of coherence function
;          <dim[*]>_errlag.xdrfu            : uncertainty of lag spectrum 
;          <dim[*]>_errnormpsd(_corr).xdrfu : uncertainty of normalized, 
;                                             not noise subtracted power spectrum 
;          <dim[*]>_errpsd.xdrfu            : uncertainty of unnormalized, 
;                                             not noise subtracted power spectrum
;          <dim[*]>_foinormpsd(_corr).xdrfu : effective noise level
; 					      of normalized power spectrum   
;          <dim[*]>_imagcpd.xdrfu           : imaginary part 
;                                             of cross power density 
;          <dim[*]>_lag.xdrfu               : lag spectrum, 
;                                             not noise subtracted
;          <dim[*]>_noicpd.xdrfu            : noise of cross power density
;          <dim[*]>_noinormpsd(_corr).xdrfu : noise of normalized power spectrum 
;          <dim[*]>_noipsd.xdrfu            : noise of unnormalized power spectrum 
;          <dim[*]>_normpsd(_corr).xdrfu    : normalized, not noise
;                                             subtracted power spectrum
;          <dim[*]>_psd.xdrfu               : unnormalized, not noise
;                                             subtracted power spectrum  
;          <dim[*]>_rawcof.xdrfu            : coherence function, 
;                                             not noise subtracted
;          <dim[*]>_realcpd.xdrfu           : real part 
;                                             of cross power density
;          <dim[*]>_rms(_corr).txt          : root mean square of normalized,
;                                             noise subtracted power spectrum   
;          <dim[*]>_signormpsd(_corr).xdrfu : normalized, noise
;                                             subtracted power spectrum
;          <dim[*]>_sigpsd.xdrfu            : unnormalized, noise
;                                             subtracted power spectrum
;   
;          <dim[*]>_rebin_cof.xdrfu               : see above, frequency rebinned
;          <dim[*]>_rebin_errcof.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_errlag.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_errnormpsd(_corr).xdrfu : see above, frequency rebinned
;          <dim[*]>_rebin_errpsd.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_foinormpsd(_corr).xdrfu : see above, frequency rebinned
;          <dim[*]>_rebin_imagcpd.xdrfu           : see above, frequency rebinned
;          <dim[*]>_rebin_lag.xdrfu               : see above, frequency rebinned 
;          <dim[*]>_rebin_noicpd.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_noinormpsd(_corr).xdrfu : see above, frequency rebinned
;          <dim[*]>_rebin_noipsd.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_normpsd(_corr).xdrfu    : see above, frequency rebinned
;          <dim[*]>_rebin_psd.xdrfu               : see above, frequency rebinned
;          <dim[*]>_rebin_rawcof.xdrfu            : see above, frequency rebinned
;          <dim[*]>_rebin_realcpd.xdrfu           : see above, frequency rebinned
;          <dim[*]>_rebin_rms(_corr).txt          : see above, frequency rebinned 
;          <dim[*]>_rebin_signormpsd(_corr).xdrfu : see above, frequency rebinned
;          <dim[*]>_rebin_sigpsd.xdrfu            : see above, frequency rebinned 
;
;
; RESTRICTIONS:
;          the input lightcurves have to be segmented,
;          evenly spaced and multidimensional; 
;          the path/directories defined by <foupath> must exist for
;          saving the results   
;
;
; PROCEDURES USED:
;   
;          fourierfreq.pro
;          fastftrans.pro
;          psdnorm.pro
;          freqrebin.pro
;          psdcorr.pro
;          psdcorr_pca.pro
;          psdcorr_hexte.pro   
;          xdrfu_w1.pro
;          xdrfu_w2.pro
;          rmscal.pro
;          colacal.pro
;
;
;
; EXAMPLE:
;          see rxte_fourier.pro for several examples 
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.6, 2000/12/13 Katja Pottschmidt,   
;                                  IDL header added,
;                                  history string array updated 
;                                  (for avg_bkg and deadtime keywords);   
;                                  keyword default values defined/changed,   
;                                  IDL and cvs version numbers
;                                  synchronized    
;          Version 1.7, 2000/12/13 Katja Pottschmidt,    
;                                  header: description of foupath
;                                  corrected  
;          Version 1.8/9, 2000/12/15 Katja Pottschmidt,    
;                                  several bugs in the keyword
;                                  defaults + minor ones corrected
;          Version 1.10, 2000/12/15 Katja Pottschmidt,   
;                                  changed basic history string
;                                  concerning the xuld rate: only the
;                                  average of the xuld rate is listed;
;          Version 1.11, 2000/12/15 Katja Pottschmidt,   
;                                  corrected first call of psdcorr_hexte
;                                  and psdcorr_pca (added avgrate) 
;          Version 1.12, 2000/12/22 KP,
;                                  corrected small bug in default vle
;                                  setting.
;          Version 1.13, 2000/12/22 EK, stop removed   
;          Version 1.14, 2000/12/28 KP,
;                                  corrected history definition for
;                                  keyword pcurate,   
;                                  if desired (chatty=1), the mean
;                                  rates for each energy band are
;                                  printed to the screen  
;          Version 1.15, 2001/01/08 KP, 
;                                  another stop removed (in pca_dt loop) 
;          Version 1.16, 2001/01/10 KP,            
;                                  keywords pcurate and clusterrate
;                                  have been removed, in the deadtime
;                                  correction programs the average
;                                  lightcurve rates per energy range
;                                  and detector are used, keyword
;                                  pcuon has been added 
;          Version 1.17, 2001/08/08 Thomas Gleissner, IAAT,            
;                                  block corrected, where is calculated
;                                  psd for each segment and each
;                                  channel: avgback=avg_bkg[chan] was
;                                  set wrong.
;                                  IF-loop for normppsd added.
;
;	   Version 1.18, 2001/10/04 Emrah Kalemci
;				   Dead-time correction for HEXTE Cluster B
;				   is added/
;
;-
   
;;   
;; set default values
;; default values for fmin and fmax, see rmscal.pro   
;;
;; segment length
;;   
IF (NOT keyword_set(inpdseg)) THEN message,'foucalc: dseg keyword has to be set' 
;;   
;; psd normalization and background keywords   
;;   
IF (n_elements(normindiv) EQ 0) THEN normindiv=0   
nsch = n_elements(schlittgen)
nlea = n_elements(leahy)
nmiy = n_elements(miyamoto)
IF ((nsch+nlea+nmiy) GT 1) THEN BEGIN  
    message,'foucalc: Only one normalization keyword can be set' 
ENDIF
IF ((nsch+nlea+nmiy) EQ 0) THEN miyamoto=1   
IF (keyword_set(avg_bkg)) THEN BEGIN
    IF (NOT keyword_set(miyamoto)) THEN BEGIN 
        message,'foucalc: Background correction can only be performed for Miyamoto normalization'
    ENDIF 
ENDIF 
;;    
;; frequency rebin keywords
;;
nlin = n_elements(linf)
nlog = n_elements(logf)
nnof = n_elements(nof) 
IF ((nlin+nlog+nnof) GT 1) THEN BEGIN
    message,'foucalc: Only one way of rebinning is allowed'
ENDIF
IF ((nlin+nlog+nnof) EQ 0) THEN logf=0.15
;;
;; deadtime correction keywords
;;
nzha = n_elements(zhang_dt)
npca = n_elements(pca_dt)
nhex = n_elements(hexte_dt)
IF ((nzha+npca+nhex) GT 1) THEN BEGIN  
    message,'foucalc: Only one deadtime-type-keyword can be set' 
ENDIF
IF ((nzha+npca+nhex) EQ 0) THEN zhang_dt=1 
IF (keyword_set(zhang_dt)) THEN BEGIN 
    IF (n_elements(ninstr) EQ 0) THEN BEGIN 
        ninstr=5       
        print,'foucalc: ninstr=5 (default for zhang_dt=1)'
    ENDIF 
    IF (n_elements(deadtime) EQ 0) THEN BEGIN 
        deadtime=1D-5
        print,'foucalc: deadtime=1D-5 (default for zhang_dt=1)'
    ENDIF  
    IF (n_elements(nonparalyzable) EQ 0) THEN BEGIN 
        nonparalyzable=0
        print,'foucalc: nonparalyzable=0 (default for zhang_dt=1)'
    ENDIF 
ENDIF ELSE BEGIN 
    IF (keyword_set(ninstr)) THEN BEGIN 
        message,'foucalc: ninstr keyword cannot be set without zhang_dt=1'     
    ENDIF 
    IF (keyword_set(deadtime)) THEN BEGIN  
        message,'foucalc: deadtime keyword cannot be set without zhang_dt=1'
    ENDIF 
    IF  (keyword_set(nonparalyzable)) THEN BEGIN 
        message,'foucalc: nonparalyzable keyword cannot be set without zhang_dt=1' 
    ENDIF 
ENDELSE  
IF (keyword_set(hexte_dt)) THEN BEGIN
    IF (n_elements(xuld) EQ 0) THEN BEGIN
        xuld=[100.,100.]
        print,'foucalc: xuld=[100.,100.] (default for hexte_dt=1)'
    ENDIF 
ENDIF ELSE BEGIN
    IF (keyword_set(xuld)) THEN BEGIN 
        message,'foucalc: xuld keyword cannot be set without hexte_dt=1'
    ENDIF
    IF (keyword_set(cluster_a)) THEN BEGIN 
        message,'foucalc: cluster_a keyword cannot be set without hexte_dt=1'
    ENDIF
    IF (keyword_set(cluster_b)) THEN BEGIN 
        message,'foucalc: cluster_b keyword cannot be set without hexte_dt=1'
    ENDIF
ENDELSE 
IF (keyword_set(pca_dt)) THEN BEGIN
    IF (n_elements(pcuon) EQ 0) THEN BEGIN
        pcuon=5
        print,'foucalc: pcuon=5 (default for pca_dt=1)'
    ENDIF
    IF (n_elements(level) EQ 0) THEN BEGIN
        level=1
        print,'foucalc: level=1 (default for pca_dt=1)'
    ENDIF
    IF (n_elements(vle) EQ 0) THEN BEGIN
        vle=100.
        print,'foucalc: vle=100. (default for pca_dt=1)'
    ENDIF
ENDIF ELSE BEGIN
    IF (keyword_set(pcuon)) THEN BEGIN 
        message,'foucalc: pcuon keyword cannot be set without pca_dt=1'
    ENDIF
    IF (keyword_set(level)) THEN BEGIN 
        message,'foucalc: level keyword cannot be set without pca_dt=1'
    ENDIF
    IF (keyword_set(vle)) THEN BEGIN 
        message,'foucalc: vle keyword cannot be set without pca_dt=1'
    ENDIF
ENDELSE 
;;
;; history keywords
;;
IF (n_elements(obsid) EQ 0) THEN BEGIN 
    obsid='Keyword obsid has not been set (foucalc)'
ENDIF 
IF (n_elements(username) EQ 0) THEN BEGIN 
    username='Keyword username has not been set (foucalc)' 
ENDIF     
IF (n_elements(date) EQ 0) THEN BEGIN
    date='Keyword date has not been set (foucalc)'
ENDIF              
;;
;;
IF (n_elements(chatty) EQ 0) THEN chatty=1


;; helpful parameters   
dseg=long(inpdseg)                    ; dimension of segments, long
nch=n_elements(rate(0,*))             ; number of channels, long
nt=n_elements(time)                   ; dimension of lc, long
nus=long(nt/dseg)                     ; number of segments 
                                      ; with dimension dseg, long
bt=time(1)-time(0)                    ; bintime of lc
startbin=0L                           ; startindex of first segment
endbin=dseg-1L                        ; endindex of first segment
length=time(endbin)-time(startbin)+bt ; length of lc  
     
   
;; define history
nlchist=n_elements(inphistory)   
normname='not normalized'
IF (n_elements(schlittgen) NE 0) THEN normname='schlittgen'
IF (n_elements(leahy) NE 0) THEN normname='leahy'
IF (n_elements(miyamoto) NE 0) THEN normname='miyamoto'
;;
;; basic_history
;;
basic_history=strarr(nlchist+20)
nbasic=n_elements(basic_history)
basic_history(0)='Dimension of history (foucalc)='+string(nbasic)
IF (nlchist NE 0) THEN BEGIN 
    basic_history(1:nlchist)=inphistory
ENDIF
basic_history(nbasic-19)='Dimension of segments (foucalc)='+string(dseg)
basic_history(nbasic-18)='Number of segments (foucalc)='+string(nus)
;;
;;
IF (n_elements(linf) NE 0) THEN BEGIN 
    basic_history(nbasic-17)='Keyword linf (foucalc)='+string(linf)
ENDIF ELSE BEGIN 
    basic_history(nbasic-17)='Keyword linf has not been set (foucalc)'
ENDELSE 
IF (n_elements(logf) NE 0) THEN BEGIN 
    basic_history(nbasic-16)='Keyword logf (foucalc)='+string(logf)
ENDIF ELSE BEGIN 
    basic_history(nbasic-16)='Keyword logf has not been set (foucalc)'
ENDELSE 
IF (n_elements(nof) NE 0) THEN BEGIN     
    basic_history(nbasic-15)='Keyword nof (foucalc)='+string(nof)
ENDIF ELSE BEGIN 
    basic_history(nbasic-15)='Keyword nof has not been set (foucalc)' 
ENDELSE 
;;
;;
IF (n_elements(zhang_dt) NE 0) THEN BEGIN    
    basic_history(nbasic-14)='Keyword zhang_dt (foucalc)='+string(zhang_dt)
ENDIF ELSE BEGIN 
    basic_history(nbasic-14)='Keyword zhang_dt has not been set (foucalc)'
ENDELSE 
IF (n_elements(ninstr) NE 0) THEN BEGIN    
    basic_history(nbasic-13)='Keyword ninstr (foucalc)='+string(ninstr)
ENDIF ELSE BEGIN 
    basic_history(nbasic-13)='Keyword ninstr has not been set (foucalc)'
ENDELSE 
IF (n_elements(deadtime) NE 0) THEN BEGIN    
    basic_history(nbasic-12)='Keyword deadtime (foucalc)='+string(deadtime)
ENDIF ELSE BEGIN 
    basic_history(nbasic-12)='Keyword deadtime has not been set (foucalc)'
ENDELSE 
IF (n_elements(nonparalyzable) NE 0) THEN BEGIN    
    basic_history(nbasic-11)='Keyword nonparalyzable (foucalc)='+ $
      string(nonparalyzable)
ENDIF ELSE BEGIN 
    basic_history(nbasic-11)='Keyword nonparalyzable has not been set (foucalc)'
ENDELSE 
;;
;;
IF (n_elements(pca_dt) NE 0) THEN BEGIN    
    basic_history(nbasic-10)='Keyword pca_dt (foucalc)='+string(pca_dt)
ENDIF ELSE BEGIN 
    basic_history(nbasic-10)='Keyword pca_dt has not been set (foucalc)'
ENDELSE 
IF (n_elements(pcurate) NE 0) THEN BEGIN    
    basic_history(nbasic-9)='Keyword pcuon (foucalc)='+string(pcurate)
ENDIF ELSE BEGIN 
    basic_history(nbasic-9)='Keyword pcuon has not been set (foucalc)'
ENDELSE 
IF (n_elements(vle) NE 0) THEN BEGIN    
    basic_history(nbasic-8)='Keyword vle (foucalc)='+string(vle)
ENDIF ELSE BEGIN 
    basic_history(nbasic-8)='Keyword vle has not been set (foucalc)'
ENDELSE 
IF (n_elements(level) NE 0) THEN BEGIN    
    basic_history(nbasic-7)='Keyword level (foucalc)='+string(level)
ENDIF ELSE BEGIN 
    basic_history(nbasic-7)='Keyword level has not been set (foucalc)'
ENDELSE 
;;
;;
IF (n_elements(hexte_dt) NE 0) THEN BEGIN    
    basic_history(nbasic-6)='Keyword hexte_dt (foucalc)='+string(hexte_dt)
ENDIF ELSE BEGIN 
    basic_history(nbasic-6)='Keyword hexte_dt has not been set (foucalc)'
ENDELSE 
IF (n_elements(xuld) NE 0) THEN BEGIN    
    basic_history(nbasic-5)='Average value of keyword xuld (foucalc)='+string(avg(xuld))
ENDIF ELSE BEGIN 
    basic_history(nbasic-5)='Keyword xuld has not been set (foucalc)'
ENDELSE
;;
;;
IF (n_elements(obsid) NE 0) THEN BEGIN     
    basic_history(nbasic-4)='Keyword obsid (foucalc)='+obsid
ENDIF ELSE BEGIN 
    basic_history(nbasic-4)='Keyword obsid has not been set (foucalc)'
ENDELSE 
IF (n_elements(username) NE 0) THEN BEGIN    
    basic_history(nbasic-3)='Keyword username (foucalc)='+username
ENDIF ELSE BEGIN 
    basic_history(nbasic-3)='Keyword username has not been set (foucalc)'
ENDELSE 
IF (n_elements(date) NE 0) THEN BEGIN    
    basic_history(nbasic-2)='Keyword date (foucalc)='+date
ENDIF ELSE BEGIN 
    basic_history(nbasic-2)='Keyword date has not been set (foucalc)'
ENDELSE     
basic_history(nbasic-1)='Quantity is not normalized (foucalc)'
;;   
;; norm_history
;;
norm_history=[basic_history(0:nbasic-2),'Normalization (foucalc)='+normname]
IF (n_elements(avg_bkg) NE 0) THEN BEGIN
    norm_history=[norm_history,'Keyword avg_bkg (foucalc)='+string(avg_bkg)]
ENDIF ELSE BEGIN
    norm_history=[norm_history,'Keyword avg_bkg has not been set']
ENDELSE 


;; output filenames
fi_normpsd    = foupath+'_normpsd.xdrfu'
fi_noinormpsd = foupath+'_noinormpsd.xdrfu'
fi_foinormpsd = foupath+'_foinormpsd.xdrfu'
fi_signormpsd = foupath+'_signormpsd.xdrfu'
fi_errnormpsd = foupath+'_errnormpsd.xdrfu'
fi_psd        = foupath+'_psd.xdrfu'
fi_noipsd     = foupath+'_noipsd.xdrfu'
fi_sigpsd     = foupath+'_sigpsd.xdrfu'
fi_errpsd     = foupath+'_errpsd.xdrfu'
fi_realcpd    = foupath+'_realcpd.xdrfu'
fi_imagcpd    = foupath+'_imagcpd.xdrfu'
fi_noicpd     = foupath+'_noicpd.xdrfu'
fi_cof        = foupath+'_cof.xdrfu'
fi_errcof     = foupath+'_errcof.xdrfu'
fi_lag        = foupath+'_lag.xdrfu'
fi_errlag     = foupath+'_errlag.xdrfu'
fi_rawcof     = foupath+'_rawcof.xdrfu'
fi_rms        = foupath+'_rms.txt'
   

;; file names for background corrected power spectra
IF keyword_set(avg_bkg) AND (keyword_set(miyamoto)) THEN BEGIN
    fi_normpsd    = foupath+'_normpsd_corr.xdrfu'
    fi_noinormpsd = foupath+'_noinormpsd_corr.xdrfu'
    fi_foinormpsd = foupath+'_foinormpsd_corr.xdrfu'
    fi_signormpsd = foupath+'_signormpsd_corr.xdrfu'
    fi_errnormpsd = foupath+'_errnormpsd_corr.xdrfu'
    fi_rms        = foupath+'_rms_corr.txt'    
ENDIF    
    

;; calculate Fourier frequencies (FREQ)
fourierfreq,time(startbin:endbin),freq
freq=float(temporary(freq))  
   
   
;; calculate psd for each segment and each channel (pppsd)
;; average pppsd over nus individual segments (ppsd)
;; optional: normalize individual ppsds (normppsd)
ppsd=fltarr(n_elements(freq),nch)
normppsd=fltarr(n_elements(freq),nch)
;dft=complexarr(n_elements(freq),nus,nch)   
FOR chan=0,nch-1 DO BEGIN
    startbin=0L
    endbin=dseg-1L 
    FOR seg=0,nus-1 DO BEGIN 
        fastftrans,rate(startbin:endbin,chan),ddft        
        pppsd=abs(ddft)^2.
        ddft=0.
        ppsd(*,chan)=ppsd(*,chan)+pppsd
        IF (keyword_set(normindiv)) THEN BEGIN
            IF (n_elements(avg_bkg) NE 0) THEN BEGIN 
                psdnorm,mean(rate(startbin:endbin,chan)),length,dseg,pppsd, $
                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                  avgback=avg_bkg[chan],chatty=chatty
            ENDIF ELSE BEGIN 
                psdnorm,mean(rate(startbin:endbin,chan)),length,dseg,pppsd, $
                  schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                  chatty=chatty
            ENDELSE 
            normppsd(*,chan)=normppsd(*,chan)+pppsd
        ENDIF
        pppsd=0. 
        startbin=endbin+1
        endbin=startbin+dseg-1 
    ENDFOR
    ppsd(*,chan)=ppsd(*,chan)/nus
    IF (keyword_set(normindiv)) THEN BEGIN
      normppsd(*,chan)=normppsd(*,chan)/nus
    ENDIF
ENDFOR 


;; average over Fourier frequencies (PSD, NORMPSD); 
;; calculate uncertainties (ERRPSD, ERRNORMPSD);
;;
;; new frequencies: NFREQ;
;; number of averaged frequencies per bin: nf;
;; total number of averaged values: alln;
;;   
;; NFREQ, alln
;;
freqrebin,freq,ppsd(*,0),nfreq,rebpsd,errebpsd, $
  linf=linf,logf=logf,nof=nof,nf=alln,chatty=chatty 
rebpsd=0. & errebpsd=0.
alln=temporary(alln)*nus
;;
;; PSD, ERRPSD
;;
psd=fltarr(n_elements(nfreq),nch)
errpsd=fltarr(n_elements(nfreq),nch)
FOR chan=0,nch-1 DO BEGIN 
    freqrebin,freq,ppsd(*,chan),nu,rebpsd,errebpsd, $
      linf=linf,logf=logf,nof=nof,chatty=chatty
    psd(*,chan)=rebpsd
    errpsd(*,chan)=errebpsd/sqrt(nus)
    nu=0. & rebpsd=0. & errebpsd=0.
ENDFOR 
ppsd=0.
;;
;; NORMPSD, ERRNORMPSD
;;
normpsd=fltarr(n_elements(nfreq),nch)
errnormpsd=fltarr(n_elements(nfreq),nch)
IF (keyword_set(normindiv)) THEN BEGIN
    FOR chan=0,nch-1 DO BEGIN 
        freqrebin,freq,normppsd(*,chan),nu,rebnormpsd,errebnormpsd, $
          linf=linf,logf=logf,nof=nof,chatty=chatty
        normpsd(*,chan)=rebnormpsd
        errnormpsd(*,chan)=errebnormpsd/sqrt(nus)
        nu=0. & rebnormpsd=0. & errebnormpsd=0.
    ENDFOR 
    normppsd=0.
ENDIF ELSE BEGIN
    FOR chan=0,nch-1 DO BEGIN
        pd=psd(*,chan)
        IF (n_elements(avg_bkg) NE 0) THEN BEGIN
            psdnorm,mean(rate(*,chan)),length,dseg,pd, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgback=avg_bkg[chan],chatty=chatty
        ENDIF ELSE BEGIN 
            psdnorm,mean(rate(*,chan)),length,dseg,pd, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              chatty=chatty
        ENDELSE   
        normpsd(*,chan)=pd & pd=0.
        errnormpsd(*,chan)=errpsd(*,chan)*normpsd(0,chan)/psd(0,chan)
    ENDFOR
ENDELSE


;; calculate observational noise with deadtime influence for the
;; raw and the normalized psd for each channel (noippsd, noinormppsd)
;; average over Fourier frequencies (NOIPSD, NOINORMPSD)
noippsd=fltarr(n_elements(freq),nch)
noinormppsd=fltarr(n_elements(freq),nch)
FOR chan=0,nch-1 DO BEGIN
    ;;
    ;;
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'######### foucalc: Number of energy band: '
        print,chan
        print,'######### foucalc: Mean countrate       : '
        print,mean(rate(*,chan))
    ENDIF 
    ;;
    ;;
    IF (keyword_set(zhang_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'foucalc: Zhang deadtime correction is applied'
    ENDIF 
    IF (keyword_set(pca_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'foucalc: PCA deadtime correction is applied'
    ENDIF 
    IF (keyword_set(hexte_dt)) AND (keyword_set(chatty)) THEN BEGIN 
       print,'foucalc: HEXTE deadtime correction is applied'
    ENDIF 
    ;;
    ;; 
    IF (keyword_set(zhang_dt)) THEN BEGIN 
        totrate=mean(rate(*,chan))
        psdcorr,totrate,length,dseg, $
          cfreq,noipd, $
          ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $
          unnormalized=1, $
          chatty=chatty
        noippsd(*,chan)=noipd & noipd=0. & cfreq=0.
        IF (n_elements(avg_bkg) NE 0) THEN BEGIN
            psdcorr,totrate,length,dseg, $
              cfreq,noinormpd, $
              ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgback=avg_bkg[chan], $
              chatty=chatty
        ENDIF ELSE BEGIN 
            psdcorr,totrate,length,dseg, $
              cfreq,noinormpd, $
              ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              chatty=chatty
        ENDELSE 
        noinormppsd(*,chan)=noinormpd & noinormpd=0. & cfreq=0.
    ENDIF 
    ;;
    ;; 
    IF (keyword_set(pca_dt)) THEN BEGIN 
        pic=mean(rate(*,chan))/float(pcuon)
        psdcorr_pca,length,dseg, $
          cfreq,noipd, $
          pcurate=pic,vle=vle,level=level, $
          unnormalized=1, $
          avgrate=mean(rate(*,chan)),chatty=chatty      
        noippsd(*,chan)=noipd & noipd=0. & cfreq=0.
        IF (n_elements(avg_bkg) NE 0) THEN BEGIN 
            psdcorr_pca,length,dseg, $
              cfreq,noinormpd, $
              pcurate=pic,vle=vle,level=level, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgrate=mean(rate(*,chan)),avgback=avg_bkg[chan], $ 
              chatty=chatty
        ENDIF ELSE BEGIN
            psdcorr_pca,length,dseg, $
              cfreq,noinormpd, $
              pcurate=pic,vle=vle,level=level, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgrate=mean(rate(*,chan)), $ 
              chatty=chatty
        ENDELSE 
        noinormppsd(*,chan)=noinormpd & noinormpd=0. & cfreq=0.
    ENDIF 
    ;;    
    ;;
    IF (keyword_set(hexte_dt)) THEN BEGIN 
        clus=mean(rate(*,chan))
        psdcorr_hexte,length,dseg, $
          cfreq,noipd, $
          clusterrate=clus,xuld=xuld, $
          cluster_a=cluster_a,cluster_b=cluster_b, $
          unnormalized=1, $
          avgrate=mean(rate(*,chan)),chatty=chatty
        noippsd(*,chan)=noipd & noipd=0. & cfreq=0.
        IF (n_elements(avg_bkg) NE 0) THEN BEGIN
            psdcorr_hexte,length,dseg, $
              cfreq,noinormpd, $
              clusterrate=clus,xuld=xuld, $
              cluster_a=cluster_a,cluster_b=cluster_b, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgrate=mean(rate(*,chan)),avgback=avg_bkg[chan], $
              chatty=chatty
        ENDIF ELSE BEGIN
            psdcorr_hexte,length,dseg, $
              cfreq,noinormpd, $
              clusterrate=clus,xuld=xuld, $
              cluster_a=cluster_a,cluster_b=cluster_b, $
              schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
              avgrate=mean(rate(*,chan)), $
              chatty=chatty
        ENDELSE 
        noinormppsd(*,chan)=noinormpd & noinormpd=0. & cfreq=0.
    ENDIF 
    ;;
    ;;
ENDFOR
;;
;; NOIPSD, NOINORMPSD
;;
noipsd=fltarr(n_elements(nfreq),nch)
noinormpsd=fltarr(n_elements(nfreq),nch)
foinormpsd=fltarr(n_elements(nfreq),nch)
FOR chan=0,nch-1 DO BEGIN
    freqrebin,freq,noippsd(*,chan),nu,rebnoipsd,errebnoipsd, $
      linf=linf,logf=logf,nof=nof,chatty=chatty
    noipsd(*,chan)=rebnoipsd
    nu=0. & rebnoipsd=0. & errebnoipsd=0.       
    freqrebin,freq,noinormppsd(*,chan),nu,rebnoinormpsd,errebnoinormpsd, $
      linf=linf,logf=logf,nof=nof,chatty=chatty       
    noinormpsd(*,chan)=rebnoinormpsd
    nu=0. & rebnoinormpsd=0. & errebnoinormpsd=0. 
    ;; calculate effective noise level
    foinormpsd(*,chan)=noinormpsd(*,chan)/sqrt(alln(*))
ENDFOR 
noippsd=0. & noinormppsd=0.


;; correct NORMPSD with NOINORMPSD for observational noise
;; and deadtime (SIGNORMPSD) 
signormpsd=normpsd-noinormpsd


;; calculate the rms (RMS) for the normalized, corrected
;; (observational noise and deadtime) psd (SIGNORMPSD),
;; for Miyamoto normalized psds only,
;; write RMS in file
IF (keyword_set(miyamoto)) THEN BEGIN
    rms=fltarr(nch)
    FOR chan=0,nch-1 DO BEGIN 
        rms(chan)=rmscal(nfreq,signormpsd(*,chan), $
                         fmin=fmin,fmax=fmax, $
                         chatty=chatty)
    ENDFOR
    openw,unit,fi_rms,/get_lun
    printf,unit,rms
    free_lun,unit
ENDIF


;; write NORMPSD, NOINORMPSD,SIGNORMPSD and ERRNORMPSD in separate files
xdrfu_w1,fi_normpsd,nfreq,normpsd,history=norm_history,chatty=chatty 
xdrfu_w1,fi_noinormpsd,nfreq,noinormpsd,history=norm_history,chatty=chatty
xdrfu_w1,fi_foinormpsd,nfreq,foinormpsd,history=norm_history,chatty=chatty
xdrfu_w1,fi_signormpsd,nfreq,signormpsd,history=norm_history,chatty=chatty
xdrfu_w1,fi_errnormpsd,nfreq,errnormpsd,history=norm_history,chatty=chatty 
normpsd=0. & noinormpsd=0. & foinormpsd=0. & signormpsd=0. & errnormpsd=0.


;; calculate real and imaginary part of the cross power density
;; for all channel combinations: realcccpd, imagcccpd
;; average over nus individual segments (realccpd, imagcpd)
realccpd=fltarr(n_elements(freq),nch-1,nch)
imagccpd=fltarr(n_elements(freq),nch-1,nch)
FOR soft=0,nch-2 DO BEGIN  
    FOR hard=soft+1,nch-1 DO BEGIN 
        startbin=0L
        endbin=dseg-1L
        FOR seg=0,nus-1 DO BEGIN  
            fastftrans,rate(startbin:endbin,soft),sdft
            fastftrans,rate(startbin:endbin,hard),hdft
            realcccpd=float(conj(sdft)*hdft)           
            realccpd(*,soft,hard)=realccpd(*,soft,hard)+realcccpd
            realcccpd=0.
            imagcccpd=imaginary(conj(sdft)*hdft)           
            imagccpd(*,soft,hard)=imagccpd(*,soft,hard)+imagcccpd
            imagcccpd=0.
            sdft=0. & hdft=0.
            startbin=endbin+1
            endbin=startbin+dseg-1 
        ENDFOR 
     ENDFOR
ENDFOR
realccpd=realccpd/nus
imagccpd=imagccpd/nus
;; average realccpd over Fourier frequencies (REALCPD)
realcpd=fltarr(n_elements(nfreq),nch-1,nch)
FOR soft=0,nch-2 DO BEGIN 
    FOR hard=soft+1,nch-1 DO BEGIN
        freqrebin,freq,realccpd(*,soft,hard),nu,rebrec,errebrec, $
          linf=linf,logf=logf,nof=nof,chatty=chatty
        realcpd(*,soft,hard)=rebrec
        nu=0. & rebrec=0. & errebrec=0.
    ENDFOR 
ENDFOR
realccpd=0.
;; average imagccpd over Fourier frequencies (IMAGCPD)
imagcpd=fltarr(n_elements(nfreq),nch-1,nch)
FOR soft=0,nch-2 DO BEGIN 
    FOR hard=soft+1,nch-1 DO BEGIN
        freqrebin,freq,imagccpd(*,soft,hard),nu,rebimc,errebimc, $
          linf=linf,logf=logf,nof=nof,chatty=chatty
        imagcpd(*,soft,hard)=rebimc
        nu=0. & rebimc=0. & errebimc=0.       
    ENDFOR 
ENDFOR
imagccpd=0.
cpd=complex(realcpd,imagcpd) & realcpd=0. & imagcpd=0.
;; write REALCPD and IMAGCPD in separate files
xdrfu_w2,fi_realcpd,nfreq,realcpd,history=basic_history,chatty=chatty
xdrfu_w2,fi_imagcpd,nfreq,imagcpd,history=basic_history,chatty=chatty


;; correct PSD with NOIPSD for observational noise 
;; and deadtime (SIGPSD) 
;; use SIGPSD and NOIPSD to calculate 
;; the cross power density noise (NOICPD)
;;
;; SIGPSD
;;
sigpsd=psd-noipsd 
;;
;; NOICPD
;;
noicpd=fltarr(n_elements(nfreq),nch-1,nch)
FOR s=0,nch-2 DO BEGIN 
    FOR h=s+1,nch-1 DO BEGIN
        noicpd(*,s,h)=(sigpsd(*,s)*noipsd(*,h) $
                       +noipsd(*,s)*sigpsd(*,h) $
                       +noipsd(*,s)*noipsd(*,h))/alln(*)
    ENDFOR   
ENDFOR 


;; write PSD, NOIPSD, SIGPSD, ERRPSD and NOICPD in separate files
xdrfu_w1,fi_psd,nfreq,psd,history=basic_history,chatty=chatty 
xdrfu_w1,fi_noipsd,nfreq,noipsd,history=basic_history,chatty=chatty
xdrfu_w1,fi_sigpsd,nfreq,sigpsd,history=basic_history,chatty=chatty  
xdrfu_w1,fi_errpsd,nfreq,errpsd,history=basic_history,chatty=chatty
errpsd=0. 
xdrfu_w2,fi_noicpd,nfreq,noicpd,history=basic_history,chatty=chatty  


;; use CPD, NOICPD, SIGPSD, NOIPSD and PSD to calculate the
;; corrected (observational noise, deadtime) 
;; coherence function (COF) with error (ERRCOF) 
;; and the timelags (LAG) with error (ERRLAG) 
cof    = fltarr(n_elements(nfreq),nch-1,nch)
errcof = fltarr(n_elements(nfreq),nch-1,nch)
lag    = fltarr(n_elements(nfreq),nch-1,nch)
errlag = fltarr(n_elements(nfreq),nch-1,nch)
rawcof = fltarr(n_elements(nfreq),nch-1,nch)
FOR soft=0,nch-2 DO BEGIN 
    FOR hard=soft+1,nch-1 DO BEGIN
        colacal,nfreq, $
          cpd(*,soft,hard),noicpd(*,soft,hard), $
          sigpsd(*,soft),sigpsd(*,hard), $
          noipsd(*,soft),noipsd(*,hard), $
          psd(*,soft),psd(*,hard), $
          alln(*), $
          onecof,oneerrcof, $
          onelag,oneerrlag, $
          onerawcof
        cof(*,soft,hard)    = onecof     & onecof    = 0.
        errcof(*,soft,hard) = oneerrcof  & oneerrcof = 0.
        lag(*,soft,hard)    = onelag     & onelag    = 0.
        errlag(*,soft,hard) = oneerrlag  & oneerrlag = 0.
        rawcof(*,soft,hard) = onerawcof  & onerawcof = 0.
    ENDFOR
ENDFOR

;; write COF, ERRCOF, LAG and ERRLAG in separate files
xdrfu_w2,fi_cof,nfreq,cof,history=basic_history,chatty=chatty 
xdrfu_w2,fi_errcof,nfreq,errcof,history=basic_history,chatty=chatty  
xdrfu_w2,fi_lag,nfreq,lag,history=basic_history,chatty=chatty    
xdrfu_w2,fi_errlag,nfreq,errlag,history=basic_history,chatty=chatty  
xdrfu_w2,fi_rawcof,nfreq,rawcof,history=basic_history,chatty=chatty 
cof=0. & errcof=0. & lag=0. & errlag=0. & rawcof=0.


END
 











