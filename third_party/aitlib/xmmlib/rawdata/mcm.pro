PRO mcm,files,dir=dir,titles=titles,ps=ps,outpath=outpath
;+
; NAME: mcm
;
;
;
; PURPOSE:          
;                   Extract mcm data from calibration
;                   data-files. 
;
;
; CATEGORY: 
;                   Data-Screening
;
;
;
; CALLING SEQUENCE: 
;                   mcm
;
;
; 
; INPUTS:
;                   none
;
;
; OPTIONAL INPUTS:
;                   none
;
;      
; KEYWORD PARAMETERS:
;                   none
;
;
; OUTPUTS:
;                   none
;
;
; OPTIONAL OUTPUTS:
;                   none
;
;
; COMMON BLOCKS:
;                   none
;
;
; SIDE EFFECTS:
;                   none
;
;
; RESTRICTIONS:
;                   none
;
;
; EXAMPLE:
;                   mcm_panter,/ps
; 
;
; MODIFICATION HISTORY:
; V1.0 06.01.99 M. Kuster
; V1.1 01.03.99 M. Kuster changed file handling
; V1.2 21.10.99 M. Kuster added keyword 'outpath'   
;-
   IF (keyword_set(ps)) THEN BEGIN
       ps=1
   END ELSE BEGIN 
       ps=0
   END 
   IF (keyword_set(dir)) THEN BEGIN
       dir=dir
   END ELSE BEGIN
       dir='/cdrom/'
   END 
   IF (keyword_set(titles)) THEN BEGIN
       titles=titles
   END ELSE BEGIN 
       titles=''
   END
   IF (NOT keyword_set(outpath)) THEN outpath='./'
   
   nobs=n_elements(files)
   rates=fltarr(4,nobs)
   mcm_0=0 & mcm_1=0 & mcm_2=0 & mcm_3=0
   mess_0=0 & mess_1=0 & mess_2=0 & mess_3=0
   athr_0=0 & athr_1=0 & athr_2=0 & athr_3=0
   obsend_0=0 & obsend_1=0 & obsend_2=0 & obsend_3=0
   fifr_0=0

   FOR i=0, nobs-1 DO BEGIN
       file=dir+files(i)
       readrawdata,file,$
         q0=rawdata0,q1=rawdata1,q2=rawdata2,q3=rawdata3,/chatty
       
       getcountinfo,rawdata0,messcount=mess0,fifr=fifr0,athr=athr0,mcm=mcm0,/chatty
       athr_0=[athr_0,athr0]
       fifr_0=[fifr_0,fifr0]
       mcm_0=[mcm_0,mcm0]
       mess_0=[mess_0,mess0]
       obsend=n_elements(mcm_0)
       obsend_0=[obsend_0,obsend]
              
       getcountinfo,rawdata1,messcount=mess1,athr=athr1,mcm=mcm1,/chatty
       athr_1=[athr_1,athr1]
       mcm_1=[mcm_1,mcm1]       
       mess_1=[mess_2,mess1]
       obsend=n_elements(mcm_1)
       obsend_1=[obsend_1,obsend]
       
       getcountinfo,rawdata2,messcount=mess2,athr=athr2,mcm=mcm2,/chatty
       athr_2=[athr_2,athr2]
       mcm_2=[mcm_2,mcm2]
       mess_2=[mess_2,mess2]
       obsend=n_elements(mcm_2)
       obsend_2=[obsend_2,obsend]
       
       getcountinfo,rawdata3,messcount=mess3,athr=athr3,mcm=mcm3,/chatty
       athr_3=[athr_3,athr3]
       mcm_3=[mcm_3,mcm3]
       mess_3=[mess_3,mess3]
       obsend=n_elements(mcm_3)
       obsend_3=[obsend_3,obsend]
   ENDFOR

   IF (ps EQ 1) THEN BEGIN
       plotcount,"mcm_smooth",outpath=outpath,athr=athr_0(1:*),mcm=mcm_0(1:*),mess_0(1:*),0,$
         titles=energien,/smooth,obsend=obsend_0,/chatty,/ps
   END ELSE BEGIN 
       window,1 & window,2 & window,3 & window,4
       wset,1
       plotcount,"mcm_smooth",athr=athr_0(1:*),mcm=mcm_0(1:*),mess_0(1:*),0,$
         titles=energie,/smooth,obsend=obsend_0,/chatty       
   END 
   
   IF (ps EQ 1) THEN BEGIN
       plotcount,"mcm_smooth",outpath=outpath,athr=athr_1(1:*),mcm=mcm_1(1:*),mess_1(1:*),1,$
         titles=energien,/smooth,obsend=obsend_1,/chatty,/ps      
   END ELSE BEGIN
       wset,2
       plotcount,"mcm_smooth",athr=athr_1(1:*),mcm=mcm_1(1:*),mess_1(1:*),1,$
         titles=energien,/smooth,obsend=obsend_1,/chatty       
   END 
   
   IF (ps EQ 1) THEN BEGIN   
       plotcount,"mcm_smooth",outpath=outpath,athr=athr_2(1:*),mcm=mcm_2(1:*),mess_2(1:*),2,$
         titles=energien,/smooth,obsend=obsend_2,/chatty,/ps
   END ELSE BEGIN 
       wset,3
       plotcount,"mcm_smooth",athr=athr_2(1:*),mcm=mcm_2(1:*),mess_2(1:*),2,$
         titles=energien,/smooth,obsend=obsend_2,/chatty
   END
       
   IF (ps EQ 1) THEN BEGIN   
       plotcount,"mcm_smooth",outpath=outpath,athr=athr_3(1:*),mcm=mcm_3(1:*),mess_3(1:*),3,$
         titles=energien,/smooth,obsend=obsend_3,/chatty,/ps
   END ELSE BEGIN
       wset,4
       plotcount,"mcm_smooth",athr=athr_3(1:*),mcm=mcm_3(1:*),mess_3(1:*),3,$
         titles=energien,/smooth,obsend=obsend_3,/chatty
   END

   print,'!!!!!!!!!!! FINISHED !!!!!!!!!!!!'
END






