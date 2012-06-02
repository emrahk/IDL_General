PRO rxte_syncseg,path,channels, $
		 hexte=hexte,bkg=bkg,back_p=back_p,back_m=back_m, $
                 orgbin=orgbin,newbin=newbin,dseg=dseg,dutylimit=dutylimit, $
                 obsid=obsid,username=username,date=date, $
                 chatty=chatty,novle=novle
;+
; NAME:
;          rxte_syncseg  
;
;
; PURPOSE: produce evenly spaced segments out of RXTE/PCA and
;          RXTE/HEXTE lightcurves, process PCA deadtime info    
;   
;   
; FEATURES:      
;          prepare RXTE high time-resolution lightcurves extracted
;          in multiple energy bands (``channels'') and with given
;          bintimes (``orgbin'') for the analysis with
;          rxte_fourier.pro (calculate Fourier quantities) and
;          rxte_zuramo.pro (perform first order linear state space
;          model fits); the lightcurves can be rebinned by an integer
;          factor given by ``newbin''; strictly time-synchronous
;          lightcurves for all energy bands are created (and can be
;          checked for the occurence of neighboring zero count rates:
;          see ``dutylimit'') and cut into evenly spaced segments of
;          dimension ``dseg''; the input and output lightcurves are
;          stored in subdirectories of the input directory ``path'';
;          the output lightcurves contain a history string array
;          containing the keyword strings ``obsid'', ``username'',
;          ``date'', and others; for PCA lightcurves, if the deadtime
;          information exists in the <path>/light/raw/ directory,
;          subroutines generate pcadead-files in the
;          <path>/light/processed/ directory for the final lcs 
;
; CATEGORY:
;          timing tools for RXTE/PCA lightcurves 
;
;
; CALLING SEQUENCE:
;         rxte_syncseg,path,channels, $
;                      hexte=hexte,bkg=bkg,back_p=back_p,back_m=back_m, $
;                      orgbin=orgbin,newbin=newbin,dseg=dseg, $
;                      dutylimit=dutylimit, $
;                      obsid=obsid,username=username,date=date, $
;                      chatty=chatty  
;
;   
; INPUTS:
;          path     : string containing the path to the observation
;                     directory which must have a subdirectory light/raw/ where
;                     the original lightcurves are stored in FITS format, named
;                     according to the output of the IAAT extraction scripts
;                     (e.g., PCA: FS37_978fa90-9790888__excl_8_160-214.lc or
;                     HEXTE: FS_04.00-a_src_6_15-30.lc), and a subdirectory
;                     light/processed/ for the resulting xdr
;                     lightcurves       
;          channels : string array containing the channel ranges (pha
;                     channels) of all energy bands that are to be
;                     considered  
;          orgbin   : double array containing the bintime exponent of
;                     each energy band with the bintime in sec being
;                     expressed as power of the basis 2 (the basis 2
;                     is generally used for the bintime by the PCA
;                     modi und the exponent is part of the FITS
;                     lightcurve file name)  
;
;   
; OPTIONAL INPUTS:
;          newbin   : integer array containing the rebin factor for
;                     each energy band;    
;                     default: 1 for all energy bands, i.e., no
;                     rebinning
;          dseg     : parameter containing the length in bins (after
;                     rebinning) of the evenly spaced, synchronous
;                     lightcurve segments that are produced;
;                     default: 1/10th of the time between the first
;                     and the last time bin of the synchronized time
;                     array given in the same units as the time array 
;          dutylimit: array giving the limit for the percentage of the
;                     elements of the rate array (after synchronizing,
;                     before segmenting) for each energy channel, that
;                     are NOT ZERO FOLLOWED BY ANOTHER ZERO; 
;                     gaps in the corresponding time array are NOT
;                     taken into account;
;                     if dutylimit is not given or the measured
;                     duty cycle is above the given limit, the duty cycle
;                     is printed to the screen and to the history string;
;                     if the measured duty cycle is below the given
;                     limit, the program is interrupted;
;                     default: dutylimit undefiend    
;          obsid    : string giving the name of the observation;
;                     this name is stored in the history keyword of
;                     the xdr lightcurve;
;                     default: 'Keyword obsid has not been set
;                     (rxte_syncseg)' 
;          username : string giving the name of the user ;
;                     this name is stored in the history keyword of
;                     the xdr lightcurve;
;                     default: 'Keyword username has not been set
;                     (rxte_syncseg)' 
;          date     : string giving the production date of the xdr
;                     lightcurve;
;                     this name is stored in the history keyword of
;                     the xdr lightcurve;
;                     default: 'Keyword date has not been set
;                     (rxte_syncseg)'    
;
;
; KEYWORD PARAMETERS:
;          hexte    : only those lightcurves in the <path>/light/raw
;                     directory that have a name according to the
;                     HEXTE high time resolution extraction
;                     (e.g., FS_04.00-a_src_6_15-30.lc or
;                      FS_04.00-a_bkg_6_15-30.lc) are time-synchronized and
;                     segmented;
;                     if hexte=1 and none of the background keywords
;                     is set, then the HEXTE source files are read       
;                     default: hexte=0, i.e, PCA lightcurves
;                              are read    
;          bkg      : HEXTE background lightcurves are read;
;                     hexte=1 has to be set for this;   
;                     the background has to be combined 
;                     (e.g., FS_04.00-a_bkg_6_15-30.lc);   
;                     default: bkg=0
;          back_p   : HEXTE background lightcurves are read;
;                     hexte=1 has to be set for this; 
;                     the background has to be ``plus'' 
;                     (e.g., FS_04.00-a_p_6_15-30.lc);   
;                     default: back_p=0
;          back_m   : HEXTE background lightcurves are read;
;                     hexte=1 has to be set for this;  
;                     the background has to be ``minus'' 
;                     (e.g., FS_04.00-a_m_6_15-30.lc);   
;                     default: back_m=0
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0        
;          novle    : if set, do not synchronize pcadeadtime files   
;   
;   
; OUTPUTS:
;          none, but: see side effects and keyword defaults
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
;          the resulting two multidimensional lightcurves are
;          written to the <path>/light/processed/ directory in xdr
;          format; first lightcurve: sync(_bkg(_p/m)).xdrlc, containes the
;          time-synchronized, rebinned lightcurves of all energy
;          bands; second lightcurve: <dseg>_seg(_bkg(_p/m)).xdrlc, produced
;          by cutting sync(_bkg(_p/m)).xdrlc into evenly spaced segments of
;          dimension dseg (during the procedure, temporary files are
;          also written to this directory and deleted again), 
;          for PCA lightcurves, if the deadtime information exists
;          in the <path>/light/raw/ directory, subroutines generate
;          pcadead-files in the <path>/light/processed/ directory
;          for the final lcs,   
;          some keyword defaults are set   
;
;   
; RESTRICTIONS: 
;          input lightcurves have to be FITS lightcurves in the
;          <path>/light/raw/ subdirectory and have to be named
;          according to the output of the IAAT extraction scripts
;          (e.g., PCA: FS37_978fa90-9790888__excl_8_160-214.lc or
;          HEXTE: FS_04.00-a_src_6_15-30.lc); the subdirectories
;          <path>/light/raw/ and <path>/light/processed/ must exist;
;          outside of the gaps the lightcurves have to be evenly
;          spaced with a bintime given in sec that can be expressed as
;          integer power for the basis 2; outside of the gaps the
;          lightcurves from different energy bands must have the same
;          time array after rebinning them by the integer factors
;          given in newbin;
;          several parameters/keywords must have the same number of
;          elements: channels,orgbin,newbin,dutylimit   
;   
;
; PROCEDURES USED: 
;          lcmerge.pro, lcsync.pro, lcseg.pro      
;          pcadeadmerge.pro, pcadeadsync.pro
;
; EXAMPLE:
;          rxte_syncseg,'01.all',['0-10','11-13'], $
;                 orgbin=[-8D0,-8D0],newbin=[2L,2L],dseg=131072L, $
;                 dutylimit=[80D0,80D0], $   
;                 obsid='P40099/01.all', $
;                 username='Katja Pottschmidt', $
;                 date=systime(0),/chatty      
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/20 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined   
;          Version 1.3, 2000/10/20 Katja Pottschmidt,    
;                                  minor changes,
;                                  synchronizing of IDL and cvs
;                                  version numbers
;          Version 1.4, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header: minor changes,  
;                                  default for history keywords changed   
;          Version 1.5, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header: minor changes 
;                                  in dseg description  
;          Version 1.6, 2000/11/02 Katja Pottschmidt,   
;                                  IDL header: minor changes, 
;                                  default for chatty keyword changed
;          Version 1.7, 2000/11/02 Katja Pottschmidt,   
;                                  IDL version number corrected    
;          Version 1.8, 2000/11/07 Katja Pottschmidt,   
;                                  IDL header: minor changes     
;          Version 1.9, 2000/11/16 Katja Pottschmidt,   
;                                  no changes     
;          Version 1.10,2000/11/22 Katja Pottschmidt, Emrah Kalemci,   
;                                  added HEXTE background correction
;                                  keywords (for the psd normalization),
;                                  ``path'' does not contain ``light''
;                                  anymore,
;                                  careful: defaults and IDL header
;                                  are not updated yet
;          Version 1.11,2000/12/11 Katja Pottschmidt,   
;                                  defaults and IDL header
;                                  have been updated (see V 1.10)  
;          Version 1.12,2000/12/12 Katja Pottschmidt,      
;                                  no changes   
;          Version 1.13,2000/12/13 Emrah Kalemci 
;                                  hexte background keyword bug corrected
;          Version 1.14,2000/12/14 KP:merged EK and KP changes   
;          Version 1.15,2000/12/22 KP: produce average pcadead files   
;          Version 1.16,2000/12/22 KP/JW: added novle keyword
;          Version 1.17,2001/01/05 KP: added dutylimit keyword              
;          Version 1.18,2001/01/28 KP: IDL header updated (pcadead routines) 
;          Version 1.19,2001/07/19 KP: if the mergeXXX.xdrlc
;                                  help-files cannot be removed
;                                  because they do not exist, then the 
;                                  mergeXXX.xdrlc.gz files are removed
;
;-
   
   
;; helpful parameters
pa         = path+'/light'  
lcroot     = pa+'/raw'
nch        = n_elements(channels)
mergenames = strarr(nch)
mergeroot  = pa+'/processed/merge'
syncname   = pa+'/processed/sync.xdrlc'
segname    = pa+'/processed/'+string(format='(I7.7)',dseg)+'_seg.xdrlc'
   

;; set default values,
;; the default value for dseg is set in the lcseg.pro subroutine
IF (n_elements(hexte) EQ 0) THEN hexte=0
IF (n_elements(bkg) EQ 0) THEN bkg=0
IF (n_elements(back_p) EQ 0) THEN back_p=0
IF (n_elements(back_m) EQ 0) THEN back_m=0
IF (n_elements(obsid) EQ 0) THEN BEGIN 
    obsid='Keyword obsid has not been set (rxte_syncseg)'
ENDIF     
IF (n_elements(username) EQ 0) THEN BEGIN 
    username='Keyword username has not been set (rxte_syncseg)'
ENDIF     
IF (n_elements(date) EQ 0) THEN BEGIN 
    date='Keyword date has not been set (rxte_syncseg)'
ENDIF     
IF (n_elements(newbin) EQ 0) THEN BEGIN 
    newbin=lonarr(nch)
    newbin[*]=1L
ENDIF 
IF (n_elements(chatty) EQ 0) THEN chatty=1


;; merge lightcurves for each individual energy range
nsum=bkg+back_p+back_m
FOR i=0,nch-1 DO BEGIN
    
    bin=string(format='(I1)',orgbin(0))
   
    IF keyword_set(hexte) THEN BEGIN
  
        IF (nsum GE 2) THEN BEGIN
            message,'Only one HEXTE background keyword can be set'
        ENDIF 
        IF keyword_set(bkg) THEN BEGIN 
            ;; list HEXTE background lightcurve names
            spawn,['/usr/bin/find',lcroot,'-name', $
                   '*'+'bkg_'+bin+'_'+channels(i)+'.lc'], $
              lclist,/noshell
            syncname   = pa+'/processed/sync_bkg.xdrlc'
            segname    = pa+'/processed/'+string(format='(I7.7)',dseg)+'_seg_bkg.xdrlc'
        ENDIF
        IF keyword_set(back_p) THEN BEGIN 
            ;; list HEXTE background lightcurve names
            spawn,['/usr/bin/find',lcroot,'-name', $
                   '*'+'p_'+bin+'_'+channels(i)+'.lc'], $
              lclist,/noshell
            print,lclist
            syncname   = pa+'/processed/sync_bkg_p.xdrlc'
            segname    = pa+'/processed/'+string(format='(I7.7)',dseg)+'_seg_bkg_p.xdrlc'
        ENDIF
        IF keyword_set(back_m) THEN BEGIN 
            ;; list HEXTE background lightcurve names
            spawn,['/usr/bin/find',lcroot,'-name', $
                   '*'+'m_'+bin+'_'+channels(i)+'.lc'], $
              lclist,/noshell
            syncname   = pa+'/processed/sync_bkg_m.xdrlc'
            segname    = pa+'/processed/'+string(format='(I7.7)',dseg)+'_seg_bkg_m.xdrlc'
        ENDIF
        IF (nsum EQ 0) THEN BEGIN
            ;; list HEXTE source lightcurve names
            spawn,['/usr/bin/find',lcroot,'-name', $
                   '*'+'src_'+bin+'_'+channels(i)+'.lc'], $
              lclist,/noshell
        ENDIF
        
    ENDIF ELSE BEGIN
        
        IF (nsum NE 0) THEN BEGIN
            message,'No HEXTE background keyword can be set, if hexte=1 is not specified'     
        ENDIF 
       ;; list PCA lightcurve names
        spawn,['/usr/bin/find',lcroot,'-name','*'+bin+'_'+channels(i)+'.lc'], $
          lclist,/noshell
        
    ENDELSE

    
    mergenames[i]=mergeroot+string(format='(I3.3)',i)+'.xdrlc'
    lcmerge,lclist,mergenames(i),channelrange=channels(i), $
      bintime=orgbin(i),factor=newbin(i),chatty=chatty

ENDFOR 

IF (NOT keyword_set(novle) AND NOT keyword_set(hexte)) THEN BEGIN 
    ;; compute averages of PCA deadtime indicators
    pcadeadmerge,lclist,mergeroot
END 

;; time-synchronize merged lightcurves from all energy ranges
lcsync,mergenames,syncname,dutylimit=dutylimit, $
  obsid=obsid,username=username,date=date, $
  chatty=chatty

;; remove merged lightcurves
FOR i=0,nch-1 DO BEGIN
     IF (NOT file_exist(mergenames[i])) THEN mergenames[i]=mergenames[i]+'.gz'
    spawn,['/bin/rm',mergenames(i)],/noshell
ENDFOR 

IF (NOT keyword_set(novle) AND NOT keyword_set(hexte) ) THEN BEGIN 
    ;; copy mergeroot.pcadead to syncname.pcadead 
    ppp=strpos(syncname,'.xdrlc')
    deadsyncname=strmid(syncname,0,ppp)
    pcadeadsync,mergeroot+'.pcadead',deadsyncname
    spawn,['/bin/rm',mergeroot+'.pcadead'],/noshell
ENDIF 

;; cut synchronized lightcurves into segments of dimension dseg  
lcseg,syncname,segname,dseg=dseg,chatty=chatty

IF ( NOT keyword_set(novle) AND NOT keyword_set(hexte) ) THEN BEGIN 
    ;; copy syncname.pcadead to segname.pcadead 
    ppp=strpos(segname,'.xdrlc')
    deadsegname=strmid(segname,0,ppp)
    pcadeadsync,deadsyncname+'.pcadead',deadsegname
ENDIF 



END  








