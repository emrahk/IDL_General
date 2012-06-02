PRO timeseg,time,ndx,dseg=dseg,searchgap=searchgap, $
            gaps=gaps,gapdura=gapdura,tolerance=tolerance,chatty=chatty

;+
; NAME:
;          timeseg
;
;
; PURPOSE: 
;          cut a time array into segments of a given dimension taking
;          gaps into account by returning the ``good'' indices 
;   
;   
; FEATURES: 
;          the indices ``ndx'' of the array ``time'' are determined
;          that must be used to cut the array into segments of
;          dimension ``dseg'' (default: 1/10th of the time between the
;          first and the last time bin of the original time array
;          given in the same units as the time array); the time array
;          is searched for gaps (no gap search is performed if
;          ``searchgap'' is set to 0) and segments that are not
;          containing any gaps are formed; the parameter ``tolerance''
;          defines the lower limit for the gap detection in terms of a
;          relative deviation from the first time bin; the time array
;          has to be evenly spaced outside of the gaps; the startbins
;          of the gaps in the time array and the gap lengths given in
;          the same units as the time array are determined and are
;          optional array outputs, called ``gaps'' and ``gapdura''
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          timeseg,time,ndx, $
;                  dseg=dseg,searchgap=searchgap, $
;                  gaps=gaps,gapdura=gapdura,tolerance=tolerance,chatty=chatty
;
;
; INPUTS:
;          time     : time array to be searched for gaps and segmented 
;
;
; OPTIONAL INPUTS:
;          dseg     : parameter containing the segment length in bins;
;                     default: 1/10th of the time between the first
;                     and the last time bin of the original time array
;                     given in the same units as the time array 
;          tolerance: parameter defining the lower limit for the gap
;                     length; the reference is the time difference
;                     between the first and second entry in the time
;                     array; tolerance defines the maximum allowed relative
;                     deviation from this reference bin length; 
;                     default: 1D-8  
;
;
; KEYWORD PARAMETERS:
;          searchgap: decides whether the time array is searched for gaps 
;                     default: gap search;  
;                     to turn off the gap serach, set searchgap=0   
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0
;
;
; OUTPUTS:
;          ndx      : long array containing the indices of the time
;                     array that have to be used in order to produce
;                     evenly spaced segments of the given dimension 
;
;
; OPTIONAL OUTPUTS:
;          gaps     : long array containing the startbins of gaps
;                     in the time array;
;                     if searchgap=0 is set, this output is not present   
;          gapdura  : array containing the lengths of the gaps in the
;                     time array, given in the same units as
;                     the time array;    
;                     if searchgap=0 is set, this output is not present    
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
;          outside of the gaps the lightcurve has
;          to be evenly spaced 
;
;
; PROCEDURES USED:
;          timegap.pro
;
;
; EXAMPLE:
;          time=[findgen(100),150.+findgen(50)]
;          timeseg,time,ndx,dseg=10L,tolerance=1D-8, $
;                  gaps=gaps,gapdura=gapdura,/searchgaps,/chatty
;   
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2-1.5, 2000/01/25 Katja Pottschmidt,   
;                                  zseg code corrected,
;                                  dtdseg definition corrected,   
;                                  gahe array added and corrected
;          Version 1.6, 2000/10/25 Katja Pottschmidt,    
;                                  IDL header added,
;                                  keyword default values defined/changed,
;                                  IDL and cvs version numbers
;                                  synchronized         
;          Version 1.7, 2000/10/25 Katja Pottschmidt,    
;                                  IDL header: minor changes   
;          Version 1.8, 2000/11/02 Katja Pottschmidt,    
;                                  default for chatty keyword changed   
;          Version 1.9, 2000/11/16 Katja Pottschmidt,    
;                                  gahe loop corrected                   
;          Version 1.10, 2001/01/03 Katja Pottschmidt,    
;                                   corrected
;                                   "IF (dblock EQ n_elements(time)) 
;                                   THEN BEGIN" 
;                                   to
;                                   "IF (dblock(zndx) EQ
;                                   n_elements(time)) 
;                                   THEN BEGIN"
;          Version 1.11, 2001/01/03 Katja Pottschmidt,    
;                                   "IF (dblock[zndx[0]] EQ ...."    
;          Version 1.12, 2001/02/20 Katja Pottschmidt,    
;                                   replaced part of the code        
;                                   with Joern's simpler version
;   
;-
   
   
;; set default values
;; the default value for tolerance is set in the timegap.pro subroutine   
IF (n_elements(chatty) EQ 0) THEN chatty=1    
   
   
;;
;; dseg-keyword, default: 
;; dimension of the segments corresponds to [1/10] of the time 
;; between the first and the last bin 
;; of the evenly binned input time array 
;;
IF (n_elements(dseg) NE 0) THEN BEGIN
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'timeseg: The dimension of the lightcurve segments is: ',dseg
    ENDIF     
ENDIF ELSE BEGIN  
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'timeseg: No dimension'
        print,' for the lightcurve segments has been given,'
        print,' the default is the dimension corresponding to [1/10]'
        print,' of the time between the first and the last bin'
        print,' of the evenly binned input time array.'
    ENDIF 
    dura=fix((max(time)-min(time))/10.)
    dseg=long(dura/(time(1)-time(0)))
    dura=0.
ENDELSE 
dseg=long(dseg)


;;
;; searchgap-keyword, default: 
;; searchgap=1: the rebinned time array is searched for gaps  
;; 
IF (n_elements(searchgap) EQ 0) THEN BEGIN 
    searchgap=1
ENDIF 
IF (keyword_set(chatty)) THEN BEGIN 
    print,'timeseg: The time array is searched' 
    print,' for gaps (1=yes, 0=no): ',searchgap
ENDIF 


;;
;; determine the indices of the old time array that contribute to
;; the time segments, if the time array is not searched for gaps
;;
IF (searchgap EQ 0) THEN BEGIN
    ntold=n_elements(time)
    nseg=long(ntold/dseg)
    ntnew=long(nseg*dseg)
    ndx=lindgen(ntnew)
    ntold=0. & nseg=0. & ntnew=0.
ENDIF ELSE BEGIN 
       
    ;;
    ;; determine the array containing the bin numbers where the time
    ;; gaps start (gap) and the array of dimensions of the uninterrupted,
    ;; evenly binned time segments (dblock) 
    ;;
    timegap,time,gaps,dblock,gapdura,tolerance=tolerance,chatty=chatty
       
    ;;
    ;; determine the array of numbers of time segments with dimension dseg
    ;; (zseg) in each uninterrupted time segment with dimension
    ;; dblock
    dstart=[0]
    IF (gaps[0] NE -1) THEN BEGIN 
         dstart=[0,gaps+1]
    ENDIF 
    zseg=long(dblock/dseg)
    zndx=where(dblock GE dseg,nn)
    IF (nn GT 0) THEN BEGIN 
         dstart=dstart[zndx]
         dblock=dblock[zndx]
         zseg=zseg[zndx]
         
         start=-1
         FOR i=0,nn-1 DO BEGIN 
              start=[start,dstart[i]+dseg*lindgen(zseg[i])]
         ENDFOR 
         start=start(where(start GE 0))
    ENDIF ELSE BEGIN 
         message,'warning, data does not contain a valid segment'
    ENDELSE 


    
;          zseg=long(dblock/dseg)
;          zndx=where(zseg GT 0L,nn)
;          IF (zseg(0) GT 0L) THEN BEGIN
;               IF (nn EQ 1) THEN BEGIN 
;                    IF (dblock[zndx[0]] EQ n_elements(time)) THEN BEGIN 
;                         gaps=n_elements(time)-1 
;                    ENDIF ELSE BEGIN 
;                         gahe=gaps(0)
;                         gaps=gahe & gahe=0.
;                    ENDELSE
;               ENDIF
;               IF (nn GT 1) THEN BEGIN
;                    gahe=lonarr(nn-1)
;                    FOR i=0,nn-2 DO BEGIN 
;                         gahe(i)=gaps(zndx(i+1)-1) 
;                    ENDFOR 
;                    gaps=gahe & gahe=0.
;               ENDIF 
;          ENDIF ELSE BEGIN 
;               gaps=gaps(zndx-1)
;          ENDELSE
;          zseg=zseg(zndx)
;       
;          ;;
;          ;; determine the array of bin numbers (start) that correspond to the
;          ;; start times of the time segments with dimension dseg 
;          ;;
;          start=lonarr(total(zseg))
;          a=0L & b=zseg(0)-1L
;          IF (gaps(0) GE dseg-1L) THEN BEGIN 
;               start(a:b)=dseg*lindgen(zseg(0))    
;               FOR i=0,n_elements(zseg)-2 DO BEGIN
;                    a=b+1L & b=b+zseg(i+1)
;                    start(a:b)=gaps(i)+1L+dseg*lindgen(zseg(i+1))
;               ENDFOR
;          ENDIF ELSE BEGIN        
;               FOR i=0,n_elements(zseg)-1 DO BEGIN
;                    start(a:b)=gaps(i)+1L+dseg*lindgen(zseg(i))
;                    IF (i LE n_elements(zseg)-2) THEN BEGIN 
;                         a=b+1L & b=b+zseg(i+1)
;                    ENDIF 
;               ENDFOR           
;          ENDELSE 
;          zseg=0. & a=0. & b=0.

 

    ;;
    ;; determine the indices of the time array that contribute to
    ;; the time segments
    ;;
    ndx=lonarr(n_elements(start)*dseg)
    FOR i=0L,n_elements(start)-1L DO BEGIN 
        ndx(i*long(dseg):(i+1)*long(dseg)-1L)=start(i)+lindgen(dseg)
    ENDFOR
    
    tdseg=time(ndx(0))-time(ndx(dseg-1))
    dtdseg=dblarr(n_elements(ndx)/dseg)
    FOR i=0L,(n_elements(ndx)/dseg)-1L DO BEGIN
        dtdseg(i)=tdseg-(time(ndx(i*dseg))-time(ndx((i+1)*dseg-1L)))
    ENDFOR 
    ndxtest=where(dtdseg NE 0D0)
    IF (ndxtest[0] NE -1) THEN BEGIN 
         print,'Test for timeseg:'
         print,'Index of segments with a duration (in time units)'
         print,'that is different from the duration of the first segment:' 
         print,ndxtest
    ENDIF 
       
    start=0.
       
ENDELSE 
       
   
END 















