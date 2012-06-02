PRO mkreadnoise,file,noise=noise,$
                chatty=chatty
;+
; NAME:            mkreadnoise
;
;
;
; PURPOSE:
;                  Read noise data from a rawdata stream of one
;                  quadrant from a HK-file
;
;
;
; CATEGORY:
;                  Data-I/O
;
;
; CALLING SEQUENCE:
;                  mkreadnoise,file,noise=ndata,/chatty
; 
; INPUTS:
;                  file    : Name of the data-file to read
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
;                  noisemap : Array containing a nosiemap when found
;                             in data (HBR)
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
   singleccd=dblarr(12,200,64)

   readrawdata,file,q0=noise0,q1=noise1,q2=noise2,q3=noise3,/chatty
   noise=[noise0,noise1,noise2,noise3]
   FOR i=0, 11 DO BEGIN
       noi=noise
       getnoisehbr,noi,i,noise=n
       singleccd(i,*,*)=n
   ENDFOR
   noise=singleccd
END

