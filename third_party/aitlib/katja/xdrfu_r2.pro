PRO xdrfu_r2,funame,freq,quan, $             
             select=select,history=history, $
             nf=nf,nch=nch,first=first,last=last, $             
             high=high,chatty=chatty
;+
; NAME: 
;          xdrfu_r2
;
;
; PURPOSE:
;          read a multidimensional Fourier quantity (with each set
;          calculated from two lightcurves) and some extra information 
;          in xdr format that have been written by xdrfu_w2
;
;
; FEATURES: 
;          read a multidimensional Fourier quantity, i.e., the
;          frequency array ``freq'', the multidimensional quantity
;          array ``quan'', the keywords (``history'', ``nf'', ``nch'',
;          ``first'', ``last'') from the xdr file ``funame''; if
;          present, the high frequency boundary ``high'' of each
;          frequency bin is also read; the different sets of the
;          ``quan'' array are defined by two parameters (e.g., the
;          energy bands of the corresponding lightcurves); the
;          optional input ``select'' allows to select a certain set of
;          the multidimensional Fourier quantity; the order and IDL
;          formats of the output components are documented in the
;          ASCII file ``xdrfu.format'' (see also OUTPUTS and OPTIONAL
;          OUTPUTS); gzipped files can also be read (automatically)
;
;          note: xdrfu_r2 only reads the ``cross terms'' of the two
;          parameters and only their first occurence, e.g., quan[*,0,1];       
;   
;          this rountine was written to read quantities that are based
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
;          xdrfu_r2,funame,freq,quan, $
;                   select=select,history=history, $
;                   nf=nf,nch=nch,first=first,last=last, $
;                   high=high,chatty=chatty   
;
; 
; INPUTS:             
;          funame : string containing the file name of
;                   the multidimensional Fourier quantity in xdr format
;                   that is to be read     
;
;
; OPTIONAL INPUTS: 
;          select : integer array giving the two numbers
;                   identifying one set of the multidimensional
;                   quantity array that is to be read (starting with
;                   number [1,1]); default: all sets of the quantity array
;                   are read 
;   
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0      
;
;
; OUTPUTS: 
;          freq (fltarr(nf))           : frequency array of the xdr Fourier
;                                        quantity 
;          quan (fltarr(nf,nch-1,nch)) : multidimensional quantity
;                                        array of the xdr Fourier
;                                        quantity, e.g., for all
;                                        relevant combinations of a
;                                        number (nch) of energy
;                                        channels: each set of this
;                                        quantity is defined by two
;                                        parameters; 
;                                        note: xdrfu_r2 only reads the
;                                        ``cross terms'' of the two
;                                        parameters and only their
;                                        first occurence, e.g., quan[*,0,1]  
;   
;
; OPTIONAL OUTPUTS:   
;          history (strarr(nhist))  : string array describing the different
;                                     processing steps of the
;                                     Fourier quantity;   
;                                     [an example for a typical history string 
;                                     array produced by the analysis of 
;                                     RXTE/PCA lightcurves (using 
;                                     rxte_syncseg.pro and rxte_fourier.pro)
;                                     is given by the ASCII file history.bsp;
;                                     this example has been written by 
;                                     xdrfu_w[1,2].pro]             
;          nf      (long)           : dimension of the frequency array 
;          nch     (long)           : maximum of the two integers
;                                     defining a certain set of the
;                                     quantity array , e.g., number of
;                                     energy channels   
;          first   (float)          : smallest frequency value in units of
;                                     the frequency array  
;          last    (float)          : biggest frequency value in units of
;                                     the frequency array 
;          high    (fltarr(nf))     : frequency array containing the
;                                     upper boundaries of the
;                                     frequency bins starting at the
;                                     values given in ``freq''
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
;          the multidimensional xdr Fourier quantity has to be written
;          by the xdrfu_w2.pro routine 
;
;
; PROCEDURES USED:
;          none
;
;
; EXAMPLE:            
;          xdrfu_r2,'0008192_rebin_lag.xdrfu',freq,quan, $
;                  select=[1,2],history=history, $
;                  nf=nf,nch=nch,first=first,last=last,/chatty 
;
;          note: xdrfu_r2 only reads the ``cross terms'' of the two
;          parameters and only their first occurence, e.g., quan[*,0,1];    
;   
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled  
;          Version 1.2, 2000/10/30 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed    
;                                  keywords added: select, 
;                                                  nf, nch, 
;                                                  first, last 
;          Version 1.3, 2000/11/16 Katja Pottschmidt,   
;                                  bug in reading the frequencies 
;                                  (present since previous version, 1.2)
;                                  has been corrected
;          Version 1.4, 2001/02/08 Katja Pottschmidt,
;                                  ouput keyword ``high'' added     
;                                  and new version number ('xdrfu2 1.1')
;                                  introduced
;          Version 1.5, 2001/02/20 Katja Pottschmidt,
;                                  gzipped files can now also be read 
;                                  (works automatically)
;          Version 1.6, 2001/07/10 Katja Pottschmidt,
;                                  if the non-gzipped file does not
;                                  exist, the gzipped file is read  
;   
;   
;-
   
   
;; set default values
IF (n_elements(chatty) EQ 0) THEN chatty=1

       
;; open input xdr file    
IF (NOT file_exist(funame)) THEN funame=funame+'.gz'
openr,unit,funame,/get_lun,/xdr,/compress


;; read and check version
version=''
readu,unit,version
ma=0 & mb=0
IF (version NE 'xdrfu2 1.0') THEN  ma=1
IF (version NE 'xdrfu2 1.1') THEN  mb=1
mc=ma+mb
IF (mc EQ 2) THEN BEGIN 
    message,'Problem in xdrfu2: versionstring wrong'
ENDIF 


;; read history
nhist=0L
readu,unit,nhist
history=strarr(nhist)
readu,unit,history


;; read helpful parameters
nf=0L      & readu,unit,nf
nch=0L     & readu,unit,nch
first=0.   & readu,unit,first
last=0.    & readu,unit,last


;; read frequency
freq=fltarr(nf)
readu,unit,freq
IF (version EQ 'xdrfu2 1.1') THEN BEGIN 
     high=fltarr(nf) 
     readu,unit,high
ENDIF 

;; read quantity array
IF (n_elements(select) NE 0) THEN BEGIN
    select_soft=fix(select[0])
    select_hard=fix(select[1])
    quan=fltarr(nf)
    FOR i=0,select_soft-2 DO BEGIN 
        FOR j=select_soft,nch-1 DO BEGIN
            readu,unit,quan
        ENDFOR       
    ENDFOR 
    FOR i=select_soft,select_hard-1 DO BEGIN 
        readu,unit,quan
    ENDFOR      
ENDIF ELSE BEGIN
    quan=fltarr(nf,nch-1,nch)
    quatmp=fltarr(nf)
    FOR soft=0,nch-2 DO BEGIN 
        FOR hard=soft+1,nch-1 DO BEGIN
            readu,unit,quatmp
            quan[*,soft,hard]=quatmp
        ENDFOR 
    ENDFOR 
ENDELSE 


;; close input xdr file 
free_lun,unit   


END 









