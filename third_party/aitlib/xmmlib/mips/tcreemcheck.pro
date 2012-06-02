PRO tcreemcheck,data,ccd,mode,emin=emin,emax=emax,tmax=tmax,$
                lend=lend,ltrace=ltrace,inctrace=inctrace,$
                chatty=chatty,showframes=showframes,stop=stop
   
;+
; NAME:            tcreemcheck
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
;                  tcreemcheck,data,ccd,mode,emin=emin,emax=emax,tmax=tmax,$
;                              lend=lend,ltrace=ltrace,inctrace=inctrace,$
;                              /chatty,/showframes,/stop
;
; 
; INPUTS:
;                  data  :  data struct array with the data to be corrected
;                  ccd :  number of the ccd containing the data (0..11)
;                  mode: string with mode of measurement: 'FF', 'TI', 'BU', 'SW',
;                        or 'full', 'timing', 'burst', 'small'  
;                        or integer 1..4
;
; OPTIONAL INPUTS:
;                  emin: the minimum energy value in ADU 
;                  emax: the maximum energy value in ADU
;                  tmax: the maximum time value, data with smaller
;                        time values are discarded
;                  lend: number of empty frames after which a trace is
;                        considered to have ended (default: 25)    
;   
;
; KEYWORD PARAMETERS:
;                  showframes: show energy image of each frame
;                  chatty: give more info
;                  stop: stop before returning
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;		   ltrace: intarr(302), each element contains the
;		           number of traces with length (in # of
;		           frames) equaling the element number;
;		           the last element contains the
;		           number of traces that are longer than 300
;		           frames 
;                  inctrace: number of incomplete traces which occur
;                          when a second high energy event hits the
;                          trace of a high energy event in a previous
;                          frame 
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
;                  if keyword tmax is not set, all data with
;                  time values > 32000 is discarded  
;
;
; PROCEDURE:
;                  Search all data for events with energies > 3000 ADU,
;                  check the following frames for events in the same column.
;                  If there are <lend> frames without an event, store
;                  trace length in ltrace.
;
;
; EXAMPLE:
;                  
;                  
;
; MODIFICATION HISTORY:
; V1.0 08.09.00 T. Clauss first version
;-
   
   
   IF (NOT keyword_set(emin)) THEN emin=0
   IF (NOT keyword_set(emax)) THEN emax=4095
   IF (NOT keyword_set(tmax)) THEN tmax=10000L
   
   IF keyword_set(chatty) THEN chatty=1 ELSE chatty=0
   IF keyword_set(showframes) THEN BEGIN 
       showframes=1 
       zoom=4
       xsize=200*zoom
       ysize=64*zoom
       tcreversect,3
       window,10,xsize=xsize,ysize=ysize,xpos=200,ypos=200+ysize       
   ENDIF ELSE showframes=0  
   minfo=0
   
   mode=string(mode)
   
   CASE strtrim(mode,2) OF
       'FF': tframe=(0.07326592d - 0.00000001d)
       'TI': tframe=(0.00590400d - 0.00000001d)
       'BU': tframe=(0.00433728d - 0.00000001d)
       'SW': tframe=(0.00565856d - 0.00000001d)
       '1' : tframe=(0.07326592d - 0.00000001d)
       '2' : tframe=(0.00590400d - 0.00000001d)
       '3' : tframe=(0.00433728d - 0.00000001d)
       '4' : tframe=(0.00565856d - 0.00000001d)
       ELSE: BEGIN
           print,'% TCREEMCHECK: No valid mode given, returning...'
           return
       ENDELSE
   ENDCASE
   
   dat=data(where(data.ccd EQ ccd))
   
   IF (keyword_set(emin) OR keyword_set(emax)) THEN BEGIN 
       IF (NOT keyword_set(emax)) THEN emax=4095
       IF (NOT keyword_set(tmax)) THEN tmax=10000L
       ind=where((dat.energy gt emin) and (dat.energy lt emax))
       dat=dat(ind)
   ENDIF
   
  IF keyword_set(tmax) THEN BEGIN
       dat.time=dat.time-dat(0).time
       ind=where(dat.time lt tmax)
       dat=dat(ind)
   ENDIF ELSE BEGIN
       ind=where(dat.time lt 32000)   ;; get rid of swaps
       dat=dat(ind)    
   ENDIF
      
   checkstruct={checkstructelem,sdist:0,fdist:0,ncol:0,columns:intarr(64),nframes:0}
   checklist=replicate(checkstruct,1)
   checkelem=replicate(checkstruct,1)
   
   IF NOT keyword_set(lend) THEN lend=25
   
   lmax=300  ;; max. trace length to be counted, all longer traces are counted in ltrace(lmax+1)
   ltrace=lonarr(lmax+2)   
   ltrace(*)=0
   inctrace=0 ;; incomplete traces
   
   ; calculate frame border indices
   frame=dat.time-shift(dat.time,-1)
   frameind=where(frame ne 0)
   numframes=n_elements(frameind)
   
   FOR f=1l,numframes-1 DO BEGIN 
                 
       IF (f NE 1) THEN BEGIN
           framedat=dat(frameind(f-1)+1:frameind(f))
           dtime=framedat(0).time-dat(frameind(f-1)).time
       ENDIF ELSE BEGIN   ;; first frame
           framedat=dat(0:frameind(f-1))
           dtime=0
       ENDELSE
       
       neframes=fix(dtime/tframe)-1  ;; number of empty frames
       
       ncheck=n_elements(checklist)
       
       IF neframes GE 1 THEN BEGIN  ;; empty frames
           IF chatty EQ 1 THEN print,'%TCREEMCHECK: ',strtrim(neframes,2),' empty frames.'
           delind=-1
           FOR i=1,ncheck-1 DO BEGIN
               checklist(i).sdist=checklist(i).sdist+neframes
               checklist(i).fdist=checklist(i).fdist+neframes
               IF checklist(i).fdist GT lend THEN BEGIN
                   IF checklist(i).nframes LE lmax THEN BEGIN 
                       ltrace(checklist(i).nframes)=ltrace(checklist(i).nframes)+1
                   ENDIF ELSE BEGIN 
                       ltrace(lmax+1)=ltrace(lmax+1)+1
                   ENDELSE
                   delind=[delind,i]
               ENDIF
           ENDFOR
           IF n_elements(delind) GT 1 THEN tmp=tcdelarrelem(checklist,delind(1:*))
       ENDIF
       
       IF chatty EQ 1 THEN print,'%TCREEMCHECK: working on frame number ',strtrim(f,2)
       
       IF showframes EQ 1 THEN BEGIN
           framedat1=framedat
           wset,10
           mkplotenergy1,framedat1,ccd,/scale,zoom=zoom,/nowin
       ENDIF
              
       fcols=framedat.column
       fcols=fcols(sort(fcols))
       fcols=fcols(uniq(fcols))
       nfcol=n_elements(fcols)
       
       hind=where(framedat.energy GE 3000)
       IF hind(0) NE -1 THEN BEGIN  
           hcols=framedat(hind).column
           hcols=hcols(sort(hcols))
           hcols=hcols(uniq(hcols))
           nhcol=n_elements(hcols)
       ENDIF ELSE BEGIN
           nhcol=0
       ENDELSE 
       
       ncheck=n_elements(checklist)
       
       IF ncheck GT 1 THEN BEGIN 
           
           IF nhcol GT 0 THEN BEGIN
               IF chatty EQ 1 THEN print,'%TCREEMCHECK: ',strtrim(nhcol,2),' high energy event(s).'
               res=1
               delind=-1
               FOR i=1,ncheck-1 DO BEGIN
                   IF res GT 0 THEN BEGIN 
                       check1=tccomparr(hcols,checklist(i).columns(0:checklist(i).ncol-1),indarr1=indhcl)
                       IF check1 GT 0 THEN BEGIN  
                           IF checklist(i).sdist GE 0 THEN BEGIN  ;; new high energy event
                               IF chatty EQ 1 THEN print,'%TCREEMCHECK: new high energy event in reemitting line.'
                               
                               delind=[delind,i]
                               inctrace=inctrace+1
                               
                               indhcl=tcfindnbelems(hcols,indhcl)  ;; find adjoining columns
                               
                               checkelem.sdist=-2
                               checkelem.fdist=0
                               checkelem.ncol=n_elements(indhcl)
                               checkelem.columns(0:checkelem.ncol-1)=hcols(indhcl)
                               checkelem.nframes=0
                               checklist=[checklist,checkelem]
                               res=tcdelarrelem(hcols,indhcl)
                           ENDIF ELSE BEGIN
                               indhcl=tcfindnbelems(hcols,indhcl)
                               res=tcdelarrelem(hcols,indhcl)
                           ENDELSE
                       ENDIF
                   ENDIF
               ENDFOR
               IF n_elements(delind) GT 1 THEN tmp=tcdelarrelem(checklist,delind(1:*))
               WHILE res GT 0 DO BEGIN  ;; elements in hcols left
                   IF chatty EQ 1 THEN print,'%TCREEMCHECK: adding new high energy event.'
                   IF minfo EQ 1 THEN BEGIN 
                       pcount=0
                       penergy=0
                       doeventspec,framedat,ind(0),pcount,penergy
                   ENDIF 
                   indhcl=tcfindnbelems(hcols,0)
                   checkelem.sdist=-2
                   checkelem.fdist=0
                   checkelem.ncol=n_elements(indhcl)
                   checkelem.columns(0:checkelem.ncol-1)=hcols(indhcl)
                   checkelem.nframes=0
                   checklist=[checklist,checkelem]               
                   res=tcdelarrelem(hcols,indhcl)
               ENDWHILE
           ENDIF
           
           ncheck=n_elements(checklist)

           IF nfcol GT 0 THEN BEGIN
               res=1
               delind=-1
               FOR i=1,ncheck-1 DO BEGIN
                   checklist(i).sdist=checklist(i).sdist+1
                   IF res GT 0 THEN BEGIN 
                       check1=tccomparr(fcols,checklist(i).columns(0:checklist(i).ncol-1),indarr1=indfcl)
                       IF check1 GT 0 THEN BEGIN   ;; found event
                           checklist(i).nframes=checklist(i).nframes+checklist(i).fdist
                           checklist(i).fdist=1
                           res=tcdelarrelem(fcols,indfcl)
                       ENDIF ELSE BEGIN  ;; no event
                           IF checklist(i).fdist LE lend THEN BEGIN
                               checklist(i).fdist=checklist(i).fdist+1
                           ENDIF ELSE BEGIN
                               IF checklist(i).nframes LE lmax THEN BEGIN 
                                   ltrace(checklist(i).nframes)=ltrace(checklist(i).nframes)+1
                               ENDIF ELSE BEGIN
                                   ltrace(lmax+1)=ltrace(lmax+1)+1
                               ENDELSE
                               delind=[delind,i]
                           ENDELSE 
                       ENDELSE
                   ENDIF ELSE BEGIN  ;; fcols empty
                       IF checklist(i).fdist LE lend THEN BEGIN
                           checklist(i).fdist=checklist(i).fdist+1
                       ENDIF ELSE BEGIN
                           IF checklist(i).nframes LE lmax THEN BEGIN 
                               ltrace(checklist(i).nframes)=ltrace(checklist(i).nframes)+1
                           ENDIF ELSE BEGIN 
                               ltrace(lmax+1)=ltrace(lmax+1)+1
                           ENDELSE 
                           delind=[delind,i]
                       ENDELSE 
                   ENDELSE
               ENDFOR
               IF n_elements(delind) GT 1 THEN tmp=tcdelarrelem(checklist,delind(1:*))
           ENDIF ELSE BEGIN  ;; this shouldn't happen
               print,'%TCREEMCHECK: empty frame!!'
           ENDELSE
       ENDIF ELSE BEGIN  ;; checklist empty
           IF nhcol GT 0 THEN BEGIN
               res=1
               WHILE res GT 0 DO BEGIN  ;; elements in hcols left
                   IF chatty EQ 1 THEN print,'%TCREEMCHECK: adding new high energy event.'
                   indhcl=tcfindnbelems(hcols,0)
                   checkelem.sdist=-2
                   checkelem.fdist=0
                   checkelem.ncol=n_elements(indhcl)
                   checkelem.columns(0:checkelem.ncol-1)=hcols(indhcl)
                   checkelem.nframes=0
                   checklist=[checklist,checkelem]               
                   res=tcdelarrelem(hcols,indhcl)
               ENDWHILE
           ENDIF
       ENDELSE
       IF showframes EQ 1 THEN stop 
   ENDFOR
      
   IF keyword_set(stop) THEN stop
END
