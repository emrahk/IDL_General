PRO timerebin,time,quan,factor=inpfactor,error=error, $
              gaps=gaps,gapdura=gapdura,chatty=chatty
;+
; NAME:
;          timerebin
;
;
; PURPOSE:
;          rebin a lightcurve array by an integer factor, find gaps
;
;
; FEATURES:   
;          the time array ``time'' and the corresponding signal array
;          ``quan'' have to be provided; they are rebinned by the
;          integer factor ``factor''; optionally an input array
;          ``error'' containing the uncertainties can be rebinned
;          also; all original input arrays are overwritten by their
;          rebinned versions; the bins where gaps start and the
;          gap lengths in the original lightcurve are optional array
;          outputs, called ``gaps'' and ``gapdura'' 
;   
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          timerebin,time,quan,factor=inpfactor,error=error, $
;                    gaps=gaps,gapdura=gapdura,chatty=chatty
;
;
; INPUTS:
;          time     : time array of input lightcurve
;          quan     : signal array of input lightcurve
;   
;
; OPTIONAL INPUTS:
;          factor   : integer containing the rebin factor for
;                     the given energy band;    
;                     default: 1, i.e., no rebinning 
;          error    : error array of input lightcurve;  
;                     default: 0, i.e., no error rebinning
;   
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0 
;
;
; OUTPUTS:
;          time     : time array of rebinned output lightcurve
;          quan     : signal array of rebinned output lightcurve 
;   
;
; OPTIONAL OUTPUTS:
;          error    : error array of rebinned output lightcurve;
;                     only present if an input error has been given 
;          gaps     : long array containing the startbins of gaps
;                     in the original time array 
;          gapdura  : array containing the lengths of the gaps in the
;                     original time array, given in the same units as
;                     the time array  
;
;   
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          time and quan (and error) are overwritten by their rebinned
;          versions 
;
;
; RESTRICTIONS:
;          outside of the gaps the lightcurve has to be evenly spaced
;
;
; PROCEDURES USED:
;          timegap.pro
;
;
; EXAMPLE:
;          time=[findgen(100),150.+findgen(50)]
;          rate=randomn(zufall,n_elements(time))
;          timerebin,time,rate,factor=1, $
;                    gaps=gaps,gapdura=gapdura,/chatty 
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed   
;          Version 1.3, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header: description of
;                                  ``gaps'' and ``gapdura'' corrected    
;          Version 1.4, 2000/10/26 Katja Pottschmidt,   
;                                  IDL header: minor changes,  
;                                  default for chatty keyword corrected 
;                                  default for error  keyword corrected    
;                                  screen output for factor keyword changed    
;
;-
   
     
;; helpful parameters, set default values
factor=long(inpfactor)
IF (n_elements(chatty) EQ 0) THEN chatty=1


;; factor-keyword, default: 
;; factor has to be given 
IF (n_elements(factor) EQ 0) THEN BEGIN
    factor=1L
ENDIF     
IF (keyword_set(chatty)) THEN BEGIN 
    print,'timerebin: The quanities will be rebinned by a factor of: ', $
      factor  
ENDIF      
IF (factor LT 1L) THEN message,'timerebin: factor-keyword is wrong'   


;; error-keyword, default: 
;; error=0: no errors are calculated 
IF (NOT keyword_set(error)) THEN BEGIN
    error=0
    ee=0
ENDIF ELSE BEGIN  
    ee=1
ENDELSE 
IF (n_elements(error) NE n_elements(time)) THEN BEGIN
    IF (ee NE 0) THEN ee=-1
ENDIF 
IF (keyword_set(chatty)) THEN BEGIN 
    print,'timerebin: Errors are given and will be rebinned '
    print,'(0=no, 1=yes, -1=problems with given error array): ',ee  
ENDIF 


;; determin the time gap indices array and the array of the dimensions
;; of uninterrupted time segments 
timegap,time,gaps,dblock,gapdura,chatty=chatty
   
   
;; rebin the time and quantity array
FOR i=0L,n_elements(dblock)-1 DO BEGIN
    nt=long(dblock(i)/factor)
    IF (nt GT 0) THEN BEGIN 
        
        ndx=findgen(nt)*factor
        IF (i NE 0) THEN BEGIN 
            ndx=ndx+gaps(i-1)+1
        ENDIF 
        t1=time(ndx)
        q1=quan(ndx)
        FOR j=1,factor-1 DO BEGIN 
            q1=q1+quan(ndx+j)
        ENDFOR 
        q1=q1/factor
        
        IF (n_elements(ntime) EQ 0) THEN BEGIN 
            ntime=t1
            nquan=q1
        ENDIF ELSE BEGIN 
            ntime=temporary([ntime,t1])
            nquan=temporary([nquan,q1])
        ENDELSE  
        
        ;; Gaussian Error Propagation if error is given
        IF keyword_set(error) THEN BEGIN 
            e1=error(ndx)*error(ndx)
            FOR j=1,factor-1 DO BEGIN 
                e1=e1+error(ndx+j)*error(ndx+j)
            ENDFOR 
            e1=sqrt(e1)/factor
            IF (n_elements(nerr) EQ 0) THEN BEGIN 
                nerr=e1
            ENDIF ELSE BEGIN 
                nerr=temporary([nerr,e1])
            ENDELSE               
        ENDIF 
        
    ENDIF  
ENDFOR  
time=ntime
quan=nquan


IF keyword_set(error) THEN error=nerr
   

END 












