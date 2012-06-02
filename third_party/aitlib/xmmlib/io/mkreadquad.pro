PRO mkreadquad,file,quadrant,data=data,ids=ids,idhis=idhis,$
               chatty=chatty
;+
; NAME:            mkreadquad
;
;
;
; PURPOSE:
;                  Read a rawdata stream of one quadrant from a HK-file
;
;
;
; CATEGORY:
;                  Data-I/O
;
;
; CALLING SEQUENCE:
;                  mkreadquad,file,quadrant,data=data,ids=ids,idhis=idhis,/chatty
; 
; INPUTS:
;                  file    : Name of the data-file to read
;                  quadrant: Number of the quadrant (0-3)                                
;
;
; OPTIONAL INPUTS:
;                  none
;
;      
; KEYWORD PARAMETERS:
;                  /chatty : Give more information on what's going
;                            on
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
;;
; EXAMPLE:
;                  readrawdata,file,q0=rawdata0,q1=rawdata1,$
;                              q2=rawdata2,q3=rawdata3,/chatty
;
;
; MODIFICATION HISTORY:
; V1.0 15.05.99 Markus Kuster
;-
   IF (keyword_set(chatty)) THEN chatty=1 ELSE chatty=0
   
   CASE quadrant OF 
       0: BEGIN
           IF (chatty EQ 1) THEN BEGIN 
               print,'% MKREADQUAD: Reading Data of Q0 ...'
               readrawdata,file,q0=rawdata,ids=ids,idhis=idhis,/chatty
           ENDIF ELSE BEGIN 
               readrawdata,file,q0=rawdata,ids=ids,idhis=idhis
           ENDELSE
       END
       
       1: BEGIN
           IF (chatty EQ 1) THEN BEGIN 
               print,'% MKREADQUAD: Reading Data of Q1 ...'
               readrawdata,file,q1=rawdata,ids=ids,idhis=idhis,/chatty
           ENDIF ELSE BEGIN
               readrawdata,file,q1=rawdata,ids=ids,idhis=idhis
           ENDELSE 
       END
       
       2: BEGIN
           IF (chatty EQ 1) THEN BEGIN 
               print,'% MKREADQUAD: Reading Data of Q2 ...'
               readrawdata,file,q2=rawdata,ids=ids,idhis=idhis,/chatty
           ENDIF ELSE BEGIN 
               readrawdata,file,q2=rawdata,ids=ids,idhis=idhis,/chatty
           ENDELSE 
       END
       
       3: BEGIN
           IF (chatty EQ 1) THEN BEGIN 
               print,'% MKREADQUAD: Reading Data of Q3 ...'           
               readrawdata,file,q3=rawdata,ids=ids,idhis=idhis,/chatty
           ENDIF ELSE BEGIN 
                readrawdata,file,q3=rawdata,ids=ids,idhis=idhis
            ENDELSE 
       END
       ELSE: print,'% MKREADQUAD: ERROR ! No valid Quadrant given !!'
   ENDCASE 
   IF (chatty EQ 1) THEN geteventdata,rawdata,256,1,reddata=data,/chatty ELSE $
     geteventdata,rawdata,256,1,reddata=data
END

