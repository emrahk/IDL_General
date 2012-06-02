PRO foumerge,foulist,mergename,historyname,fcut=inpfcut,chatty=chatty
;+
; NAME:
;          foumerge
;
;
; PURPOSE:   
;          read, merge and save multidimensional Fourier quanities
;          (xdr format) that were obtained from the same original
;          lightcurves but for different lightcurve segment lengths
;   
;
; FEATURES:
;          merge several ``versions'' of the same multidimensional
;          Fourier quanity, either calculated from one lightcurve
;          (power spectra) or from two lightcurves (lag spectra,
;          coherence functions), that were obtained from the same
;          lightcurve data but for different lightcurve segment
;          lengths (thus coverage of low frequencies can be achieved
;          with long segments, and at the same time the higher
;          frequencies can be covered with better statistics from the
;          short segments); the upper frequency boundary up to which
;          data from each segment length are included is given by the
;          ``fcut'' array, the lower frequency boundary is given by
;          1./(segment length); the path+filenames of the xdr datasets that
;          are to be merged are given by the input string array
;          ``foulist'' and the path+filename for the resulting merged xdr
;          quantity is given by the output string ``mergename'' with
;          the corresponding merged history being stored in an ASCII
;          file whose path+name has to be given in the string
;          ``historyname''
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          foumerge,foulist,mergename,historyname,fcut=inpfcut,chatty=chatty
;
;
; INPUTS:
;          foulist     : paths and names of the xdr files
;                        containing the Fourier quantities that are to
;                        be merged 
;          mergename   : path and name of the xdr file containing the
;                        resulting merged Fourier property 
;          historyname : path and name of the history file (ASCII)
;                        containing the merged histories extracted
;                        from the headers of the xdr files given in foulist 
;          fcut        : upper frequency boundary for each element of
;                        <foulist>, only frequencies below this limit
;                        will be taken into account in the merged
;                        Fourier quantity for the given element    
;
; OPTIONAL INPUTS:
;          none     
;                        
;
; KEYWORD PARAMETERS:
;          chatty      :  controls screen output; 
;                         default: screen output;  
;                         to turn off screen output, set
;                         chatty=0
;
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
;          the resulting merged Fourier quantity and the
;          corresponding history file are written to
;          the directory specified by <mergelist>; it is written   
;          in xdr format (the .history file is ASCII) and the output
;          file name is also specified by <mergelist>;    
;   
;          if <foulist>, <mergelist>, <historyname>, and the optional
;          keywords are provided by rxte_fourier, foumerge is called
;          several times and the following files are written to
;          <path>/light/fourier/<type>/merged/:  
;   
;          (``_corr'' is added to the filenames of normalized psd
;          quantities when the miyamoto/pca_bkg or miyamoto/hexte_bkg
;          keyword combination has been set in rxte_fourier;
;          the .history files are ASCII;   
;          only ``*_rebin_*'' files are merged)
;   
;          merge_rebin_cof.history               : history file of: see below
;          merge_rebin_cof.xdrfu                 : frequency rebinned and merged
;                                                  coherence function,
;                                                  noise subtracted   
;          merge_rebin_errcof.history            : history file of: see below
;          merge_rebin_errcof.xdrfu              : frequency rebinned and merged
;                                                  uncertainty of
;                                                  coherence function 
;          merge_rebin_errlag.history            : history file of: see below
;          merge_rebin_errlag.xdrfu              : frequency rebinned and merged
;                                                  uncertainty of lag spectrum  
;          merge_rebin_errnormpsd(_corr).history : history file of: see below
;          merge_rebin_errnormpsd(_corr).xdrfu   : frequency rebinned and merged   
;                                                  uncertainty of normalized,
;                                                  not noise subtracted
;                                                  power spectrum    
;          merge_rebin_foinormpsd(_corr).history : history file of: see below
;          merge_rebin_foinormpsd(_corr).xdrfu   : frequency rebinned and merged
;                                                  effective noise level
;                                                  of normalized power spectrum   
;          merge_rebin_lag.history               : history file of: see below
;          merge_rebin_lag.xdrfu                 : frequency rebinned and merged
;                                                  lag spectrum, 
;                                                  not noise subtracted
;          merge_rebin_noinormpsd(_corr).history : history file of: see below
;          merge_rebin_noinormpsd(_corr).xdrfu   : frequency rebinned and merged
;                                                  normalized, 
;                                                  not noise subtracted 
;                                                  power spectrum
;          merge_rebin_signormpsd(_corr).history : history file of: see below
;          merge_rebin_signormpsd(_corr).xdrfu   : frequency rebinned and merged  
;                                                  normalized, 
;                                                  noise subtracted 
;                                                  power spectrum      
;      
;   
; RESTRICTIONS:
;          the Fourier quantities that are to be merged have to be
;          stored in xdr format in the directory and under the file
;          names specified by <foulist>; the frequency boundary fcut[*]
;          has to be given for each element of <foulist>    
;
;
;
; PROCEDURES USED:
;          xdrfu_r1.pro
;          xdrfu_r2.pro
;          xdrfu_w1.pro
;          xdrfu_w2.pro
;
;
; EXAMPLE:
;          see rxte_fourier.pro
;   
;          in this case:  
;   
;          mergelist=strarr(nfou)
;          histolist=strarr(nfou)
;          FOR j=0,nfou-1 DO BEGIN
;              mergelist(j)=fouroot+'/merged/merge_rebin_'+fouquan(j)+'.xdrfu'
;              histolist(j)=fouroot+'/merged/merge_rebin_'+fouquan(j)+'.history'
;              foulist=strarr(ndim)
;              FOR i=0,ndim-1 DO BEGIN 
;                  foulist(i)=fouroot+'/onelength/'+string(format='(I7.7)',dim(i))
;                  foulist(i)=foulist(i)+'_rebin_'+fouquan(j)+'.xdrfu'
;              ENDFOR 
;          foumerge,foulist,mergelist(j),histolist(j),fcut=fcut,chatty=chatty
;          ENDFOR    
;   
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.3, 2000/12/13 Katja Pottschmidt,   
;                                  IDL header added,
;                                  not yet finished   
;          Version 1.4, 2001/01/30 Katja Pottschmidt,  
;                                  IDL header completed
;          Version 1.5, 2001/01/31 Katja Pottschmidt,  
;                                  minor changes in header   
;          Version 1.6, 2001/07/10 Katja Pottschmidt,  
;                                  if the non-gzipped file does not
;                                  exist, the gzipped file is read 
;                                     
;
;-
   

;; helpful parameters   
fcut=double(inpfcut)
ncut=n_elements(fcut)
ndim=n_elements(foulist)
IF (ndim NE ncut) THEN BEGIN 
    message, $
      'foumerge: foulist und fcut must have the same number of elements and the same order' 
ENDIF 


;; read version
IF (NOT file_exist(foulist[0])) THEN foulist[0]=foulist[0]+'.gz'
openr,unit,foulist[0],/get_lun,/xdr,/compress
version=''
readu,unit,version
free_lun,unit


;; version 1 merge
IF (version EQ 'xdrfu1 1.0') THEN BEGIN
    xdrfu_r1,foulist(0),freq,oneseg,history=history,chatty=chatty
    fgrenz=string(fcut(0))
    hisfin=temporary([history,'Maximum frequency (foumerge)='+fgrenz])
    ndx=where(freq LT fcut(0))
    mergefreq=freq(ndx)
    mergequan=oneseg(ndx,*)    
    FOR i=0,ndim-2 DO BEGIN
        xdrfu_r1,foulist(i+1),freq,oneseg, $
          history=history,chatty=chatty
        fgrenz=string(fcut(i+1))
        hisfin=temporary([hisfin,history,'Maximum frequency (foumerge)='+fgrenz])
        ndx=where(freq LT fcut(i+1))
        mergefreq=temporary([mergefreq,freq(ndx)])
        mergequan=temporary([mergequan,oneseg(ndx,*)])
    ENDFOR 
    nhist=n_elements(hisfin)+1
    finfin=['Dimension of history (foumerge)='+string(nhist),hisfin]
    xdrfu_w1,mergename,mergefreq,mergequan,history=finfin,chatty=chatty
ENDIF 


;; version 2 merge
IF (version EQ 'xdrfu2 1.0') THEN BEGIN
    xdrfu_r2,foulist(0),freq,oneseg,history=history,chatty=chatty
    fgrenz=string(fcut(0))
    hisfin=temporary([history,'Maximum frequency (foumerge)='+fgrenz])
    ndx=where(freq LT fcut(0))
    mergefreq=freq(ndx)
    mergequan=oneseg(ndx,*,*)    
    FOR i=0,ndim-2 DO BEGIN
        xdrfu_r2,foulist(i+1),freq,oneseg, $
          history=history,chatty=chatty
        fgrenz=string(fcut(i+1))
        hisfin=temporary([hisfin,history,'Maximum frequency (foumerge)='+fgrenz])
        ndx=where(freq LT fcut(i+1))
        mergefreq=temporary([mergefreq,freq(ndx)])
        mergequan=temporary([mergequan,oneseg(ndx,*,*)])
    ENDFOR
    nhist=n_elements(hisfin)+1
    finfin=['Dimension of history (foumerge)='+string(nhist),hisfin]
    xdrfu_w2,mergename,mergefreq,mergequan,history=finfin,chatty=chatty
ENDIF 


openw,unit,historyname,/get_lun
printf,unit,finfin
free_lun,unit


END 




