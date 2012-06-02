FUNCTION tcmiptracecorr,data,ccdid,ndcframes=ndcframes,ndcframe0=ndcframe0,dcol=dcol,$
                        noframeinfo=noframeinfo,mode=mode,ndccols=ndccols
   
;+
; NAME:            tcmiptracecorr
;
;
;
; PURPOSE:
;		   Discard events and traces from highly ionizing
;		   particles (hip)
;		   
;
;
; CATEGORY:
;                  XMM-Data Analysis
;
;
; CALLING SEQUENCE:
;                  cdata=tcmiptracecorr,data,ccdid,mode,ndcframes=ndcframes,/ndcframe0
;
; 
; INPUTS:
;                  data : data struct array 
;                  ccdid :  number of ccd containing the data (0..11)
;   
;
; OPTIONAL INPUTS:
;                  ndcframes: number of additional frames in which columns are to
;                             be discarded after each frame with a hip event
;                             (for ndcframes=0, set /ndcframe0)
;                  dcol: number of columns to be discarded on each
;                        side of mip on each frame (default dcol=2)   
;                  mode: mode of measurement (needed if keyword
;                        /noframeinfo is set, default: timing)
;   
;
; KEYWORD PARAMETERS:
;                  ndcframe0: only columns in the frame with the hip
;                             event are discarded
;                  noframeinfo: data struct does not contain the element data.frame
;
;
; OUTPUTS:
;                  data from which all events from highly ionizing
;                  particles are removed
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
;                  none
;
;
; PROCEDURE:
;         
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 08.09.00 T. Clauss first version
;-
   
   IF (NOT keyword_set(ndcframes)) THEN ndcframes=20
   IF keyword_set(ndcframe0) THEN ndcframes=0
   IF NOT keyword_set(dcol) THEN dcol=2
   
   dat=data(where(data.ccd EQ ccdid))
   
   IF keyword_set(noframeinfo) THEN BEGIN 
       IF NOT keyword_set(mode) THEN mode='timing'
       dat=tcaddframeinfo(dat,mode)
   ENDIF
   
   ldat=dat(0)
   ldat.energy=0
   ldat.time=dat(n_elements(dat)-1).time+100
   ldat.frame=dat(n_elements(dat)-1).frame+110
   dat=[dat,ldat]  ;; dummy event as last event
   
   frame=dat.frame-shift(dat.frame,-1)
   frameind=where(frame NE 0)   ; frame borders of frames containing events
   numframes=n_elements(frameind) ; number of frames containing events
   
   ndccols=0
   
   FOR f=1l,numframes-2 DO BEGIN   
                 
       IF (f NE 1) THEN BEGIN
           framedat=nframedat  ;; data in this frame 
           nframedat=dat(frameind(f)+1:frameind(f+1))  ;; data in next frame 
       ENDIF ELSE BEGIN   ;; first frame
           framedat=dat(0:frameind(f-1))
           nframedat=dat(frameind(f-1)+1:frameind(f))
       ENDELSE
       
       heind=where(framedat.energy GE 3000)
       
       IF heind(0) NE -1 THEN BEGIN 
           
           ;; search for all high energy events from highly ionizing particles
;           dcind=tcsearchalphas(framedat,nframedat,heind)
           
           ;; take all high energy events
           dcind=heind
           
           IF dcind(0) NE -1 THEN BEGIN 
               
               IF f EQ 1 THEN BEGIN
                   find=indgen(frameind(0)+1)
               ENDIF ELSE BEGIN
                   find=indgen(frameind(f)-frameind(f-1)) + frameind(f-1)+1  ;; current frame
               ENDELSE 
               
               ;; find columns  
               col1=framedat(dcind).column
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
               
               ;; delete columns in following frames
               nf=0
               framenr=framedat(0).frame
               tframedat=nframedat
               dframes=tframedat(0).frame-framenr
               find=indgen(frameind(f+1+nf)-frameind(f+nf)) + frameind(f+nf)+1
               WHILE dframes LE ndcframes DO BEGIN
                   FOR icol=0,ncol-1 DO BEGIN 
                       ind=where(tframedat.column EQ col(icol))
                       IF ind(0) NE -1 THEN dat(find(ind)).energy=0
                   ENDFOR 
                   nf=nf+1
                   find=indgen(frameind(f+1+nf)-frameind(f+nf)) + frameind(f+nf)+1  ;; next frame
                   tframedat=dat(find)
                   dframes=tframedat(0).frame-framenr
               ENDWHILE
           ENDIF 
       ENDIF
   ENDFOR
      
;   dat=dat(frameind(0)+1:*)  ; discard first frame
   
   ndccols=ndccols*(ndcframes+1)
   
   dat=dat(where(dat.energy GT 0))

   return,dat
   
END
