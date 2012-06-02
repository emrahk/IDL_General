PRO zrmcalc,time,rate,zrmpath, $
            dseg=inpdseg,factor=inpfactor,ord=inpord, $
            energy=energy,obsid=obsid,username=username,date=date, $ 
            history=inphistory,chatty=chatty  
   
      
   
;; helpful parameters 
factor=long(inpfactor)                ; rebin factor, long
dseg=long(inpdseg)                    ; dimension of segments, long
ord=long(inpord)                      ; order of the Zuramo, long
nch=n_elements(rate(0,*))             ; number of channels, long
nt=n_elements(time)                   ; dimension of lc, long
nus=long(nt/dseg)                     ; number of segments 
                                      ; with dimension dseg, long
bt=time(1)-time(0)                    ; bintime of lc
startbin=0L                           ; startindex of first segment
endbin=dseg-1L                        ; endindex of first segment
length=time(endbin)-time(startbin)+bt ; length of lc  


;; check, if rebin factor is set correctly
ratio=dseg
IF (n_elements(factor) NE 0) THEN BEGIN 
    ratio=double(dseg)/double(factor)
    check=ratio-long(ratio)
    IF check NE 0D0 THEN BEGIN 
        message,'zrmcalc: The wrong rebin factor has been given'
    ENDIF      
ENDIF 


;; define history
nlchist           = n_elements(inphistory)
nbasic            = nlchist+12
basic_history     = strarr(nbasic)

basic_history(0) ='Dimension of history (zrmcalc)='+string(nbasic)
IF (nlchist NE 0) THEN BEGIN 
    basic_history(1:nlchist)=inphistory
ENDIF

basic_history(nbasic-10)='Dimension of input segments (zrmcalc)='+string(dseg)
basic_history(nbasic-9)='Number of segments (zrmcalc)='+string(nus)
basic_history(nbasic-8)='Original bintime (zrmcalc)='+string(bt)
IF (n_elements(factor) NE 0) THEN BEGIN 
    basic_history(nbasic-7)='Rebin factor (zrmcalc)='+string(factor)
    basic_history(nbasic-6)='Dimension of rebinned segments (zrmcalc)=' $
      +string(long(ratio)) 
ENDIF ELSE BEGIN 
    basic_history(nbasic-7)='Keyword factor has not been set (zrmcalc)'
    basic_history(nbasic-6)='Dimension of rebinned segments (zrmcalc)=' $
      +string(dseg) 
ENDELSE 
basic_history(nbasic-5)='Order of the Zuramo model (zrmcalc)='+string(ord)
IF (n_elements(energy) NE 0) THEN BEGIN     
    basic_history(nbasic-4)='Keyword energy (zrmcalc)='+energy
ENDIF ELSE BEGIN 
    basic_history(nbasic-4)='Keyword channels has not been set (zrmcalc)'
ENDELSE 
IF (n_elements(obsid) NE 0) THEN BEGIN     
    basic_history(nbasic-3)='Keyword obsid (zrmcalc)='+obsid
ENDIF ELSE BEGIN 
    basic_history(nbasic-3)='Keyword obsid has not been set (zrmcalc)'
ENDELSE 
IF (n_elements(username) NE 0) THEN BEGIN    
    basic_history(nbasic-2)='Keyword username (zrmcalc)='+username
ENDIF ELSE BEGIN 
    basic_history(nbasic-2)='Keyword username has not been set (zrmcalc)'
ENDELSE 
IF (n_elements(date) NE 0) THEN BEGIN    
    basic_history(nbasic-1)='Keyword date (zrmcalc)='+date
ENDIF ELSE BEGIN 
    basic_history(nbasic-1)='Keyword date has not been set (zrmcalc)'
ENDELSE     


;; calculate zuramo of given order for each segment and each channel range
;; write important Zuramo parameters 
;; (P&tau, Dyn, WfWNR, VdBeoR, supremum, Iterationen im EM-Algorithmus)
;; in one file for each channel range
;; delete zuramo .out files
;; delete zuramo .par files
;; delete zuramo .txt files
FOR chan=0,nch-1 DO BEGIN    
    startbin=0L
    endbin=dseg-1L
    
    ;; write history
    openw,unit,zrmpath+'_'+energy(chan)+'.history',/get_lun
    printf,unit,nbasic
    printf,unit,basic_history
    free_lun,unit
    
    FOR seg=0,nus-1 DO BEGIN 
                    
        ;; rebin each lightcurve segment seperately
        nti=time(startbin:endbin)
        nra=rate(startbin:endbin,chan)
        IF (n_elements(factor) NE 0) THEN BEGIN 
            timerebin,nti,nra,factor=factor,chatty=chatty
        ENDIF 
        
        ;; write the rebinned segment into a file 
        ;; which is used as zuramo input        
        openw,unit,zrmpath+'z.txt',/get_lun
        arr=dblarr(2,ratio)
        arr(0,*)=nti & arr(1,*)=nra
        printf,unit,ratio
        printf,unit,arr
        free_lun,unit
        
        ;; calculate Zuramo model of given order and 
        ;; save important parameters
        spawn,'/usr/local/share/rsi/local/aitlib/katja/zuramo.ksh '+zrmpath+ $
          ' '+energy(chan)+' '+string(ord) 
        
        startbin=endbin+1
        endbin=startbin+dseg-1
        
    ENDFOR
    
ENDFOR 


END 











