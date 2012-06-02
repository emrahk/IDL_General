PRO lcseg,nameorg,namefin,dseg=dseg,gaps=gaps,gapdura=gapdura,chatty=chatty
;+
; NAME:
;          lcseg
;
;
; PURPOSE:
;          read multidimensional xdr lightcurve and cut it into segments of 
;          given dimension taking gaps into account, write segmented
;          multidimensional xdr lightcurve 
;
;
; FEATURES: 
;          a string named ``nameorg'' containing the name of the
;          multidimensional xdr lightcurve that is to be cut into
;          segments of dimension ``dseg'' (default: 1/10th of the time
;          between the first and the last time bin of the original
;          time array given in the same units as the time array) has
;          to be given; the lightcurve is read; the startbins of the
;          gaps in the time array and the gap lengths given in the
;          same units as the time array are determined and are
;          optional array outputs, called ``gaps'' and ``gapdura'';
;          the updated history string array, the gap array, and the
;          segmented multidimensional lightcurve are written to the
;          xdr file ``namefin''
;
;
; CATEGORY:
;          timing tools
;
;
; CALLING SEQUENCE:
;          lcseg,nameorg,namefin,dseg=dseg, $
;                gaps=gaps,gapdura=gapdura,chatty=chatty 
;
;
; INPUTS:
;          nameorg  : string containing the file name of
;                     the multidimensional lightcurve in xdr format
;                     that is to be read and cut into segments
;          namefin  : string giving the file name of the segmented 
;                     multidimensional xdr output lightcurve (with the
;                     file also containing the updated history array
;                     and the gap array)
;
; OPTIONAL INPUTS:
;          dseg     : parameter containing the segment length in bins;
;                     default: 1/10th of the time between the first
;                     and the last time bin of the original time array
;                     given in the same units as the time array   
;
;
; KEYWORD PARAMETERS:
;          chatty   : controls screen output; 
;                     default: screen output;  
;                     to turn off screen output, set chatty=0
;
;
; OUTPUTS:
;          none, but see side effects and optional outputs
;
;
; OPTIONAL OUTPUTS:
;          gaps         : long array containing the startbins of gaps
;                         in the time array; 
;                         separately written to the xdr output file      
;          gapdura      : array containing the lengths of the gaps in the
;                         time array, given in the same units as
;                         the time array   
;
;
; COMMON BLOCKS:
;          none
;
;
; SIDE EFFECTS:
;          the resulting segmented multidimensional lightcurve,
;          the updated history string array, and the gap array are
;          written to the file namefin in xdr format
;
;
; RESTRICTIONS:
;          the input lightcurve has to be an xdr lightcurve written by the
;          xdrlc_w.pro routine; outside of the gaps the lightcurve has
;          to be evenly spaced 
;
;
; PROCEDURES USED:
;          xdrlc_r.pro, timeseg.pro, xdrlc_w.pro
;
;
; EXAMPLE:
;         lcseg,'syncseg.xdrlc','0008192_seg.xdrlc',dseg=8192L, $
;               gaps=gaps,gapdura=gapdura,/chatty
;
;
; MODIFICATION HISTORY:
;          Version 1.1, 1998       Katja Pottschmidt
;                       1999/10/14 Katja Pottschmidt,
;                                  cvs version control enabled      
;          Version 1.2, 2000/10/24 Katja Pottschmidt,   
;                                  IDL header added,
;                                  keyword default values defined/changed    
;          Version 1.3, 2000/11/02 Katja Pottschmidt,   
;                                  default for chatty keyword changed   
;          Version 1.4, 2001/01/05 Katja Pottschmidt,   
;                                  if an empty segment is found,
;                                  the program stops   
;                                     
;   
;
;-
   
   
;; set default values,
;; the default value for dseg is set in the timeseg.pro subroutine
IF (n_elements(chatty) EQ 0) THEN chatty=1
   
    
;; read "nameorg"
xdrlc_r,nameorg,time,rate,history=hisfin,chatty=chatty
maxdim=string(dseg)   
nhist=n_elements(hisfin)+2
hisfin=temporary(['Dimension of history (lcseg)='+string(nhist), $
                  hisfin,'Maximum dimension of segments (lcseg)='+maxdim])


;; cut "time" into segments with dimension "dseg", "ndx" gives the
;; indices of "time" that have to be used
timeseg,time,ndx,dseg=dseg,searchgap=1,gaps=gaps,gapdura=gapdura,chatty=chatty


;; new "time" array
time=time[ndx]


;; new "rate" array
rate=temporary(rate[ndx,*])

;; check for empty segments
nch=n_elements(rate[0,*])
num=n_elements(time)/dseg
FOR j=0,nch-1 DO BEGIN
    FOR i=0,num-1 DO BEGIN
        segrate=long(total(rate[(i*dseg):((i+1)*dseg)-1,j]))
        IF (segrate EQ 0L) THEN BEGIN
            print,'00000000000000000000000000000000000000000000000'
            print,'lcseg: Energy range: ',j
            print,'       No. of segment: ',i 
            message,'lcseg: A segment with a total count rate of zero is found'
        ENDIF 
    ENDFOR   
ENDFOR 



;; write xdr file
xdrlc_w,namefin,time,rate,history=hisfin,gaps=gaps,dseg=dseg,chatty=chatty 


END 











