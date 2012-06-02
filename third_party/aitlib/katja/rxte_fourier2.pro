PRO rxte_fourier2,path,type=type, $
                 maxdim=inpmaxdim,dim=inpdim,normindiv=normindiv, $
                 schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
                 hexte_bkg=hexte_bkg,pca_bkg=pca_bkg, $
                 linf=linf,logf=logf,nof=nof, $
                 zhang_dt=zhang_dt, $
                 ninstr=ninstr,deadtime=deadtime, $
                 nonparalyzable=nonparalyzable, $
                 pca_dt=pca_dt, $ 
                 pcuon=pcuon, $
                 hexte_dt=hexte_dt, $
     		 cluster_a=cluster_a,cluster_b=cluster_b, $                   
                 fmin=fmin,fmax=fmax,fcut=fcut, $
		 xmin=plotxmin,xmax=plotxmax, $
		 ymin=plotymin,ymax=plotymax, $
                 xtenlog=plotxtenlog,ytenlog=plotytenlog,sym=plotsym, $
		 ebounds=ebounds,obsid=obsid,username=username,date=date, $
		 color=plotcolor,postscript=postscript,chatty=chatty,$
                 addch=addch
;Last keyword added by Tolga Dincer.
;It allows to add lightcurves in different channel bands
;eg: addch=[1,2] means additionally, add light curves in the second
;and the third channels bands 

;+
; NAME:
;          rxte_fourier
;
;
; PURPOSE:
;          calculate and save Fourier quantities, their uncertainties, and
;          noise corrections from segmented, evenly spaced, 
;          multidimensional xdr lightcurves for all given energy
;          channels  
;
;
; FEATURES:       
;          segmented, evenly spaced, multidimensional (i.e.,
;          containing more than one energy band) xdr lightcurves
;          (e.g., prepared by the rxte_syncseg.pro routine) are read;
;          several multidimensional Fourier quantities and their
;          uncertainties are calculated:   
;          --- e.g., the normalized 
;                        (see keywords tagged ``kw1'', in case of
;                        Miyamoto normalization an additional
;                        background correction is possible for PCA and
;                        for HEXTE data), 
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
;          the rms value for each psd is calculated (``kw4''); the
;          maximum segment length ``maxdim'' of the input lightcurves
;          has to be given in time bins; the Fourier quantities can be
;          calculated for several segment lengths ``dim[*]'' obtained
;          by dividing ``maxdim'' by integer factors; the Fourier
;          quantities obtained for different segment lengths are saved
;          individually but also merged by taking different frequency
;          ranges from different segment lengths (``kw5''); the Fourier
;          quantities are rebinned (``kw2''): logarithmic or linear
;          rebinning can be chosen; unrebinned Fourier quantities can
;          be saved additionally by setting ``nof=1'', the latter are
;          only saved individually, not merged; the input xdr
;          lightcurves and output xdr Fourier quantities and overview
;          ps plots (``kw6'') are stored in subdirectories of the input
;          directory ``path'' (see RESTRICTIONS and SIDE EFFECTS)
;                
;          most important subroutines: 
;          readxuld.pro: read HEXTE housekeeping data for
;                        deadtime correction
;          readvle.pro : read PCA housekeeping data for
;                        deadtime correction
;          ebandrate   : read average PCA background rate 
;                        from standard2f spectra    
;          foucalc.pro : calculate Fourier quantities  
;          foumerge.pro: merge Fourier quantities    
;          fouplot.pro : plot Fourier quantities    
;
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          rxte_fourier,path,type=type, $
;                   maxdim=inpmaxdim,dim=inpdim,normindiv=normindiv, $
;                   schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
;                   hexte_bkg=hexte_bkg,pca_bkg=pca_bkg, $
;                   linf=linf,logf=logf,nof=nof, $
;                   zhang_dt=zhang_dt, $
;                   ninstr=ninstr,deadtime=deadtime, $
;                   nonparalyzable=nonparalyzable, $
;                   pca_dt=pca_dt, $ 
;                   pcuon=pcuon, $   
;                   hexte_dt=hexte_dt, $
;                   cluster_a=cluster_a,cluster_b=cluster_b, $  
;                   fmin=fmin,fmax=fmax,fcut=fcut, $
;                   xmin=plotxmin,xmax=plotxmax, $
;                   ymin=plotymin,ymax=plotymax, $
;                   xtenlog=plotxtenlog,ytenlog=plotytenlog,sym=plotsym, $
;                   ebounds=ebounds,obsid=obsid,username=username,date=date, $
;                   color=plotcolor,postscript=postscript,chatty=chatty
;
;
; INPUTS:
;          path               : string containing the path to the observation
;                               directory which must have a
;                               subdirectory called light/processed/ where
;                               the prepared lightcurves are stored in
;                               xdr format, named according to the
;                               output of rxte_syncseg.pro routine      
;          type               : string indicating whether one
;                               (type='high') or more segment lengths
;                               (type='low') are given, and whether the
;                               non-frequency rebinned Fourier
;                               quantities are saved as well
;                               (type='low') or not (type='high');  
;                               note that the keywords/inputs
;                               corresponding to the above behavior
;                               still have to be set/given!     
;          maxdim             : parameter giving the maximum segment
;                               length of the input lightcurves in
;                               time bins; maxdim is part of the file
;                               name of the multidimensional input
;                               lightcurve; maxdim=long(inpmaxdim) is
;                               used    
;          dim                : array giving the different segment
;                               lengths (in bins) for which the Fourier
;                               quantities are to be calculated; to
;                               ensure that exactly the same
;                               lightcurve data are used for all
;                               segment lengths, dim should only
;                               contain integer values obtained by
;                               dividing maxdim by an integer value;  
;                               dim=long(inpdim) is used
;
;
; OPTIONAL INPUTS:  
;          see KEYWORD PARAMETERS
;
;
; KEYWORD PARAMETERS:
;          and OPTIONAL INPUTS:
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
;              hexte_bkg      : read HEXTE background lightcurves
;                               in order to determine the average 
;                               background rate which is used
;                               for correcting the psd
;                               normalization in case of
;                               Miyamoto normalization 
;                               default: hexte_bkg undefined   
;              pca_bkg        : read PCA standard2f spectra
;                               in order to determine the average
;                               background rate which is used   
;                               for correcting the psd
;                               normalization in case of
;                               Miyamoto normalization
;                               default: pca_bkg undefined      
;              ebounds        : energy ranges, needed for reading the 
;                               PCA background, see also
;                               plotting keywords ``kw6''
;   
;       -- for the frequency rebinning (kw2)
;              linf           : parameter giving the number of
;                               frequency bins for linear frequency
;                               rebinning 
;              logf           : parameter giving df/f for logarithmic
;                               frequency rebinning;
;                               default: linf undefined, logf=0.15   
;              nof            : if set, the non-frequency-rebinned
;                               Fourier quantities are saved
;                               additionally to the rebinned ones;
;                               default: nof undefined: the
;                               non-frequency-rebinned quantities are
;                               not saved 
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
;                               a special file containing PCA
;                               houskeeping information is read from
;                               the <path>/light/raw/directory;   
;                               default: see below   
;              hexte_dt       : deadtime correction for HEXTE psds
;                               (after: Kalemci, 2000, priv. comm);
;                               special HEXTE housekeeping files in
;                               the <path>/house/ directory are read;
;                               warning: check if the correct HK files
;                                        are present   
;                               default: see below 
;              cluster_a      : deadtime correction for HEXTE psds for
;                               cluster A;
;                               hexte_dt=1 has to be set;
;                               default: cluster_a undefined;   
;                                        cluster_a=1 is the default  
;              cluster_b      : 
;                               deadtime correction for HEXTE psds for
;				cluster B; 
;                               default: cluster_b undefined
;                                           
;              only one of the  keywords zhang_dt/pca_dt/hexte_dt can
;              be set;  
;              default: zhang_dt=1, pca_dt undefined, hexte_dt undefined
;   
;       -- for the determination of the rms for each psd (kw4)    
;              fmin           : minimum frequency in Hz;
;                               default (set in rmscal.pro, called by
;                               foucalc.pro): fmin=min(freq)  
;              fmax           : maximum frequency in Hz;
;                               default (set in rmscal.pro, called by
;                               foucalc.pro): fmax=max(freq) 
;   
;       -- for the merging of Fourier quantities from different
;          lightcurve segment lengths (kw5) 
;              fcut           : for the merging of Fourier quantities
;                               from different segment lengths, the
;                               frequency range selected for each
;                               segment length dim[*] ranges from the
;                               minimum frequency given by
;                               1./(dim[*]*bt) to the maximum
;                               frequency given by an entry in fcut 
;                               corresponding to dim[*] (e.g., for
;                               three segment lengths,
;                               fcut=[0.013D0,0.059D0,128D0]); fcut
;                               has to be given in Hz;     
;                               default: fcut=128D0 
;   
;       -- for the plot routines, three overview plots 
;          (psd-coherence-time lags, in this order) are produced (kw6) 
;              xmin, xmax     : define the plotted frequency range in Hz;
;                               default:  xmin=[0.001,0.001,0.001] 
;                                         xmax=[128.,128.,128.] 
;              ymin, ymax     : define the plotted range for the
;                               Fourier quantities in psd norm (psd),
;                               relative coherence (coherence) and sec
;                               (lags);   
;                               default: ymin=[1E-6,-4.,1E-5]
;                                        ymax=[4.,4.,1.]  
;            xtenlog, ytenlog : plot x/y-axis logarithmically (1) or
;                               not (0);
;                               default: xtenlog=[1,1,1]
;                                        ytenlog=[1,0,1] 
;              sym            : plot symbol for the rebinned quantities
;                               and - if present - for the unrebinned
;                               quantities;   
;                               default: sym=[4,-3]  
;              ebounds        : array containing the channel ranges (pha
;                               channels); plotted on the overview plots;
;                               needed for for reading the PCA background;   
;                               default: ebounds iis undefined, i.e.: 
;                                        1. plotting: see string
;                                           ``channels''   
;                                        2. if pca_bkg=1 then the 
;                                           background rate is read
;                                           for the whole energy range 
;                                           of the standard2f spectrum
;                                           per default   
;                               example: ebounds=[[36,81],[82,159]]   
;              obsid          : string giving the name of the observation;
;                               plotted on the overview plots;
;                               inserted in the history string array;
;                               default: 'Keyword obsid has not been set
;                                        (rxte_fourier)'  
;              username       : string giving the name of the user; 
;                               plotted on the overview plots; 
;                               inserted in the history string array;   
;                               default: 'Keyword username has not been set
;                                        (rxte_fourier)'  
;              date           : string giving the production date of
;                               the Fourier quantities; plotted on the
;                               overview plots; 
;                               inserted in the history string array;   
;                               default: 'Keyword date has not been set
;                                        (rxte_fourier)'
;              color          : decide which color (of color table 39) is
;                               used for each of the three plots;
;                               default: color=[50,50,50]: blue   
;              postscript     : decide whether ps or eps plots are
;                               produced; 
;                               default: postscript=1: ps plots are
;                                        produced   
;   
;       -- for the screen output
;              chatty         : controls screen output; 
;                               default: screen output;  
;                               to turn off screen output, set
;                               chatty=0       
;   
;   
; OUTPUTS:
;          none, but: see side effects   
;
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
;          the resulting Fourier quantities and the corresponding
;          history files are written to subdirectories of the
;          <path>/light/fourier/ directory
;          (``_corr'' is added to the filenames of normalized psd
;          quantities when the miyamoto/hexte_bkg or the
;          miyamoto/pca_bkg keyword combination has been set)
;   
;          in xdr format under the following file names 
;          (the .history and the .txt files are ASCII): 
;   
;          <path>/light/fourier/<type>/onelength/:
;          (for nof undefined (default) only the ``*_rebin_*'' files are saved)
;                  <dim[*]>_cof.xdrfu
;                  <dim[*]>_errcof.xdrfu
;                  <dim[*]>_errlag.xdrfu
;                  <dim[*]>_errnormpsd(_corr).xdrfu
;                  <dim[*]>_errpsd.xdrfu
;                  <dim[*]>_foinormpsd(_corr).xdrfu
;                  <dim[*]>_imagcpd.xdrfu
;                  <dim[*]>_lag.xdrfu
;                  <dim[*]>_noicpd.xdrfu
;                  <dim[*]>_noinormpsd(_corr).xdrfu
;                  <dim[*]>_noipsd.xdrfu
;                  <dim[*]>_normpsd(_corr).xdrfu
;                  <dim[*]>_psd.xdrfu
;                  <dim[*]>_rawcof.xdrfu
;                  <dim[*]>_realcpd.xdrfu
;                  <dim[*]>_rebin_cof.xdrfu
;                  <dim[*]>_rebin_errcof.xdrfu
;                  <dim[*]>_rebin_errlag.xdrfu
;                  <dim[*]>_rebin_errnormpsd(_corr).xdrfu
;                  <dim[*]>_rebin_errpsd.xdrfu
;                  <dim[*]>_rebin_foinormpsd(_corr).xdrfu
;                  <dim[*]>_rebin_imagcpd.xdrfu
;                  <dim[*]>_rebin_lag.xdrfu
;                  <dim[*]>_rebin_noicpd.xdrfu
;                  <dim[*]>_rebin_noinormpsd(_corr).xdrfu
;                  <dim[*]>_rebin_noipsd.xdrfu
;                  <dim[*]>_rebin_normpsd(_corr).xdrfu
;                  <dim[*]>_rebin_psd.xdrfu
;                  <dim[*]>_rebin_rawcof.xdrfu
;                  <dim[*]>_rebin_realcpd.xdrfu
;                  <dim[*]>_rebin_rms(_corr).txt
;                  <dim[*]>_rebin_signormpsd(_corr).xdrfu
;                  <dim[*]>_rebin_sigpsd.xdrfu                  
;                  <dim[*]>_rms(_corr).txt
;                  <dim[*]>_signormpsd(_corr).xdrfu
;                  <dim[*]>_sigpsd.xdrfu 
;          <path>/light/fourier/<type>/merged/:
;                   merge_rebin_cof.history
;                   merge_rebin_cof.xdrfu
;                   merge_rebin_errcof.history
;                   merge_rebin_errcof.xdrfu
;                   merge_rebin_errlag.history
;                   merge_rebin_errlag.xdrfu
;                   merge_rebin_errnormpsd(_corr).history
;                   merge_rebin_errnormpsd(_corr).xdrfu   
;                   merge_rebin_foinormpsd(_corr).history
;                   merge_rebin_foinormpsd(_corr).xdrfu
;                   merge_rebin_lag.history
;                   merge_rebin_lag.xdrfu
;                   merge_rebin_noinormpsd(_corr).history
;                   merge_rebin_noinormpsd(_corr).xdrfu
;                   merge_rebin_signormpsd(_corr).history
;                   merge_rebin_signormpsd(_corr).xdrfu     
;   
;          and as ps plots under the following file names:
;
;          <path>/light/fourier/<type>/plots/:    
;          (for nof undefined (default) the ``*_norebin_*'' files are not saved)   
;          <dim[*]>_cof_norebin.ps
;          <dim[*]>_lag_norebin.ps
;          <dim[*]>_signormpsd(_corr)_norebin.ps
;          cof.ps
;          lag.ps
;          signormpsd(_corr).ps
;   
;
;  for a description of the Fourier quantities labeled by these file
;  names, see subroutines of rxte_fourier.pro or the ASCII file
;  readme.txt     
;   
;   
; RESTRICTIONS: 
;          the input lightcurves must have been produced
;          according to rxte_syncseg.pro: they have to be segmented,
;          evenly spaced and multidimensional, it must be possible to
;          read them with xdrlc_r.pro and they must be stored in a
;          directory named <path>/light/processed/; the subdirectories
;          <path>/light/fourier/<type>/merged,
;          <path>/light/fourier/<type>/onelength, and
;          <path>/light/fourier/<type>/plots must exist for saving the
;          results; to ensure that exactly the same lightcurve data
;          are used for all segment lengths, dim should only contain
;          integer values obtained by dividing maxdim by an integer
;          value
;   
;   
; PROCEDURES USED:
;          readxuld.pro, readvle.pro, ebandrate.pro   
;          xdrlc_r.pro, foucalc.pro, foumerge.pro, fouplot.pro
;  
;
; EXAMPLE:
;          rxte_fourier,'01.all/light',type='low', $
;                        maxdim=131072L,dim=[131072L,32768L,8192L], $
;                        pca_dt=1,pcuon=5,ebounds=[[36,81],[82,159]],/chatty
;
; for an example of the rest of the keywords see default values  
;   
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/11/01 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed  
;          Version 1.3, 2000/11/07 Katja Pottschmidt,   
;                                  IDL header: minor changes   
;          Version 1.4, 2000/11/22 Katja Pottschmidt, Emrah Kalemci,   
;                                  added deadtime correction 
;                                  keywords (Zhang and HEXTE cluster A 
;                                  is implemented),
;                                  added HEXTE background correction
;                                  keyword for the psd normalization,
;                                  careful: defaults and IDL header
;                                  are not updated yet
;          Version 1.5, 2000/12/01 Katja Pottschmidt,   
;                                  added PCA background correction
;                                  keyword for the psd normalization,
;                                  changed keyword "channels" (string)
;                                  to keyword "ebounds" (intarr),   
;                                  careful: defaults and IDL header
;                                  are not updated yet   
;          Version 1.6, 2000/12/11 Katja Pottschmidt,   
;                                  header updated: keywords hexte_bkg,
;                                  pca_bkg, ebounds, zhang_dt, pca_dt,
;                                  hexte_dt, cluster_a, cluster_b;
;                                  header updated: ``path'' does not
;                                  contain ``light'' anymore;
;                                  added deadtime correction for the
;                                  PCA (readvle.pro);
;                                  defaults/warnings for the new
;                                  keywords have been updated   
;          Version 1.7/1.8, 2000/12/12 Katja Pottschmidt,  
;                                  minor changes  
;          Version 1.9, 2000/12/15 Katja Pottschmidt,   
;                                  corrected call of readxuld  
;          Version 1.10/11, 2000/12/15 Katja Pottschmidt,   
;                                  corrected names of plotting keywords     
;                                  in the setting of their defaults
;          Version 1.12, 2000/12/22 Katja Pottschmidt,
;                                  changed reading of PCA deadtime
;                                  information;    
;                                  corrected foucalc calls (deadtime
;                                  keywords)   
;          Version 1.13, 2001/01/10 Katja Pottschmidt,    
;                                  keyword pcuon has been added, 
;                                  in the calls of foucalc the
;                                  keywords pcurate and clusterrate
;                                  have been removed (see foucalc) 
;
;	   Version 1.14, 2001/10/04 Emrah Kalemci
;				   now it includes dead-time correction
;				   for HEXTE cluster B. Minor modifications
;			           are done to foucalc.pro, readxuld.pro,
;      				   psdcorr_hexte.pro also
;   
;-   
   

;;   
;; set default values
;; default values for fmin and fmax, see foucalc.pro   
;;
;; psd normalization and background keywords   
;;   
IF (n_elements(normindiv) EQ 0) THEN normindiv=0   
;;
;;
nsch = n_elements(schlittgen)
nlea = n_elements(leahy)
nmiy = n_elements(miyamoto)
IF ((nsch+nlea+nmiy) GT 1) THEN BEGIN  
    message,'rxte_fourier: Only one normalization-keyword can be set' 
ENDIF
IF ((nsch+nlea+nmiy) EQ 0) THEN miyamoto=1   
;;
;; 
nbkghex = n_elements(hexte_bkg)
nbkgpca = n_elements(pca_bkg)
IF ((nbkghex+nbkgpca) GT 1) THEN BEGIN
    message,'rxte_fourier: Only one way of background correction (PCA or HEXTE) is allowed' 
ENDIF
IF ((nbkghex+nbkgpca) EQ 1) THEN BEGIN
    IF (NOT keyword_set(miyamoto)) THEN BEGIN 
        message,'rxte_fourier: Background correction can only be performed for Miyamoto normalization'
    ENDIF 
ENDIF
IF ((nbkghex+nbkgpca) EQ 0) THEN BEGIN
    print,'rxte_fourier: No background correction of the power spectra is performed' 
ENDIF 
;;
;;
IF (NOT keyword_set(ebounds)) THEN BEGIN
  channels='Keyword ebounds has not been set (rxte_fourier)'   
ENDIF ELSE BEGIN     
    nbou=n_elements(ebounds[0,*]) 
    IF (nbou EQ 0) THEN BEGIN 
        message,'Keyword ebounds has not been set correctly (rxte_fourier)'
    ENDIF 
    channels=strtrim(string(ebounds[0,0]),2)+'-'+ $
      strtrim(string(ebounds[1,0]),2)
    FOR i=1,nbou-1 DO BEGIN 
        channels=channels + ', ' + strtrim(string(ebounds[0,i]),2)
        channels=channels + '-'  + strtrim(string(ebounds[1,i]),2)
    ENDFOR
ENDELSE 
;; 
;; frequency rebin keywords
;;
nlin = n_elements(linf)
nlog = n_elements(logf)
IF ((nlin+nlog) GT 1) THEN BEGIN
    message,'rxte_fourier: Only one way of rebinning is allowed'
ENDIF
IF ((nlin+nlog) EQ 0) THEN logf=0.15
;; 
;; deadtime correction keywords
;;
nzha = n_elements(zhang_dt)
npca = n_elements(pca_dt)
nhex = n_elements(hexte_dt)
IF ((nzha+npca+nhex) GT 1) THEN BEGIN  
    message,'rxte_fourier: Only one deadtime-type-keyword can be set' 
ENDIF
IF ((nzha+npca+nhex) EQ 0) THEN zhang_dt=1 
IF (keyword_set(zhang_dt)) THEN BEGIN 
    IF (n_elements(ninstr) EQ 0) THEN ninstr=5    
    IF (n_elements(deadtime) EQ 0) THEN deadtime=1D-5    
    IF (n_elements(nonparalyzable) EQ 0) THEN nonparalyzable=0
ENDIF ELSE BEGIN 
    IF (keyword_set(ninstr)) THEN BEGIN 
        message,'rxte_fourier: ninstr keyword cannot be set without zhang_dt=1'     
    ENDIF 
    IF (keyword_set(deadtime)) THEN BEGIN  
        message,'rxte_fourier: deadtime keyword cannot be set without zhang_dt=1'
    ENDIF 
    IF  (keyword_set(nonparalyzable)) THEN BEGIN 
        message,'rxte_fourier: nonparalyzable keyword cannot be set without zhang_dt=1' 
    ENDIF 
ENDELSE  
IF (keyword_set(hexte_dt)) THEN BEGIN
    IF ((n_elements(cluster_a)+n_elements(cluster_b)) EQ 0) THEN BEGIN
        cluster_a=1
        cluster_b=0
    ENDIF
    IF (keyword_set(cluster_b)) THEN BEGIN 
        cluster_a=0
    ENDIF 
    IF (keyword_set(cluster_a)) THEN BEGIN 
        cluster_b=0
    ENDIF 
ENDIF ELSE BEGIN 
    IF (keyword_set(cluster_a)) THEN BEGIN 
        message,'rxte_fourier: cluster_a keyword cannot be set without hexte_dt=1'
    ENDIF
    IF (keyword_set(cluster_b)) THEN BEGIN 
        message,'rxte_fourier: cluster_b keyword cannot be set without hexte_dt=1'
    ENDIF
ENDELSE 
;; 
;; plotting keywords
;;
IF (n_elements(fcut) EQ 0) THEN fcut=128D0      
IF (n_elements(plotxmin) EQ 0) THEN plotxmin=[0.001,0.001,0.001]
IF (n_elements(plotxmax) EQ 0) THEN plotxmax=[128.,128.,128.]
IF (n_elements(plotymin) EQ 0) THEN plotymin=[1E-6,-4.,1E-5]    
IF (n_elements(plotymax) EQ 0) THEN plotymax=[4.,4.,1.]   
IF (n_elements(plotxtenlog) EQ 0) THEN plotxtenlog=[1,1,1]  
IF (n_elements(plotytenlog) EQ 0) THEN plotytenlog=[1,0,1]    
IF (n_elements(plotsym) EQ 0) THEN plotsym=[4,-3]   
IF (n_elements(obsid) EQ 0) THEN BEGIN 
    obsid='Keyword obsid has not been set (rxte_fourier)'
ENDIF 
IF (n_elements(username) EQ 0) THEN BEGIN 
    username='Keyword username has not been set (rxte_fourier)' 
ENDIF     
IF (n_elements(date) EQ 0) THEN BEGIN
    date='Keyword date has not been set (rxte_fourier)'
ENDIF              
IF (n_elements(plotcolor) EQ 0) THEN plotcolor=[50,50,50]    
IF (n_elements(postscript) EQ 0) THEN postscript=1   
;; 
;;
IF (n_elements(chatty) EQ 0) THEN chatty=1



;;
;; helpful parameters, file names   
;;
maxdim      = long(inpmaxdim)   
dim         = long(inpdim)
ndim        = n_elements(dim)

segname     = path+'/light/processed/'+string(format='(I7.7)',maxdim)+'_seg.xdrlc'
fouroot     = path+'/light/fourier/'+type

fouquan     = ['signormpsd','errnormpsd','noinormpsd','foinormpsd', $
               'cof','errcof', $
               'lag','errlag']
nfou        = n_elements(fouquan)

plotquan          = ['signormpsd','cof','lag']
ploterror         = ['errnormpsd','errcof','errlag']
ploterror_norebin = ['none','none','none']
plotnoise         = ['foinormpsd','none','none']
nplot             = n_elements(plotquan)

corrbkg=0
IF keyword_set(hexte_bkg) THEN corrbkg=1 
IF keyword_set(pca_bkg) THEN corrbkg=1
IF (corrbkg EQ 1) AND (keyword_set(miyamoto)) THEN BEGIN
    fouquan     = ['signormpsd_corr','errnormpsd_corr', $
                   'noinormpsd_corr','foinormpsd_corr', $
                   'cof','errcof', $
                   'lag','errlag']
    nfou        = n_elements(fouquan)
    plotquan          = ['signormpsd_corr','cof','lag']
    ploterror         = ['errnormpsd_corr','errcof','errlag']
    ploterror_norebin = ['none','none','none']
    plotnoise         = ['foinormpsd_corr','none','none']
    nplot             = n_elements(plotquan)
ENDIF 




;;
;; read synchronized, segmented lightcurves for all channels
;;
xdrlc_r,segname,time,rate,history=lchistory,chatty=chatty


;
;This line is added by Tolga Dinçer to cope with adding light curves
;in different channels
IF (keyword_set(addch)) THEN BEGIN
rate_temp=0.
    FOR loo=0,n_elements(addch)-1 DO BEGIN
        rate_temp=rate_temp+rate[*,addch(loo)]
    ENDFOR
rate_temp2=[[rate],[rate_temp]]
rate=rate_temp2

ENDIF

nch=n_elements(rate[0,*])




;;
;; read background and/or housekeeping data
;;

;; read high energy particle rates for the HEXTE deadtime correction
IF (keyword_set(hexte_dt)) THEN BEGIN       
    IF (keyword_set(cluster_a)) THEN BEGIN
        hkf_hexte=path+'/house' 
        spawn,['/usr/bin/find',hkf_hexte,'-name', $
               '*_FH53_a.gz'], $
          hkflist,/noshell
        spawn,['/usr/bin/find',hkf_hexte,'-name', $
               '*_good_hexte.gti'], $
          gtilist,/noshell	    
        nhkf=n_elements(hkflist) 
    ENDIF 
    IF (keyword_set(cluster_b)) THEN BEGIN
        hkf_hexte=path+'/house' 
        spawn,['/usr/bin/find',hkf_hexte,'-name', $
               '*_FH59_b.gz'], $
          hkflist,/noshell
        spawn,['/usr/bin/find',hkf_hexte,'-name', $
               '*_good_hexte.gti'], $
          gtilist,/noshell	
        nhkf=n_elements(hkflist) 
    ENDIF        
;    gtione='' & hkfone=''
    gtione=gtilist[0]
    hkfone=hkflist[0]    
    readxuld,gtione,hkfone,xuld,gtime,cluster_a=cluster_a,cluster_b=cluster_b
    IF (nhkf GT 1) THEN BEGIN
        For i=1,nhkf-1 DO BEGIN
            readxuld,gtilist[i],hkflist[i],xulda,gtime,cluster_a=cluster_a,cluster_b=cluster_b
            xuld=[xuld,xulda]
        ENDFOR
    ENDIF
ENDIF

;; read very large event rate and total average PCU count rate
;; for the PCA deadtime correction
;; level is the VLE discriminator level, needed for the amount of
;; VLE deadtime
IF (keyword_set(pca_dt)) THEN BEGIN
    hkfile=strmid(segname,0,strpos(segname,'.xdrlc'))+'.pcadead'
    readvle,hkfile,pcurate=pcurate,vle=vle,level=level
ENDIF

;; read HEXTE background for psd normalization
IF (keyword_set(hexte_bkg)) THEN BEGIN
    backfile=path+'/light/processed/'+string(format='(I7.7)',maxdim)+ $
      '_seg_b*.xdrlc'
    xdrlc_r,backfile,ti,bkg,chatty=chatty
    nch_bkg=n_elements(bkg[0,*])
    avg_bkg=fltarr(nch_bkg)
    IF (nch NE nch_bkg) THEN BEGIN
        message,'rxte_fourier: source and background lightcurves do not contain the same number of energy bands'
    ENDIF 
    FOR i=0,nch_bkg-1 DO BEGIN   
        bt=ti[1]-ti[0]
        length=(maxdim*bt)
        nseg=n_elements(ti)/maxdim
        avg_bkg[i]=total(bkg[*,i])*bt/((length-4D0)*nseg)
    ENDFOR 
ENDIF

;; read PCA background for psd normalization
IF (keyword_set(pca_bkg)) THEN BEGIN
    backfile=path+'/spectrum/fullback.pha'
    avg_bkg=fltarr(nch)
    FOR i=0,nch-1 DO BEGIN  
        ebandrate,backfile,avgrate,cmin=ebounds[0,i],cmax=ebounds[1,i]        
        avg_bkg[i]=avgrate
    ENDFOR 
ENDIF




;;
;; Fourier quantities
;;

;; calculate Fourier quantities for Fourier frequencies
;; save results
IF (nof EQ 1) THEN BEGIN 
    FOR i=0,ndim-1 DO BEGIN
        foupath=fouroot+'/onelength/'+string(format='(I7.7)',dim(i))
        foucalc,time,rate,foupath, $
          dseg=dim(i),normindiv=normindiv, $ 
          avg_bkg=avg_bkg, $ 
          schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $ 
          nof=nof, $
          zhang_dt=zhang_dt, $
          ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $ 
          pca_dt=pca_dt, $
          pcuon=pcuon,vle=vle,level=level, $
          hexte_dt=hexte_dt, cluster_a=cluster_a, $
          xuld=xuld, cluster_b=cluster_b, $
          fmin=fmin,fmax=fmax, $  
          obsid=obsid,username=username,date=date, $
          history=lchistory,chatty=chatty  
    ENDFOR
ENDIF 

;; calculate Fourier quantities, then perform frequency rebinning
;; save results
FOR i=0,ndim-1 DO BEGIN
    foupath=fouroot+'/onelength/'+string(format='(I7.7)',dim(i))+'_rebin'
    foucalc,time,rate,foupath, $
      dseg=dim(i),normindiv=normindiv, $
      schlittgen=schlittgen,leahy=leahy,miyamoto=miyamoto, $
      avg_bkg=avg_bkg, $ 
      linf=linf,logf=logf, $
      zhang_dt=zhang_dt, $
      ninstr=ninstr,deadtime=deadtime,nonparalyzable=nonparalyzable, $ 
      pca_dt=pca_dt, $
      pcuon=pcuon,vle=vle,level=level, $
      hexte_dt=hexte_dt, cluster_a=cluster_a, $
      xuld=xuld, cluster_b=cluster_b, $
      fmin=fmin,fmax=fmax, $  
      obsid=obsid,username=username,date=date, $
      history=lchistory,chatty=chatty    
ENDFOR

;; merge rebinned Fourier quantities from different segment lengths
;; (fmin=1/dim[*]*bt, fmax=fcut) for all channels
;; save results
mergelist=strarr(nfou)
histolist=strarr(nfou)
FOR j=0,nfou-1 DO BEGIN
    mergelist(j)=fouroot+'/merged/merge_rebin_'+fouquan(j)+'.xdrfu'
    histolist(j)=fouroot+'/merged/merge_rebin_'+fouquan(j)+'.history'
    foulist=strarr(ndim)
    FOR i=0,ndim-1 DO BEGIN 
        foulist(i)=fouroot+'/onelength/'+string(format='(I7.7)',dim(i))
        foulist(i)=foulist(i)+'_rebin_'+fouquan(j)+'.xdrfu'
    ENDFOR 
    foumerge,foulist,mergelist(j),histolist(j),fcut=fcut,chatty=chatty
ENDFOR 

;; save ps-plot of merged Fourier quantities for all channels
FOR i=0,nplot-1 DO BEGIN
    mergename=fouroot+'/merged/merge_rebin_'+plotquan(i)+'.xdrfu'
    plotname=fouroot+'/plots/'+plotquan(i)
    IF (ploterror(i) NE 'none') THEN BEGIN 
        errorname=fouroot+'/merged/merge_rebin_'+ploterror(i)+'.xdrfu'
    ENDIF ELSE BEGIN
        errorname='none'
    ENDELSE    
    IF (plotnoise(i) NE 'none') THEN BEGIN 
        noisename=fouroot+'/merged/merge_rebin_'+plotnoise(i)+'.xdrfu'
    ENDIF ELSE BEGIN
        noisename='none'
    ENDELSE     
    fouplot,mergename,plotname,errorname=errorname,noisename=noisename, $
      quantity=plotquan(i), $
      xmin=plotxmin(i),xmax=plotxmax(i), $
      ymin=plotymin(i),ymax=plotymax(i), $
      xtenlog=plotxtenlog(i),ytenlog=plotytenlog(i),sym=plotsym(0), $
      fcut=fcut,label=[type,obsid,username,date,channels], $
      color=plotcolor(i),postscript=postscript,chatty=chatty 
ENDFOR 

;; save ps-plot of none-rebinned Fourier quantities for all channels
IF (nof EQ 1) THEN BEGIN
    FOR i=0,nplot-1 DO BEGIN
        FOR j=0,ndim-1 DO BEGIN 
            onename=fouroot+'/onelength/'+string(format='(I7.7)',dim(j))+'_'
            onename=onename+plotquan(i)+'.xdrfu'
            plotname=fouroot+'/plots/'+string(format='(I7.7)',dim(j))+'_'
            plotname=plotname+plotquan(i)+'_norebin'
            IF (ploterror_norebin(i) NE 'none') THEN BEGIN 
                errorname=fouroot+'/onelength/'+string(format='(I7.7)',dim(j))+'_'
                errorname=errorname+ploterror_norebin(i)+'.xdrfu'
            ENDIF ELSE BEGIN
                errorname='none'
            ENDELSE    
            IF (plotnoise(i) NE 'none') THEN BEGIN 
                noisename=fouroot+'/onelength/'+string(format='(I7.7)',dim(j))+'_'
                noisename=noisename+plotnoise(i)+'.xdrfu'
            ENDIF ELSE BEGIN
                noisename='none'
            ENDELSE     
            fouplot,onename,plotname,errorname=errorname,noisename=noisename, $
              quantity=plotquan(i), $
              xmin=plotxmin(i),xmax=plotxmax(i), $
              ymin=plotymin(i),ymax=plotymax(i), $
              xtenlog=plotxtenlog(i),ytenlog=plotytenlog(i),sym=plotsym(1), $
              label=[type,obsid,username,date,channels], $
              color=plotcolor(i),postscript=postscript,chatty=chatty 
        ENDFOR 
    ENDFOR 
ENDIF 




END 





