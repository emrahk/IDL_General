PRO fouplot,nameorg,pathfin,errorname=errorname,noisename=noisename, $
            quantity=quantity, $
            xmin=xmin,xmax=xmax, $
            ymin=ymin,ymax=ymax, $
            xtenlog=xtenlog,ytenlog=ytenlog,sym=sym, $
            fcut=fcut,label=label, $
            color=color,postscript=postscript,chatty=chatty   
;+
; NAME:
;          fouplot
;
;
; PURPOSE:
;          read and plot multidimensional Fourier quanity (xdr
;          format)  
;
;
; FEATURES:
;          read and plot multidimensional Fourier quanity (xdr
;          format); one overview plot is produced, showing individual plot
;          windows for each dataset of the multidimensional quantity,
;          the path+filename of the Fourier quanity that is to be plotted
;          is given by the input string ``nameorg'' and the
;          path+filename for the resulting ps/eps plot (keyword 
;          ``postscript'') is given by the output string ``pathfin'';
;          uncertainties and noise components can be overplotted by
;          specifying their path+name in the ``errorname'' and
;          ``noisename'' keyword strings; several keywords controling
;          the ``layout'' of the plot may be given
;          (``quantity'', ``xmin'', ``xmax'', ``ymin'', ``ymax'',
;          ``xtenlog'', ``ytenlog'', ``sym'', ``fcut'', ``label'',
;          ``color'')  
;
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          fouplot,nameorg,pathfin,errorname=errorname,noisename=noisename, $
;                  quantity=quantity, $
;                  xmin=xmin,xmax=xmax, $
;                  ymin=ymin,ymax=ymax, $
;                  xtenlog=xtenlog,ytenlog=ytenlog,sym=sym, $
;                  fcut=fcut,label=label, $
;                  color=color,postscript=postscript,chatty=chatty    
;
;
; INPUTS:
;          nameorg    : path and name of the xdr file containing the
;                       multidimensional Fourier quantity that is to
;                       be plotted 
;          pathfin    : path and name of the ps/eps file containing the  
;                       resulting plot
;   
; OPTIONAL INPUTS:
;          errorname  : path and name of the xdr file containing the
;                       multidimensional frequency dependent error
;                       assigned to the quantity given in <nameorg>;
;                       if given, the errors are included in each plot
;                       window
;                       default: no errors are plotted   
;          noisename  : path and name of the xdr file containing the
;                       multidimensional noise component associated
;                       with the quantity given in <nameorg>; 
;                       if given, the noise component is overplotted
;                       in each plot window   
;                       default: no noise component is plotted
;   
;    ``layout'' keywords :
;          quantity         : string that controls the plot labels;
;                             if ``quantity'' is set to 
;                             'signormpsd','signormpsd_corr','cof', or
;                             'lag', the following labels are used:
;   
;                             'signormpsd       : title  : 'Power Spectral Density'
;                                                 y-label: 'PSD [RMS^2/Hz]'
;                                                           +', E'+energy   
;   
;                             'signormpsd_cor'  : title  : 'Power Spectral Density'
;                                                 y-label: 'PSD [RMS^2/Hz]'   
;                                                           +', E'+energy   
;   
;                             'cof'             : title  : 'Coherence'
;                                                 y-label: 'Coherence'
;                                                          +', E'+esoft+'/E'+ehard   
;   
;                             'lag'             : title  : 'Time Lags'
;                                                 y-label: 'Lag [sec]'  
;                                                          +', E'+esoft+'/E'+ehard      
;   
;                             default: ``quantity'' is undefined,
;                                      label default:
;                                      title  : '' 
;                                      x-label: 'Frequency [Hz]' (fix)
;                                      y-label: 'Arbitrary Units' 
;                                               + ', E'+energy
;                                      or
;                                      y-label: 'Arbitrary Units' 
;                                               +', E'+esoft+'/E'+ehard
;   
;          xmin, xmax       : define the plotted frequency range in Hz;
;                             default: minimum and maximum value of
;                             the frequency array that is to be
;                             plotted   
;          ymin, ymax       : define the plotted range for the
;                             Fourier quantities in psd norm (psd),
;                             relative coherence (coherence) and sec
;                             (lags);
;                             default: minimum and maximum value of
;                                      the first quantity set in the
;                                      multidimensional Fourier
;                                      quantity array that is to be
;                                      plotted      
;          xtenlog, ytenlog : switching between linear and logarithmic
;                             plotting; if set to 1 the corresponding
;                             axis is logarithmic; 
;                             default: 1, 1 for version 1 (psds),
;                                      0, 0 for version 2 (lags, coherence)  
;          sym              : value defining the plot symbol to be used;  
;                             default: 4 (diamond)  
;          fcut             : array containing the frequency boundaries
;                             between the merged quantities from
;                             different lightcurve segment lengths; 
;                             default: undefined  
;          label            : info label to be written below the plot; 
;                             string array with a maximum of five
;                             entries;     
;                             default: undefined  
;          color            : value defining the color of the plot
;                             windows;   
;                             default: 50, color table 39;
;                                      this is blue  
;   
;
; KEYWORD PARAMETERS:
;          postscript  :  decide whether a ps or an eps plot is
;                         produced; 
;                         default: postscript=1: ps plot  
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
;   
;       1. for most of the ``layout'' keywords, if they are not
;          set, the defaults are set by this routine;
;   
;       2. the resulting Fourier quantity plot is written to the
;          directory/filename specified by <nameorg> in ps or eps
;          format; 
;   
;          if <nameorg>, <pathfin>, and the optional keywords are
;          provided by rxte_fourier, fouplot is called several times
;          and the following files are written to
;          <path>/light/fourier/<type>/plots/:    
;   
;          (``_corr'' is added to the filenames of normalized psd
;          quantities when the miyamoto/pca_bkg or miyamoto/hexte_bkg
;          keyword combination has been set in rxte_fourier)
;          
;          (for non-frequency rebinned quantities (they are
;          additionally calculated only for <type>='low'), the
;          plots (``*_norebin_*'') are saved in the non-merged form
;          only) 
;   
;          <dim[*]>_cof_norebin.ps               : plots of the resulting coherence functions,
;                  			           all energy band combinations,
;                                                  noise corrected,
;                                                  full Fourier frequency resolution
;                                                  (only for
;                                                  <type>='low' and
;                                                  individual segment
;                                                  lengths) 
;          <dim[*]>_lag_norebin.ps		 : plots of the resulting lag spectra,
; 					           all energy band combinations,
;                                                  not noise corrected,
;                                                  full Fourier frequency resolution
;                                                  (only for
;                                                  <type>='low' and
;                                                  individual segment
;                                                  lengths) 
;          <dim[*]>_signormpsd(_corr)_norebin.ps : plots of the resulting power spectra,
; 					           all energy bands,
; 					           noise corrected,
;                                                  normalized,
;                                                  ``_corr'': background corrected,
;                                                  full Fourier frequency resolution
;                                                  (only for
;                                                  <type>='low' and
;                                                  individual segment
;                                                  lengths)  
;          cof.ps				 : plots of the resulting coherence functions,
; 					           all energy band combinations,
;                                                  noise corrected,
;                                                  rebinned and merged 
; 					           (for <type>='high'
; 					           only one segment
; 					           length is ``merged'') 
;          lag.ps				 : plots of the resulting lag spectra,
; 					           all energy band combinations,
;                                                  not noise corrected,
;                                                  rebinned and merged 
; 					           (for <type>='high' only one segment
; 					           length is ``merged'')
;          signormpsd(_corr).ps                  : plots of the resulting power spectra,
; 					           all energy bands,
;                                                  noise corrected,
;                                                  normalized
;                                                  ``_corr'': background corrected,
;                                                  rebinned and merged 
; 					           (for <type>='high' only one segment
;					           length is ``merged'')
;
;
; RESTRICTIONS:
;          the Fourier quantities that are to be ploted have to be
;          stored in xdr format in the directory and under the file
;          names specified by <nameorg>         
;
;
; PROCEDURES USED:
;          xdrfu_r1.pro
;          xdrfu_r2.pro   
;          jwoploterr.pro
;
;
; EXAMPLE:
;          see rxte_fourier.pro
;   
;          in this case:    
;          (for the definition of the ``layout'' keywords
;          (xmin, ..., colors) in this example, look up rxte_fourier)   
;   
;          plotquan          = ['signormpsd','cof','lag']
;          ploterror         = ['errnormpsd','errcof','errlag']
;          plotnoise         = ['foinormpsd','none','none']
;          nplot             = n_elements(plotquan)   
;   
;          ;; save ps-plot of merged Fourier quantities for all channels
;          FOR i=0,nplot-1 DO BEGIN
;              mergename=fouroot+'/merged/merge_rebin_'+plotquan(i)+'.xdrfu'
;              plotname=fouroot+'/plots/'+plotquan(i)
;              IF (ploterror(i) NE 'none') THEN BEGIN 
;                  errorname=fouroot+'/merged/merge_rebin_'+ploterror(i)+'.xdrfu'
;              ENDIF ELSE BEGIN
;                  errorname='none'
;              ENDELSE    
;              IF (plotnoise(i) NE 'none') THEN BEGIN 
;                  noisename=fouroot+'/merged/merge_rebin_'+plotnoise(i)+'.xdrfu'
;              ENDIF ELSE BEGIN
;                  noisename='none'
;              ENDELSE     
;              fouplot,mergename,plotname,errorname=errorname,noisename=noisename, $
;                      quantity=plotquan(i), $
;                      xmin=plotxmin(i),xmax=plotxmax(i), $
;                      ymin=plotymin(i),ymax=plotymax(i), $
;                      xtenlog=plotxtenlog(i),ytenlog=plotytenlog(i),sym=plotsym(0), $
;                      fcut=fcut,label=[type,obsid,username,date,channels], $
;                      color=plotcolor(i),postscript=1,chatty=1
;          ENDFOR    
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled
;          Version 1.2, 2001/01/11 Katja Pottschmidt,
;                                  added recognition of _corr in the
;                                  psd name   
;          Version 1.3, 2001/01/31 Katja Pottschmidt,   
;                                  IDL header added,  
;                                  keyword defaults defined/changed    
;          Version 1.4, 2001/07/10 Katja Pottschmidt,  
;                                  if the non-gzipped file does not
;                                  exist, the gzipped file is read 
;   
;   
;-
   
   
;; read version  
IF (NOT file_exist(nameorg)) THEN nameorg=nameorg+'.gz' 
openr,unit,nameorg,/get_lun,/xdr,/compress
version=''
readu,unit,version
free_lun,unit   


;; set keyword defaults
IF n_elements(postscript) EQ 0 THEN postscript=1
IF n_elements(chatty) EQ 0 THEN chatty=1
;; the defaults for the ``layout'' keywords are set slightly
;; differently for the two different versions, see below 


;; prepare plot
IF (postscript EQ 1) THEN BEGIN
    namefin=pathfin+'.ps'
ENDIF ELSE BEGIN 
    namefin=pathfin+'.eps'
ENDELSE 
xtext='Frequency [Hz]' & titext=''
IF (n_elements(quantity) NE 0) THEN BEGIN
    ytext_basic=quantity
ENDIF ELSE BEGIN 
    ytext_basic='Arbitrary Units'
ENDELSE 


;; version 1 plot
IF (version EQ 'xdrfu1 1.0') THEN BEGIN    
    
    ;; read Fourier quantity
    xdrfu_r1,nameorg,freq,fouquan,chatty=chatty
    nch=n_elements(fouquan(0,*))
    
    ;; read error of Fourier quantity
    IF (errorname NE 'none') THEN BEGIN 
        xdrfu_r1,errorname,cfreq,errquan,chatty=chatty
    ENDIF        
    
    ;; read noise for Fourier quantity
    IF (noisename NE 'none') THEN BEGIN 
        xdrfu_r1,noisename,dfreq,noiquan,chatty=chatty
    ENDIF     
    
    ;; prepare psd plot
    IF (quantity EQ 'signormpsd') THEN BEGIN
        titext='Power Spectral Density'
        ytext_basic='PSD [RMS^2/Hz]'
    ENDIF 
    IF (quantity EQ 'signormpsd_corr') THEN BEGIN
        titext='Power Spectral Density'
        ytext_basic='PSD [RMS^2/Hz]'
    ENDIF 
    
    ;; set default for ``layout'' keywords 
    IF n_elements(xmin) EQ 0 THEN xmin=min(freq)
    IF n_elements(xmax) EQ 0 THEN xmax=max(freq)
    IF n_elements(ymin) EQ 0 THEN ymin=min(fouquan[*,0])
    IF n_elements(ymax) EQ 0 THEN ymax=max(fouquan[*,0])
    IF n_elements(xtenlog) EQ 0 THEN xtenlog=1
    IF n_elements(ytenlog) EQ 0 THEN ytenlog=1
    IF n_elements(sym) EQ 0 THEN sym=4
    IF n_elements(color) EQ 0 THEN color=50
    
    ;; plot to namefin
    open_print,namefin,/color,postscript=postscript
    !p.multi=[0,2,fix((nch+1.)/2.)+1.]
    loadct,39     
    FOR chan=0,nch-1 DO BEGIN
        energy=strtrim(string(chan),2)
        ytext=textoidl(ytext_basic)+', E'+energy
        plot,freq,fouquan(*,chan), $
          psym=sym,symsize=0.5,color=color, $
          xstyle=1,ystyle=1, $
          xrange=[xmin,xmax], $ 
          yrange=[ymin,ymax], $
          xlog=xtenlog,ylog=ytenlog, $
          title=titext,xtitle=xtext,ytitle=ytext
        IF (errorname NE 'none') THEN BEGIN 
            jwoploterr,freq,fouquan(*,chan),errquan(*,chan), $
              psym=3,color=color,size=0.50
        ENDIF
        IF (noisename NE 'none') THEN BEGIN
            freq2=freq(sort(freq))
            noiquan2=noiquan(sort(freq),chan)
            oplot,freq2,noiquan2, $
              psym=10,symsize=0.5,color=color
        ENDIF
        IF (keyword_set(fcut)) THEN BEGIN
            FOR i=0,n_elements(fcut)-1 DO BEGIN 
                oplot,[fcut(i),fcut(i)],[ymin,ymax], $              
                  psym=10,color=color 
            ENDFOR 
        ENDIF
    ENDFOR 
    ;; plot label infos
    IF (n_elements(label(0)) NE 0) THEN BEGIN
        xyouts,0.99,0.11,label(0),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(1)) NE 0) THEN BEGIN
        xyouts,0.99,0.09,label(1),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(2)) NE 0) THEN BEGIN
        xyouts,0.99,0.07,label(2),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(3)) NE 0) THEN BEGIN 
        xyouts,0.99,0.05,label(3),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(4)) NE 0) THEN BEGIN
        xyouts,0.99,0.03,label(4),/normal,alignment=1,size=0.70
    ENDIF
    close_print
    
ENDIF 


;; version 2 plot
IF (version EQ 'xdrfu2 1.0') THEN BEGIN
    
    ;; read Fourier quantity
    xdrfu_r2,nameorg,freq,fouquan,chatty=chatty
    nch=n_elements(fouquan(0,0,*))
    
    ;; read error of Fourier quantity
    IF (errorname NE 'none') THEN BEGIN 
        xdrfu_r2,errorname,cfreq,errquan,chatty=chatty
    ENDIF 
    
    ;; read noise for Fourier quantity
    IF (noisename NE 'none') THEN BEGIN 
        xdrfu_r2,noisename,dfreq,noiquan,chatty=chatty
    ENDIF 
    
    ;; prepare coherence or time-lag plot
    IF (quantity EQ 'cof') THEN BEGIN
        titext='Coherence'
        ytext_basic='Coherence'
    ENDIF 
    IF (quantity EQ 'lag') THEN BEGIN
        titext='Time Lags'
        ytext_basic='Lag [sec]'
    ENDIF    
        
    ;; set default for ``layout'' keywords 
    IF n_elements(xmin) EQ 0 THEN xmin=min(freq)
    IF n_elements(xmax) EQ 0 THEN xmax=max(freq)
    IF n_elements(ymin) EQ 0 THEN ymin=min(fouquan[*,0,1])
    IF n_elements(ymax) EQ 0 THEN ymax=max(fouquan[*,0,1])
    IF n_elements(xtenlog) EQ 0 THEN xtenlog=0
    IF n_elements(ytenlog) EQ 0 THEN ytenlog=0
    IF n_elements(sym) EQ 0 THEN sym=4
    IF n_elements(color) EQ 0 THEN color=50
    
    ;; plot to namefin
    open_print,namefin,/color,postscript=postscript
    !p.multi=[0,fix((nch+1.)/2.),nch]
    loadct,39
    FOR soft=0,nch-2 DO BEGIN 
        FOR hard=soft+1,nch-1 DO BEGIN
            esoft=strtrim(string(soft),2)
            ehard=strtrim(string(hard),2)
            ytext=ytext_basic+', E'+esoft+'/E'+ehard
            plot,freq,fouquan(*,soft,hard), $
              psym=sym,symsize=0.5,color=color, $
              xstyle=1,ystyle=1, $
              xrange=[xmin,xmax], $ 
              yrange=[ymin,ymax], $
              xlog=xtenlog,ylog=ytenlog, $
              title=titext,xtitle=xtext,ytitle=ytext
            IF (errorname NE 'none') THEN BEGIN 
                jwoploterr,freq,fouquan(*,soft,hard),errquan(*,soft,hard), $
                  psym=3,color=color,size=0.50
            ENDIF
            IF (noisename NE 'none') THEN BEGIN
                freq2=freq(sort(freq))
                noiquan2=noiquan(sort(freq),soft,hard)
                oplot,freq2,noiquan2, $
                  psym=-3,symsize=0.5,color=color
            ENDIF
            IF (quantity EQ 'cof') THEN BEGIN
                oplot,[xmin,xmax],[1.,1.], $
                  psym=10,color=color 
            ENDIF
            IF (keyword_set(fcut)) THEN BEGIN
                FOR i=0,n_elements(fcut)-1 DO BEGIN 
                    oplot,[fcut(i),fcut(i)],[ymin,ymax], $              
                      psym=10,color=color 
                ENDFOR 
            ENDIF
        ENDFOR 
    ENDFOR
    ;; plot label infos
    IF (n_elements(label(0)) NE 0) THEN BEGIN
        xyouts,0.99,0.11,label(0),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(1)) NE 0) THEN BEGIN
        xyouts,0.99,0.09,label(1),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(2)) NE 0) THEN BEGIN
        xyouts,0.99,0.07,label(2),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(3)) NE 0) THEN BEGIN 
        xyouts,0.99,0.05,label(3),/normal,alignment=1,size=0.70
    ENDIF
    IF (n_elements(label(4)) NE 0) THEN BEGIN
        xyouts,0.99,0.03,label(4),/normal,alignment=1,size=0.70
    ENDIF
    close_print
    
ENDIF 

   
END 

