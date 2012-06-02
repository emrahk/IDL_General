FUNCTION tctimingmipcorr,data,ccdid,dcol=dcol,noframeinfo=noframeinfo,$
                         ndccols=ndccols,chatty=chatty
   
;+
; NAME:            tctimingmipcorr
;
;
;
; PURPOSE:
;		   High energy event correction for timing mode
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  corrdata=tctimingmipcorr,data,ccdid,dcol=dcol,/noframeinfo,chatty=chatty 
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
;                  noframeinfo: has to be set if data struct does not
;                               contain th element data.frame
;                  chatty: give more info
;
;
; OUTPUTS:
;                  data without high energy events
;
;
; OPTIONAL OUTPUTS:
;		   ndccols: number of discarded columns (with or
;		            without any events)  
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
;                  if /noframeinfo is not set, data struct must contain the element data.frame
;                  
;
; PROCEDURE:
;                  search all data for events with energies > 3000 ADU,
;                  discard column containing event and adjoining
;                  columns on that frame, discard columns on next frame
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 19.09.00 T. Clauss first version derived from tcmipcorr
;-
   
   IF (NOT keyword_set(dcol)) THEN dcol=2
   
   dat=data(where(data.ccd EQ ccdid))
   
   IF keyword_set(noframeinfo) THEN BEGIN 
       dat=tcaddframeinfo(dat,'timing')
   ENDIF
   
   frame=dat.frame-shift(dat.frame,-1)
   frameind=where(frame NE 0)   ; frame borders of frames containing events
   numevframes=n_elements(frameind) ; number of frames containing events
   
   IF keyword_set(chatty) THEN $
     print,'% TCTIMINGMIPCORR: number of frames containing events: ',strtrim(numevframes,2) 
   
   tend=dat(n_elements(dat)-1).time
   ndccols=0
   
   FOR i=0l,numevframes-2,1 DO BEGIN
       IF i EQ 0 THEN BEGIN
           find=indgen(frameind(i)+1)
       ENDIF ELSE BEGIN
           find=indgen(frameind(i)-frameind(i-1)) + frameind(i-1)+1
       ENDELSE 
       
       framedat=dat(find)
       ind1=where(framedat.energy GE 3000)
       IF ind1(0) NE -1 THEN BEGIN 
           
           nframe=-1
           IF dat(max(find)+1).frame EQ framedat(0).frame+1 THEN BEGIN
               ;; next frame not empty
               nframe=1
               nfind=indgen(frameind(i+1)-frameind(i)) + frameind(i)+1
               nframedat=dat(nfind)
           ENDIF 
               
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
               IF nframe EQ 1 THEN BEGIN 
                   ind=where((nframedat.column EQ col(icol)) AND (nframedat.energy LT 3000))
                   IF ind(0) NE -1 THEN dat(nfind(ind)).energy=0 
               ENDIF
           ENDFOR
       ENDIF
   ENDFOR
   
   ndccols=ndccols*2  ;; discarded columns on two frames
   
   ;; treat last frame separately
   i=numevframes-1
   find=indgen(frameind(i)-frameind(i-1)) + frameind(i-1)+1
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
   
   ind=where(dat.energy GT 0)
   dat=dat(ind)
   
   return,dat
   
END
