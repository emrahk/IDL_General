PRO freqrebin,ofreq,oquan,nfreq,nquan,nsigm,osigm, $
              linf=linf,logf=logf,nof=nof,newfreq=newfreq, $
              nseg=nseg,nf=nf,high=high,chatty=chatty
;+
; NAME:
;          freqrebin
;
;
; PURPOSE:
;          frequency rebinning of a Fourier quantity can
;          be performed; for multi-segment Fourier quantities
;          averaging over segments is performed
;
; FEATURES: Linear (``linf'' bins) or logarithmic (to df/f=``logf'')
;          frequency rebinning can be performed for a
;          ''multi-segment'' Fourier quantity or for one channel (PSD)
;          / one channel pair (lags) of a ``multi-band'' Fourier
;          quantity (given as ``ofreq'' and ``oquan''), alternatively
;          a new frequency array can be provided for rebinning
;          (``newfreq''), the uncertainties for each new frequncy bin
;          are given (``nsigm'',``osigm''). If ``nof'' is set
;          (default) no frequency rebinning is performed. IF THE
;          FORMAT OF THE INPUT ARRAY ``oquan'' IS SUCH THAT THE SECOND
;          DIMENSION IS A NUMBER OF SEGMENTS, THEN AN AVERAGING OVER
;          SEGMENTS IS ALSO PERFORMED AND THE OUTPUT ``nseg'' GIVES
;          THE NUMBER OF SEGMENTS. IF THE SECOND DIMENSION IS A
;          SELECTED ENERGY BAND / BAND PAIR (SEE ``FOUCLAC'' !!!) THE
;          AVERAGING (OF ``oquan'', ``nsigm'',``osigm'') OVER SEGMENTS
;          HAS TO BE PERFORMED SEPARATELY AND THE OUTPUT ``nseg'' IS
;          1. The new multidimensional Fourier quantity is given in
;          the ``nfreq'' and ``nquan'' output arrays. The output array
;          ''high'' contains the upper frequency boundary of the new
;          frequency bins, ``nf'' the number of original frequencies
;          in each new bin.
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          freqrebin,ofreq,oquan,nfreq,nquan,nsigm,osigm, $
;                    linf=linf,logf=logf,nof=nof,newfreq=newfreq, $
;                    nseg=nseg,nf=nf,high=high,chatty=chatty
;
;
; INPUTS:
;          ofreq    : original frequency array
;          oquan    : original Fourier quantity array;
;                     details about the dimensions are explained in FEATURES
;
; OPTIONAL INPUTS:
;          newfreq  : if given, the quanities are rebinned to this new, user supplied frequency array
;          linf     : if given, linear frequency rebinning to the given number of bins is performed
;          logf     : if given, logarithmic frequency rebinning is  performed to constant df/f
;                default: newfreq/linf/logf not set, but nof=1, see blow;
;                         only one of the inputs newfreq/linf/logf/nof
;                         may be given 
; KEYWORD PARAMETERS:
;           nof     : if set, no frequency rebinning is performed 
;           chatty  : if set, information is written to screen
;
; OUTPUTS:
;          nfreq    : rebinned frequency array
;          nquan    : rebinned Fourier quantity array
;          nsigm    : one sigma error for averaged psds(!!) (chi^2 distribution):
;                     nsigm(i)=nquan(i)/sqrt(nf(i)*nseg)
;          osigm    : standard deviation of all the old quanity values 
;                     in the new frequency bin:
;                     osigm(i)=sqrt(total((oquan(ndx,*)-nquan(i))^2.)/((nf(i)*nseg)-1.))
; 
; OPTIONAL OUTPUTS:
;          nseg     : number of segments contributing to each new frequency bin;
;                     note: read FEATURES!
;          nf       : number of original Fourier frequencies in each new bin 
;          high     : while ``nfreq'' is giving the lower boundary of each new
;                     frequency bin, high is an array giving the upper boundary,
;                     (nfreq+high)/2. should be used plots etc.
;  
; COMMON BLOCKS:
;          none 
;
;
; SIDE EFFECTS:
;          setting of keywords (e.g., nof=1 is default)
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
;          Version 1.2  1999/01/25 Katja Pottschmidt,  
;                                  minor changes
;          Version 1.3  2001/02/08 Katja Pottschmidt,
;                                  IDL header added (not yet finished),   
;                                  output keyword ``high'' added 
;          Version 1.4  2001/12/06 Katja Pottschmidt,
;                                  IDL header completed                                   
;
;-
   
   
;; frequency-rebin-keywords (logf,linf,newfreq,nof), default: 
;; nof=1: no frequency rebinning
nkey=0
IF (n_elements(logf) NE 0)    THEN nkey=nkey+1
IF (n_elements(linf) NE 0)    THEN nkey=nkey+1
IF (n_elements(nof) NE 0)     THEN nkey=nkey+1
IF (n_elements(newfreq) NE 0) THEN nkey=nkey+1
IF (nkey GT 1) THEN BEGIN
    message,'freqrebin: Only one way of rebinning is allowed'
ENDIF 
IF (nkey EQ 0) THEN BEGIN 
    nof=1
ENDIF 


;; chatty-keyword   
IF (n_elements(logf) NE 0) AND (keyword_set(chatty)) THEN BEGIN
    print,'freqrebin: The frequency array '
    print,'will be logarithmically rebinned, df/f: ',logf
ENDIF
IF (n_elements(linf) NE 0) AND (keyword_set(chatty)) THEN BEGIN
    print,'freqrebin: The frequency array '
    print,'will be linearly rebinned, number of bins: ',linf
ENDIF 
IF (keyword_set(nof)) AND (keyword_set(chatty)) THEN BEGIN 
    print,'freqrebin: The frequency array '
    print,'will not be rebinned'
ENDIF 
IF (n_elements(newfreq) NE 0) AND (keyword_set(chatty)) THEN BEGIN 
    print,'freqrebin: The frequency array '
    print,' is custom-rebinned'
ENDIF  
   

;; number of segments to be averaged
nseg=n_elements(oquan(0,*))
IF (keyword_set(chatty)) THEN BEGIN 
    print,'freqrebin: Number of lightcurve segments the Fourier-'
    print,'quantities will be averaged over: ',nseg 
ENDIF 
   

;; generate the rebinned frequency array
fmin=min(ofreq)
fmax=max(ofreq)
IF (n_elements(linf) NE 0) THEN BEGIN 
    efreq=fmin+(findgen(linf+1)*(fmax-fmin)/linf)
ENDIF    
IF (n_elements(logf) NE 0) THEN BEGIN 
    imax=fix(1.+alog(fmax/fmin)/alog(1.+logf))
    efreq=alog(fmin)+findgen(imax)*alog(1.+logf)
    efreq=exp(efreq)
ENDIF 
IF (n_elements(newfreq) NE 0) THEN BEGIN 
    efreq=newfreq
ENDIF 


;; dimension of the rebinned frequency array
IF (keyword_set(nof)) THEN BEGIN
    ndim=n_elements(ofreq)
ENDIF ELSE BEGIN
    ndim=n_elements(efreq)
ENDELSE 


;; initialize rebinned arrays
nfreq = fltarr(ndim)   &   nquan = fltarr(ndim) 
nsigm = fltarr(ndim)   &   osigm = fltarr(ndim)
nf    = lonarr(ndim)   &   high  = fltarr(ndim)  


;; rebin the frequency array and the quantity array (averaging over nseg
;; segments and optionally over frequencies), 
;; determine the quantity error array and the number nf of averaged frequencies
IF (keyword_set(nof)) THEN BEGIN
    nf(*)=1L
    FOR i=0L,ndim-1 DO BEGIN 
        nquan(i)=total(oquan(i,*))/nseg
    ENDFOR 
    nfreq=ofreq
    nsigm=nquan/sqrt(nseg)
    osigm=oquan
ENDIF ELSE BEGIN 
    i=0L
    FOR k=0L,ndim-2L DO BEGIN 
        ndx=where((ofreq GE efreq(k)) AND (ofreq LT efreq(k+1)))
        IF (ndx(0) NE -1) THEN BEGIN
            nf(i)=n_elements(ndx)
            nquan(i)=total(oquan(ndx,*))/(nf(i)*nseg)
            nfreq(i)=efreq(k)
            high(i)=efreq(k+1)
            ;; one sigma error for averaged psds (chi^2 distribution)
            nsigm(i)=nquan(i)/sqrt(nf(i)*nseg)
            ;; standard deviation of all the old psd values 
            ;; in the new frequency bin
            IF (nf(i)*nseg NE 1L) THEN BEGIN 
                osigm(i)=sqrt(total((oquan(ndx,*)-nquan(i))^2.)/ $
                              ((nf(i)*nseg)-1.))
            ENDIF ELSE BEGIN 
                osigm(i)=nquan(i)
            ENDELSE                 
            i=i+1L
        ENDIF ELSE BEGIN 
            IF (keyword_set(chatty)) THEN BEGIN 
                print,'Empty frequency-bin, rebinned index: ',k+1L
            ENDIF 
        ENDELSE 
    ENDFOR 
    nfreq = temporary(nfreq(0L:i-1L))   &   nquan = temporary(nquan(0L:i-1L))
    nsigm = temporary(nsigm(0L:i-1L))   &   osigm = temporary(osigm(0L:i-1L))
    nf    = temporary(nf(0L:i-1L))      &   high  = temporary(high(0L:i-1L))
    
ENDELSE 


END 





