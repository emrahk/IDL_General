PRO readrawdata,file,lrahmen=lrahmen,ids=ids,idhis=idhis,q0=q0,q1=q1,q2=q2,q3=q3,$
                offsetmap=offsetmap,noisemap=noisemap,dslinmap=dslinmap,$
                numoffset=numoffset,numnoise=numnoise,$
                chatty=chatty,stat=stat,stream=stream
;+
; NAME:            readrawdata
;
;
;
; PURPOSE:
;                  Read a rawdata stream from a HK-file
;
;
;
; CATEGORY:
;                  Data-I/O
;
;
; CALLING SEQUENCE:
;                  readrawdata,file,lrahmen=lrahmen,ids=ids,idhis=idhis,q0=q0,q1=q1,q2=q2,q3=q3,$
;                              offsetmap=offsetmap,noisemap=noisemap,dslinmap=dslinmap,$
;                              chatty=chatty,stat=stat,stream=stream
; 
; INPUTS:
;                  file    : Name of the data-file to read
;                                
;
;
; OPTIONAL INPUTS:
;                  stream  : Number of the data stream to write
;                            statiscal info; only necessary when
;                            keyword /stat is set !
;
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on
;                  /stat   : Write statistical information to
;                            file-stream given in parameter "stream"  
;    
;
;
; OUTPUTS:
;                  none
;
;
; OPTIONAL OUTPUTS:
;                  lrahmen  : Structure containing the data with all
;                             header information as read from file 
;                  ids      : Vector with all frame-ids in the data stream
;                  idhis    : Histogram of all frame-ids in the data stream
;                  q0       : All data of quadrant 0
;                  q1       : All data of quadrant 1
;                  q2       : All data of quadrant 2
;                  q3       : All data of quadrant 3
;                  offsetmap: Array containing a offsetmap when found
;                             in data (LBR)
;                  noisemap : Array containing a nosiemap when found
;                             in data (LBR)
;                  dslinmap : Array containing a dskinmap when found
;                             in data                  
;
; COMMON BLOCKS:
;                  none
;
;
; SIDE EFFECTS:
;                  if no science data could be found, the programm
;                  will return -1 as the specified data.
;
;
; RESTRICTIONS:
;                  none
;
;
; PROCEDURE:
;                  see code
;
;
; EXAMPLE:
;                  readrawdata,file,q0=rawdata0,q1=rawdata1,$
;                              q2=rawdata2,q3=rawdata3,/chatty
;
;
; MODIFICATION HISTORY:
; V1.0 10.11.98 Markus Kuster
; V1.1 18.12.98 M. Kuster added statistical output to file and screen
; V1.2 22.12.98 M. Kuster offset, noise and dslin map reading added
; V1.3 12.02.99 M. Kuster fixed bug: program crashed while reading
;                         data with events = 0 within one quadrant 
; V1.4 23.02.99 M. Kuster fixed bug; first 30 frames in hk-file are
;                         dummy header frames and should not be
;                         counted in statistics
; V1.5 02.03.99 M. Kuster Changed id for noise and offsetmaps from
;                         28/29 to 32/33
; V1.6 13.12.99 M. Kuster Changed output to file and screen
;-
   
   IF (keyword_set(chatty)) THEN BEGIN
       chatty=1
   END ELSE BEGIN
       chatty=0
   END
   IF (keyword_set(stat)) THEN BEGIN
       stat=1
   END ELSE BEGIN
       stat=0
   END
   ;;--------------------------------------
   ;; set default values for used variables
   q0=1 & q1=1 & q2=1 & q3=1
   noisemap=1 & offsetmap=1 & dslinmap=1
   dzahl0=0 & dzahl1=0 & dzahl2=0 & dzahl3=0
   ;;--------------------------------------
  
   rahmen={dummyeb:byte(0),dummy90:byte(0),zeit:long(0),zaehler:byte(0),$
           id:byte(0),zz:lonarr(30)}
   
   IF (chatty EQ 1) THEN BEGIN
       print,'% READRAWDATA: Reading file ',file
   END
   
   openr,unit,file,/get_lun
  
   si=fstat(unit) 
   siz=si.size/128.
   lrahmen=replicate(rahmen,siz)
   
   readu,unit,lrahmen
   free_lun,unit
   
;; Frame-Ids
   ids=lrahmen.id
   
;; Histogramm of quadrants
   idhis=histogram(ids)
   
;; Remove header from read data 
   rawdata=lrahmen.zz
   lrahmen=0l                   ;to save memory !!!
;; Convert from network to host order to prevent problems with little/big endian
   byteorder, rawdata, /ntohl   
;; Filter out Quadrants 
   ind0=where(ids EQ 160,numq0)
   ind1=where(ids EQ 161,numq1)
   ind2=where(ids EQ 162,numq2)
   ind3=where(ids EQ 163,numq3)
   
;; Filter out Offset and Discarded Line maps
   indoffset=where(ids EQ '20'X,numoffset)
   indnoise =where(ids EQ '21'X,numnoise)
   inddiscarded=where(ids EQ '1E'X,numdisc)
   
;   numoffset= numoffset/217 for dietmar compatibility
;   numnoise = numnoise/217
;   numdisc  = numdisc/4
   
   numall   = TOTAL(idhis)-30 ; subtract 30 because header consists of 30 blocks
;; TBC
   numhk    = numall-TOTAL(idhis(160:163))-idhis(143)-idhis(32)-idhis(33)
   numsonst = numall-numoffset-numnoise-numdisc-numhk
   
   
   IF (ind0[0] EQ -1) THEN BEGIN 
       IF (chatty EQ 1) THEN BEGIN 
           print,'% READRAWDATA: Warning no Science-Data in Q0 !!!'
       END 
       q0=-1
   END 
   IF (ind1[0] EQ -1) THEN BEGIN 
       IF (chatty EQ 1) THEN BEGIN 
           print,'% READRAWDATA: Warning no Science-Data in Q1 !!!'
       END 
       q1=-1
   END 
   IF (ind2[0] EQ -1) THEN BEGIN 
       IF (chatty EQ 1) THEN BEGIN 
           print,'% READRAWDATA: Warning no Science-Data in Q2 !!!'
       END 
       q2=-1
   END 
   IF (ind3[0] EQ -1) THEN BEGIN 
       IF (chatty EQ 1) THEN BEGIN 
           print,'% READRAWDATA: Warning no Science-Data in Q3 !!!'
       END 
       q3=-1
   END
   IF (inddiscarded[0] EQ -1) THEN BEGIN 
       IF (chatty EQ 1) THEN BEGIN
           print,'% READRAWDATA: Warning no Discarded Line Map found !!!'
       END
       dslinmap=-1
   END
   IF (indoffset[0] EQ -1) THEN BEGIN
       IF (chatty EQ 1) THEN BEGIN
           print,'% READRAWDATA: Warning no Offset Map found !!!'
       END
       offsetmap=-1
   END
   IF (indnoise[0] EQ -1) THEN BEGIN
       IF (chatty EQ 1) THEN BEGIN
           print,'% READRAWDATA: Warning no Noise Map found !!!'
       END
       noisemap=-1
   END   
   
   IF ( q0 NE -1) THEN BEGIN 
       q0=temporary(rawdata(*,ind0))
       q0=temporary(reform(q0,30*numq0))
       index0=where(q0 NE 0,dzahl0) ; dzahl0 is equal to the number of events in q0,
                                ; events equal to zero are already
                                ; removed from the data
       IF (index0[0] EQ -1) THEN BEGIN
           q0=-1                ; we have only events equal to 0 in q0
       END ELSE BEGIN
           q0=q0(index0)        ; erase events = 0
       END 
   END 

   IF ( q1 NE -1) THEN BEGIN 
       q1=temporary(rawdata(*,ind1))
       q1=temporary(reform(q1,30*numq1))
       index1=where(q1 NE 0,dzahl1) ; dzahl1 is equal to the number of events in q1
       IF (index1[0] EQ -1) THEN BEGIN
           q1=-1                ; we have only events equal to 0 in q1
       END ELSE BEGIN
           q1=q1(index1)        ; erase events = 0
       END 
   END 
   
   IF ( q2 NE -1) THEN BEGIN 
       q2=temporary(rawdata(*,ind2))
       q2=temporary(reform(q2,30*numq2))
       index2=where(q2 NE 0,dzahl2) ; dzahl2 is equal to the number of events in q2
       IF (index2[0] EQ -1) THEN BEGIN
           q2=-1                ; we have only events equal to 0 in q2
       END ELSE BEGIN
           q2=q2(index2)        ; erase events = 0
       END 
   END
   
   IF ( q3 NE -1) THEN BEGIN 
       q3=temporary(rawdata(*,ind3))
       q3=temporary(reform(q3,30*numq3))
       index3=where(q3 NE 0,dzahl3) ; dzahl3 is equal to the number of events in q3
       IF (index3[0] EQ -1) THEN BEGIN
           q3=-1                ; we have only events equal to 0 in q3
       END ELSE BEGIN
           q3=q3(index3)        ; erase events = 0
       END
   END 
   
   IF ( dslinmap NE -1) THEN BEGIN
       dslinmap=temporary(rawdata(*,inddiscarded))
       dslinmap=temporary(reform(dslinmap,30*numdisc))
   END
   
   IF ( offsetmap NE -1) THEN BEGIN
       offsetmap=temporary(rawdata(*,indoffset))
;       offsetmap=temporary(reform(offsetmap,30*numoffset))
   END
   
   IF ( noisemap NE -1) THEN BEGIN
       noisemap=temporary(rawdata(*,indnoise))
;       noisemap=temporary(reform(noisemap,30*numnoise))
   END
   
   dzahl=dzahl0+dzahl1+dzahl2+dzahl3

   IF ((chatty EQ 1) OR (stat EQ 1)) THEN BEGIN

       IF (stat EQ 1) THEN BEGIN
           printf,stream,'/cdrom/hk/'+file ; for dietmar compatibility
           printf,'% READRAWDATA: Number of Frames        : '+STRTRIM(numall,2) ; number of all frames
;       printf,'% READRAWDATA: Es gab SONSTIGE         : '+STRTRIM(numsonst,2)           
           printf,'% READRAWDATA: Number of HK Frames     : '+STRTRIM(numhk,2) ; number of housekeeping frames
           printf,'% READRAWDATA: Number of OFFSET Frames : '+STRTRIM(numoffset,2) ; number of offset frames
           printf,'% READRAWDATA: Number of Noise Frames  : '+STRTRIM(numnoise,2) ; number of noise frames
           printf,'% READRAWDATA: Number of DSLIN Frames  : '+STRTRIM(numdisc,2) ; number of dslin-map frames
           printf,'% READRAWDATA: Number of Frames in  Q0 : '+STRTRIM(numq0,2) ; frames of q0 i.e. events/30
           printf,'% READRAWDATA: Number of Frames in  Q1 : '+STRTRIM(numq1,2) ; frames of q1 (no events=0)
           printf,'% READRAWDATA: Number of Frames in  Q2 : '+STRTRIM(numq2,2) ; frames of q2
           printf,'% READRAWDATA: Number of Frames in  Q3 : '+STRTRIM(numq3,2) ; frames of q3
           printf,'% READRAWDATA: Total Number of  Events : '+STRTRIM(dzahl,2) ; number of events
       END
       print,'% READRAWDATA: Number of Frames        : '+STRTRIM(numall,2) ; number of all frames
;       print,'% READRAWDATA: Es gab SONSTIGE         : '+STRTRIM(numsonst,2)           
       print,'% READRAWDATA: Number of HK Frames     : '+STRTRIM(numhk,2) ; number of housekeeping frames
       print,'% READRAWDATA: Number of OFFSET Frames : '+STRTRIM(numoffset,2) ; number of offset frames
       print,'% READRAWDATA: Number of Noise Frames  : '+STRTRIM(numnoise,2) ; number of noise frames
       print,'% READRAWDATA: Number of DSLIN Frames  : '+STRTRIM(numdisc,2) ; number of dslin-map frames
       print,'% READRAWDATA: Number of Frames in  Q0 : '+STRTRIM(numq0,2) ; frames of q0 i.e. events/30
       print,'% READRAWDATA: Number of Frames in  Q1 : '+STRTRIM(numq1,2) ; frames of q1 (no events=0)
       print,'% READRAWDATA: Number of Frames in  Q2 : '+STRTRIM(numq2,2) ; frames of q2
       print,'% READRAWDATA: Number of Frames in  Q3 : '+STRTRIM(numq3,2) ; frames of q3
       print,'% READRAWDATA: Total Number of  Events : '+STRTRIM(dzahl,2) ; number of events
   END   
END





