PRO lcsync,lclist,namefin,bound=bound,dutylimit=dutylimit, $
           obsid=obsid,username=username,date=date, $
           chatty=chatty
;+
; NAME:
;          lcsync
;
;
; PURPOSE: 
;          read quasi-simultaneous xdr lightcurves and
;          time-synchronize them, write one multidimensional xdr
;          lightcurve  
;
; FEATURES: 
;          a string array ``lclist'' containing the names of the
;          quasi-simultaneous xdr lightcurves (e.g., from different
;          energy ranges and/or instrument modi) that are to be
;          time-synchronized has to be given; the lightcurves are read
;          and synchronized; the count rate array is searched for
;          run-away values higher than ``bound'' which are replaced by
;          zero count rates; if more than 10 run-away count rates are
;          present, lcsync stops; the count rate array is also
;          searched for the occurence of neighboring zeros; if the
;          percentage of bins NOT containing zero counts followed by
;          another zero bin for a given energy band is lower than the
;          corresponding entry of ``dutylimit'', lsync stops; a
;          multidimensional xdr lightcurve for the timebins common to
;          all single lightcurves is written to the file ``namefin'',
;          which is also containing the history string array, updated
;          with the ``obsid'', ``username'', ``date'', and
;          ``dutylimit'' keywords 
;   
;   
; CATEGORY: 
;          timing tools
;
;
; CALLING SEQUENCE:
;          lcsync,lclist,namefin,bound=bound,dutylimit=dutylimit, $
;                 obsid=obsid,username=username,date=date, $
;                 chatty=chatty
;
;
; INPUTS:
;          lclist   : string array containing the file names of
;                     the quasi-simultaneous lightcurves in xdr format
;                     that are to be read and synchronized  
;          namefin  : string giving the file name of the synchronized 
;                     multidimensional xdr output lightcurve (with the
;                     file also containing the updated history array) 
;   
;
; OPTIONAL INPUTS:
;          bound    : boundary (lower limit) for run-away count rates;
;                     default: 5E4;
;                     the run-away count rates are replaced by
;                     zero count rates; if more than 10 run-away count
;                     rates are present after time-synchronizing
;                     lcsync stops 
;          dutylimit: array giving the limit for the percentage of the
;                     elements of the rate array for each energy 
;                     channel, that are NOT ZERO FOLLOWED BY ANOTHER
;                     ZERO; 
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
;                     the synchronized xdr lightcurve;
;                     default: 'Keyword obsid has not been set (lcsync)'   
;          username : string giving the name of the user ;
;                     this name is stored in the history keyword of
;                     the synchronized xdr lightcurve;
;                     default: 'Keyword username has not been set (lcsync)'   
;          date     : string giving the procuction date of the xdr
;                     lightcurve;
;                     this name is stored in the history keyword of
;                     the synchronized xdr lightcurve;
;                     default: 'Keyword date has not been set (lcsync)'  
;
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0    
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
;          the resulting time-synchronized multidimensional lightcurve
;          and the updated history string array are written to the
;          file namefin in xdr format 
;
;
; RESTRICTIONS:
;          input lightcurves have to be xdr lightcurves written by the
;          the xdrlc_w.pro routine;    
;          outside of the gaps the lightcurves have to be evenly
;          spaced and the lightcurves from different energy ranges
;          must have the same bintime and even have to be binned to
;          identical times (i.e., lc1: 4s, 8s, 12s and lc2: 6s, 10s,
;          14s will not give meaningful results)  
;
;
; PROCEDURES USED:
;          xdrlc_r.pro, xdrlc_w.pro
;
;
; EXAMPLE:
;          lcsync,['merge001.xdrlc','merge002.xdrlc'], $
;                 'syncseg.xdrlc', $
;                 obsid='P40099/01.all', $
;                 username='Katja Pottschmidt', $
;                 date=systime(0),/chatty     
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2-1.6, 2000/01/25 Katja Pottschmidt,   
;                                  bound keyword added and corrected 
;          Version 1.7, 2000/10/24 Katja Pottschmidt,    
;                                  IDL header added,
;                                  keyword default values defined/changed,
;                                  IDL and cvs version numbers synchronized   
;          Version 1.8, 2000/10/24 Katja Pottschmidt,      
;                                  IDL header: minor changes   
;          Version 1.9, 2000/10/24 Katja Pottschmidt,      
;                                  IDL header: minor changes       
;          Version 1.10, 2000/11/02 Katja Pottschmidt,      
;                                   default for chatty keyword changed
;          Version 1.11, 2001/01/05 Katja Pottschmidt,      
;                                   check for neighboring zero count rates is
;                                   performed, the duty cycle of each
;                                   energy band (= percentage of bins
;                                   NOT containing zero counts
;                                   followed by another zero bin, gaps
;                                   in the time array are NOT taken
;                                   into account) is printed to the
;                                   screen (if chatty=1 is set) and
;                                   added to the history string;
;                                   keyword dutylimit has been added    
;   
;
;-
   
   
;; set default values
IF (n_elements(obsid) EQ 0) THEN BEGIN 
    obsid='Keyword obsid has not been set (lcsync)' 
ENDIF 
IF (n_elements(username) EQ 0) THEN BEGIN 
    username='Keyword username has not been set (lcsync) '
ENDIF 
IF (n_elements(date) EQ 0) THEN BEGIN 
    date='Keyword data has not been set (lcsync)'
ENDIF 
IF (n_elements(chatty) EQ 0) THEN chatty=1
IF (keyword_set(bound)) THEN BEGIN
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'lcsync: Boundary for run-away count rates: ',bound
    ENDIF 
ENDIF ELSE BEGIN 
    bound=5E4
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'lcsync: Boundary for run-away count rates' 
        print,'lcsync: has been set to the default value of 50000.'       
    ENDIF 
ENDELSE 


;; number of lightcurves to be synchronized   
nch=n_elements(lclist)


;; read first lightcurve
xdrlc_r,lclist(0),time,rate,history=history,chatty=chatty
rate=0.
timeref=time
tfin=time
dfin=n_elements(time)
hisfin=history

FOR i=1,nch-1 DO BEGIN
    
    ;; read next lightcurve
    xdrlc_r,lclist(i),time,rate,history=history,chatty=chatty
    rate=0.
    hisfin=temporary([hisfin,history])
 
    ;; compare time array of next lightcurve to previous one
    marker=0
    ndxref=where(time NE timeref)
    dnref=long(n_elements(timeref)-n_elements(time))
    IF (ndxref(0) EQ -1) AND (dnref EQ 0L) THEN BEGIN
        marker=1
    ENDIF
    timeref=time
    
    ;; synchronize next lightcurve with the previous ones
    IF (marker NE 1) THEN BEGIN
        ndx=where(tfin NE time)
        dnt=long(n_elements(time)-n_elements(tfin))
        
        ;; if the times are different: synchronize step by step
        IF (ndx[0] NE -1) AND (dnt NE 0L) THEN BEGIN 
      
            ;; cut time down to start and stop time of current lightcurve
            ndx=where((time GE tfin[0]) AND (time LE tfin[dfin-1]),dnow)
            IF (ndx(0) EQ -1) THEN BEGIN 
                message,'lcsync: lightcurves do not overlap'
            ENDIF ELSE BEGIN 
                time=temporary(time[ndx])
            ENDELSE 
            dfin1=dfin-1L
            dnow1=dnow-1L
            
            ;; initialize counters and new final time array ttmp
            ndxfin=0L
            ndxnow=0L
            ttmp=0D0
            
            ;; save common times of tfin and time
            ;; until the end of the current lightcurve is reached
            WHILE(ndxfin LT dfin1 AND ndxnow LT dnow1) DO BEGIN               
                ;; skip in ``tfin'' until we reach next value 
                ;; of ``time''
                WHILE (tfin[ndxfin] LT time[ndxnow] AND $
                       ndxfin LT dfin1) DO BEGIN 
                    ndxfin=ndxfin+1L
                ENDWHILE                
                ;; skip in ``time'' until we reach next value of
                ;; ``tfin''
                WHILE (time[ndxnow] LT tfin[ndxfin] AND $
                       ndxnow LT dnow1) DO BEGIN 
                    ndxnow=ndxnow+1L
                ENDWHILE                             
                ;; save common times until next gap is reached
                IF (tfin[ndxfin] EQ time[ndxnow]) THEN BEGIN 
                    startfin=ndxfin
                    startnow=ndxnow
                    WHILE (tfin[ndxfin] EQ time[ndxnow] AND $
                           ndxfin LT dfin1 AND $
                           ndxnow LT dnow1) DO BEGIN 
                        ndxfin=ndxfin+1L
                        ndxnow=ndxnow+1L
                    ENDWHILE
                    ttmp=[temporary(ttmp),time[startnow:ndxnow-1L]]
                ENDIF
            ENDWHILE
            
            ;; take care of the last element of tfin and time 
            repair=0
            IF (tfin[ndxfin] EQ time[dnow1]) THEN BEGIN 
                ttmp=temporary([ttmp,time[dnow1]])
                repair=1
            ENDIF
            IF ((tfin[dfin1] EQ time[ndxnow]) AND (repair NE 1)) THEN BEGIN 
                ttmp=temporary([ttmp,time[ndxnow]])
            ENDIF
            
            ;; make tfin the new final time array
            tfin=ttmp[1:n_elements(ttmp)-1] & ttmp=0D0
            dfin=n_elements(tfin)
            
        ENDIF    
    ENDIF 
ENDFOR   


;; copy rates having corresponding times in tfin for all channels 
rfin=fltarr(n_elements(tfin),nch)
FOR i=0,nch-1 DO BEGIN
    xdrlc_r,lclist[i],time,rate,history=history,chatty=chatty
    ntime=n_elements(time)-1
    dnew=0L
    FOR dref=0L,n_elements(tfin)-1 DO BEGIN 
        WHILE (dnew LT ntime AND tfin[dref] NE time[dnew]) DO BEGIN 
            dnew=dnew+1L
        ENDWHILE  
        IF (dnew EQ ntime) THEN BEGIN 
            IF (tfin[dref] EQ time[dnew]) THEN BEGIN 
                rfin[dref,i]=rate[dnew]
            ENDIF 
        ENDIF ELSE BEGIN 
            rfin[dref,i]=rate[dnew] 
            dnew=dnew+1L
        ENDELSE  
    ENDFOR 
ENDFOR 


;; update history
hisfin=[hisfin,'Keyword obsid (lcsync)='+obsid]
hisfin=[hisfin,'Keyword username (lcsync)='+username]
hisfin=[hisfin,'Keyword date (lcsync)='+date]


;; check for run-away count rates -> set to 0.
;; check for neighboring zero count rates
FOR i=0,nch-1 DO BEGIN
    rtemp=rfin(*,i)
    ndx=where(rtemp GE bound,count)
    IF count GT 10 THEN BEGIN 
        print,'lcsync: Working on channel: ',i
        message,'lcsync: There are >10 run-away count rates'
    ENDIF 
    IF count NE 0L THEN BEGIN 
        IF (keyword_set(chatty)) THEN BEGIN 
            print,'lcsync: Energy range: ',i
            print,'        There are run-away count rates: ndx= ',ndx
            print,'        They will be replaced by zero count rates'
        ENDIF 
        rfin(ndx,i)=0.    
    ENDIF
    ndx_zero=where((rtemp EQ 0. AND shift(rtemp,-1) EQ 0.), count_zero)
    ;; note: gaps in the time array are NOT taken into account here
    duty=(1D0-(double(count_zero)/n_elements(rtemp)))*100D0
    IF (n_elements(dutylimit) NE 0) THEN BEGIN
        IF (duty LT dutylimit[i]) THEN BEGIN
            print,'00000000000000000000000000000000000000000000000'
            print,'lcsync: Energy range: ',i
            print,'        Check for "double zeros"'
            print,'        Duty cycle [%]: ',duty
            print,'        Duty limit [%]: ',dutylimit[i]
            message,'lcsync: The duty cycle of bins without neighboring zero count rates is lower than the given limit for this energy band'
        ENDIF
    ENDIF 
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'00000000000000000000000000000000000000000000000'
        print,'lcsync: Energy range: ',i
        print,'        No. of double zeros: ',count_zero
        print,'        No. of bins: ',n_elements(rtemp)  
        print,'        Duty cycle [%]: ',duty
        print,'        (of bins without neighboring '
        print,'         zero count rates'
        print,'         gaps in the time array '
        print,'         are NOT taken into account)'  
        print,'00000000000000000000000000000000000000000000000'       
    ENDIF 
    ;; update history
    hisfin=[hisfin,' channel '+string(i)+ $
            ' has a duty cycle of bins' + $
            ' without neighboring zero count rates of '+string(duty)+'%']  
ENDFOR 


;; write synchronized multichannel lightcurve
nhist=n_elements(hisfin)+1
finfin=['Dimension of history (lcsync)='+string(nhist),hisfin]
xdrlc_w,namefin,tfin,rfin,history=finfin,dseg=-1,chatty=chatty


END 
















