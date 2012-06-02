FUNCTION tcmipcorr,data,ccdid,dcol=dcol,noframeinfo=noframeinfo,$
                   ndccols=ndccols,chatty=chatty
   
;+
; NAME:            tcmipcorr
;
;
;
; PURPOSE:
;		   High energy event correction
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  corrdata=tcmipcorr,data,ccdid,dcol=dcol,/noframeinfo,/chatty
;
; 
; INPUTS:
;                  data  :  data struct array with the data to be corrected
;                  ccdid :  number of ccd containing the data (0..11)
;   
;
; OPTIONAL INPUTS:
;                  dcol: number of columns to be discarded on each
;                        side of mip (default dcol=2)
;   
;
; KEYWORD PARAMETERS:
;                  noframeinfo: data struct does not contain the element data.frame
;                  chatty: give more info
;
;
; OUTPUTS:
;                  data without high energy events
;
;
; OPTIONAL OUTPUTS:
;		   ndccols: number of discarded columns   
;                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  none
;
;
; RESTRICTIONS:
;                  if keyword /noframeinfo is set, all data with
;                  time values > 32700 is discarded  
;
;
; PROCEDURE:
;                  search all data for events with energies > 3000 ADU,
;                  discard column containing event and adjoining
;                  columns on that frame
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 11.09.00 T. Clauss first version
; V1.1 19.09.00 T. Clauss added keyword /noframeinfo   
;-
   
   IF (NOT keyword_set(dcol)) THEN dcol=2
   
   tmax=32700
   
   dat=data(where(data.ccd EQ ccdid))
   
   IF keyword_set(noframeinfo) THEN BEGIN 
       ind=where(dat.time lt tmax)
       dat=dat(ind)  
       frame=dat.time-shift(dat.time,-1)
       frameind=where(frame NE 0) ; frame borders of frames containing events
       numevframes=n_elements(frameind) ; number of frames containing events
   ENDIF ELSE BEGIN
       frame=dat.frame-shift(dat.frame,-1)
       frameind=where(frame NE 0) ; frame borders of frames containing events
       numevframes=n_elements(frameind) ; number of frames containing events
   ENDELSE
   
   IF keyword_set(chatty) THEN $
     print,'% TCMIPCORR: number of frames containing events: ',strtrim(numevframes,2) 
   
   ndccols=0l
   
   FOR i=0l,numevframes-1,1 DO BEGIN
       IF i EQ 0 THEN BEGIN
           find=indgen(frameind(i)+1)
       ENDIF ELSE BEGIN
           find=indgen(frameind(i)-frameind(i-1)) + frameind(i-1)+1
       ENDELSE 
       framedat=dat(find)
       ind1=where(framedat.energy GE 3000)
       IF ind1(0) NE -1 THEN BEGIN
           ;; find columns with high energy events 
           col1=framedat(ind1).column
           col1=col1(sort(col1))
           col1=col1(uniq(col1))
           ;; find adjoining columns
           col=col1           
           FOR icol=0,n_elements(col1)-1 DO BEGIN 
               FOR j=1,dcol DO BEGIN
                   col=[col,col1(icol)-j,col1(icol)+j]
               ENDFOR
           ENDFOR
           col=col(sort(col))
           col=col(uniq(col))
           ncol=n_elements(col)
           ndccols=ndccols+ncol    
           ;; delete events in columns
           FOR icol=0,ncol-1 DO BEGIN 
               ind=where(framedat.column EQ col(icol))
               IF ind(0) NE -1 THEN dat(find(ind)).energy=0
           ENDFOR
           
       ENDIF
   ENDFOR
   
   ind=where(dat.energy GT 0)
   dat=dat(ind)
   return,dat
END
