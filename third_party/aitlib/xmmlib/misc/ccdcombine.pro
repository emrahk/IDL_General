function ccdcombine,ccds,noise=noise,offset=offset
;+
; NAME: ccdcombine
;
;
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
; 
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;      
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
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
;
;-
   IF (keyword_set(noise)) THEN array=fltarr(389,401) ELSE array=intarr(389,401) ; total ccd array

   array=intarr(389,401)        ; total ccd array
   array(*,*)=0
   
   IF (keyword_set(offset) OR keyword_set(noise)) THEN BEGIN 
       rot0=6
       rot1=4
   ENDIF ELSE BEGIN 
       rot0=6
       rot1=4
   ENDELSE 
   
   ccd0=rotate(reform(ccds(0,*,*)),rot0)
   ccd1=rotate(reform(ccds(1,*,*)),rot0)
   ccd2=rotate(reform(ccds(2,*,*)),rot0)
   ccd3=rotate(reform(ccds(3,*,*)),rot0)
   ccd4=rotate(reform(ccds(4,*,*)),rot0)
   ccd5=rotate(reform(ccds(5,*,*)),rot0)
   ccd6=rotate(reform(ccds(6,*,*)),rot1)
   ccd7=rotate(reform(ccds(7,*,*)),rot1)
   ccd8=rotate(reform(ccds(8,*,*)),rot1)
   ccd9=rotate(reform(ccds(9,*,*)),rot1)
   ccd10=rotate(reform(ccds(10,*,*)),rot1)
   ccd11=rotate(reform(ccds(11,*,*)),rot1)

;; Quadrant 0  
   array(130:193,201:400)=ccd0
   array( 65:128,201:400)=ccd1
   array(  0: 63,201:400)=ccd2
;; Quadrant 1
   array(195:258,201:400)=ccd3
   array(260:323,201:400)=ccd4
   array(325:388,201:400)=ccd5
;; Quadrant 3
   array(195:258,  0:199)=ccd6
   array(260:323,  0:199)=ccd7
   array(325:388,  0:199)=ccd8
;; Quadrant 4
   array(130:193,  0:199)=ccd9
   array( 65:128,  0:199)=ccd10
   array(  0: 63,  0:199)=ccd11  
   return,array
END



