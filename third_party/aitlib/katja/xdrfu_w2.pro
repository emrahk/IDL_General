PRO xdrfu_w2,funame,inpfreq,inpquan, $
            history=history,high=inphigh, $
            chatty=chatty,gzip=gzip  
;+
; NAME:
;          xdrfu_w2
;
;
; PURPOSE: 
;          write a multidimensional Fourier quantity, i.e., the
;          frequency array, the multidimensional quantity array (with
;          each set calculated from two lightcurves), and the history
;          keyword to a file in xdr format
;
;
; FEATURES:
;          write a multidimensional Fourier quantity, i.e., the
;          frequency array ``inpfreq'', the multidimensional quantity
;          array ``inpquan'', the keyword ``history'' (optional), the
;          upper boundary of the frequency bins ``high'' (optional),
;          and further information to the file ``funame'' in xdr
;          format; the different sets of the ``inpquan'' array are
;          defined by two parameters (e.g., the energy bands of the
;          corresponding lightcurves); the order and IDL formats of
;          the output components are documented in the ASCII file
;          ``xdrfu.format''; a gzipped file is written, if ``gzip'' is
;          set 
;   
;          note: xdrfu_w2 only saves the ``cross terms'' of the two
;          parameters and only their first occurence; for the example
;          given below this means only inpquan[*,0,1]=psd0*psd1 is
;          written to ``funame'';    
;   
;          this rountine was written to save quantities that are based
;          on the CROSS POWER SPECTRUM - like the TIMELAG SPECTRUM and
;          the COHERENCE FUNCTION - for all combinations of all given
;          energy bands that produce meaningful and different results
;   
;   
; CATEGORY:
;          timing tools  
;
;
; CALLING SEQUENCE:
;          xdrfu_w2,funame,inpfreq,inpquan, $
;            history=history,high=inphigh, $
;            chatty=chatty,gzip=gzip  
;
;
; INPUTS:
;          funame   : string containing the file name of
;                     the multidimensional Fourier quantity
;                     that is to be writtenin xdr format  
;          inpfreq  : frequency array of the xdr Fourier quantity;
;                     freq=float(inpfreq) is written to funame
;          inpquan  : multidimensional quantity array of the xdr
;                     Fourier quantity; each set of this quantity is
;                     defined by two parameters; quan=float(inpquan)
;                     is written to funame;   
;                     note: xdrfu_w2 only saves the ``cross terms'' of
;                     inpquan and only their first
;                     occurence; for the example given below this means only
;                     inpquan[*,0,1]=psd0*psd1 is written to funame;
;
;   
; OPTIONAL INPUTS:
;          history  : string array;
;                     default: 'History is not known.';
;                     [an example for a typical history string array
;                     produced by the analysis of RXTE/PCA lightcurves
;                     (using rxte_syncseg.pro and rxte_fourier.pro) is given
;                     by the ASCII file history.bsp; this example has
;                     been written by xdrfu_w[1,2].pro]
;          high     : frequency array containing the upper boundaries
;                     of the frequency bins starting at the values
;                     given in ``freq''; default: not defined 
;   
;   
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0   
;          gzip     : if set, a gzipped file is written (.gz is
;                     appended to the funame);
;                     default: undefined 
;
;
; OUTPUTS:
;          none, but see side effects (and optional outputs)
;
;
; OPTIONAL OUTPUTS:
;          (default values of the keywords history and chatty can be
;          returned if those keywords are undefined in the calling of
;          xdrfu_w2) 
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS: 
;          a file named funame is written containing the
;          frequency array, the multidimensional quantity array, the
;          history keyword, and further information in xdr format; the
;          order and IDL formats of these output components are
;          documented in the ASCII file ``xdrlc.format''; note that -
;          contrary to the input arrays in the xdrlc_w.pro routine -
;          the IDL format of inpfreq and inpquan (and high) is NOT
;          changed by the xdrfu_w[1,2].pro routines!
;
;
; RESTRICTIONS:
;          none
;
;
; PROCEDURES USED:
;          none  
;
; EXAMPLE:
;          time=[findgen(100),150.+findgen(50)]     
;          rate0=randomn(seed0,n_elements(time))
;          rate1=randomn(seed1,n_elements(time))
;          psd,time,rate0,fr,psd0
;          psd,time,rate1,fr,psd1
;          inpfreq=fr
;          inpquan=fltarr(n_elements(fr),1,1)
;          inpquan[*,0,0]=psd0*psd0
;          inpquan[*,0,1]=psd0*psd1
;          inpquan[*,1,0]=psd1*psd0
;          inpquan[*,1,1]=psd1*psd1   
;          xdrfu_w2,'test.cof',inpfreq,inpquan, $
;                  history='Test',/chatty   
;
; note: xdrfu_w2 only saves the ``cross terms'' of inpquan and only
; their first occurence, in this case: inpquan[*,0,1]=psd0*psd1 
;   
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/26 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed    
;          Version 1.3, 2000/10/30 Katja Pottschmidt,   
;                                  IDL header: minor changes   
;          Version 1.4, 2001/02/08 Katja Pottschmidt,
;                                  input keyword ``high'' added     
;                                  and new version number ('xdrfu2 1.1')
;                                  introduced
;          Version 1.5, 2001/02/20 Katja Pottschmidt,
;                                  a gzipped file can now also be written: 
;                                  the gzip keyword has to be set
;          Version 1.6, 2001/07/10 Katja Pottschmidt,
;                                  files written to the ``onelength''
;                                  directory are automatically gzipped
;   
;
;-
   
   
;; set default values
;; default value for history see below
IF (n_elements(chatty) EQ 0) THEN chatty=1
     
   
;; frequency and Fourier quantity array format    
freq=float(inpfreq)
quan=float(inpquan)
IF (n_elements(inphigh) NE 0) THEN BEGIN 
     high=float(inphigh)
     IF (n_elements(high) NE n_elements(freq)) THEN BEGIN
          message,'xdrfu_w2: ``freq'' and ``high'' must have the same dimension'
     ENDIF 
ENDIF 


;; open output xdr file  
IF (strmatch(funame,'*onelength*') EQ 1) THEN gzip=1
IF (keyword_set(gzip)) THEN BEGIN
     openw,unit,funame+'.gz',/get_lun,/xdr,/compress
ENDIF ELSE BEGIN 
     openw,unit,funame,/get_lun,/xdr
ENDELSE 


;; write version
version='xdrfu2 1.0'
IF (n_elements(high) NE 0) THEN version='xdrfu2 1.1'
writeu,unit,version


;; write history
IF (n_elements(history) EQ 0) THEN BEGIN
    history='History is not known.'
ENDIF
nhist=n_elements(history)     & writeu,unit,nhist
writeu,unit,history


;; write helpful parameters
nf=n_elements(freq)           & writeu,unit,nf
nch=n_elements(quan(0,0,*))   & writeu,unit,nch
first=float(min(freq))        & writeu,unit,first 
last=float(max(freq))         & writeu,unit,last


;; write frequency and Fourier quantity array
writeu,unit,freq
IF (n_elements(high) NE 0) THEN BEGIN 
     writeu,unit,high
ENDIF 
FOR soft=0,nch-2 DO BEGIN 
    FOR hard=soft+1,nch-1 DO BEGIN
        writeu,unit,quan(*,soft,hard)
    ENDFOR 
ENDFOR    


;; close output xdr file 
free_lun,unit


END 











