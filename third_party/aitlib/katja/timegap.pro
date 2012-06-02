PRO timegap,time,gaps,dblock,gapdura,tolerance=tolerance,chatty=chatty, $
            bt=bt
;+
; NAME:
;          timegap
;
;
; PURPOSE:
;          find gaps in a time array, determine gap and segment lengths
;
;
; FEATURES: 
;          the time array ``time'' has to be evenly spaced outside of
;          the gaps; the parameter ``tolerance'' defines the lower
;          limit for the gap detection in terms of a relative
;          deviation from the first time bin; the ``gaps'' array
;          containing the startbins of the gaps is determined; the
;          ``dblock'' array containing the durations of uninterrupted
;          time segments in time bins is determined; and the
;          ``gapdura'' array containing the length of each gap given in
;          the same units as the time array is determined 
;
;   
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          timegap,time,gaps,dblock,gapdura,tolerance=tolerance,chatty=chatty
;
;
; INPUTS:
;          time     : time array to be searched for gaps
;
;
; OPTIONAL INPUTS:
;          tolerance: parameter defining the lower limit for the gap
;                     length; the reference is the time difference
;                     between the first and second entry in the time
;                     array; tolerance defines the maximum allowed relative
;                     deviation from this reference bin length; 
;                     default: 1D-8
;          bt       : bin-time of the light curve (default: bt=time[1]-time[0])
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0 
;
;
; OUTPUTS:
;          gaps     : long array containing the startbins of gaps
;                     in the time array 
;          dblock   : long array containing the dimensions of 
;                     uninterrupted time segments  
;          gapdura  : array containing the lengths of the gaps, given
;                     in the same units as the time array
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
;          none
;
;
; RESTRICTIONS:
;          outside of the gaps the lightcurve has to be evenly spaced
;
;
; PROCEDURES USED:
;          none
;
;
; EXAMPLE:
;          time=[findgen(100),150.+findgen(50)] 
;          timegap,time,gaps,dblock,gapdura,tolerance=1D-8,/chatty
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
;                                  screen output: minor changes   
;          Version 1.4, 2000/10/25 Katja Pottschmidt,   
;                                  a tolerance value of 0 is allowed
;                                  now   
;          Version 1.5, 2000/11/02 Katja Pottschmidt,   
;                                  default for chatty keyword changed    
;          Version 1.6, 2001/02/16 KP, JW
;                                  if chatty=0 we now completely shut
;                                  up
;          Version 1.7, 2001/08/10 Joern Wilms
;                                  * added bt keyword and rephrased some
;                                    of the informative messages
;                                  * use absolute value of dt-bt for comparing
;
;-
   
   
;; helpful parameters, set default values
IF (n_elements(chatty) EQ 0) THEN chatty=1   


;; tolerance-keyword, default: 
;; tolerance=1D-8: tolerance for gap definition 
IF (n_elements(tolerance) EQ 0) THEN tolerance=1D-8
IF (keyword_set(chatty)) THEN BEGIN 
    print,'timegap: The tolerance for gap definition is: ',tolerance 
ENDIF 

IF (n_elements(bt) EQ 0) THEN bt=time[1]-time[0]
   

;; determine where the time difference between two consecutive time values
;; is bigger or smaller than the bin time;
;; determine the array containing the bin numbers where the time
;; gaps start  
nt=n_elements(time)
dt=shift(time,-1)-time
dt=dt(0:nt-2) 
ref=where(dt LT bt,cc)
gaps=where(abs(dt-bt)/bt GT tolerance)

ng=n_elements(gaps)
IF (cc GT 1) THEN BEGIN 
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'timegap: There are time differences shorter than the bin time'
    ENDIF
ENDIF 


;; determine the array of dimensions of the uninterrupted,
;; time segments (dblock)
IF (gaps(0) EQ -1 ) OR (n_elements(gaps) EQ 1 AND gaps(0) EQ 0) THEN BEGIN 
    IF (keyword_set(chatty)) THEN BEGIN 
        print,'timegap: There is no gap in the time array'
    ENDIF 
    dblock=long(nt)
    gapdura=0
ENDIF ELSE BEGIN 
     IF (keyword_set(chatty)) THEN BEGIN 
          print,'timegap: There are gaps in the time array'
     ENDIF 
     dblock=lonarr(ng+1)
     dblock(0)=gaps(0)+1
     dblock(1:ng)=shift(gaps,-1)-gaps
     dblock(ng)=nt-(gaps(ng-1)+1)
     gapdura=time(gaps+1)-time(gaps)
ENDELSE 


END  









