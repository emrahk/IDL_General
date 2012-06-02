PRO mkreadoffset,file,offset=offset,$
               chatty=chatty
;+
; NAME:            mkreadoffset
;
;
;
; PURPOSE:
;                  Read offset data from a rawdata stream of one
;                  quadrant from a HK-file
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
   singleccd=intarr(12,200,64)

   readrawdata,file,q0=offset0,q1=offset1,q2=offset2,q3=offset3,/chatty
   offset=[offset0,offset1,offset2,offset3]
   FOR i=0, 11 DO BEGIN
       off=offset
       getoffsethbr,off,i,offset=o
       singleccd(i,*,*)=o
   ENDFOR
   ;; Add 256 to offset because epea software stores offset-256
   offset=singleccd+256
END

